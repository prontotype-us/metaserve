http = require 'http'
fs = require 'fs'
ecstatic = require('ecstatic')(__dirname + '/static')
coffee = require 'coffee-script'
jade = require 'jade'
styl = require 'styl'

server = http.createServer (req, res) ->
    console.log "Serving #{ req.url }"
    if matched = req.url.match /^\/([^.\/]+)(.html)?$/
        res.setHeader 'Content-Type', 'text/html'
        filename = matched[1] + '.jade'
        return res.end() if not fs.existsSync filename
        res.end jade.compile(fs.readFileSync(filename).toString())()
    else if matched = req.url.match /(\w+).js/
        res.end coffee.compile(fs.readFileSync(matched[1] + '.coffee').toString())
    else if matched = req.url.match /(\w+).css/
        res.end styl(fs.readFileSync(matched[1] + '.sass').toString(), {whitespace: true}).toString()
    else
        ecstatic(req, res)

server.listen 8000, '0.0.0.0', -> console.log 'HTTP server listening.'
