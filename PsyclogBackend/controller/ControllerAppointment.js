// =====================
// imports
// =====================
const { catchAsync } = require('../utils/ErrorHandling')
const ApiError = require('../utils/ApiError')
const Appointment = require('../model/appointment')
const User = require('../model/user')
const { isMatching } = require('../utils/util')
const constants = require('../utils/constants')


// =====================
// methods
// =====================

const createAppointment = catchAsync(async (req, res, next) => {
    // constructing review data.
    const patient = req.currentUser
    const psychologistId = req.body.psychologistId
    if (!patient.registeredPsychologists.includes(psychologistId)) {
        return next(new ApiError(__('error_unauthorized'), 403))
    }

    // TODO Payments need to be handled in the future
    const { date, appointmentTimes } = body

    if (!Appointment.areAppointmentsValid(appointmentTimes)) {
        return next(new ApiError('invalid appointment times are entered.', 400))
    }

    
 
    res.status(200).json({
       status: 200,
       data: { review } 
    })
 })

module.exports = {
   createReview,
   deleteReview,
   updateReview,
   retrievePsychologistReviews
}