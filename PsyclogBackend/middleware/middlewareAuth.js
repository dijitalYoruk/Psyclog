const { catchAsync } = require('../utils/ErrorHandling')
const ApiError = require('../utils/ApiError')
const User = require('../model/user')
const Util = require('../utils/util')
const constants = require('../utils/constants')

const middlewareAuth = catchAsync(async (req, res, next) => {
   // getting the jwt token
   const token = Util.retrieveJWTtoken(req)
      
   // checking whether the token exists in the header
   if (!token) {
      return next(new ApiError('You are not logged in! Please log in to get access.', 401))
   }
 
   // decoding the token
   const decodedTokenData = await User.decodeJWT(token);

   // Check if user still exists
   const currentUser = await User.findById(decodedTokenData.id)
   
   if (!currentUser) {
      return next(new ApiError('The user belonging to this token does no longer exist.', 401))
   }

   if ( currentUser.role === constants.ROLE_USER && (!currentUser.isAccountVerified)) {
      return next(new ApiError(__('error_not_verified'), 403)) 
   }

   // setting founded user as current user.
   req.currentUser = currentUser
   next()

})

 module.exports = middlewareAuth
