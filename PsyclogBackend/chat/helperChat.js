const { io } = require('../index')
const User = require('../model/user')
const Chat = require('../model/chat')
const Message = require('../model/message')
const Constants = require('../utils/constants')
const { isMatching } = require('../utils/util')



// error handler
const catchSocketException = func => {
    return (data, cbError) => {
       func(data, cbError).catch(error => {
            console.log(error)
            cbError(error)
       })
    } 
}



// =======================
// MESSAGE SEEN
// =======================
const seeMessage = socket => {
    return catchSocketException(async (data, cbError) => {
        // parsing data
        let { accessToken, chat } = data
        const decodedTokenData = await User.decodeJWT(accessToken)
        const seenUserId = decodedTokenData.id
         
        // retrieving corresponding unseen messages.
        let messageIds = await Message.find({ chat, contact: seenUserId, isSeen:false }).select('_id')
        messageIds = messageIds.map(msg => msg._id)
        if (messageIds.length == 0) return  
         
        // update messages
        await Message.updateMany({ _id: { $in: messageIds }}, { isSeen: true })
        chat = await Chat.findOne({ _id: chat, $or: [{ psychologist: seenUserId }, 
            { patient: seenUserId }] }).populate('lastMessage')
        
        // send notifications.
        if (isMatching(chat.lastMessage.author, seenUserId)) { return }
        io.to(chat._id).emit(`message-seen-chat-${seenUserId}`, messageIds)
        io.to(chat._id).emit(`message-seen-list`, chat.lastMessage)
    })
}
 
 

// =======================
// ACTIVATE USER
// =======================
const activateUser = socket => {
    return catchSocketException(async (data, cbError) => {
        // parsing data
        const decodedTokenData = await User.decodeJWT(data.accessToken)
        const role = decodedTokenData.role
        let user = decodedTokenData.id
           
        // activate user
        user = await User.findByIdAndUpdate(
           user, { isActive: true, socket: socket.id }, 
           { new: true })
     
        // find chats to be published.
        let chats = []
        select = 'name profileImage isActive username'
     
        // populate patient 
        if (role == Constants.ROLE_USER) {
           chats = await Chat.find({ patient: user })
                             .populate({ path:'psychologist', options : { select }})
                             .populate('lastMessage')
        } 
        // populate psychologist
        else if (role === Constants.ROLE_PSYCHOLOGIST) {
           chats = await Chat.find({ psychologist: user })
                             .populate({ path:'patient', options : { select }})
                             .populate('lastMessage')
        }
     
        // join chats to socket and emit them.
        for (let chat of chats) { socket.join(chat._id) }
        socket.emit('chats', chats)
     
        // signaling user is active.
        io.emit(user._id, true)
    })
}
    
 
 
// =======================
// PREVIOUS MESSAGES
// =======================
const retrievePreviousMessages = socket => {
    return catchSocketException(async (data, cbError) => {
        // parsing data
        let { accessToken, chat, skip } = data
        const decodedTokenData = await User.decodeJWT(accessToken)
        const joinedUser = decodedTokenData.id

        // retrieving the chat
        chat = await Chat.findOne({ _id: chat, $or: [{ psychologist: joinedUser }, { patient: joinedUser }] })
        if (!chat) { return cbError({ message: 'Chat not Found', status: 404 }) }
 
        // retrieve previous messages
        const messages = await Message.find({ chat })
                                      .skip(skip)
                                      .limit(10)
                                      .sort('-createdAt')
                                      .populate({ path: 'author' })
 
        // send messages.
        socket.emit('previousMessages', messages)
    })
}
 

 
// =======================
// SEND MESSAGE
// =======================
const sendMessage = socket => {
    return catchSocketException(async (data, cbError) => {
        // parsing data
        let { accessToken, message, chat } = data
        const decodedTokenData = await User.decodeJWT(accessToken)
        const author = decodedTokenData.id
     
        // getting the chat
        chat = await Chat.findOne({ _id: chat, $or: [{ psychologist: author }, { patient: author }] })
        const contact = isMatching(author, chat.psychologist) ? chat.patient : chat.psychologist
        if (!chat) { return cbError({ message: 'Chat not Found', status: 404 }) }
     
        // create message and send data
        const select = 'name username profileImage'
        message = await Message.create({ message, author, contact, chat: chat._id })
        chat.lastMessage = await message.populate({ path: 'author', options: { select }}).execPopulate()
        await chat.save()
        io.to(chat._id).emit('message', message)
    })
}


 
// =======================
// DISCONNECT 
// =======================
const disconnect = (socket) => {
    return async () => {
        try {
           const socketId = socket.id
           
           // remove socket
           const user = await User.findOneAndUpdate(
              { socket: socketId }, 
              { socket: undefined, isActive: false }, 
              { runValidators: true, new: true })
           
           // signal user became inactive
           if (!user) return 
           io.emit(user._id, false)
           console.log('disconnected')
        } 
        catch(exception) {
           console.log(exception)
        }
    }
} 
    

module.exports = {
    disconnect,
    seeMessage,
    sendMessage,
    activateUser,
    retrievePreviousMessages
}