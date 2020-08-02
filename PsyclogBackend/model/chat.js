const mongoosePaginate = require('mongoose-paginate-v2')
const mongoose = require('mongoose')
const Schema = mongoose.Schema

const ChatSchema = new Schema({
    lastMessage: {
        type: mongoose.Schema.ObjectId,
        ref: 'Message'
    },
    isLastMessageSeen: {
        type: Boolean
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


ChatSchema.plugin(mongoosePaginate)
const Chat = mongoose.model('Chat', ChatSchema)
module.exports = Chat