// =====================
// imports
// =====================
const express = require('express')
const Constants = require('../utils/constants')
const middlewareAuth = require('../middleware/middlewareAuth')
const middlewareRestrict = require('../middleware/middlewareRestrict')
const routerWallet = express.Router({ mergeParams: true })


// =====================
// methods
// =====================
const { uploadMoney, withdrawMoney, checkBalance } = require('../controller/ControllerWallet')


// =====================
// routes
// =====================
routerWallet.use(middlewareAuth)
routerWallet.post('/upload', middlewareRestrict(Constants.ROLE_USER), uploadMoney)
routerWallet.post('/withdraw', middlewareRestrict(Constants.ROLE_PSYCHOLOGIST, Constants.ROLE_USER), withdrawMoney)
routerWallet.get('/checkBalance', middlewareRestrict(Constants.ROLE_PSYCHOLOGIST, Constants.ROLE_USER), checkBalance)
module.exports = routerWallet