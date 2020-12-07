// =====================
// imports
// =====================
const express = require('express')
const Constants = require('../utils/constants')
const middlewareAuth = require('../middleware/middlewareAuth')
const middlewareRestrict = require('../middleware/middlewareRestrict')
const { uploadPostImages, uploadNewPostImages } = require('../utils/FileUpload')
const routerForum = express.Router({ mergeParams: true })


// =====================
// methods
// =====================
const {
    createTopic,
    deleteTopic,
    createPost,
    updatePost,
    deletePost,
    retrievePosts,
    retrieveTopics,
    retrieveNewestTopics,
    retrieveMostPopularTopics } = require('../controller/ControllerForum')


// =====================
// routes
// =====================
routerForum.use(middlewareAuth)
routerForum.post('/topic', middlewareRestrict(Constants.ROLE_USER), uploadPostImages, createTopic)
routerForum.delete('/topic', middlewareRestrict(Constants.ROLE_USER), deleteTopic)
routerForum.get('/topic', middlewareRestrict(Constants.ROLE_USER), retrieveTopics)
routerForum.get('/topic/newest', middlewareRestrict(Constants.ROLE_USER), retrieveNewestTopics)
routerForum.get('/topic/popular', middlewareRestrict(Constants.ROLE_USER), retrieveMostPopularTopics)
routerForum.get('/topic/:topicId/posts', middlewareRestrict(Constants.ROLE_USER), retrievePosts)


routerForum.use(middlewareRestrict(Constants.ROLE_USER))
routerForum.route('/post')
           .post(uploadPostImages, createPost)
           .delete(uploadPostImages, deletePost)
           .patch(uploadNewPostImages, updatePost)

module.exports = routerForum