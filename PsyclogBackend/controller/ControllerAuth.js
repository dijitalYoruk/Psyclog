// =====================
// imports
// =====================
const { catchAsync } = require('../utils/ErrorHandling')
const ApiError = require('../utils/ApiError')
const constants = require('../constants')
const Mailer = require('../utils/mailer')
const User = require('../model/user')
const crypto = require('crypto')


// =====================
// methods
// =====================

// sign up the user.
const signUpUser = catchAsync(async (req, res, next) => { 
   // parsing the body 
   const { username, name, surname, email, password, passwordConfirm } = req.body
   const data = { username, name, surname, email, cash: 0, clientRequests: [], 
      role: constants.ROLE_USER, password, passwordConfirm }

   // creating the user.
   const user = await User.create(data)

   res.status(200).json({
      'status': '200',
      'data': { user } 
   })
})


// sign up the psychologist.
const signUpPsychologist = catchAsync(async (req, res, next) => { 
   // TODO In this place, the cv and transcript will be obtained as files in
   // pdf format. These will be stored in an S3 bucket in the future.

   // parsing the body 
   const { username, name, surname, email, password, passwordConfirm, transcript, cv, appointmentPrice, biography } = req.body
   const data = { username, name, surname, email, password, passwordConfirm, transcript, cv, appointmentPrice,
      biography, patiens: [], clientRequests: [], isPsychologistVerified: false, isActiveForClientRequest: true }
   
   // creating the user.
   const user = await User.create(data)

   res.status(200).json({
      'status': '200',
      'data': { user } 
   })
})


// sign in the user.
const signIn = catchAsync(async(req, res, next) => {
   // parsing body
   const { emailOrUsername, password } = req.body

   // checking whether email and password exists.
   if (!emailOrUsername || !password) { 
      return next(new ApiError('Please provide password and username.', 400)) 
   }

   // checking whether user exists in db.
   const user = await User.findOne({ $or: [{email: emailOrUsername}, {username: emailOrUsername}] }).select('+password')
   if (!user) { 
      return next(new ApiError('User could not be found.', 404)) 
   }

   // checking whether the passwords match with each other. 
   const isPasswordCorrect = await User.correctPassword(password, user.password)
   if (!isPasswordCorrect) { 
      return next(new ApiError('Password is wrong.', 404)) 
   }
   
   // if psychologist, checking whether account has been verified by admin.
   if (user.role === constants.ROLE_PSYCHOLOGIST && user.isPsychologistVerified) {
      return next(new ApiError('Unauthorized. Account has not been verified yet.', 403)) 
   } 

   // generating corrsponding JWT token
   const token = User.generateJWT(user._id)

   res.status(200).json({
      'status': '200',
      'data': { token, user } 
   })
})


// generates password reset token and saves the user.
const forgotPassword = catchAsync(async (req, res, next) => {   
   // parsing the body.
   const email = req.body.email
   const user = await User.findOne({ email })
   
   if (!user) { 
      return next('User not found.', 404)
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


// resets the password and removes the reset tokens.
const resetPassword = catchAsync(async (req, res, next) => {
   const hashedToken = crypto
      .createHash('sha256')
      .update(req.body.token)
      .digest('hex')
 
   const user = await User.findOne({
      passwordResetToken: hashedToken,
      passwordResetExpires: { $gt: Date.now() }
   })
 
   if (!user) return new ApiError('Token is invalid or has expired', 400)
   
   user.password = req.body.password
   user.passwordConfirm = req.body.passwordConfirm
   user.passwordResetToken = undefined
   user.passwordResetExpires = undefined
   await user.save()
 
   res.status(200).json({
      status: '200',
      data: {
         message: 'Password has been changed successfully.' 
      }
   })
})


// retrieves the profile of the current user.
const retrieveProfile = catchAsync(async (req, res, next) => {
   const currentUser = req.currentUser

   res.status(200).json({
      status: 200,
      data: { profile: currentUser }
   })
})


// deletes the current profile of the user.
const deleteProfile = catchAsync(async (req, res) => {   
   const id = req.currentUser._id
   await User.findByIdAndDelete(id)

   res.status(204).json({
      status: '204',
      data: {
         'message': `User with id ${id} has been successfully deleted.` 
      }
   })
})


// TODO email update will be done by a seperate 
// route after account verification with email.
// updates the profile of the current user
const updateProfile = catchAsync(async (req, res, next) => {
   // parsing body
   const currentUser = req.currentUser
   const data = User.filterBody(currentUser.role, req.body)
   
   // update the user.
   const user = await User.findByIdAndUpdate(currentUser, data, 
      { runValidators: true, new: true })

   res.status(200).json({
      status: '200',
      data: { user }
   })
})


module.exports = {
   signIn,
   signUpUser,
   resetPassword,
   updateProfile,
   deleteProfile,
   forgotPassword,
   retrieveProfile,
   signUpPsychologist
}