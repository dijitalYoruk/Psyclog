// =====================
// imports
// =====================
const { isMatching, getToday, 
    constructStartDate, constructEndDate } = require('../utils/util')
const { catchAsync } = require('../utils/ErrorHandling')
const Appointment = require('../model/appointment')
const constants = require('../utils/constants')
const ApiError = require('../utils/ApiError')
const Calendar = require('../model/calendar')
const Wallet = require('../model/wallet')
const User = require('../model/user')
const cron = require('node-cron');


// =====================
// methods
// =====================


const blockIntervals = catchAsync(async (req, res, next) => {
    // retrieve data
    const psychologist = req.currentUser
    let { blockedIntervals, day } = req.body

    // excess slots error
    if (blockedIntervals.length > 13) {
        next(new ApiError('There can not be more than 13 time slots.'))
    }
        
    // update the blocked times.
    const calendar = await Calendar.findById(psychologist.calendar)
    calendar.updateBlockedTimes(day, blockedIntervals)
    await calendar.save()

    res.status(200).json({
        status: 200,
        data: { 
            message: "Intervals are blocked successfully."
        } 
    })
})


const retrieveDateStatus = catchAsync(async (req, res, next) => {
    // get required data.
    const patient = req.currentUser
    const { psychologistId, day, month, year } = req.body
    const psychologist = await User.findById(psychologistId)
                                   .populate('calendar')

    // check whether patient is registered to psychologist.
    if (!patient.registeredPsychologists.includes(psychologistId)) {
        return next(new ApiError(__('error_unauthorized'), 403))
    }

    // get already reserved appointments.
    const appointmentDate = new Date(`${year}-${month}-${day}`)
    const appointments = await Appointment.find({ appointmentDate, psychologist })
                                          .select('intervals')

    // extract reserved intervals.
    const reserved = []
    for (let appointment of appointments) {
        reserved.push(...appointment.intervals)
    }

    // extract blocked intervals.
    const blocked = psychologist.calendar.retrieveBlockedTimes(
        appointmentDate.getDay())

    res.status(200).json({
        status: 200,
        data: { blocked, reserved } 
    })
})

// TODO Payments need to be handled in the future
const createAppointment = catchAsync(async (req, res, next) => {
    // get required data.
    const patient = req.currentUser
    let { day, month, year, intervals, psychologistId } = req.body
    const psychologist = await User.findById(psychologistId)
                                   .populate('calendar')


    // check whether patient is registered to psychologist.
    if (!patient.registeredPsychologists.includes(psychologistId)) {
        return next(new ApiError(__('error_unauthorized'), 403))
    }

    // validate appointment date
    const appointmentDate = new Date(`${year}-${month}-${day}`)
    const dateError = Appointment.validateDate(appointmentDate, true)
    if (dateError) { return next(dateError) }
    
    // check whether the appointment times are sequential.
    if (!Appointment.areTimesValid(intervals)) {
        return next(new ApiError('Invalid times', 400))
    }

    // check whether the appointment times are conflicting with the blocked times.
    const calendar = psychologist.calendar
    const blockedIntervals = calendar.retrieveBlockedTimes(appointmentDate.getDay())
    if (Appointment.conflictsWithBlocked(intervals, blockedIntervals)) {
        return next(new ApiError('Blocked Violation', 400))
    }

    // check whether the appointment times are violating reserved intervals.
    const count = await Appointment.countDocuments({ 
        psychologist, appointmentDate, intervals: { $in: intervals } })
    if (count > 0) { return next(new ApiError(__('reservation_violation'), 400)) }

    // retrieve patient wallet
    const price = intervals.length * psychologist.appointmentPrice
    const patientWallet = await Wallet.findById(patient.wallet)
    if (patientWallet.cash < price) {
        return next(new ApiError('Cash Not Enough', 400))
    }

    // save appointment and wallet.
    let appointment = { psychologist, intervals, appointmentDate, patient, price }
    patientWallet.cash -= price

    appointment = await Appointment.create(appointment) 
    await patientWallet.save()

    // update calendar.
    calendar.appointments.push(appointment)
    await calendar.save()

    res.status(200).json({
        status: 200,
        data: { 
            message: __('success_create', 'Appointment')
        } 
    })
})


const updateAppointmentTime = catchAsync(async (req, res, next) => {
    // get required data.
    const psychologist = req.currentUser
    let { appointmentId, day, month, year, updatedTimes } = req.body

    const appointment = await Appointment.findById(appointmentId)
    if (!isMatching(appointment.psychologist, psychologist._id)) {
        return next(new ApiError(__('error_unauthorized'), 403))
    }

    // validate appointment date
    const appointmentDate = new Date(`${year}-${month}-${day}`)
    const dateError = Appointment.validateDate(appointmentDate, false)
    if (dateError) { return next(dateError) }

    // check whether the appointment times are sequential.
    if (!Appointment.areTimesValid(updatedTimes)) {
        return next(new ApiError('invalid dates', 400))
    }

    // check whether the times are updated 
    // within the same previous date.
    let queryIn = [...updatedTimes]
    const previousDate = appointment.appointmentDate
    if (Date.parse(previousDate) === Date.parse(appointmentDate)) {
        queryIn = queryIn.filter(val => !appointment.intervals.includes(val));
    }

    // check whether the appointment times are violating reserved intervals.
    const count = await Appointment.countDocuments({ 
        psychologist, appointmentDate, intervals: { $in: queryIn } })
    if (count > 0) { return next(new ApiError(__('reservation_violation'), 400)) }

    // save appointment.
    appointment.appointmentDate = appointmentDate
    appointment.intervals = updatedTimes
    await appointment.save()
    
    res.status(200).json({
        status: 200,
        data: { 
            message: __('success_change', 'Appointment')
        } 
    })
})


const cancelAppointment = catchAsync(async (req, res, next) => {
    // retrieve data
    const currentUser = req.currentUser
    const { appointmentId } = req.body
    
    // calculate remaining days
    const todayParsed = getToday(true)
    const appointment = await Appointment.findById(appointmentId)
    const appointmentDateParsed = Date.parse(appointment.appointmentDate)
    const remainingTime = appointmentDateParsed - todayParsed
    const price = appointment.price

    // psychologist removing
    if (currentUser.role === constants.ROLE_PSYCHOLOGIST && 
        isMatching(appointment.psychologist, currentUser._id)) {
        await Wallet.findOneAndUpdate(
            { owner: appointment.patient }, 
            { $inc: { cash: price } })
        await appointment.remove()
    } 

    // patient removing before 3 days
    else if (currentUser.role === constants.ROLE_USER && 
        isMatching(appointment.patient, currentUser._id) && 
        remainingTime > constants.DAYS_3) {
        await Wallet.findOneAndUpdate(
            { owner: appointment.patient }, 
            { $inc: { cash: price } })
        await appointment.remove()
    }

    // patient removing within the last 3 days.
    else if (currentUser.role === constants.ROLE_USER && 
        isMatching(appointment.patient, currentUser._id)) {        
        await Wallet.findOneAndUpdate(
            { owner: appointment.psychologist }, 
            { $inc: { cash: price } })
        await appointment.remove()
    }

    else {
        return next(new ApiError(__('error_unauthorized'), 403))
    }

    res.status(205).json({
       status: 205,
       data: { message: __('success_delete', 'Appointment') } 
    })
})


const terminateAppointment = catchAsync(async (req, res, next) => {
    // retrieve data
    const patient = req.currentUser
    const { appointmentId } = req.body
    const appointment = await Appointment.findById(appointmentId)

    // check whether patient belongs to appointment.
    if (!isMatching(appointment.patient, patient._id)) {
        return next(new ApiError(__('error_unauthorized'), 403))
    }

    // construct the date object for starting time
    const startingTimeSlot = appointment.intervals[0]
    const appointmentDate = appointment.appointmentDate
    const startTime = constructStartDate(appointmentDate, startingTimeSlot)

    // check whether the appointment started.
    if (startTime > Date.now()) {
        return next(new ApiError(__('ternination_not_possible'), 403))
    }

    await Wallet.findOneAndUpdate(
        { owner: appointment.psychologist }, 
        { $inc: { cash: appointment.price } })
    await appointment.remove()
 
    res.status(200).json({
       status: 200,
       data: { message: __('success_terminate') } 
    })
})


const retrievePersonalAppointments = catchAsync(async (req, res, next) => {
    // retrieve data
    const currentUser = req.currentUser
    let appointments = []

    // psychologist gets his own appointments.
    if (currentUser.role === constants.ROLE_PSYCHOLOGIST) {
        appointments = await Appointment.find({ psychologist: currentUser._id })
            .populate({ path: 'patient', select: 'username name surname profileImage email' })
            .lean()
    }
    else { // patient views his own appointments.
        appointments = await Appointment.find({ patient: currentUser._id })
            .populate({ path: 'psychologist', select: 'username name surname profileImage email' })
            .lean()
    }

    // construct start and end times.
    for (const appointment of appointments) {
        // construct the date object for starting time
        const endTimeSlot = appointment.intervals.pop()
        const startingTimeSlot = appointment.intervals[0]
        const appointmentDate = appointment.appointmentDate
        appointment.end = constructEndDate(appointmentDate, endTimeSlot)
        appointment.start = constructStartDate(appointmentDate, startingTimeSlot)
    }

    res.status(200).json({
       status: 200,
       data: { appointments } 
    })
})

cron.schedule('0 0 * * *', async () => {
    const fourDayBefore = Date.now() - 1000 * 60 * 60 * 4
    const appointments = await Appointment.find({ 
        appointmentDate : { $lte: fourDayBefore } })
    const promises = []

    for (const appointment of appointments) {
        const promise1 = Wallet.findOneAndUpdate(
            { owner: appointment.psychologist }, 
            { $inc: { cash: appointment.price } })
        const promise2 = appointment.remove()
        promises.push(promise1)
        promises.push(promise2)
    }

    await Promise.all(promises)
});


module.exports = {
    updateAppointmentTime,
    createAppointment,
    retrieveDateStatus,
    blockIntervals,
    cancelAppointment,
    terminateAppointment,
    retrievePersonalAppointments
}