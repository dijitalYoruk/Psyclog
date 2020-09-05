const mongoose = require('mongoose')
const Constants = require('../utils/constants')
const { getToday } = require('../utils/util')
const ApiError = require('../utils/ApiError')
const Schema = mongoose.Schema

const AppointmentSchema = new Schema({
    intervals: [{
        type: Number,
        required: true
    }],
    appointmentDate: {
        type: Date,
        required: true
    },
    psychologist: {
        type: mongoose.Schema.ObjectId,
        ref: 'User',
        required: [true, 'Chat should have a psychologist.'],
    },
    patient: {
        type: mongoose.Schema.ObjectId,
        ref: 'User',
        required: [true, 'Chat should have a patient.'],
    }
}, {
    timestamps: true,
    versionKey: false
})


AppointmentSchema.statics.areTimesValid = function(appointmentTimes) {
    // no or excess appointments available
    if (appointmentTimes.length == 0 || 
        appointmentTimes.length > 3) return false
    
    // sort and remove duplicates
    appointmentTimes.sort((a, b) => a - b);
    appointmentTimes = [...new Set(appointmentTimes)]

    // check validity of times.
    for (let index = 0; index < appointmentTimes.length - 1; index++) {        
        const appointmentCurrent = appointmentTimes[index]
        const appointmentNext = appointmentTimes[index+1]

        if ((appointmentCurrent < 0 || 12 < appointmentCurrent) || 
            (appointmentNext < 0 || 12 < appointmentNext) || 
            (appointmentNext - appointmentCurrent !== 1)) return false
    }

    return true
}

AppointmentSchema.statics.conflictsWithBlocked = function(intervals, blocked)  {
    return !intervals.every(interval => !blocked.includes(interval))
} 

AppointmentSchema.statics.validateDate = function(appointmentDate, isCreate) {

    // parse dates to miliseconds
    let parsed = getToday(true)
    if (isCreate) parsed += Constants.ONE_DAY
    const appointmentParsed = Date.parse(appointmentDate)
    const appointmentDay = appointmentDate.getDay()

    // appointment date is left or today
    if (parsed > appointmentParsed) {
        return new ApiError('Date error.', 400)
    }
    
    // apointment date is on weekend
    else if (appointmentDay === 0 || appointmentDay === 6) {
        return new ApiError('Appointments are not possible in weekends.', 400)
    }
}


const Appointment = mongoose.model('Appointment', AppointmentSchema)
module.exports = Appointment