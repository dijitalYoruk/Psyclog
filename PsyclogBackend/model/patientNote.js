const mongoose = require('mongoose')
const Schema = mongoose.Schema
const mongoosePaginate = require('mongoose-paginate-v2');

const PatientNoteSchema = new Schema({ 
   content: {
      type: String, 
      required: [true, 'You should provide a countent.'],
      trim: true
   }, 
   patient: {
      type: mongoose.Schema.ObjectId,
      ref: 'User', 
      required:  [true, 'Note should have a patient.'],
   },
   psychologist: {
      type: mongoose.Schema.ObjectId,
      ref: 'User', 
      required:  [true, 'Note should have a psychologist.'],
   }
}, {timestamps: true, versionKey: false})


PatientNoteSchema.plugin(mongoosePaginate)
const PatientNote = mongoose.model('PatientNote', PatientNoteSchema)
module.exports = PatientNote