// =====================
// imports
// =====================
const { catchAsync } = require('../utils/ErrorHandling')
const constants = require('../utils/constants')
const Calendar = require('../model/calendar')
const ApiError = require('../utils/ApiError')
const Mailer = require('../utils/mailer')
const Wallet = require('../model/wallet')
const User = require('../model/user')
const crypto = require('crypto')


// =====================
// methods
// =====================

/**
 * sign up the the patient.
 */
const signUpPatient = catchAsync(async (req, res, next) => {


   //creating verification token for every user 
   const verifyToken = crypto.randomBytes(32).toString('hex')

   // hash the token
      const verificationToken = crypto
         .createHash('sha256')
         .update(verifyToken)
         .digest('hex')

   // setup expiration date of reset token.
      const verificationExpires = Date.now() + 10 * 60 * 1000

   // parsing the body 
   req.body.cash = 0
   req.body.role = constants.ROLE_USER
   req.body.verificationExpires = verificationExpires;
   req.body.verificationToken = verificationToken;
   const data = User.filterBody(req.body)

   // create calendar for the user
   const calendar = new Calendar({ role: data.role})
   data.calendar = calendar._id
   
   // create wallet for the user
   const wallet = new Wallet({})
   data.wallet = wallet._id

   // creating the user.
   const user = await User.create(data)
   calendar.user = user
   wallet.owner = user
   await calendar.save()
   await wallet.save()

   const verificationURL = `${req.protocol}://${req.get('host')}/api/v1/auth/verification/${verificationToken}`;
   await Mailer.sendAccountVerification(user,verificationURL)


   res.status(200).json({
      status: 200,
      data: { user } 
   })
})


/**
 * sign up the the psychologist.
 */
const signUpPsychologist = catchAsync(async (req, res, next) => { 
   // parsing the body 
   req.body.role = constants.ROLE_PSYCHOLOGIST
   const data = User.filterBody(req.body)
   const user = new User(data)
   await user.uploadCvAndTranscript(req.files, user._id)

   // create calendar for the psychologist
   const calendar = new Calendar({ role: data.role, user: user._id })

   // create wallet for the psychologist
   const wallet = new Wallet({ owner: user._id })

   user.calendar = calendar._id
   user.wallet = wallet._id
 
   // creating the psychologist.
 //  calendar.user = user
//   wallet.owner = user
   await calendar.save()
   await wallet.save()
   await user.save()

   // sending response
   res.status(200).json({
      status: 200,
      data: { user } 
   })
})

/**
 *  verifies the user and removes the verification tokens.
 */
const verifyUser = catchAsync(async (req, res, next) => {

   const user = await User.findOne({
      verificationToken: req.params.token
   })

   if (!user) {
      return new ApiError(__('error_jwt_invalid'), 400)
   }

   if(user.verificationExpires<Date.now()){
      user.verificationExpires = undefined
      user.verificationToken = undefined
      await user.save()

      res.status(200).render('verification_error',{
      });

   }else{
      user.isAccountVerified = true
      user.verificationExpires = undefined
      user.verificationToken = undefined
      await user.save()

      res.status(200).render('verification_okey',{
      });

   }

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

   console.log("->")

   // checking whether user exists in db.
   const user = await User.findOne({ 
      $or: [{email: emailOrUsername}, 
            {username: emailOrUsername}]
   }).populate('wallet').select('+password')
   
   if (!user) {
      return next(new ApiError(__('error_not_found', 'User'), 404)) 
   }

   // checking whether the passwords match with each other. 
   const isPasswordCorrect = await User.correctPassword(password, user.password)
   if (!isPasswordCorrect) { 
      return next(new ApiError(__('error_wrong_password'), 404)) 
   }
   
   // if psychologist, checking whether account has been verified by admin.
   if (user.role === constants.ROLE_PSYCHOLOGIST && !user.isPsychologistVerified) {
      return next(new ApiError(__('error_not_verified'), 403)) 
   } 

   // if user, checking whether account has been verified by e-mail verification.
   if (user.role === constants.ROLE_USER && (!user.isAccountVerified)) {
      return next(new ApiError(__('error_not_verified'), 403)) 
   }

   // generating corrsponding JWT token
   const token = User.generateJWT({ id: user._id, role: user.role})

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
      return next(new ApiError(__('error_not_found', 'User'), 404))
   }

   // generating token
   const resetToken = user.createPasswordResetToken()
   await user.save()

   try {

      const resetURL = `${req.protocol}://${req.get('host')}/api/v1/auth/reset-password/${resetToken}`;

      // sending email.
      await Mailer.sendPasswordReset(user,resetURL)

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
      return next(new ApiError(error, 400))
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
   await req.currentUser.remove()

   res.status(204).json({
      status: 204,
      data: {
         message: __('success_delete', 'Profile')
      }
   })
})


// TODO email update will be done by a seperate 
// route after account verification with email.
// updates the profile of the current user
const updateProfile = catchAsync(async (req, res, next) => {
   // parsing body
   const profile = req.currentUser
   User.mapData(profile, req.body, false)

   // update profile image 
   if (req.file) {      
      await profile.updateProfileImage(req.file)
   }

   await profile.save()

   res.status(200).json({
      status: 200,
      data: { profile }
   })
})

/**
 * retrieves the reset password page for specific user.
 */ 
const getResetPassword = catchAsync(async (req, res, next) => {
   res.status(200).render('resetnew',{
      token: req.params.token
   });
})


module.exports = {
   signIn,
   signUpPatient,
   resetPassword,
   getResetPassword,
   updateProfile,
   deleteProfile,
   forgotPassword,
   retrieveProfile,
   signUpPsychologist,
   verifyUser
}