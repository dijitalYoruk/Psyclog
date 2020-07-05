const mongoose = require('mongoose')
const Schema = mongoose.Schema
const mongoosePaginate = require('mongoose-paginate-v2');

const ClientRequestSchema = new Schema({ 
   content: {
      type: String, 
      required: [true, 'You should provide a countent.'],
      trim: true
   }, 
   patient: {
      type: mongoose.Schema.ObjectId,
      ref: 'User', 
      required:  [true, 'You should register yourself.'],
   },
   psychologist: {
      type: mongoose.Schema.ObjectId,
      ref: 'User', 
      required:  [true, 'You should request a psychologist.'],
   }
}, {timestamps: true, versionKey: false})


ClientRequestSchema.plugin(mongoosePaginate)
const ClientRequest = mongoose.model('ClientRequest', ClientRequestSchema)
module.exports = ClientRequest