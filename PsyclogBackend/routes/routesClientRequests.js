// =====================
// imports
// =====================
const express = require('express')
const Constants = require('../utils/constants')
const middlewareAuth = require('../middleware/middlewareAuth')
const middlewareRestrict = require('../middleware/middlewareRestrict')
const routerClientRequests = express.Router({ mergeParams: true })


// =====================
// methods
// =====================
const {
   retrieveClientRequests,
   createClientRequest,
   acceptClientRequest,
   denyClientRequest,
   deleteClientRequest } = require('../controller/ControllerClientRequest')


// =====================
// routes
// =====================
routerClientRequests.route('/')
   .get(middlewareAuth, middlewareRestrict(Constants.ROLE_PSYCHOLOGIST, Constants.ROLE_USER), retrieveClientRequests)
   .post(middlewareAuth, middlewareRestrict(Constants.ROLE_USER), createClientRequest)

routerClientRequests.post('/accept', middlewareAuth, middlewareRestrict(Constants.ROLE_PSYCHOLOGIST), acceptClientRequest)
routerClientRequests.post('/deny',   middlewareAuth, middlewareRestrict(Constants.ROLE_PSYCHOLOGIST), denyClientRequest)
routerClientRequests.delete('/', middlewareAuth, middlewareRestrict(Constants.ROLE_USER), deleteClientRequest)
module.exports = routerClientRequests