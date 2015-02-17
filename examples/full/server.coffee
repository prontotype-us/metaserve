metaserve = require 'metaserve'
express = require 'express'

app = express()

# A full-featured set of compilers
full_compilers =

    html: [
        require('metaserve-html-mustache')(),
        require('metaserve-html-jade')()
    ]

    css: [
        require('metaserve-bouncer')(ext: 'bounced.css')
        require('metaserve-css-styl')()
    ]

    js: [
        require('metaserve-js-coffee')(),
        require('metaserve-bouncer')(ext: 'bounced.js')
        require('metaserve-js-browserify-coffee-jsx')(ext: 'jsx.coffee')
    ]

app.use app.router # Handle the custom routes
app.use metaserve({compilers: full_compilers}) # Fall back to metaserve

app.get '/dogs', (req, res) ->
    res.end 'woof'

PORT = process.env.METASERVE_PORT || 8000
app.listen(PORT, '0.0.0.0', -> console.log "Metaserving at http://localhost:#{ PORT }/")

