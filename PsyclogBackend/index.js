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
   socket.on('messageSeen', async data => {
      try {
         // parsing data
         let { accessToken, chat } = data
         const decodedTokenData = await User.decodeJWT(accessToken)
         const seenUserId = decodedTokenData.id
         let messageIds = await Message.find({ chat, contact: seenUserId, isSeen:false }).select('_id')
         messageIds = messageIds.map(msg => msg._id)
         if (messageIds.length == 0) return  

         await Message.updateMany({ _id: { $in: messageIds }}, { isSeen: true })
         chat = await Chat.findOne({ _id: chat, $or: [{ psychologist: seenUserId }, { patient: seenUserId }] }).populate('lastMessage')

         if (isMatching(chat.lastMessage.author, seenUserId)) { return }
         io.to(chat._id).emit(`message-seen-chat-${seenUserId}`, messageIds)
         io.to(chat._id).emit(`message-seen-list`, chat.lastMessage)
      } 
      catch(e) {
         console.log(e)
      }
   })


   // =======================
   // ACTIVATE USER
   // =======================
   socket.on('activateUser', async data => {
      try {
         // parsing data
         const decodedTokenData = await User.decodeJWT(data.accessToken)
         const role = decodedTokenData.role
         let user = decodedTokenData.id
         
         // activate user
         user = await User.findByIdAndUpdate(user, { isActive: true, socket: socket.id }, { new: true })
         let chats = []

         // find chats to be published.
         if (role == Constants.ROLE_USER) {
            chats = await Chat.find({ patient: user }).populate({ path:'psychologist', options : { select: 'name profileImage isActive username' }}).populate('lastMessage')
         } else if (role === Constants.ROLE_PSYCHOLOGIST) {
            chats = await Chat.find({ psychologist: user }).populate({ path:'patient', options : { select: 'name profileImage isActive username' }}).populate('lastMessage')
         }

         // join chats to socket and emit them.
         for (let chat of chats) { socket.join(chat._id) }
         socket.emit('chats', chats)

         // signaling user is active.
         io.emit(user._id, true)
      } 
      catch(exception) {
         console.log(exception)
      }
   })


   // =======================
   // PREVIOUS MESSAGES
   // =======================
   socket.on('retrievePreviousMessages', async data => {
      try {
         // parsing data
         let { accessToken, chat, skip } = data
         const decodedTokenData = await User.decodeJWT(accessToken)
         const joinedUser = decodedTokenData.id

         // retrieving the chat
         chat = await Chat.findOne({ _id: chat, $or: [{ psychologist: joinedUser }, { patient: joinedUser }] })

         if (!chat) {
            console.log('Chat not Found')
            return
         }

         // retrieve previous messages
         const messages = await Message.find({ chat }).skip(skip).limit(10).sort('-createdAt')
         .populate({ path: 'author' })
   
         // send messages.
         socket.emit('previousMessages', messages)
      } 
      catch (e) {
         console.log(e)
      }
   })


   // =======================
   // SEND MESSAGE
   // =======================
   socket.on('sendMessage', async data => {
      try {
         // parsing data
         let { accessToken, message, chat } = data
         const decodedTokenData = await User.decodeJWT(accessToken)
         const author = decodedTokenData.id

         // getting the chat
         chat = await Chat.findOne({ _id: chat, $or: [{ psychologist: author }, { patient: author }] })
         const contact = isMatching(author, chat.psychologist) ? chat.patient : chat.psychologist

         if (!chat) {
            console.log('Chat not Found')
            return
         }

         // create message and send data
         message = await Message.create({ message, author, contact, chat: chat._id })
         chat.lastMessage = await message.populate({ path: 'author', options: { select: 'name profileImage' }}).execPopulate()
         await chat.save()
         io.to(chat._id).emit('message', message)
      } 
      catch (e) {
         console.log(e)
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
         io.emit(user._id, false)
         if (!user) return 
         console.log('disconnected')
      } 
      catch(e) {
         console.log(e)
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