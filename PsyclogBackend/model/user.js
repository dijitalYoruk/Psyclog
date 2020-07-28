// =====================
// imports
// =====================
const mongoosePaginate = require('mongoose-paginate-v2')
const ClientRequest = require('../model/clientRequest')
const { filterObject } = require('../utils/util')
const Constants = require('../utils/constants')
const Review = require('../model/review')
const { promisify } = require('util')
const mongoose = require('mongoose')
const jwt = require('jsonwebtoken')
const bcrypt = require('bcryptjs')
const crypto = require('crypto')
const s3 = require('../utils/S3')
const Schema = mongoose.Schema


// =====================
// Schema
// =====================
const UserSchema = new Schema({
   username: {
      type: String,
      unique: [true, 'Username needs to be unique'],
      required: [true, 'You should have a username.'],
      trim: true
   },  
   name: {
      type: String, 
      required: [true, 'You should have a name.'],
      trim: true,
      minlength:2
   }, 
   surname: {
      type: String, 
      required:  [true, 'You should have a surname.'],
      trim: true
   }, 
   profileImage: {
      type: String
   },
   email: {
      type: String,
      unique: [true, 'Email needs to be unique'], 
      required:  [true, 'You should have an email.'],
   },
   // Currently, User specific
   cash: {
      type: Number,
      required: [
         function() { return (this.role === Constants.ROLE_USER) },
         'Cash is required.'
      ]
   },
   role: {
      type: String,
      required:  [true, 'You should have a role.'],
      default: Constants.ROLE_USER,
      enum: [Constants.ROLE_USER, Constants.ROLE_ADMIN,  Constants.ROLE_PSYCHOLOGIST]
   },
   // Psychologist specific
   appointmentPrice: {
      type: Number,
      required: [
         function() { return (this.role === Constants.ROLE_PSYCHOLOGIST) },
         'Appointment Price is required.'
      ]
   },
   // Psychologist specific
   patients: [{
      type: mongoose.Schema.ObjectId,
      ref: 'User'
   }],
   registeredPsychologists: [{
      type: mongoose.Schema.ObjectId,
      ref: 'User'
   }],
   // Psychologist specific
   isPsychologistVerified: {
      type: Boolean,
      default: false,
      required: [
         function() { return (this.role === Constants.ROLE_PSYCHOLOGIST) },
         'isPsychologistVerified is required.'
      ],
   },
   // Psychologist specific
   isActiveForClientRequest: {
      type: Boolean,
      default: true,
      required: [
         function() { return this.role === Constants.ROLE_PSYCHOLOGIST },
         'isActiveForClientRequest is required'
      ]
   },
   password: {
      required:  [true, 'You should provide a password.'],
      type: String,
      trim: true,
      minlength: 10,
      select: false
   },
   // Psychologist specific
   biography: {
      type:String,
      trim: true,
      required: [
         function() { return (this.role === Constants.ROLE_PSYCHOLOGIST) }, 
         'Biography is required'
      ]
   },
   // Psychologist specific
   transcript: {
      type:String,
      trim: true,
      required: [
         function() { return this.role == Constants.ROLE_PSYCHOLOGIST },
         'Transcript is required.'
      ]
   },
   // Psychologist specific
   cv: {
      type:String,
      trim: true,
      required: [
         function() { return this.role == Constants.ROLE_PSYCHOLOGIST },
         'CV is required.'
      ]
   },
   passwordConfirm: {
      type: String,
      trim: true,
      required: [true, 'You should type password twice.'],
      select: false,
      validate: {
         validator(value) { return value === this.password },
         message: 'Passwords do not match.'
      }
   },
   passwordResetToken: String,
   passwordResetExpires: Date,

}, {timestamps: true, versionKey: false})


// =====================
// methods
// =====================

// Not reflecting password in result object.
UserSchema.methods.toJSON = function () {
   const userObject = this.toObject()
   delete userObject.password
   return userObject
}

// checking whether the hashed password matches 
UserSchema.statics.correctPassword = async (candidate, encrypted) => {
   return await bcrypt.compare(candidate, encrypted)
}

// generates JWT
UserSchema.statics.generateJWT = id => {
   return jwt.sign({ id }, process.env.JWT_SECRET, { expiresIn: process.env.JWT_EXPIRES_IN })
}

// decodes JWT
UserSchema.statics.decodeJWT = async token => {
   return await promisify(jwt.verify)(token, process.env.JWT_SECRET)
}


UserSchema.statics.filterBody = body => {

   const itemsUser = [
      'passwordConfirm', 
      'username', 
      'password', 
      'surname', 
      'email',      
      'role',
      'cash',
      'name']

   const itemsPsychologist = [
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
      'cv'
   ]

   let data = {}
   const role = body.role

   // filtering user items
   if (role === Constants.ROLE_USER) {
      data = filterObject(body, ...itemsUser)  
   }
   // filtering psychologist items
   else if (role === Constants.ROLE_PSYCHOLOGIST) {
      data = filterObject(body, ...itemsPsychologist)
   }
   // filtering admin items
   else if (role === Constants.ROLE_ADMIN) {
      data = filterObject(body, ...itemsUser)  
   }

   return data
}


UserSchema.statics.mapData = (user, data, psychologistVerificationEnabled) => {
   const items = [
      'name',
      'email',
      'username', 
      'surname',  
      'profileImage']
   
   const itemsPsychologist = [
      'cv',
      'biography',
      'transcript', 
      'appointmentPrice',  
      'isActiveForClientRequest']

   // enabling verification
   if (psychologistVerificationEnabled) {
      itemsPsychologist.push('isPsychologistVerified')
   }

   // filtering user items
   if (user.role === Constants.ROLE_USER) {
      data = filterObject(data, ...items)  
   }
   // filtering psycvhologist items
   else if (user.role === Constants.ROLE_PSYCHOLOGIST) {
      data = filterObject(data, ...items, ...itemsPsychologist)
   }
   // filtering admin items
   else if (user.role === Constants.ROLE_ADMIN) {
      data = filterObject(data, ...items)  
   }

   Object.keys(data).map(key => {
      user[key] = data[key]
   })
}


// sets the visibility of certain areas for different roles.
UserSchema.pre('save', async function(next) {
   
   // changing password
   if (!this.isModified('password')) return next()
   this.password = await bcrypt.hash(this.password, 10)
   this.passwordConfirm = undefined

   // seting irrelevant items for admin as undefined.
   if (this.role === Constants.ROLE_ADMIN) {
      this.isActiveForClientRequest = undefined
      this.registeredPsychologists = undefined
      this.isPsychologistVerified = undefined
      this.appointmentPrice = undefined
      this.transcript = undefined
      this.biography = undefined
      this.patients = undefined
      this.cash = undefined
      this.cv = undefined
   }

   // seting irrelevant items for user as undefined.
   else if (this.role === Constants.ROLE_USER) {
      this.isActiveForClientRequest = undefined
      this.isPsychologistVerified = undefined
      this.appointmentPrice = undefined
      this.transcript = undefined
      this.biography = undefined
      this.patients = undefined
      this.cv = undefined
   }

   // seting irrelevant items for psychologist as undefined.
   else if (this.role === Constants.ROLE_PSYCHOLOGIST) {
      this.registeredPsychologists = undefined
      this.cash = undefined
   }

   next()
})

// sets the visibility of certain areas for different roles.
UserSchema.pre('remove', async function(next) {
   const promiseReview = Review.deleteMany({ 
      $or: [{ author: this.id }, { psychologist: this.id }]
   })
   
   const promiseRequests = ClientRequest.deleteMany({ 
      $or: [{ patient: this.id }, { psychologist: this.id }]
   })
   
   await Promise.all([promiseReview, promiseRequests])
   next()
})


// generates hashed password  reset token.
UserSchema.methods.createPasswordResetToken = function() {
   // generate reset token 
   const resetToken = crypto.randomBytes(32).toString('hex')
 
   // hash the token
   this.passwordResetToken = crypto
     .createHash('sha256')
     .update(resetToken)
     .digest('hex')
 
   // setup expiration date of reset token.
   this.passwordResetExpires = Date.now() + 10 * 60 * 1000
   return resetToken
}

// update profile photo
UserSchema.methods.updateProfileImage = async function(data) {
   const { file, filename } = data
   await s3.deleteFile(this.profileImage)
   const url = await s3.uploadFile('profileImages', file, filename)
   this.profileImage = url
}
 
// Pagination and export.
UserSchema.plugin(mongoosePaginate)
const User = mongoose.model('User', UserSchema)
module.exports = User