const { server } = require('./index')
const chatSocket = require('./chat/socketChat')
const mongoose = require('mongoose')
const dotenv = require('dotenv')
dotenv.config({ path: './config.env' })

// =======================================
// CHAT SOCKET INITIALIZER
// =======================================
chatSocket.initChatSocket()

// ========================================
// EXCEPTION CATCHER
// ========================================
process.on('uncaughtException', err => {
   console.log('UNCAUGHT EXCEPTION! 💥 Shutting down...')
   console.log(err.name, err.message)
   process.exit(1)
})

// ============================
// DATABASE CONNECTION
// ============================
mongoose.connect(process.env.DATA_BASE_CONNECTION, {
   useNewUrlParser: true,
   useCreateIndex: true,
   useFindAndModify: false,
   useUnifiedTopology: true
}).then(result => {
   console.log('DB connection successful')
}).catch(error => {
   console.error(error)
})


// ============================
// SERVER CONNECTION
// ============================

const serverPort = process.env.PORT
server.listen(serverPort, () => {
   console.log(`Server running on Port ${serverPort}`)
})

process.on('unhandledRejection', err => {
   console.log('UNHANDLED REJECTION! 💥 Shutting down...')
   console.log(err.name, err.message)
   server.close(() => { process.exit(1) })
})