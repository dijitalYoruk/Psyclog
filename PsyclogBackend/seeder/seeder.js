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

const seedUsersData = () => {
   for (let i = 0; i < 100; i++) {
      const username = faker.internet.userName()
      const surname = faker.name.lastName()
      const email = faker.internet.email()
      const name = faker.name.firstName()
      const cash = faker.random.number()
      const role = 'user'
      User.create({username, surname, email, name, cash, role})
   }
}

connectToDatabase()
   .then(result => {
      seedUsersData()
   }).catch(error => {
      console.error(error)
      process.exit()
   })