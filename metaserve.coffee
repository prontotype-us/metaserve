#!/usr/bin/env coffee
http = require 'http'
fs = require 'fs'
ecstatic = require('ecstatic')('./')
coffee = require 'coffee-script'
jade = require 'jade'
styl = require 'styl'
argv = require('optimist').argv

HOST = if argv.host? then argv.host else '0.0.0.0'
PORT = if argv.port? then argv.port else 8000

server = http.createServer (req, res) ->
    console.log "Serving #{ req.url }"
    if req.url == '/'
        req.url = '/index.html'
    if matched = req.url.match /^\/([^.\/]+)(.html)?$/
        res.setHeader 'Content-Type', 'text/html'
        filename = matched[1] + '.jade'
        if fs.existsSync filename
            return res.end jade.compile(fs.readFileSync(filename).toString(), {filename: '.'})()
    else if matched = req.url.match /(\w+).js/
        filename = matched[1] + '.coffee'
        if fs.existsSync filename
            return res.end coffee.compile(fs.readFileSync(filename).toString())
    else if matched = req.url.match /([\w\/]+).css/
        filename = matched[1] + '.sass'
        console.log '.' + filename
        if fs.existsSync '.' + filename
            return res.end styl(fs.readFileSync('.' + filename).toString(), {whitespace: true}).toString()
    console.log "Falling back to ecstatic."
    ecstatic(req, res)

server.listen PORT, HOST, -> console.log "metaserving on #{ HOST }:#{ PORT }."
