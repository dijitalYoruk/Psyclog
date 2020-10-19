const mongoose = require("mongoose");
const mongoosePaginate = require('mongoose-paginate-v2')
const ForumPost = require('../model/forumPost')
const Schema = mongoose.Schema;
const s3 = require('../utils/S3')

const ForumTopicSchema = new Schema(
    {
        title: {
            type: String,
            required: [true, 'You should have a title.'],
            trim: true,
            unique: true
        },
        description: {
            type: String,
            required: [true, 'You should have a description.'],
            trim: true,
        },
        author: {
            ref: "User",
            type: mongoose.Schema.ObjectId,
            required: [true, "You should have a wallet owner."],
        },
        posts: [{
            ref: "Post",
            type: mongoose.Schema.ObjectId,
        }]
    },
    { timestamps: true, versionKey: false }
);


ForumTopicSchema.pre('remove', async function(next) {
    const posts = this.posts
    await ForumPost.deleteMany({_id:{$in:posts}})
    posts.map(async postId => { await s3.emptyS3Directory(`${this.author}/posts/${postId}` )})
    next()
})


ForumTopicSchema.plugin(mongoosePaginate)
const Topic = mongoose.model("Topic", ForumTopicSchema);
module.exports = Topic;
