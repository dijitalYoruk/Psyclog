const mongoosePaginate = require('mongoose-paginate-v2');
const mongoose = require('mongoose')
const Schema = mongoose.Schema

const ReviewSchema = new Schema({
   title: {
      type: String,
      required: [true, 'You should have a title.'],
      trim: true
   },  
   content: {
      type: String, 
      required: [true, 'You should provide a countent.'],
      trim: true
   }, 
   rating: {
      type: Number,
      min: 1,
      max: 5,
      required: true
   },
   author: {
      type: mongoose.Schema.ObjectId,
      ref: 'User', 
      required:  [true, 'You should have an author.'],
   },
   psychologist: {
      type: mongoose.Schema.ObjectId,
      ref: 'User', 
      required:  [true, 'You should have a psychologist.'],
   }
}, {timestamps: true, versionKey: false})


ReviewSchema.plugin(mongoosePaginate)
const Review = mongoose.model('Review', ReviewSchema)
module.exports = Review