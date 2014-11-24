metaserve = require('metaserve')
express = require('express')

app = express()

# A full-featured set of compilers
full_compilers =

    '(.*)\.html': [
        require('metaserve/src/compilers/html/mustache')(),
        require('metaserve/src/compilers/html/jade')()
    ]

    'css\/(.*)\.css': [
        require('metaserve/src/compilers/raw/bouncer')(base_dir: './static/css', ext: 'bounced.css')
        require('metaserve/src/compilers/css/styl')()
    ]

    'js\/(.*)\.js': [
        require('metaserve/src/compilers/js/coffee')(),
        require('metaserve/src/compilers/raw/bouncer')(base_dir: './static/js', ext: 'bounced.js')
        require('metaserve/src/compilers/js/browserify-coffee-jsx')(ext: 'jsx.coffee')
    ]

app.use app.router # Handle the custom routes
app.use metaserve({compilers: full_compilers}) # Fall back to metaserve

app.get '/dogs', (req, res) ->
    res.end 'woof'

PORT = process.env.METASERVE_PORT || 8000
app.listen(PORT, '0.0.0.0', -> console.log "Metaserving at http://localhost:#{ PORT }/")

