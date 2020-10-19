const AWS = require('aws-sdk')
const dotenv = require('dotenv')
dotenv.config({ path: './config.env' })
const bucket = 'psyclog'

// configuring the AWS environment
AWS.config.update({
    accessKeyId: process.env.S3_ACCESS_KEY_ID,
    secretAccessKey: process.env.S3_SECRET_ACEESS_KEY
})

const s3 = new AWS.S3()
const bucketAddress = 'https://psyclog.s3.eu-west-1.amazonaws.com/'

const uploadFile = async (subfolder, file, filename) => {
    const params = {
        Bucket: bucket,
        Body : file,
        Key : `${subfolder}/${filename}` 
    }

    const result = await s3.upload(params).promise() 
    return result.Location
}

const deleteFile = async filePath => {
    const params = {
        Bucket: bucket,
        Key : filePath.replace(bucketAddress, '')
    }

    await s3.deleteObject(params).promise() 
} 


const emptyS3Directory = async dir => {
    const listParams = {
        Bucket: bucket,
        Prefix: dir
    };

    const listedObjects = await s3.listObjectsV2(listParams).promise();

    if (listedObjects.Contents.length === 0) return;

    const deleteParams = {
        Bucket: bucket,
        Delete: { Objects: [] }
    };

    listedObjects.Contents.forEach(({ Key }) => {
        deleteParams.Delete.Objects.push({ Key });
    });

    await s3.deleteObjects(deleteParams).promise();
    if (listedObjects.IsTruncated) await emptyS3Directory(bucket, dir);
}


module.exports = {
    uploadFile,
    deleteFile,
    emptyS3Directory
}