// =====================
// imports
// =====================
const { catchAsync } = require('../utils/ErrorHandling')
const ApiError = require('../utils/ApiError')
const { filterObject } = require('../util')
const Review = require('../model/review')


// =====================
// methods
// =====================

const createReview = catchAsync(async (req, res, next) => {
   // constructing review data.
   const author = req.currentUser._id
   const psychologist = req.params.userId
   const { title, content, rating } = req.body
   const data = { title, content, rating, author, psychologist}

   // creating the review.
   const review = await Review.create(data)
   if (!review) next(new ApiError('Review could not be created', 400))

   res.status(200).json({
      status: 200,
      data: { review } 
   })
})


const retrievePsychologistReviews = catchAsync(async (req, res, next) => {
   const psychologist = req.params.userId
   const reviews = await Review.paginate({ psychologist }, { page:1, limit:10 })
   if (!reviews) next(new ApiError('Reviews could not be retrieved', 400))

   res.status(200).json({
      status: 200,
      data: { reviews } 
   })
})


const deleteReview = catchAsync(async (req, res, next) => {
   const authorId = req.currentUser._id
   const reviewId = req.params.reviewId

   const review = await Review.findOne({ _id: reviewId })
   if (!review) next(new ApiError('Review could not be retrieved', 400))
   if (!review.author === authorId) { next(new ApiError('Unauthorized', 403)) }
   await Review.remove(review)

   res.status(200).json({
      status: 200,
      data: 'successfull delete' 
   })
})


const updateReview = catchAsync(async (req, res, next) => {
   const authorId = req.currentUser._id
   const reviewId = req.params.reviewId
   
   let review = await Review.findOne({ _id: reviewId })
   if (!review) next(new ApiError('Review could not be retrieved', 400))
   if (!review.author === authorId) { next(new ApiError('Unauthorized', 403)) }
   
   const data = filterObject(req.body, 'title', 'content', 'rating')
   review = await Review.findByIdAndUpdate(reviewId, data, { new: true})

   res.status(200).json({
      status: 200,
      data: review
   })
})

module.exports = {
   createReview,
   deleteReview,
   updateReview,
   retrievePsychologistReviews
}