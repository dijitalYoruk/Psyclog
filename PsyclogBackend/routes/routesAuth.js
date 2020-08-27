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
   getResetPassword,
   updateProfile,
   deleteProfile,
   forgotPassword,
   retrieveProfile,
   signUpPsychologist,
   verifyUser} = require('../controller/ControllerAuth')

const { uploadProfileImage } = require('../utils/FileUpload')

// =====================
// routes
// =====================
routerAuth.post('/signUp/psychologist', signUpPsychologist)
routerAuth.post('/forgotPassword', forgotPassword)
routerAuth.patch('/reset-password', resetPassword)
routerAuth.get('/reset-password/:token', getResetPassword)
routerAuth.post('/signUp/patient', signUpPatient)
routerAuth.post('/signIn', signIn)
routerAuth.get('/verification/:token', verifyUser)

// authentication required
routerAuth.use(middlewareAuth)
routerAuth.delete('/profile', deleteProfile)
routerAuth.patch('/profile', uploadProfileImage, updateProfile)
routerAuth.get('/profile', retrieveProfile)

module.exports = routerAuth