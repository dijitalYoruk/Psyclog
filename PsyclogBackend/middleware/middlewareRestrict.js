const ApiError = require('../utils/ApiError')

const middlewareRestrict = (...roles) => {
   return (req, res, next) => {
         const currentRole = req.currentUser.role
         if (!roles.includes(currentRole)) 
            return next(new ApiError('Unauthorized', 403))
         next()
   }
}

module.exports = middlewareRestrict