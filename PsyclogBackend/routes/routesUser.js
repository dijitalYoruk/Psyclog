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
   finishPatient,
   retrievePsychologists,
   retrieveRegisteredPsychologists} = require('../controller/ControllerUser')


// =====================
// routes
// =====================
routerUser.use(middlewareAuth)
routerUser.get('/registered-psychologists', middlewareRestrict(Constants.ROLE_USER), retrieveRegisteredPsychologists)
routerUser.post('/finish', middlewareRestrict(Constants.ROLE_PSYCHOLOGIST, Constants.ROLE_ADMIN), finishPatient)
routerUser.get('/psychologists', middlewareRestrict(Constants.ROLE_ADMIN, Constants.ROLE_USER), retrievePsychologists)
routerUser.get('/', middlewareRestrict(Constants.ROLE_ADMIN), retrieveUsers)

routerUser.route('/:userId')
          .get(middlewareRestrict(Constants.ROLE_ADMIN), retrieveUser)
          .patch(middlewareRestrict(Constants.ROLE_ADMIN), updateUser)
          .delete(middlewareRestrict(Constants.ROLE_ADMIN), deleteUser)
module.exports = routerUser