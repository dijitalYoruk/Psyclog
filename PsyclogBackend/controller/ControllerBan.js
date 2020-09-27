const { catchAsync } = require('../utils/ErrorHandling')
const { constructStartDate } = require('../utils/util')
const Appointment = require('../model/appointment')
const Constants = require('../utils/constants')
const ApiError = require('../utils/ApiError')
const User = require('../model/user')

/**
 * Admin can ban a patient for any number of
 * days if the patient has been complaint.
 */
const banPatientAsAdmin = catchAsync(async (req, res, next) => {
    // get required data.
    let { duration, patientId } = req.body
    
    // check whether patient exists
    const exists = await User.exists({ _id: patientId, role: Constants.ROLE_USER })
    if (!exists) return next(new ApiError(__('error_not_found', 'Patient'), 404))
    
    // ban patient
    const banTerminationDate = Date.now() + duration * Constants.ONE_DAY
    await User.findByIdAndUpdate(patientId, { banTerminationDate })
    
    res.status(200).json({
        status: 200,
        data: { 
            message: 'Patient succeesfully Banned'
        } 
    })
})

/**
 * Psychologist can ban a patient for two days if 
 * the patient has not attended an appointment.
 */
const banPatientAsPsychologist = catchAsync(async (req, res, next) => {
    // get required data.
    let { patient } = req.body
    const psychologist = req.currentUser

    // check whether patient exists
    const exists = await User.exists({ _id: patient, role: Constants.ROLE_USER })
    if (!exists) return next(new ApiError(__('error_not_found', 'Patient'), 404))

    let appointments = await Appointment.find({ patient, psychologist })
    let hasAnyAppointmentPassed = false

    for (const appointment of appointments) {
        // construct the date object for ending time
        const endTimeSlot = appointment.intervals.slice(-1).pop()
        const appointmentDate = appointment.appointmentDate
        const endTime = constructStartDate(appointmentDate, endTimeSlot)
        if (endTime < Date.now()) hasAnyAppointmentPassed = true
    }

    if (!hasAnyAppointmentPassed) {
        return next(new ApiError('No appointment has been left', 400))
    }

    // ban patient
    const banTerminationDate = Date.now() + 2 * Constants.ONE_DAY
    await User.findByIdAndUpdate(patient, { banTerminationDate })
    
    res.status(200).json({
        status: 200,
        data: { message: 'Patient succeesfully Banned' } 
    })
})


/**
 * Admin can remove a ban from a patient. 
 */
const removeBanFromPatient = catchAsync(async (req, res, next) => {
    // get required data.
    let { patientId } = req.body
    
    // check whether patient exists
    const exists = await User.exists({ _id: patientId, role: Constants.ROLE_USER })
    if (!exists) return next(new ApiError(__('error_not_found', 'Patient'), 404))
    
    // ban patient
    await User.findByIdAndUpdate(patientId, { banTerminationDate: undefined })
    
    res.status(200).json({
        status: 200,
        data: { 
            message: 'Ban successfully removed.'
        } 
    })
})

module.exports = {
    banPatientAsAdmin,
    banPatientAsPsychologist,
    removeBanFromPatient
}