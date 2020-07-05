// =====================
// imports
// =====================
const mongoosePaginate = require('mongoose-paginate-v2');
const ClientRequest = require('../model/clientRequest')
const { filterObject } = require('../util')
const Review = require('../model/review')
const Constants = require('../constants')
const { promisify } = require('util')
const mongoose = require('mongoose')
const jwt = require('jsonwebtoken')
const bcrypt = require('bcryptjs')
const crypto = require('crypto')
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
      trim: true
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
      validate: {
         validator(value) {
            return (this.role === Constants.ROLE_USER) ? value : true
         },
         message: 'Appointment Price is required.'
      }
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
      validate: {
         validator(value) {
            return (this.role === Constants.ROLE_PSYCHOLOGIST) ? value : true
         },
         message: 'Appointment Price is required.'
      }
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
      validate: {
         validator(value) {
            return (this.role === Constants.ROLE_PSYCHOLOGIST) ? value : true
         },
         message: 'isPsychologistVerified is required.'
      },
      default: false
   },
   // Psychologist specific
   isActiveForClientRequest: {
      type: Boolean,
      validate: {
         validator(value) {
            return (this.role === Constants.ROLE_PSYCHOLOGIST) ? value : true
         },
         message: 'isActiveForClientRequest is required.'
      },
      default: true
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
      validate: {
         validator(value) {
            return (this.role === Constants.ROLE_PSYCHOLOGIST) ? value : true
         },
         message: 'Biography is required.'
      }
   },
   // Psychologist specific
   transcript: {
      type:String,
      trim: true,
      validate: {
         validator(value) {
            return (this.role === Constants.ROLE_PSYCHOLOGIST) ? value : true
         },
         message: 'Transcript is required.'
      }
   },
   // Psychologist specific
   cv: {
      type:String,
      trim: true,
      validate: {
         validator(value) {
            return (this.role === Constants.ROLE_PSYCHOLOGIST) ? value : true
         },
         message: 'CV is required.'
      }
   },
   // Psychologist and User specific
   clientRequests: [{
      type: mongoose.Schema.ObjectId,
      ref: 'ClientRequest'
   }],
   passwordConfirm: {
      type: String,
      trim: true,
      required: [true, 'You should type password twice.'],
      select: false,
      validate: {
         validator(value) {
            return value === this.password
         },
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

// filters update data based on roles
UserSchema.statics.filterBody = async (role, bodyData) => {
   // filtering user items
   if (role === constants.ROLE_USER) {
      data = filterObject(bodyData, 'username', 'name', 'surname', 'email', 'profileImage')  
   }
   // filtering psyvhologist items
   else if (role === constants.ROLE_PSYCHOLOGIST) {
      data = filterObject(bodyData, 'username', 'name', 'surname', 'email', 'profileImage', 
               'appointmentPrice', 'biography', 'isActiveForClientRequest')
   }
   // filtering admin items
   else if (role === constants.ROLE_ADMIN) {
      data = filterObject(bodyData, 'username', 'name', 'surname', 'email', 'profileImage')  
   }

   return data
}


// sets the visibility of certain areas for different roles.
UserSchema.pre('save', async function(next) {
   
   // changing password
   if (!this.isModified('password')) return next()
   this.password = await bcrypt.hash(this.password, 10)
   this.passwordConfirm = undefined

   // seting irrelevant items for admin as undefined.
   if (Constants.ROLE_ADMIN) {
      this.isActiveForClientRequest = undefined
      this.registeredPsychologists = undefined
      this.isPsychologistVerified = undefined
      this.appointmentPrice = undefined
      this.clientRequests = undefined
      this.transcript = undefined
      this.biography = undefined
      this.patients = undefined
      this.cash = undefined
      this.cv = undefined
   }

   // seting irrelevant items for user as undefined.
   else if (Constants.ROLE_USER) {
      this.isActiveForClientRequest = undefined
      this.isPsychologistVerified = undefined
      this.appointmentPrice = undefined
      this.transcript = undefined
      this.biography = undefined
      this.patients = undefined
      this.cv = undefined
   }

   // seting irrelevant items for psychologist as undefined.
   else if (Constants.ROLE_PSYCHOLOGIST) {
      this.registeredPsychologists = undefined
      this.cash = undefined
   }

   next()
})


// sets the visibility of certain areas for different roles.
UserSchema.pre('remove', async function(next) {
   const userId = this._id
   const promiseReview = Review.deleteMany({ author: userId })
   const promiseRequests = ClientRequest.deleteMany({ patient: userId })
   const result = await Promise.all([promiseReview, promiseRequests])
   console.log(result)
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
 
// Pagination and export.
UserSchema.plugin(mongoosePaginate)
const User = mongoose.model('User', UserSchema)
module.exports = User