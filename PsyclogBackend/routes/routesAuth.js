// =====================
// imports
// =====================
const express = require('express')
const routerAuth = express.Router()
const middlewareAuth = require('../middleware/middlewareAuth')
const { uploadProfileImage } = require('../utils/FileUpload')


// =====================
// methods
// =====================
const { 
   signIn,
   signUpPatient,
   resetPassword,
   getResetPassword,
   updateProfile,
   deleteProfile,
   forgotPassword,
   retrieveProfile,
   signUpPsychologist } = require('../controller/ControllerAuth')


// =====================
// routes
// =====================
routerAuth.post('/signUp/psychologist', signUpPsychologist)
routerAuth.post('/forgotPassword', forgotPassword)
routerAuth.patch('/reset-password', resetPassword)
routerAuth.get('/reset-password/:token', getResetPassword)
routerAuth.post('/signUp/patient', signUpPatient)
routerAuth.post('/signIn', signIn)

// authentication required
routerAuth.use(middlewareAuth)
routerAuth.delete('/profile', deleteProfile)
routerAuth.patch('/profile', uploadProfileImage, updateProfile)
routerAuth.get('/profile', retrieveProfile)

module.exports = routerAuth