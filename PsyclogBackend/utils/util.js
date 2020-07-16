const retrieveJWTtoken = req => {
   let token;
   if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
      token = req.headers.authorization.split(' ')[1]
   }
   return token 
}

const isMatching = (obj1, obj2) => {
   console.log('----------------------')
   console.log(obj1)
   console.log(obj2)
   console.log('----------------------')
   return obj1.toString() === obj2.toString()
} 

const filterObject = (obj, ...allowedFields) => {
   const newObj = {}

   Object.keys(obj).forEach(el => {
     if (allowedFields.includes(el)) newObj[el] = obj[el];
   })
   
   return newObj
}

module.exports = { retrieveJWTtoken, filterObject, isMatching }