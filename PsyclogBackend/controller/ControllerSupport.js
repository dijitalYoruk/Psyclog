// =====================
// imports
// =====================
const { catchAsync } = require('../utils/ErrorHandling')
const SupportMessage = require('../model/supportMessage')
const Constants = require('../utils/constants')
const ApiError = require('../utils/ApiError')
const User = require('../model/user')

const createSupportMessage = catchAsync(async (req, res, next) => {
    // retrieve data
    const currentUser = req.currentUser
    let { title, message, status, complaint } = req.body

    if (currentUser._id === complaint) {
        return next(new ApiError(__('error_unauthorized'), 403))
    }

    if (status === Constants.SUPPORT_COMPLAINT) {
        const exist = await User.exists({ _id: complaint }) 
        if (!exist) return next(new ApiError(__('error_not_found', 'User'), 404))
    }

    await SupportMessage.create({
        title, message, status, complaint, author: currentUser._id
    })

    res.status(200).json({
        status: 200,
        data: { 
            message: __('success_create', 'Message')
        } 
    })
})

const retrieveSupportMessages = catchAsync(async (req, res, next) => {
    
    // getting params.
    const page = req.query.page
    const status = req.query.status || ''
   
    // paginating messages.
    const supportMessages = await SupportMessage.paginate({ status }, { 
        page, limit:10, populate: { 
            path: 'author', select: 'username name surname profileImage email phoneNumber'
        } 
    })

    res.status(200).json({
        status: 200,
        data: { 
            supportMessages
        } 
    })
})


const retrieveSupportMessage = catchAsync(async (req, res, next) => {
    // getting params.
    let { supportMessage } = req.params

    // retrieve message.
    supportMessage = await SupportMessage
        .findById(supportMessage)
        .populate({
            path: 'author', 
            select: 'username name surname profileImage email phoneNumber' 
        })

    if (!supportMessage) {
        return next(new ApiError(__('error_not_found', 'Support Message'), 404))
    }

    res.status(200).json({
        status: 200,
        data: { 
            supportMessage
        } 
    })
})

const removeSupportMessage = catchAsync(async (req, res, next) => {
    // getting params.
    let { supportMessage } = req.body

    // retrieve message.
    supportMessage = await SupportMessage.findById(supportMessage)

    if (!supportMessage) {
        return next(new ApiError(__('error_not_found', 'Support Message'), 404))
    }

    await supportMessage.delete()

    res.status(200).json({
        status: 200,
        data: { message: __('success_delete', 'Support Message') } 
    })
})


const handleSupportMessage = catchAsync(async (req, res, next) => {
    // getting params.
    let { supportMessage } = req.body

    // retrieve message.
    supportMessage = await SupportMessage.findById(supportMessage)

    if (!supportMessage) {
        return next(new ApiError(__('error_not_found', 'Support Message'), 404))
    }

    supportMessage.isHandled = true
    await supportMessage.save()

    res.status(200).json({
        status: 200,
        data: { 
            message: __('handled')
        } 
    })
})

module.exports = {
    handleSupportMessage,
    removeSupportMessage,
    createSupportMessage,
    retrieveSupportMessage,
    retrieveSupportMessages,
}