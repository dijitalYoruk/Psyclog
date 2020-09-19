const Wallet = require('../model/wallet')
const { catchAsync } = require('../utils/ErrorHandling')

const uploadMoney = catchAsync(async (req, res, next) => {
    // get required data.
    const user = req.currentUser
    let { uploadedAmount, creditCardName, creditCardCVC,
        creditCardNumber, creditCardExpMonth, creditCardExpYear } = req.body
    
    // check withdraw amount
    if (uploadedAmount <= 0) {
        return next(new ApiError('Invalid Withdrawal'))
    }

    const wallet = await Wallet.findById(user.wallet)
    // TODO Here, the payment needs to be handled with 
    // Stripe to an intermediate account.
    wallet.cash += uploadedAmount

    // update wallet
    await wallet.save()
    
    res.status(200).json({
        status: 200,
        data: { 
            message: __('success_change', 'Wallet')
        } 
    })
})

const withdrawMoney = catchAsync(async (req, res, next) => {
    // get required data.
    const user = req.currentUser
    let { withdrawAmount, creditCardName, creditCardCVC,
          creditCardNumber, creditCardExpMonth, creditCardExpYear } = req.body
    const wallet = await Wallet.findById(user.wallet)
    
    // check withdraw amount
    if (withdrawAmount > wallet.cash || withdrawAmount <= 0) {
        return next(new ApiError('Invalid Withdrawal'))
    }

    // TODO Here, the payment needs to be handled with 
    // Stripe to an intermediate account.
    wallet.cash -= withdrawAmount

    // update wallet
    await wallet.save()
    
    res.status(200).json({
        status: 200,
        data: { 
            message: __('success_change', 'Wallet')
        } 
    })
})

module.exports = {
    uploadMoney,
    withdrawMoney
}