const sharp = require('sharp')
const multer = require('multer')
const ApiError = require('./ApiError')
const { catchAsync } = require('./ErrorHandling')

// setup storage type
const multerStorage = multer.memoryStorage()

// setup storage filter
const multerFilter = (req, file, cb) => {
    if (file.mimetype.startsWith('image')) {
        cb(null, true)
    } else {
        cb(new ApiError('Not an image! Please upload only images.', 400), false);
    }
}

// configuring uploader.
const uploader = multer({
    storage: multerStorage,
    fileFilter: multerFilter
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


module.exports = {
    uploadProfileImage
}
