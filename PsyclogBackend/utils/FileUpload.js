const sharp = require('sharp')
const multer = require('multer')
const ApiError = require('./ApiError')
const { catchAsync } = require('./ErrorHandling')
const { v4:uuidv4 }  = require('uuid')

// setup storage type
const multerStorage = multer.memoryStorage()

// TODO Merge these image and pdf filters in future.

// setup storage filter
const multerFilter = (req, file, cb) => {

    if (file.mimetype.startsWith('image')) {
        cb(null, true)
    } else {
        cb(new ApiError('Not an image! Please upload only images.', 400), false);
    }
}

// setup pdf filter
const multerPdfFilter = (req, file, cb) => {
    if (file.mimetype.startsWith('application/pdf')) {
        cb(null, true)
    } else {
        cb(new ApiError('Not a pdf! Please upload only pdf files.', 400), false);
    }
}

// configuring uploader.
const uploader = multer({
    storage: multerStorage,
    fileFilter: multerFilter
})


const uploaderPdf = multer({
    storage: multerStorage,
    fileFilter: multerPdfFilter
})


// =====================================================
// Upload Profile Image
// =====================================================
const resizeProfileImage = catchAsync(async (req, res, next) => {
    if (!req.file) return next();
  
    // generating file name.
    const filename = `profileImage-${Date.now()}.jpeg`

    // process image.
    const file = await sharp(req.file.buffer)
      .resize(500, 500)
      .toFormat('jpeg')
      .jpeg({ quality: 90 })
      .toBuffer()
        
    req.file = { file, filename }
    next()
})

const uploadProfileImage = [uploader.single('profileImage'), resizeProfileImage]


// =====================================================
// Upload Post Images
// =====================================================
const resizePostsImages = catchAsync(async (req, res, next) => {
    if (!req.files) return next();
    const uuid = uuidv4()

    for (let index in req.files) {
        const filename = `post-${uuid}-${index}.jpeg`;
        const file = await sharp(req.files[index].buffer)
            .resize(400, 250)
            .toFormat('jpeg')
            .jpeg({ quality: 90 })
            .toBuffer()
        req.files[index] = { file, filename }
    }

    next()
})

const uploadPostImages = [uploader.array('postImages'), resizePostsImages]
const uploadNewPostImages = [uploader.array('newPostImages'), resizePostsImages]


// =====================================================
// Upload CV and Transcript
// =====================================================

const extractCvAndTranscript = catchAsync(async (req, res, next) => {
    if (!req.files) return next();
    const uuidCV = uuidv4()
    const uuidTranscript = uuidv4()

    // generating file name.
    const filenameCV = `cv-${uuidCV}.pdf`
    const filenameTranscript = `transcript-${uuidTranscript}.pdf`

    // process image.
    const fileCV = req.files.cv[0].buffer
    const fileTranscript = req.files.transcript[0].buffer
        
    req.files.cv = { fileCV, filenameCV }
    req.files.transcript = { fileTranscript, filenameTranscript }
    next()
})

const uploadCVAndTranscript = [uploaderPdf.fields([
    { name: 'cv', maxCount: 1 },
    { name: 'transcript', maxCount: 1 },
]), extractCvAndTranscript]


module.exports = {
    uploadCVAndTranscript,
    uploadProfileImage,
    uploadPostImages,
    uploadNewPostImages
}
