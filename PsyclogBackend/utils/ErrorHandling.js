const ApiError = require('../utils/ApiError')

const catchAsync = func => {
   return (req, res, next) => {
      func(req, res, next).catch(next)
   }
}

const handleCastErrorDB = err => {
   const message = `Invalid ${err.path}: ${err.value}.`
   return new ApiError(message, 400)
}
 
const handleDuplicateFieldsDB = err => {
   const value = err.errmsg.match(/(["'])(\\?.)*?\1/)[0]
   const message = `Duplicate field value: ${value}. Please use another value!`
   return new ApiError(message, 400)
}
 
const handleValidationErrorDB = err => {
   const errors = Object.values(err.errors).map(el => el.message)
   const message = `Invalid input data.|||${errors.join('|||')}`
   const error = new ApiError(message, 400)
   error.isValidationError = true
   return error
}
 
const handleJWTError = () => {
   return new ApiError('Invalid token. Please log in again!', 401)
}
 
const handleJWTExpiredError = () => {
   return new ApiError('Your token has expired! Please log in again.', 401)
}

const sendErrorDev = (err, res) => {
   res.status(err.statusCode).json({
     status: err.status,
     error: err,
     message: err.message,
     stack: err.stack
   })
 }
 
 const sendErrorProd = (err, res) => {
   // Operational Error
   if (err.isOperational) {
     res.status(err.statusCode).json({
         statusCode: err.statusCode,
         status: err.status,
         message: err.message,
         isValidationError: (err.isValidationError == true)
     })
 
     // Programming error
   } else {
     // 1) Log error
     console.error('ERROR 💥', err)
 
     // 2) Send generic message
     res.status(500).json({
       status: 'error',
       message: 'Something went very wrong!'
     })
   }
 }

const globalErrorHandler = (err, req, res, next) => { 
   err.status = err.status || 'error'
   err.statusCode = err.statusCode || 500

   // development environment.
   if (process.env.NODE_ENV === 'development') {
      sendErrorDev(err, res);
   } 
   
   // production environment.
   else if (process.env.NODE_ENV === 'production') {
      if (err.name === 'CastError') err = handleCastErrorDB(err)
      if (err.code === 11000) err = handleDuplicateFieldsDB(err)
      if (err.name === 'ValidationError') err = handleValidationErrorDB(err)
      if (err.name === 'JsonWebTokenError') err = handleJWTError()
      if (err.name === 'TokenExpiredError') err = handleJWTExpiredError()
      sendErrorProd(err, res);
   }
}

module.exports = {
   catchAsync,
   globalErrorHandler
}