const mongoose = require('mongoose')
const Schema = mongoose.Schema
const Constants = require('../utils/constants')

const CalendarSchema = new Schema({
   appointments: [{
      type: mongoose.Schema.ObjectId,
      ref: 'Appointment',
   }],
   user: {
      type: mongoose.Schema.ObjectId,
      ref: 'User',
      required: [true, 'Calendar should have a user.'],
   },
   role: {
      type: String,
      required:  [true, 'You should have a role.'],
      default: Constants.ROLE_USER,
      enum: [
         Constants.ROLE_USER, 
         Constants.ROLE_ADMIN,  
         Constants.ROLE_PSYCHOLOGIST
      ]
   },
   blockedIntervalsMonday: [{
      type: Number,
      min: 0, 
      max: 12,
   }],
   blockedIntervalsTuesday: [{
      type: Number,
      min: 0, 
      max: 12,
   }],
   blockedIntervalsWednesday: [{
      type: Number,
      min: 0, 
      max: 12,
   }],
   blockedIntervalsThursday: [{
      type: Number,
      min: 0, 
      max: 12,
   }],
   blockedIntervalsFriday: [{
      type: Number,
      min: 0, 
      max: 12,
   }],
}, {
    timestamps: true,
    versionKey: false
})


// sets the visibility of certain areas for different roles.
CalendarSchema.pre('save', async function(next) {
   // seting irrelevant items for user as undefined.
   if (this.role === Constants.ROLE_USER) {
      this.blockedIntervalsMonday = undefined
      this.blockedIntervalsTuesday = undefined
      this.blockedIntervalsWednesday = undefined
      this.blockedIntervalsThursday = undefined 
      this.blockedIntervalsFriday = undefined
   }
   next()
})

// get blocked intervals
CalendarSchema.methods.retrieveBlockedTimes = function(day) {
    if (day == 1) {
       return this.blockedIntervalsMonday 
    } else if (day == 2) {
       return this.blockedIntervalsTuesday 
    } else if (day == 3) {
       return this.blockedIntervalsWednesday 
    } else if (day == 4) {
       return this.blockedIntervalsThursday 
    } else if (day == 5) {
       return this.blockedIntervalsFriday 
    } 
 }
 
 // get blocked intervals
 CalendarSchema.methods.updateBlockedTimes = function(day, intervals) {
    intervals = [...new Set(intervals)];
 
    if (day == 1) {
       return this.blockedIntervalsMonday = intervals
    } else if (day == 2) {
       return this.blockedIntervalsTuesday = intervals
    } else if (day == 3) {
       return this.blockedIntervalsWednesday = intervals
    } else if (day == 4) {
       return this.blockedIntervalsThursday = intervals
    } else if (day == 5) {
       return this.blockedIntervalsFriday = intervals
    }
 } 


const Calendar = mongoose.model('Calendar', CalendarSchema)
module.exports = Calendar