// =====================
// imports
// =====================
const { catchAsync } = require('../utils/ErrorHandling')
const ClientRequest = require('../model/clientRequest')
const { isMatching } = require('../utils/util')
const ApiError = require('../utils/ApiError')
const Constants = require('../utils/constants')
const User = require('../model/user')
const Chat = require('../model/chat')


// =====================
// methods
// =====================
const createClientRequest = catchAsync(async (req, res, next) => {
   const patient = req.currentUser._id
   const { psychologist, content } = req.body

   // Being already a patient.
   if (req.currentUser.registeredPsychologists.includes(psychologist)) {
      return next(new ApiError(__('error_already_patient'), 400))
   }

   // Check whether user has already been requested. 
   const isAlreadyRequested = await ClientRequest.exists({ patient, psychologist })
   if (isAlreadyRequested) {
      return next(new ApiError(__('error_already_requested'), 400))
   }

   // check whether the requested user is psychologist 
   const psychologistRole = await User.findOne({_id: psychologist}).select('role')
   if (psychologistRole.role !== Constants.ROLE_PSYCHOLOGIST) {
      return next(new ApiError(__('error_select_psychologist'), 400))
   }

   // create client request.
   const data = { patient, psychologist, content }
   const request = await ClientRequest.create(data)
   
   res.status(200).json({
      status: 200,
      data: { request } 
   })
})


const retrieveClientRequests = catchAsync(async (req, res, next) => {
   const page = req.query.page || 1
   const currentUser = req.currentUser 
   let requests

   // psychologist gets patient requests
   if (currentUser.role === Constants.ROLE_PSYCHOLOGIST) {
      requests = await ClientRequest.paginate({ psychologist: currentUser._id }, {
         page, limit: 10,
         populate: { path: 'patient', select: '-cash' }})
   }
   else { // patient views his own requests.
      requests = await ClientRequest.paginate({ patient: currentUser._id }, {
         page, limit: 10,
         populate: { path: 'psychologist', select: '-cash' }})
   }

   res.status(200).json({
      status: 200,
      data: { requests } 
   })
})


const acceptClientRequest = catchAsync(async (req, res, next) => {
   // retrieve corresponding data

   const { requestId } = req.body
   const psychologist = req.currentUser
   const clientRequest = await ClientRequest.findById(requestId)

   const patient = clientRequest.patient

   if (!clientRequest) { 
      return next(new ApiError(__('error_not_found', 'Request'), 404))
   }
   
   if (!isMatching(psychologist._id, clientRequest.psychologist)) { 
      return next(new ApiError(__('error_unauthorized'), 403))
   }

   // setting up the chat instance
   const chatData = {
      patient, psychologist, messages: []
   }

   // update the relations and delete request
   const promise1 = User.findByIdAndUpdate(psychologist, { $addToSet: { patients: patient } })
   const promise2 = User.findByIdAndUpdate(patient, { $addToSet: { registeredPsychologists: psychologist } })
   const promise3 = ClientRequest.deleteOne(clientRequest)
   const promise4 = Chat.create(chatData)
   await Promise.all([promise1, promise2, promise3, promise4])

   res.status(200).json({
      status: 200,
      data: __("success_accepted", "Patient")
   })
})


const deleteClientRequest = catchAsync(async (req, res, next) => {
   const currentUser = req.currentUser
   const { requestId } = req.body
   const clientRequest = await ClientRequest.findById(requestId)

   if (!clientRequest) { 
      return next(new ApiError(__('error_not_found', 'Request'), 404))
   }
   
   if (!isMatching(currentUser._id, clientRequest.patient)) { 
      return next(new ApiError(__('error_unauthorized'), 403))
   }

   await ClientRequest.deleteOne(clientRequest)

   res.status(200).json({
      status: 200,
      data: __('success_delete', 'Request')
   })
})


const denyClientRequest = catchAsync(async (req, res, next) => {
   const psychologist = req.currentUser
   const { requestId } = req.body
   const clientRequest = await ClientRequest.findById(requestId)

   if (!clientRequest) { 
      return next(new ApiError(__('error_not_found', 'Request'), 404))
   }
   
   if (!isMatching(psychologist._id, clientRequest.psychologist)) { 
      return next(new ApiError(__('error_unauthorized'), 403))
   }

   await ClientRequest.deleteOne(clientRequest)

   res.status(200).json({
      status: 200,
      data: __('success_deny', 'Patient')
   })
})


module.exports = {
   retrieveClientRequests,
   createClientRequest,
   acceptClientRequest,
   denyClientRequest,
   deleteClientRequest
}