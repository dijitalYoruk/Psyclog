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
   verifyPsychologist,
   retrievePsychologists,
   retrieveRegisteredPsychologists, 
   retrieveUnverifiedPsychologists,
   retrievePatients } = require('../controller/ControllerUser')


// =====================
// routes
// =====================
routerUser.use(middlewareAuth)
routerUser.get('/', middlewareRestrict(Constants.ROLE_ADMIN), retrieveUsers)
routerUser.delete('/', middlewareRestrict(Constants.ROLE_ADMIN), deleteUser)
routerUser.post('/psychologists/verify', middlewareRestrict(Constants.ROLE_ADMIN), verifyPsychologist)
routerUser.patch('/', middlewareRestrict(Constants.ROLE_ADMIN), updateUser)
routerUser.post('/finish', middlewareRestrict(Constants.ROLE_PSYCHOLOGIST, Constants.ROLE_ADMIN), finishPatient)
routerUser.get('/psychologists', middlewareRestrict(Constants.ROLE_ADMIN, Constants.ROLE_USER), retrievePsychologists)
routerUser.get('/registered-psychologists', middlewareRestrict(Constants.ROLE_USER), retrieveRegisteredPsychologists)
routerUser.get('/psychologists/unverified', middlewareRestrict(Constants.ROLE_ADMIN), retrieveUnverifiedPsychologists)

routerUser.get('/registered-patients', middlewareRestrict(Constants.ROLE_PSYCHOLOGIST), retrievePatients)
routerUser.route('/:userId').get(middlewareRestrict(Constants.ROLE_ADMIN), retrieveUser)
          

module.exports = routerUser