require('module-alias/register')
require('../module-aliases')
require('~/initialization/envSetup')
const express = require('express')
const serverSetup = require('~/initialization/serverSetup')
const logger = require('~/logger/logger')
const cors = require('cors')
const app = express()

app.use(cors({
  origin: [
    'http://localhost:3001',
    'http://192.168.0.108:3001',
    'http://frontend:3000'
  ],
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
