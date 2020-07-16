// =====================
// imports
// =====================
const { catchAsync } = require('../utils/ErrorHandling')
const ApiError = require('../utils/ApiError')
const Review = require('../model/review')
const User = require('../model/user')
const { isMatching } = require('../utils/util')
const constants = require('../utils/constants')


// =====================
// methods
// =====================

const createReview = catchAsync(async (req, res, next) => {
   // constructing review data.
   const author = req.currentUser._id
   const psychologistId = req.body.psychologistId
   const psychologist = await User.findById(psychologistId)

   // check whether psychologist exists.
   if (!psychologist || psychologist.role !== constants.ROLE_PSYCHOLOGIST) {
      return next(new ApiError(__('error_not_found', 'Psychologist'), 404))
   }

   // check whether reviewed
   const exists = await Review.exists({ author, psychologist: psychologistId })
   if (exists) {
      return next(new ApiError(__('error_already_reviewed'), 400))
   }

   // extracting review data
   const { title, content, rating } = req.body
   const data = { title, content, rating, author, psychologist}

   // creating the review.
   const review = await Review.create(data)

   res.status(200).json({
      status: 200,
      data: { review } 
   })
})


const retrievePsychologistReviews = catchAsync(async (req, res, next) => {
   const page = req.query.page
   const psychologist = req.body.psychologistId

   // retrieving reviews
   const reviews = await Review.paginate({ psychologist }, { page, limit:10 })
   if (!reviews) { 
      return next(new ApiError(__('error_not_found', 'Reviews'), 404))
   }

   res.status(200).json({
      status: 200,
      data: { reviews } 
   })
})


const deleteReview = catchAsync(async (req, res, next) => {
   const currentUser = req.currentUser
   const reviewId = req.params.reviewId

   const review = await Review.findOne({ _id: reviewId })
   if (!review) {
      return next(new ApiError(__('error_not_found', 'Review'), 404))
   }
   
   if (currentUser.role !== constants.ROLE_ADMIN && !isMatching(review.author, currentUser._id)) {
      return next(new ApiError(__('error_unauthorized'), 403)) 
   }
   
   await review.remove()

   res.status(200).json({
      status: 200,
      data: __('success_delete', 'Review')
   })
})


const updateReview = catchAsync(async (req, res, next) => {
   const currentUser = req.currentUser
   const reviewId = req.params.reviewId
   
   // retrieving reviews.
   let review = await Review.findOne({ _id: reviewId })
   if (!review) {
      return next(new ApiError(__('error_not_found', 'Review'), 404))
   }

   // check whether review belongs to user 
   if (currentUser.role !== constants.ROLE_ADMIN && !isMatching(review.author, currentUser._id)) {
      return next(new ApiError(__('error_unauthorized'), 403))
   }
   
   // update the review.
   Review.mapData(review, req.body)
   await review.save()

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