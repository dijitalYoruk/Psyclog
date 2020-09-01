const mongoose = require('mongoose')
const Schema = mongoose.Schema

const AppointmentSchema = new Schema({
    startDate: {
        type: Date,
        required: true
    },
    endDate: {
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


// generates hashed password  reset token.
UserSchema.methods.areAppointmentsValid = function() {
    
    const validTimeIntervals = [
        { startTime: '10:00', endTime: '10:45' },  
        { startTime: '11:00', endTime: '10:45' },  
        { startTime: '10:00', endTime: '10:45' },  
        { startTime: '10:00', endTime: '10:45' },  
        { startTime: '10:00', endTime: '10:45' },  
        { startTime: '10:00', endTime: '10:45' },  
        { startTime: '10:00', endTime: '10:45' },  
        { startTime: '10:00', endTime: '10:45' },  
        { startTime: '10:00', endTime: '10:45' },  
        { startTime: '10:00', endTime: '10:45' },  
        { startTime: '10:00', endTime: '10:45' },  
    ]

}

const Chat = mongoose.model('Chat', ChatSchema)
module.exports = Chat