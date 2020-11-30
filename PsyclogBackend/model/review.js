// =====================
// imports
// =====================
const mongoosePaginate = require('mongoose-paginate-v2')
const { filterObject } = require('../utils/util')
const mongoose = require('mongoose')
const User = require('../model/user')
const Schema = mongoose.Schema

// =====================
// Schema
// =====================
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

// =====================
// methods
// =====================

ReviewSchema.statics.mapData = (review, data) => {
   const items = ['title', 'content', 'rating']
   data = filterObject(data, ...items)  
   Object.keys(data).map(key => {
      review[key] = data[key]
   })
}

//Calculates average ratings
ReviewSchema.statics.calcAverageRatings = async function(psychologist){
   const psychologistId = psychologist._id
   const stats = await this.aggregate([
      {
         $match: {psychologist: psychologistId}
      },
      {
         $group: {
            _id:'$psychologist',
            nRating: { $sum: 1},
            avgRating: {$avg: '$rating'}
         }
      }
   ])

   if(stats.length>0){
      psychologist.ratingsQuantity = stats[0].nRating;
      psychologist.ratingsAverage = stats[0].avgRating;
      await psychologist.save()
   }
   else{
      psychologist.ratingsQuantity = 0;
      psychologist.ratingsAverage = 4.5;
      await psychologist.save()
   }
}

//Calls the calcAverageRatings before saving 
ReviewSchema.post('save',function(){
   //this points to current review
   this.constructor.calcAverageRatings(this.psychologist);
})


ReviewSchema.plugin(mongoosePaginate)
const Review = mongoose.model('Review', ReviewSchema)
module.exports = Review