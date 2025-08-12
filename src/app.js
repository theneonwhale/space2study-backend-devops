require('module-alias/register')
require('../module-aliases')
require('~/initialization/envSetup')
const express = require('express')
const serverSetup = require('~/initialization/serverSetup')
const logger = require('~/logger/logger')
const cors = require('cors')
const app = express()

// Get allowed origins from environment variables
const allowedOrigins = [
  'http://localhost:3001',
  'http://192.168.0.108:3001',
  'http://frontend:3000'
]

// Add CLIENT_URL from environment if it exists (for production)
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
