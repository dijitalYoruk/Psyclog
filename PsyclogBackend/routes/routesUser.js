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
const {retrieveUsers,
   retrieveUser,
   deleteUser,
   updateUser, 
   finishPatient} = require('../controller/ControllerUser')


// =====================
// routes
// =====================
routerUser.route('/')
   .get(middlewareAuth, middlewareRestrict(Constants.ROLE_ADMIN), retrieveUsers)

routerUser.route('/finish')
   .post(middlewareAuth, middlewareRestrict(Constants.ROLE_ADMIN), finishPatient)

routerUser.route('/:userId')
   .get(middlewareAuth, middlewareRestrict(Constants.ROLE_ADMIN), retrieveUser)
   .delete(middlewareAuth, middlewareRestrict(Constants.ROLE_ADMIN), deleteUser)
   .patch(middlewareAuth, middlewareRestrict(Constants.ROLE_ADMIN), updateUser)

module.exports = routerUser