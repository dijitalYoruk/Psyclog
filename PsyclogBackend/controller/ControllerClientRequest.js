// =====================
// imports
// =====================
const { catchAsync } = require('../utils/ErrorHandling')
const ClientRequest = require('../model/clientRequest')
const { isMatching } = require('../util')
const ApiError = require('../utils/ApiError')
const Constants = require('../constants')
const User = require('../model/user')


// =====================
// methods
// =====================
const createClientRequest = catchAsync(async (req, res, next) => {
   const patient = req.currentUser._id
   const { psychologist, content } = req.body

   if (req.currentUser.registeredPsychologists.includes(psychologist)) {
      return next(new ApiError('Already registered.', 400))
   }

   const psychologistRole = await User.findOne({_id: psychologist}).select('role')
   if (psychologistRole.role !== Constants.ROLE_PSYCHOLOGIST) {
      return next(new ApiError('Please select a Psychologist.', 400))
   }

   const data = { patient, psychologist, content }
   const request = await ClientRequest.create(data)
   if (!request) { 
      return next(new ApiError('Requests could not be created', 400))
   }

   res.status(200).json({
      status: 200,
      data: { request } 
   })
})


const retrieveClientRequests = catchAsync(async (req, res, next) => {
   const page = req.query.page || 1
   const currentUser = req.currentUser 
   let requests

   if (currentUser.role === Constants.ROLE_PSYCHOLOGIST) {
      requests = await ClientRequest.paginate({ psychologist: currentUser._id }, {page, limit: 10, 
         populate: { path: 'patient', select: '-cash' }})
   } else {
      requests = await ClientRequest.paginate({ patient: currentUser._id }, {page, limit: 10, 
         populate: { path: 'psychologist', select: '-cash' }})
   }

   if (!requests) { 
      return next(new ApiError('Requests could not be retrieved', 400))
   }

   res.status(200).json({
      status: 200,
      data: { requests } 
   })
})


const acceptClientRequest = catchAsync(async (req, res, next) => {
   const { requestId } = req.body
   const psychologist = req.currentUser
   const clientRequest = await ClientRequest.findById(requestId)
   const patient = clientRequest.patient

   if (!clientRequest) { 
      return next(new ApiError('Request could not be found.', 404))
   }
   
   if (!isMatching(psychologist._id, clientRequest.psychologist)) { 
      return next(new ApiError('Unauthorized', 403))
   }

   const promise1 = User.findByIdAndUpdate(psychologist, { $addToSet: { patients: patient } })
   const promise2 = User.findByIdAndUpdate(patient, { $addToSet: { registeredPsychologists: psychologist } })
   const promise3 = ClientRequest.deleteOne(clientRequest)
   await Promise.all(promise1, promise2, promise3)

   res.status(200).json({
      status: 200,
      data: 'Patient has been accepted' 
   })
})


const deleteClientRequest = catchAsync(async (req, res, next) => {
   const currentUser = req.currentUser
   const { requestId } = req.body
   const clientRequest = await ClientRequest.findById(requestId)

   if (!clientRequest) { 
      return next(new ApiError('Request could not be found.', 404))
   }
   
   if (!isMatching(currentUser._id, clientRequest.patient)) { 
      return next(new ApiError('Unauthorized', 403))
   }

   await ClientRequest.deleteOne(clientRequest)

   res.status(200).json({
      status: 200,
      data: 'Request has been successfully deleted.' 
   })
})


const denyClientRequest = catchAsync(async (req, res, next) => {
   const psychologist = req.currentUser
   const { requestId } = req.body
   const clientRequest = await ClientRequest.findById(requestId)

   if (!clientRequest) { 
      return next(new ApiError('Request could not be found.', 404))
   }
   
   if (!isMatching(psychologist._id, clientRequest.psychologist)) { 
      return next(new ApiError('Unauthorized', 403))
   }

   await ClientRequest.deleteOne(clientRequest)

   res.status(200).json({
      status: 200,
      data: 'Patient has been denied.' 
   })
})


module.exports = {
   retrieveClientRequests,
   createClientRequest,
   acceptClientRequest,
   denyClientRequest,
   deleteClientRequest
}