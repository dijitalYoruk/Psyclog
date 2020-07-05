const ClientRequest = require('../model/clientRequest')
const Constants = require('../constants')
const Review = require('../model/review')
const User = require('../model/user')
const mongoose = require('mongoose')
const dotenv = require('dotenv')
const faker = require('faker')
dotenv.config({ path: './config.env' })

// ============================
// DATABASE CONNECTION
// ============================

const connectToDatabase = async () => {
   await mongoose.connect(process.env.DATA_BASE_CONNECTION, {
      useNewUrlParser: true,
      useCreateIndex: true,
      useFindAndModify: false,
      useUnifiedTopology: true
   })
   console.log('DB connection successful')
}  

// ============================
// USER SEEDING
// ============================

const seedUsersData = async () => {
   for (let i = 0; i < 300; i++) {

      const username = faker.internet.userName()
      const surname = faker.name.lastName()
      const email = faker.internet.email()
      const name = faker.name.firstName()
      const password = 'naruto1212'
      const passwordConfirm = 'naruto1212'
       
      if (i % 2 === 0) {
         const appointmentPrice = faker.random.number()
         const biography = faker.lorem.paragraph()
         const profileImage = faker.image.imageUrl()
         const role = Constants.ROLE_PSYCHOLOGIST
         const isActiveForClientRequest = true
         const isPsychologistVerified = true
         const transcript = 'transcript'
         const clientRequests = []
         const patients = []
         const cv = 'cv'
         
         const data = { 
            username, name, 
            surname, email, 
            password, role, 
            passwordConfirm, 
            transcript, cv, 
            appointmentPrice,
            biography, patients, 
            profileImage, clientRequests, 
            isPsychologistVerified, 
            isActiveForClientRequest 
         }
         
         await User.create(data)
      }

      else {
         const cash = faker.random.number()
         const role = Constants.ROLE_USER
         const registeredPsychologists = []
         const clientRequests = []

         const data = { 
            username, name, 
            surname, email, 
            cash, clientRequests, 
            role, password, 
            registeredPsychologists,
            passwordConfirm 
         }
         
         await User.create(data)
      }
   }

   const email = 'fatihsevan15@gmail.com'
   const passwordConfirm = 'naruto1212'
   const role = Constants.ROLE_ADMIN
   const password = 'naruto1212'
   const name = 'fatih sevban'
   const username = 'fatih15'
   const surname = 'uyanik'
   
   const data = { 
      username, name, 
      surname, email, 
      role, password, 
      passwordConfirm 
   }

   await User.create(data)
}

const seedRequestsData = async () => {
   for (let i = 0; i < 20; i++) {
      const random = Math.floor(Math.random() * 10)
      const psychologist = await User.findOne({ role: Constants.ROLE_PSYCHOLOGIST })
      const patient = await User.findOne({ role: Constants.ROLE_USER }).skip
      const content = faker.lorem.paragraph()
      const data = { content, patient, psychologist }
      await ClientRequest.create(data)
   }
} 

const seedReviewsData = async () => {
   for (let i = 0; i < 100; i++) {
      const rating = 3
      const title = faker.name.title()
      const content = faker.lorem.paragraph()
      const random = Math.floor(Math.random() * 20)
      const author = await User.findOne({ role: Constants.ROLE_USER }).skip(random)
      const psychologist = await User.findOne({ role: Constants.ROLE_PSYCHOLOGIST }).skip(random)
      const data = { title, content, rating, author, psychologist }
      await Review.create(data)
   }
}

connectToDatabase()
   .then(result => {
      seedUsersData()
      seedReviewsData()
      seedRequestsData()
   }).catch(error => {
      console.error(error)
      process.exit()
   })