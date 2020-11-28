// =====================
// imports
// =====================
const express = require('express')
const Constants = require('../utils/constants')
const middlewareAuth = require('../middleware/middlewareAuth')
const middlewareRestrict = require('../middleware/middlewareRestrict')
const routerAppointment = express.Router({ mergeParams: true })


// =====================
// methods
// =====================
const { 
    blockIntervals,
    createAppointment,
    cancelAppointment,
    retrieveDateStatus,
    terminateAppointment,
    updateAppointmentTime,
    retrievePersonalAppointments } = require('../controller/ControllerAppointment')

// =====================
// routes
// =====================
routerAppointment.use(middlewareAuth)

routerAppointment.post('/', middlewareRestrict(Constants.ROLE_USER), createAppointment)
routerAppointment.put('/', middlewareRestrict(Constants.ROLE_PSYCHOLOGIST), updateAppointmentTime)
routerAppointment.post('/date-status', middlewareRestrict(Constants.ROLE_USER), retrieveDateStatus)
routerAppointment.post('/terminate', middlewareRestrict(Constants.ROLE_USER), terminateAppointment)
routerAppointment.post('/block-intervals', middlewareRestrict(Constants.ROLE_PSYCHOLOGIST), blockIntervals)
routerAppointment.post('/cancel', middlewareRestrict(Constants.ROLE_PSYCHOLOGIST, Constants.ROLE_USER), cancelAppointment)
routerAppointment.get('/personal-appointments', middlewareRestrict(Constants.ROLE_USER, Constants.ROLE_PSYCHOLOGIST), retrievePersonalAppointments)
module.exports = routerAppointment