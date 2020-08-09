// =====================
// imports
// =====================
const { globalErrorHandler, catchAsync } = require('./utils/ErrorHandling')
const initLocalization = require('./locales/LocalizationConfig')
const socketio = require('socket.io')
const express = require('express')
const http = require('http')
const User = require('./model/user')
const Message = require('./model/message')
const Chat = require('./model/chat')
const Constants = require('./utils/constants')

const app = express()
const server = http.createServer(app)
const io = socketio(server)


io.on('connection', socket => {
   console.log('New Socket Connection')

   // =======================
   // MESSAGE SEEN
   // =======================
   socket.on('messageSeen', async (data, cbError) => {
      try {
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
      } 
      catch(exception) {
         cbError(exception)
      }
   })


   // =======================
   // ACTIVATE USER
   // =======================
   socket.on('activateUser', async (data, cbError) => {
      try {
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
      } 
      catch(exception) {
         cbError(exception)
      }
   })


   // =======================
   // PREVIOUS MESSAGES
   // =======================
   socket.on('retrievePreviousMessages', async (data, cbError) => {
      try {
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
      } 
      catch (exception) {
         cbError(exception)
      }
   })


   // =======================
   // SEND MESSAGE
   // =======================
   socket.on('sendMessage', async (data,cbError) => {
      try {
         // parsing data
         let { accessToken, message, chat } = data
         const decodedTokenData = await User.decodeJWT(accessToken)
         const author = decodedTokenData.id

         // getting the chat
         chat = await Chat.findOne({ _id: chat, $or: [{ psychologist: author }, { patient: author }] })
         const contact = isMatching(author, chat.psychologist) ? chat.patient : chat.psychologist
         if (!chat) { return cbError({ message: 'Chat not Found', status: 404 }) }

         // create message and send data
         const select = 'name profileImage'
         message = await Message.create({ message, author, contact, chat })
         chat.lastMessage = await message.populate({ path: 'author', options: { select }}).execPopulate()
         await chat.save()
         io.to(chat._id).emit('message', message)
      } 
      catch (exception) {
         cbError(exception)
      }
   })


   // =======================
   // DISCONNECT
   // =======================
   socket.on('disconnect', async () => {
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
   })

})

// =====================
// middlewares
// =====================
const mongoSanitize = require('express-mongo-sanitize')
const helmet = require('helmet')
const morgan = require('morgan')
const xss = require('xss-clean')
const cors = require('cors')
const hpp = require('hpp')

app.use(mongoSanitize()) // Data sanitization against NoSQL query injection
app.use(express.json({
   limit: '10kb'
})) // limiting http packet sizes.
app.use(express.static('public')) // setting public directory
app.use(helmet()) // Set security HTTP headers
app.use(xss()) // Data sanitization against XSS
app.use(hpp()) // Prevent parameter pollution
app.use(cors())
initLocalization()

if (process.env.NODE_ENV == 'development') {
   app.use(morgan('dev'))
}

// =====================
// routes
// =====================
const routesUser = require('./routes/routesUser')
const routesAuth = require('./routes/routesAuth')
const routesReview = require('./routes/routesReview')
const routesClientRequests = require('./routes/routesClientRequests')
const { isMatching } = require('./utils/util')

app.use('/api/v1/user', routesUser)
app.use('/api/v1/auth', routesAuth)
app.use('/api/v1/review', routesReview)
app.use('/api/v1/patientRequests', routesClientRequests)
app.all('*', catchAsync((req, res, next) => next(`Cannot find ${req.originalUrl} on this server.`, 404)))
app.use(globalErrorHandler)

module.exports = server