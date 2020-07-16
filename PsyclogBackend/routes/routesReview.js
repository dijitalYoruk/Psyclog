const express = require('express')
const Constants = require('../utils/constants')
const middlewareAuth = require('../middleware/middlewareAuth')
const middlewareRestrict = require('../middleware/middlewareRestrict')
const { createReview, retrievePsychologistReviews, deleteReview, updateReview } = require('../controller/ControllerReview')
const routerReview = express.Router({ mergeParams: true })

routerReview.use( middlewareAuth )

routerReview.use(middlewareRestrict(Constants.ROLE_ADMIN, Constants.ROLE_USER, Constants.ROLE_PSYCHOLOGIST))
routerReview.post('/retrieve', retrievePsychologistReviews)

routerReview.use(middlewareRestrict(Constants.ROLE_ADMIN, Constants.ROLE_USER))
routerReview.route('/:reviewId').delete(deleteReview).patch(updateReview)

routerReview.use(middlewareRestrict(Constants.ROLE_USER))
routerReview.post('/', createReview)

module.exports = routerReview