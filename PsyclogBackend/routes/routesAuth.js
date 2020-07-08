// =====================
// imports
// =====================
const express = require('express')
const routerAuth = express.Router()
const middlewareAuth = require('../middleware/middlewareAuth')


// =====================
// methods
// =====================
const { signIn,
   signUpPatient,
   resetPassword,
   updateProfile,
   deleteProfile,
   forgotPassword,
   retrieveProfile,
   signUpPsychologist} = require('../controller/ControllerAuth')


// =====================
// routes
// =====================
routerAuth.delete('/profile', middlewareAuth, deleteProfile)
routerAuth.patch('/profile', middlewareAuth, updateProfile)
routerAuth.get('/profile', middlewareAuth, retrieveProfile)
routerAuth.post('/signUp/psychologist', signUpPsychologist)
routerAuth.post('/forgotPassword', forgotPassword)
routerAuth.patch('/reset-password', resetPassword)
routerAuth.post('/signUp/patient', signUpPatient)
routerAuth.post('/signIn', signIn)
module.exports = routerAuth