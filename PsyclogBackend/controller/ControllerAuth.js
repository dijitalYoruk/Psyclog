// =====================
// imports
// =====================
const { catchAsync } = require('../utils/ErrorHandling')
const { filterObject } = require('../utils/util')
const constants = require('../utils/constants')
const ApiError = require('../utils/ApiError')
const Mailer = require('../utils/mailer')
const User = require('../model/user')
const crypto = require('crypto')
const { __ } = require('i18n')


// =====================
// methods
// =====================

/**
 * sign up the the patient.
 */
const signUpPatient = catchAsync(async (req, res, next) => { 
   // parsing the body 
   req.body.cash = 0
   req.body.role = constants.ROLE_USER
   const data = filterObject(req.body, 
      'passwordConfirm', 
      'username', 
      'password', 
      'surname', 
      'email',      
      'role',
      'cash',
      'name')

   // creating the user.
   const user = await User.create(data)

   res.status(200).json({
      status: 200,
      data: { user } 
   })
})


/**
 * sign up the the psychologist.
 */
const signUpPsychologist = catchAsync(async (req, res, next) => { 
   // TODO In this place, the cv and transcript 
   // will be obtained as files in pdf format. 
   // These will be stored in an S3 bucket in future.

   // parsing the body 
   req.body.role = constants.ROLE_PSYCHOLOGIST
   const data = filterObject(req.body, 
      'appointmentPrice', 
      'passwordConfirm', 
      'transcript', 
      'biography',
      'username', 
      'password', 
      'surname', 
      'email',      
      'role',
      'name', 
      'cv')

   // creating the user.
   const user = await User.create(data)

   // sending response
   res.status(200).json({
      status: 200,
      data: { user } 
   })
})


/**
 * sign in the users.
 */
const signIn = catchAsync(async(req, res, next) => {
   // parsing body
   const { emailOrUsername, password } = req.body

   // checking whether email and password exists.
   if (!emailOrUsername || !password) { 
      return next(new ApiError(__('validation_password_username'), 400)) 
   }

   // checking whether user exists in db.
   const user = await User.findOne({ 
      $or: [{email: emailOrUsername}, 
            {username: emailOrUsername}] 
   }).select('+password')
   

   if (!user) {
      return next(new ApiError(__('error_not_found', 'User'), 404)) 
   }

   // checking whether the passwords match with each other. 
   const isPasswordCorrect = await User.correctPassword(password, user.password)
   if (!isPasswordCorrect) { 
      return next(new ApiError(__('error_wrong_password'), 404)) 
   }
   
   // if psychologist, checking whether account has been verified by admin.
   if (user.role === constants.ROLE_PSYCHOLOGIST && user.isPsychologistVerified) {
      return next(new ApiError(__('error_not_verified'), 403)) 
   } 

   // generating corrsponding JWT token
   const token = User.generateJWT(user._id)

   res.status(200).json({
      status: 200,
      data: { token, user } 
   })
})


/**
 * generates password reset token and saves the user.
 */ 
const forgotPassword = catchAsync(async (req, res, next) => {   
   // parsing the body.
   const email = req.body.email
   const user = await User.findOne({ email })
   
   if (!user) { 
      return next(__('error_not_found', 'User'), 404)
   }

   // generating token
   const resetToken = user.createPasswordResetToken()
   await user.save()

   try {

      // TODO reset url will be settled and email template will be used.
      // constructing email.
      const resetURL = `({{ RESET URL WILL BE SETTED }})/${resetToken}`
      const message = `${resetURL}.\n\n If you didn't forget your password, please ignore this email!`
      const subject = 'Your password reset token (valid for 10 min)'

      // sending email.
      await Mailer.sendEmail({ email, subject, message })

      res.status(200).json({
         'status': '200',
         'data': {
            resetToken 
         }
      })

   } catch(error) {
      // in case of error, removing token.
      user.passwordResetToken = undefined
      user.passwordResetExpires = undefined
      await user.save()
      next(new ApiError(error, 400))
   }
})


/**
 *  Resets the password and removes the reset tokens.
 */
const resetPassword = catchAsync(async (req, res, next) => {
   const hashedToken = crypto
      .createHash('sha256')
      .update(req.body.token)
      .digest('hex')
 
   const user = await User.findOne({
      passwordResetToken: hashedToken,
      passwordResetExpires: { $gt: Date.now() }
   })
 
   if (!user) {
      return new ApiError(__('error_jwt_invalid'), 400)
   }

   user.passwordConfirm = req.body.passwordConfirm
   user.password = req.body.password
   user.passwordResetExpires = undefined
   user.passwordResetToken = undefined
   await user.save()
 
   res.status(200).json({
      status: 200,
      data: {
         message: __('success_change', 'Password') 
      }
   })
})


/**
 * retrieves the profile of the current user.
 */ 
const retrieveProfile = catchAsync(async (req, res, next) => {
   const profile = req.currentUser

   res.status(200).json({
      status: 200,
      data: { profile }
   })
})


/**
 * Deletes the current profile of the user. 
 */ 
const deleteProfile = catchAsync(async (req, res) => {   
   await req.currentUser.delete()

   res.status(204).json({
      status: '204',
      data: {
         message: __('success_delete', 'User')
      }
   })
})


// TODO email update will be done by a seperate 
// route after account verification with email.
// updates the profile of the current user
const updateProfile = catchAsync(async (req, res, next) => {
   // parsing body
   const profile = req.currentUser
   await User.mapData(profile, req.body)
   await profile.save()

   res.status(200).json({
      status: 200,
      data: { profile }
   })
})


module.exports = {
   signIn,
   signUpPatient,
   resetPassword,
   updateProfile,
   deleteProfile,
   forgotPassword,
   retrieveProfile,
   signUpPsychologist
}