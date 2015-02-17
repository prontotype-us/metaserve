express = require 'express'
metaserve = require 'metaserve'

# Use two compilers, one for mustache and one for jade
prioritized_compilers =

    html: [
        require('metaserve-html-mustache')(base_dir: '.'),
        require('metaserve-html-jade')(base_dir: '.')
    ]

app = express()
    .use(metaserve({base_dir: '.', compilers: prioritized_compilers}))

HOST = process.env.METASERVE_HOST || '0.0.0.0'
PORT = process.env.METASERVE_PORT || 8000
app.listen PORT, HOST, -> console.log "Metaserving on http://#{HOST}:#{PORT}/"

