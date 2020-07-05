const express = require('express')
const Constants = require('../constants')
const middlewareAuth = require('../middleware/middlewareAuth')
const middlewareRestrict = require('../middleware/middlewareRestrict')
const { retrieveClientRequests, createClientRequest, acceptClientRequest, 
   denyClientRequest, deleteClientRequest } = require('../controller/ControllerClientRequest')

const routerClientRequests = express.Router({ mergeParams: true })

routerClientRequests.route('/')
   .get(middlewareAuth, middlewareRestrict(Constants.ROLE_PSYCHOLOGIST), retrieveClientRequests)
   .post(middlewareAuth, middlewareRestrict(Constants.ROLE_USER), createClientRequest)
                           

routerClientRequests.post('/accept', middlewareAuth, middlewareRestrict(Constants.ROLE_PSYCHOLOGIST), acceptClientRequest)
routerClientRequests.post('/deny',   middlewareAuth, middlewareRestrict(Constants.ROLE_PSYCHOLOGIST), denyClientRequest)
routerClientRequests.post('/delete', middlewareAuth, middlewareRestrict(Constants.ROLE_USER), deleteClientRequest)
module.exports = routerClientRequests