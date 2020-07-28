const AWS = require('aws-sdk')
const dotenv = require('dotenv')
dotenv.config({ path: './config.env' })

// configuring the AWS environment
AWS.config.update({
    accessKeyId: process.env.S3_ACCESS_KEY_ID,
    secretAccessKey: process.env.S3_SECRET_ACEESS_KEY
})

const s3 = new AWS.S3()
const bucketAddress = 'https://psyclog.s3.eu-west-1.amazonaws.com/'

const uploadFile = async (subfolder, file, filename) => {
    const params = {
        Bucket: 'psyclog',
        Body : file,
        Key : `${subfolder}/${filename}` 
    }

    const result = await s3.upload(params).promise() 
    return result.Location
}

const deleteFile = async filePath => {
    const params = {
        Bucket: 'psyclog',
        Key : filePath.replace(bucketAddress, '')
    }

    await s3.deleteObject(params).promise() 
} 

module.exports = {
    uploadFile,
    deleteFile
}