const express = require('express')
const Constants = require('../utils/constants')
const middlewareAuth = require('../middleware/middlewareAuth')
const middlewareRestrict = require('../middleware/middlewareRestrict')
const { createReview, retrievePsychologistReviews, deleteReview, updateReview } = require('../controller/ControllerReview')

const routerReview = express.Router({ mergeParams: true })

routerReview.route('/review')
   .post(middlewareAuth, middlewareRestrict(Constants.ROLE_USER), createReview)
   .get(middlewareAuth, middlewareRestrict(Constants.ROLE_USER, Constants.ROLE_ADMIN), retrievePsychologistReviews)


routerReview.route('/review/:reviewId')
   .delete(middlewareAuth, middlewareRestrict(Constants.ROLE_USER, Constants.ROLE_ADMIN), deleteReview)
   .patch(middlewareAuth, middlewareRestrict(Constants.ROLE_USER), updateReview)

                           
module.exports = routerReview