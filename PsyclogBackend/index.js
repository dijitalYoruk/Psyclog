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

app.set('view engine','pug');
app.set('views','./views')

// =====================
// routes
// =====================
const routesBan = require('./routes/routesBan')
const routesUser = require('./routes/routesUser')
const routesAuth = require('./routes/routesAuth')
const routesForum = require('./routes/routesForum')
const routesReview = require('./routes/routesReview')
const routesWallet = require('./routes/routesWallet')
const routesAppointment = require('./routes/routesAppointment')
const routesSupportMessage = require('./routes/routesSupportMessage')
const routesClientRequests = require('./routes/routesClientRequests')

app.use('/api/v1/ban', routesBan)
app.use('/api/v1/user', routesUser)
app.use('/api/v1/auth', routesAuth)
app.use('/api/v1/forum', routesForum)
app.use('/api/v1/review', routesReview)
app.use('/api/v1/wallet', routesWallet)
app.use('/api/v1/support', routesSupportMessage)
app.use('/api/v1/appointment', routesAppointment)
app.use('/api/v1/patientRequests', routesClientRequests)
app.all('*', catchAsync((req, res, next) => next(`Cannot find ${req.originalUrl} on this server.`, 404)))
app.use(globalErrorHandler)

module.exports = { server, io }