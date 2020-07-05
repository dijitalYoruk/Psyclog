const express = require('express')
const morgan = require('morgan')
const app = express()
const routesUser = require('./routes/routesUser')
const routesAuth = require('./routes/routesAuth')
const routesReview = require('./routes/routesReview')
const routesClientRequests = require('./routes/routesClientRequests')
const {globalErrorHandler} = require('./utils/ErrorHandling')
const helmet = require('helmet');
const mongoSanitize = require('express-mongo-sanitize');
const xss = require('xss-clean');
const hpp = require('hpp');
const { catchAsync } = require('./utils/ErrorHandling')


app.use(helmet()) // Set security HTTP headers
app.use(mongoSanitize()) // Data sanitization against NoSQL query injection
app.use(xss()) // Data sanitization against XSS
app.use(hpp()) // Prevent parameter pollution
app.use(express.json({ limit: '10kb' }))
app.use(express.static('public'))

if (process.env.NODE_ENV == 'development') {
   app.use(morgan('dev'))
}

app.use('/api/v1/user', routesUser)
app.use('/api/v1/auth', routesAuth)
app.use('/api/v1/clientRequests', routesClientRequests)
app.use('/api/v1/user/:userId', routesReview)
app.all('*', catchAsync((req, res, next) => next(`Cannot find ${req.originalUrl} on this server.`, 404 )))

app.use(globalErrorHandler)

module.exports = app