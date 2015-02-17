express = require 'express'
metaserve = require '/home/sean/Projects/metaserve/src/metaserve'

app = express()
app.use(metaserve())

app.listen 8000, -> console.log "listening at http://localhost:8000/"

