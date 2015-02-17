express = require 'express'
metaserve = require 'metaserve'

app = express()
app.use(metaserve())

HOST = process.env.METASERVE_HOST || '0.0.0.0'
PORT = process.env.METASERVE_PORT || 8000
app.listen PORT, HOST, -> console.log "Metaserving on http://#{HOST}:#{PORT}/"

