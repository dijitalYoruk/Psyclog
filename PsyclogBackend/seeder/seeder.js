const faker = require('faker')
const dotenv = require('dotenv')
const mongoose = require('mongoose')
const Chat = require('../model/chat')
const User = require('../model/user')
const Wallet = require('../model/wallet')
const Review = require('../model/review')
const Message = require('../model/message')
const Calendar = require('../model/calendar')
const Constants = require('../utils/constants')
const ForumPost = require('../model/forumPost')
const ForumTopic = require('../model/forumTopic')
const PatientNote = require('../model/patientNote')
const Appointment = require('../model/appointment')
const ClientRequest = require('../model/clientRequest')
const { getToday } = require('../utils/util')
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

   const patients = []
   const psychologists = [] 
   const password = '0123456789'
   const passwordConfirm = '0123456789'

   for (let i = 0; i < 100; i++) {

      const username = faker.internet.userName()
      const surname = faker.name.lastName()
      const email = faker.internet.email()
      const name = faker.name.firstName()
       
      if (i % 2 === 0) { // seed Psychologist
         const appointmentPrice = 100
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
         

         // create calendar for the psychologist
         const calendar = new Calendar({ role: data.role})
         data.calendar = calendar._id

         // create wallet for the user
         const wallet = new Wallet({})
         data.wallet = wallet._id

         // creating the psychologist.
         const user = await User.create(data)
         calendar.user = user
         wallet.owner = user
         await calendar.save()
         await wallet.save()
         psychologists.push(user)
      }

      else { // seed Patient
         const role = Constants.ROLE_USER
         const registeredPsychologists = []
         const clientRequests = []
         const cash = 3000

         const duration = Math.floor(Math.random() * 5) - 1
         const banTerminationDate = duration <= 0 ? undefined : 
                  Date.now() + duration * Constants.ONE_DAY

         const data = { 
            username, name, 
            surname, email, 
            clientRequests, 
            role, password, 
            registeredPsychologists,
            banTerminationDate,
            passwordConfirm 
         }
         

         // create calendar for the psychologist
         const calendar = new Calendar({ role: data.role})
         data.calendar = calendar._id

         // create wallet for the user
         const wallet = new Wallet({ cash })
         data.wallet = wallet._id

         // creating the psychologist.
         const user = await User.create(data)
         calendar.user = user
         wallet.owner = user
         await calendar.save()
         await wallet.save()
         patients.push(user)
      }
   }

   const oneDay = 24 * 60 * 60 * 1000
   let appointmentDate = getToday(true) + 5 * oneDay
   const intervals = [ 3, 4, 5 ] 

   for (let i = 0; i < 45; i++) {
      const psychologist = psychologists[i]

      for (let j = i; j < i + 5; j++) {
         if (i % 2 == 0) {
            psychologist.patients.push(patients[i]._id)
            patients[j].registeredPsychologists.push(psychologist)
            patients[j].passwordConfirm = passwordConfirm
            patients[j].password = password
            await patients[j].save()
            await seedReviewsData(patients[j], psychologist)
            
            const price = intervals.length * psychologist.appointmentPrice
            const appointment = { 
               psychologist: psychologist._id, 
               patient: patients[j]._id, 
               intervals, appointmentDate, price }

            await Appointment.create(appointment)
            appointmentDate += oneDay
            
            const chat = await Chat.create({ 
               psychologist: psychologist._id, 
               patient: patients[j]._id, messages: []
            })
            
            let lastMessage 

            for (let k = 0; k < 100; k++) {
               if (Math.random() < 0.5) {
                  lastMessage = await Message.create({ 
                     message: faker.lorem.paragraph(), 
                     author: psychologist._id,  
                     contact: patients[j]._id, 
                     chat: chat._id 
                  })
               } else {
                  lastMessage = await Message.create({ 
                     message: faker.lorem.paragraph(), 
                     contact: psychologist._id,  
                     author: patients[j]._id, 
                     chat: chat._id 
                  })
               }
            }

            chat.lastMessage = lastMessage
            await chat.save()
            
            for (let k = 0; k < 10; k++) {
               await PatientNote.create({
                  psychologist: psychologist._id,
                  patient: patients[j]._id, 
                  content: faker.lorem.paragraph()
               })
            }

         } 
         else {
            await ClientRequest.create({ 
               content: faker.lorem.paragraph(), 
               patient: patients[j]._id, 
               psychologist: psychologist._id 
            })
         }
      }

      psychologist.passwordConfirm = passwordConfirm
      psychologist.password = password
      await psychologist.save()      
   }

   for (let i = 0; i < 50; i++) {
      const title = faker.name.title()
      const description = faker.lorem.paragraph()
      let isAuthorAnonymous = Math.random() < 0.5

      let random = Math.floor(Math.random() * 100)
      let author = await User.findOne()
                               .skip(random)
                               .select('id')

      const topic = await ForumTopic.create({
         title, description, author, isAuthorAnonymous
      })

      const messageCount = Math.floor(Math.random() * 100)

      for (let j = 0; j < messageCount; j ++) {
         const content = faker.lorem.paragraph()
         random = Math.floor(Math.random() * 100)
         isAuthorAnonymous = Math.random() < 0.5
         author = await User.findOne()
                            .skip(random)
                            .select('id')

         const images = []

         if (Math.random() < 0.4) {
            for (let k = 0; k < 3; k++) {
               images.push('https://picsum.photos/200/300')
            }
         }

         await ForumPost.create({
            topic: topic._id, author: author._id, 
            isAuthorAnonymous, content, images
         })
      }
   }

   const username = 'psyclogAdmin'
   const name = 'Fatih'
   const surname = 'Uyanik'
   const email = 'fatihsevban15@gmail.com'
   const role = Constants.ROLE_ADMIN

   const data = { 
      username, name, 
      surname, email, 
      role, password, 
      passwordConfirm,
      isActive:true
   }

   await User.create(data)
}


const seedReviewsData = async (author, psychologist) => {
      const rating = 3
      const title = faker.name.title()
      const content = faker.lorem.paragraph()
      const data = { title, content, rating, author, psychologist }
      await Review.create(data) 
}


connectToDatabase()
   .then(result => {
      return seedUsersData()
   })

   .then(() => {
      console.log('seeded')
   })
   .catch(error => {
      console.error(error)
      process.exit()
   })