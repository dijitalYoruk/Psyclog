// =====================
// imports
// =====================
const express = require('express')
const Constants = require('../utils/constants')
const middlewareAuth = require('../middleware/middlewareAuth')
const middlewareRestrict = require('../middleware/middlewareRestrict')
const routerPatientNote = express.Router({ mergeParams: true })


// =====================
// methods
// =====================
const {
    createPatientNote,
    deletePatientNote,
    updatePatientNote,
    retrievePatientNotes } = require('../controller/ControllerNotes')


// =====================
// routes
// =====================

routerPatientNote.use(middlewareAuth)

routerPatientNote.route('/')
    .get(middlewareRestrict(Constants.ROLE_PSYCHOLOGIST), retrievePatientNotes)
    .delete(middlewareRestrict(Constants.ROLE_PSYCHOLOGIST), deletePatientNote)
    .post(middlewareRestrict(Constants.ROLE_PSYCHOLOGIST), createPatientNote)
    .patch(middlewareRestrict(Constants.ROLE_PSYCHOLOGIST), updatePatientNote)

module.exports = routerPatientNote