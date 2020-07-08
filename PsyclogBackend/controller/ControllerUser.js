// =====================
// imports
// =====================
const { catchAsync } = require('../utils/ErrorHandling')
const ApiError = require('../utils/ApiError')
const Constants = require('../utils/constants')
const User = require('../model/user')


// =====================
// methods
// =====================

// updates the user based on their profiles
const updateUser = catchAsync(async (req, res, next) => {  
   // retrieving corresponding user
   const id = req.params.userId
   const user = await User.findById(id)

   // filtering body.
   const data = User.filterBody(user.role, req.body)
   
   // update the user.
   user = await User.findByIdAndUpdate(user, data, { runValidators: true, new: true })

   res.status(200).json({
      'status': '200',
      'data': { user } 
   })
})


// retrieves users in the db based on role.
const retrieveUsers = catchAsync(async (req, res, next) => {   
   // getting params.
   const page = req.query.page
   const role = req.query.role || Constants.ROLE_USER
   
   // paginating users.
   const users = await User.paginate({ role }, { page, limit:10 })

   res.status(200).json({
      'status': '200', size,
      'data': { users } 
   })
})


// retrieves specific user from db
const retrieveUser = catchAsync(async (req, res, next) => {   
   // retrieving user
   const id = req.params.userId
   const user = await User.findById(id)

   if (!user) {
      return next(new ApiError('User not found.', 404)) 
   }

   res.status(200).json({
      'status': '200', 
      'data': { user } 
   })   
})


// deletes a specific user.
const deleteUser = catchAsync(async (req, res) => {   
   const id = req.params.userId
   await User.findByIdAndDelete(id)

   res.status(204).json({
      status: '204',
      data: {
         'message': `User with id ${id} has been successfully deleted.` 
      }
   })
})


const finishPatient = catchAsync(async (req, res) => {   
   const psychologist = req.currentUser
   const patientId = req.body.patientId
   await User.findByIdAndUpdate(psychologist, { $pull: { 'patients': patientId }})
   await User.findByIdAndUpdate(patientId, { $pull: { 'registeredPsychologists': psychologist._id }})

   res.status(204).json({
      status: '204',
      data: {
         'message': `Finished .` 
      }
   })
})


module.exports = {
   retrieveUsers,
   retrieveUser,
   deleteUser,
   updateUser,
   finishPatient
}