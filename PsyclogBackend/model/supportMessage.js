const mongoosePaginate = require('mongoose-paginate-v2')
const Constants = require('../utils/constants')
const mongoose = require('mongoose')
const Schema = mongoose.Schema

const SupportMessageSchema = new Schema({
    message: {
        type: String,
        required: [true, 'You should have a message.'],
        trim: true
    },
    complaint: {
        type: mongoose.Schema.ObjectId,
        ref: 'User',
        required: [
            function() { return this.status === Constants.SUPPORT_COMPLAINT },
            'Complaint is required.'
         ]
    },
    isHandled: {
        type: Boolean,
        default: false,
        required: true
    },
    author: {
        type: mongoose.Schema.ObjectId,
        ref: 'User',
        required: true
    },
    status: {
        type: String,
        required:  [true, 'Support Message should have a status.'],
        default: Constants.SUPPORT_INFO,
        enum: [
           Constants.SUPPORT_INFO, 
           Constants.SUPPORT_PROBLEM,
           Constants.SUPPORT_COMPLAINT,  
        ]
     },
}, {timestamps: true, versionKey: false})


SupportMessageSchema.pre('save', async function(next) {
    if (this.status !== Constants.SUPPORT_COMPLAINT) {
       this.complaint = undefined 
    }
    next()
})
 

SupportMessageSchema.plugin(mongoosePaginate)
const SupportMessage = mongoose.model('SupportMessage', SupportMessageSchema)
module.exports = SupportMessage