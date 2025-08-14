const mongoose = require('mongoose')

const {
  config: { MONGODB_URL }
} = require('~/configs/config')
const logger = require('~/logger/logger')

const dropAllCollections = async () => {
  await mongoose.connection.db.dropDatabase()
}

const checkForLocalDB = async () => {
  if (process.env.NODE_ENV === 'test') {
    await dropAllCollections()
  }
}

const databaseInitialization = async () => {
  await mongoose.connect(MONGODB_URL)
  await checkForLocalDB()
  logger.info('Connected to MongoDB.')
}

module.exports = databaseInitialization
