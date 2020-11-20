// =====================
// imports
// =====================
const express = require('express')
const Constants = require('../utils/constants')
const middlewareAuth = require('../middleware/middlewareAuth')
const middlewareRestrict = require('../middleware/middlewareRestrict')
const routerBan = express.Router({ mergeParams: true })


// =====================
// methods
// =====================
const {
    banPatientAsAdmin,
    removeBanFromPatient,
    banPatientAsPsychologist,
    updatePenaltyOfPsychologist } = require('../controller/ControllerBan')


// =====================
// routes
// =====================
routerBan.use(middlewareAuth)
routerBan.delete('/', middlewareRestrict(Constants.ROLE_ADMIN), removeBanFromPatient)
routerBan.post('/as-admin', middlewareRestrict(Constants.ROLE_ADMIN), banPatientAsAdmin)
routerBan.post('/penalty', middlewareRestrict(Constants.ROLE_ADMIN), updatePenaltyOfPsychologist)
routerBan.post('/as-psychologist', middlewareRestrict(Constants.ROLE_PSYCHOLOGIST), banPatientAsPsychologist)
module.exports = routerBan