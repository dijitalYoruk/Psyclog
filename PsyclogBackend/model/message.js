const mongoosePaginate = require('mongoose-paginate-v2')
const mongoose = require('mongoose')
const Schema = mongoose.Schema

const MessageSchema = new Schema({
   chat: {
      type: mongoose.Schema.ObjectId,
      ref: 'Chat',
      required: true
   },
   message: {
      type: String,
      required: [true, 'You should have a message.'],
      trim: true
   },
   author: {
      type: mongoose.Schema.ObjectId,
      ref: 'User', 
      required:  [true, 'You should have an author.'],
   }
}, {timestamps: true, versionKey: false})


MessageSchema.plugin(mongoosePaginate)
const Message = mongoose.model('Message', MessageSchema)
module.exports = Message