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
   signUpUser,
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
routerAuth.post('/signUp/user', signUpUser)
routerAuth.post('/signIn', signIn)
module.exports = routerAuth