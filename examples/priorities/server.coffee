express = require 'express'
metaserve = require 'metaserve'

# Use two compilers, one for mustache and one for jade
compilers =

    '\/(.*)\.html': [
        require('metaserve/src/compilers/html/mustache')(base_dir: '.'),
        require('metaserve/src/compilers/html/jade')(base_dir: '.')
    ]

app = express()
    .use(metaserve({base_dir: '.', compilers}))

PORT = process.env.METASERVE_PORT || 8000
app.listen(PORT, '0.0.0.0', -> console.log "Metaserving at http://localhost:#{ PORT }/")

