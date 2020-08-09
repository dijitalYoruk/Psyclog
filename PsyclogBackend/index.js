// =====================
// imports
// =====================
const { globalErrorHandler, catchAsync } = require('./utils/ErrorHandling')
const initLocalization = require('./locales/LocalizationConfig')
const socketio = require('socket.io')
const express = require('express')
const http = require('http')

const app = express()
const server = http.createServer(app)
const io = socketio(server)


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
app.use(express.json({ limit: '10kb' })) // limiting http packet sizes.
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

app.use('/api/v1/user', routesUser)
app.use('/api/v1/auth', routesAuth)
app.use('/api/v1/review', routesReview)
app.use('/api/v1/patientRequests', routesClientRequests)
app.all('*', catchAsync((req, res, next) => next(`Cannot find ${req.originalUrl} on this server.`, 404)))
app.use(globalErrorHandler)

module.exports = { server, io }