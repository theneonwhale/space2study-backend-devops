require('module-alias/register')
require('../module-aliases')
require('~/initialization/envSetup')
const express = require('express')
const serverSetup = require('~/initialization/serverSetup')
const logger = require('~/logger/logger')
const cors = require('cors')
const app = express()

const allowedOrigins = ['http://localhost:3001']

if (process.env.CLIENT_URL) {
  allowedOrigins.push(process.env.CLIENT_URL)
}

app.use(cors({
  origin: allowedOrigins,
  credentials: true
}))

const start = async () => {
  try {
    await serverSetup(app)
  } catch (err) {
    logger.error(err)
  }
}

start()
