// =====================
// imports
// =====================
const { catchAsync } = require('../utils/ErrorHandling')
const Constants = require('../utils/constants')
const ApiError = require('../utils/ApiError')
const User = require('../model/user')


// =====================
// methods
// =====================

/**
 * Updates the user based on their profiles
 */ 
const updateUser = catchAsync(async (req, res, next) => {  
   // retrieving corresponding user
   const id = req.body.userId
   const user = await User.findById(id)

   if (!user) {
      return next(new ApiError(__('error_not_found', 'User'), 404))
   }

   // update the user.
   User.mapData(user, req.body, true)
   await user.save()

   res.status(200).json({
      status: 200,
      data: { message: "User successfully updated." } 
   })
})


/**
 * Retrieves users in the db based on role.
 */
const retrieveUsers = catchAsync(async (req, res, next) => {   
   // getting params.
   const page = req.query.page
   const role = req.query.role || Constants.ROLE_USER
   const search = req.query.search
   
   let users = []

   // paginating users.
   if  (role == Constants.ROLE_PSYCHOLOGIST) {
      users = await User.paginate({ role, isPsychologistVerified: true, $or: [
         { username: { $regex: new RegExp(search.toLowerCase(), "i") } },
         { email: { $regex: new RegExp(search.toLowerCase(), "i") } },
      ]}, { page, limit:10, options: { sort: { penaltyCount: 'desc' }}})
   } else {
      users = await User.paginate({ role, $or: [
         { username: { $regex: new RegExp(search.toLowerCase(), "i") } },
         { email: { $regex: new RegExp(search.toLowerCase(), "i") } },
      ]}, { page, limit:10})
   }
   
   res.status(200).json({
      status: 200, 
      data: { users } 
   })
})


/**
 * Retrieves psychologists for the users.
 */
const retrievePsychologists = catchAsync(async (req, res, next) => {
   // getting params.
   const page = req.query.page
   const search = req.query.search
   const role = Constants.ROLE_PSYCHOLOGIST

   // paginating users.
   const psychologists = await User.paginate({ role, isPsychologistVerified: true, $or: [
      { username: { $regex: new RegExp(search.toLowerCase(), "i") } },
      { email: { $regex: new RegExp(search.toLowerCase(), "i") } },
      { name: { $regex: new RegExp(search.toLowerCase(), "i") } },
      { surname: { $regex: new RegExp(search.toLowerCase(), "i") } },
   ]},  { page, limit:10 })
   res.status(200).json({
      status: 200, 
      data: { psychologists } 
   })
})


/**
 * Retrieves psychologists for the users.
 */
const retrieveUnverifiedPsychologists = catchAsync(async (req, res, next) => {
   // getting params.
   const page = req.query.page
   const search = req.query.search
   const role = Constants.ROLE_PSYCHOLOGIST

   // paginating users.
   const psychologists = await User.paginate({ role, isPsychologistVerified: false,  $or: [
      { username: { $regex: new RegExp(search.toLowerCase(), "i") } },
      { email: { $regex: new RegExp(search.toLowerCase(), "i") } },
   ]}, { page, limit:10 })
   
   res.status(200).json({
      status: 200, 
      data: { psychologists } 
   })
})


/**
 * Retrieves psychologists for the users.
 */
const retrieveRegisteredPsychologists = catchAsync(async (req, res, next) => {
   // getting params.

   const registeredPsychologists = await User.findById(req.currentUser._id)
                           .populate('registeredPsychologists')
                           .select('registeredPsychologists')

   res.status(200).json({
      status: 200, 
      data: { registeredPsychologists } 
   })
})

/**
 * Retrieves patients for the therapists.
 */
const retrievePatients = catchAsync(async (req, res, next) => {
   // getting params.

   const registeredPatients = await User.findById(req.currentUser._id)
                           .populate('patients')
                           .select('patients')

   res.status(200).json({
      status: 200, 
      data: { registeredPatients } 
   })
})

/**
 * Retrieves specific user from db
 */ 
const retrieveUser = catchAsync(async (req, res, next) => {   
   // retrieving user
   const id = req.params.userId
   const user = await User.findById(id)

   if (!user) {
      return next(new ApiError(__('error_not_found', 'User'), 404))
   }

   res.status(200).json({
      status: 200, 
      data: { user } 
   })   
})


/**
 * Deletes a specific user.
 */ 
const deleteUser = catchAsync(async (req, res) => {   
   const id = req.body.userId
   const user = await User.findById(id)
   await user.remove()

   res.status(200).json({
      status: 200,
      data: { message: __('success_delete', 'User') }
   })
})


/**
 * Finishes the relationship between patient and psychologist.
 */ 
const finishPatient = catchAsync(async (req, res) => {   
   const psychologistId = req.body.psychologistId
   const patientId = req.body.patientId
   await User.findByIdAndUpdate(psychologistId, { $pull: { 'patients': patientId }})
   await User.findByIdAndUpdate(patientId, { $pull: { 'registeredPsychologists': psychologistId }})

   res.status(204).json({
      status: 204,
      data: {
         message: __('success_finish')
      }
   })
})


const verifyPsychologist = catchAsync(async (req, res) => {   
   const psychologistId = req.body.psychologistId
   await User.findByIdAndUpdate(psychologistId, { isPsychologistVerified: true })

   res.status(204).json({
      status: 204,
      data: {
         message: 'Psychologist successfully verified'
      }
   })
})


module.exports = {
   retrieveUsers,
   retrieveUser,
   deleteUser,
   updateUser,
   finishPatient,
   verifyPsychologist,
   retrievePsychologists,
   retrieveRegisteredPsychologists,
   retrieveUnverifiedPsychologists,
   retrievePatients
}