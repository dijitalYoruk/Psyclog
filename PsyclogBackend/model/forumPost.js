const mongoosePaginate = require('mongoose-paginate-v2')
const { filterObject } = require('../utils/util')
const mongoose = require("mongoose");
const Schema = mongoose.Schema;
const s3 = require('../utils/S3')


const ForumPostSchema = new Schema(
    {
        quotation: {
            ref: "Post",
            type: mongoose.Schema.ObjectId,
        },
        content: {
            type: String,
            required: [true, 'You should have a title.'],
            trim: true
        },
        images: [{
            type: String,
        }],
        author: {
            ref: "User",
            type: mongoose.Schema.ObjectId,
            required: true
        },
        topic: {
            ref: "Topic",
            type: mongoose.Schema.ObjectId,
            required: true
        },
        isAuthorAnonymous: {
            type: Boolean, 
            required: true
        }
    },
    { timestamps: true, versionKey: false }
);


// update post images
ForumPostSchema.methods.uploadPostImages = async function(postImageFiles, userId) {
    for (let data of postImageFiles) {
        const { file, filename } = data
        const url = await s3.uploadFile(`${userId}/posts/${this._id}`, file, filename)
        this.images.push(url)
    }
}


ForumPostSchema.methods.deletePostImages = async function(deletedPostImages) {
    if (!deletedPostImages) return
    for (let image of deletedPostImages) {
        await s3.deleteFile(image)
        this.images.splice(this.images.indexOf(image), 1); 
    }
}


ForumPostSchema.statics.mapData = async (post, data) => {
    const items = [ 'isAuthorAnonymous', 'content' ]
    data = filterObject(data, ...items)  
    Object.keys(data).map(key => {
        post[key] = data[key]
    })
}


ForumPostSchema.pre('remove', async function(next) {
    await s3.emptyS3Directory(`${this.author}/posts/${this._id}`)
    next()
})


ForumPostSchema.plugin(mongoosePaginate)
const Post = mongoose.model("Post", ForumPostSchema);
module.exports = Post;
