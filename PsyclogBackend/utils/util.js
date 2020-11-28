const Constants = require('./constants')

const retrieveJWTtoken = req => {
   let token;
   if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
      token = req.headers.authorization.split(' ')[1]
   }
   return token 
}

const isMatching = (obj1, obj2) => {
   return obj1.toString() === obj2.toString()
} 

const filterObject = (obj, ...allowedFields) => {
   const newObj = {}

   Object.keys(obj).forEach(el => {
     if (allowedFields.includes(el)) newObj[el] = obj[el];
   })
   
   return newObj
}

const getToday = isParsed => {
   let now = new Date()
   const date = now.toISOString().split('T')[0]
   let today = new Date(date) 
   if (isParsed) today = Date.parse(today) 
   return today
}

const constructStartDate = (date, timeSlotIndex) => {

   const dateISO = date.toISOString().split('T')[0]
   const timeSlot = Constants.VALID_TIME_INTERVALS[timeSlotIndex]
   const startTime = new Date(`${dateISO}T${timeSlot.startTime}`)

   return Date.parse(startTime)
}

const constructEndDate = (date, timeSlotIndex) => {
   const dateISO = date.toISOString().split('T')[0]
   const timeSlot = Constants.VALID_TIME_INTERVALS[timeSlotIndex]
   const endTime = new Date(`${dateISO}T${timeSlot.endTime}`)

   return Date.parse(endTime)
}

module.exports = { constructStartDate, 
                   constructEndDate,
                   retrieveJWTtoken, 
                   filterObject, 
                   isMatching, 
                   getToday }