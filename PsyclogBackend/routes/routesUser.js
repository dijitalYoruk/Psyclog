// =====================
// imports
// =====================
const express = require('express')
const Constants = require('../utils/constants')
const middlewareAuth = require('../middleware/middlewareAuth')
const middlewareRestrict = require('../middleware/middlewareRestrict')
const routerUser = express.Router({ mergeParams: true })


// =====================
// methods
// =====================
const {
   retrieveUsers,
   retrieveUser,
   deleteUser,
   updateUser, 
   finishPatient} = require('../controller/ControllerUser')


// =====================
// routes
// =====================
routerUser.use(middlewareAuth)

routerUser.use(middlewareRestrict(Constants.ROLE_PSYCHOLOGIST, Constants.ROLE_ADMIN))
routerUser.route('/finish').post(finishPatient)

routerUser.use(middlewareRestrict(Constants.ROLE_ADMIN))
routerUser.route('/').get(retrieveUsers)
routerUser.route('/:userId').get(retrieveUser).delete(deleteUser).patch(updateUser)
module.exports = routerUser