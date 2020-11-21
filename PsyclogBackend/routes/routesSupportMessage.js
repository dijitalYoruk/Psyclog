// =====================
// imports
// =====================
const express = require('express')
const Constants = require('../utils/constants')
const middlewareAuth = require('../middleware/middlewareAuth')
const middlewareRestrict = require('../middleware/middlewareRestrict')
const routerSupportMessage = express.Router({ mergeParams: true })


// =====================
// methods
// =====================
const {
    handleSupportMessage,
    removeSupportMessage,
    createSupportMessage,
    retrieveSupportMessage,
    retrieveSupportMessages } = require('../controller/ControllerSupport')


// =====================
// routes
// =====================

routerSupportMessage.use(middlewareAuth)

routerSupportMessage.route('/')
    .get(middlewareRestrict(Constants.ROLE_ADMIN), retrieveSupportMessages)
    .delete(middlewareRestrict(Constants.ROLE_ADMIN), removeSupportMessage)
    .post(middlewareRestrict(Constants.ROLE_PSYCHOLOGIST, Constants.ROLE_USER), createSupportMessage)

routerSupportMessage.get('/:supportMessage', middlewareRestrict(Constants.ROLE_USER), retrieveSupportMessage)
routerSupportMessage.post('/handle', middlewareRestrict(Constants.ROLE_ADMIN), handleSupportMessage)
module.exports = routerSupportMessage