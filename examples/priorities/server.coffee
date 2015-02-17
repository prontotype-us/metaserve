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

PORT = process.env.METASERVE_PORT || 8000
app.listen(PORT, '0.0.0.0', -> console.log "Metaserving at http://localhost:#{ PORT }/")

