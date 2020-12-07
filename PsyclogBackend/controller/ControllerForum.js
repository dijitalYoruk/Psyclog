const { catchAsync } = require('../utils/ErrorHandling')
const { isMatching } = require('../utils/util')
const ForumTopic = require('../model/forumTopic')
const ForumPost = require('../model/forumPost')
const ApiError = require('../utils/ApiError')


const createTopic = catchAsync(async (req, res, next) => {
    const currentUser = req.currentUser
    let { title, description, isAuthorAnonymous, postContent } = req.body
    
    // create topic  
    const topic = new ForumTopic({
        title, description, author: currentUser._id, isAuthorAnonymous, 
    })

    // create initial post
    const post = new ForumPost({
        content: postContent, 
        author: currentUser._id,
        topic: topic._id,
        isAuthorAnonymous
    })

    topic.posts.push(post);

    if (req.files) {
        await post.uploadPostImages(req.files, currentUser._id)
    }

    // save
    const promiseTopic = topic.save()
    const promisePost = post.save()
    await Promise.all([promiseTopic, promisePost])

    res.status(200).json({
        status: 200,
        data: { 
            message: __('success_create', 'Topic')
        } 
    })    
})


const deleteTopic = catchAsync(async (req, res, next) => {
    let { topicId } = req.body
    const topic = await ForumTopic.findById(topicId)
    if (!topic) return next(new ApiError(__('error_not_found', 'Topic'), 404))
    await topic.remove()

    res.status(204).json({
        status: 204,
        data: { message: __('success_delete', 'Topic') }
    })
})


const retrieveTopics = catchAsync(async (req, res, next) => {
    const page = req.query.page || 1
    const topics = await ForumTopic.paginate({}, {
        page, limit: 10, select: '-posts', sort: '+posts',
        populate: { path: 'author', select: 'username name surname profileImage' }
    }) 

    res.status(200).json({
        status: 200,
        data: { topics }
    })
})


const retrieveNewestTopics = catchAsync(async (req, res, next) => {
    const newestTopics = await ForumTopic
            .find({})
            .populate('author')
            .select('-posts')
            .limit(10)
            .sort('createdAt-')
       
    res.status(200).json({
        status: 200,
        data: { newestTopics }
    })
})


const retrieveMostPopularTopics = catchAsync(async (req, res, next) => {
    // ALternative
/*    let popularTopics = await ForumPost.aggregate([
        { $group: { _id: '$topic', postCount: { $sum: 1 } } },
        { $sort: { postCount: -1 } }, { $limit: 10 }
    ])

    popularTopics = popularTopics.map(topic => topic._id)
    popularTopics = await ForumTopic.find({ _id: { $in: popularTopics } })
                                    .select('-posts')
*/

    const popularTopics = await ForumTopic.find({})
                                          .limit(10)
                                          .select('-posts')
                                          .sort('+posts')

    res.status(200).json({
        status: 200,
        data: { popularTopics }
    })
})


const createPost = catchAsync(async (req, res, next) => {
    const currentUser = req.currentUser
    let { isAuthorAnonymous, postContent, topic, quotation } = req.body
    
    const post = new ForumPost({
        isAuthorAnonymous, content: postContent, 
        topic, quotation, author: currentUser._id
    })

    if (req.files) {
        await post.uploadPostImages(req.files, currentUser._id)
    }

    await post.save()

    res.status(200).json({
        status: 200,
        message: __('success_create', 'Post')
    })
})


const updatePost = catchAsync(async (req, res, next) => {
    const currentUser = req.currentUser
    const { deletedPostImages, postId } = req.body
    
    // retrieve post 
    const post = await ForumPost.findById(postId)
    if (!post) return next(new ApiError(__('error_not_found', 'Post'), 404))
    if (!isMatching(post.author, currentUser._id) )
        return next(new ApiError(__('error_unauthorized'), 403))

    await ForumPost.mapData(post, req.body)
    await post.save()

    // delete images
    await post.deletePostImages(deletedPostImages)

    // upload new images
    if (req.files) {
        await post.uploadPostImages(req.files, currentUser._id)
    }

    await post.save()

    res.status(200).json({
        status: 200,
        message: __('success_change', 'Post')
    })
})


const deletePost = catchAsync(async (req, res, next) => {
    const currentUser = req.currentUser
    const { postId } = req.body

    // retrieve post 
    const post = await ForumPost.findById(postId)
    if (!post) return next(new ApiError(__('error_not_found', 'Post'), 404))
    if (!isMatching(post.author, currentUser._id) )
        return next(new ApiError(__('error_unauthorized'), 403))

    await post.remove()

    res.status(204).json({
        status: 204,
        message: __('success_delete', 'Post')
    })
})

const retrievePosts = catchAsync(async (req, res, next) => {
    const topicId = req.params.topicId
    const page = req.query.page || 1
    console.log(topicId)

    const posts = await ForumPost.paginate({ topic: topicId }, {
        page, limit: 10, 
        populate: { path: 'author quotation', select: 'username name surname profileImage' }
    }) 

    return res.status(200).json({
        status: 200,
        data: { posts }
    })
})

module.exports = {
    createTopic,
    deleteTopic,
    createPost,
    updatePost,
    deletePost,
    retrievePosts,
    retrieveTopics,
    retrieveNewestTopics,
    retrieveMostPopularTopics,
}