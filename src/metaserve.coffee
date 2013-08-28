#!/usr/bin/env coffee
http = require 'http'
fs = require 'fs'
Ecstatic = require 'ecstatic'
coffee = require 'coffee-script'
jade = require 'jade'
styl = require 'styl'
argv = require('optimist').argv

HOST = if argv.host? then argv.host else '0.0.0.0'
PORT = if argv.port? then argv.port else 8000

module.exports = metaserve = (base_dir) ->
    base_dir = '.' if !base_dir
    ecstatic = Ecstatic base_dir
    return (req, res) ->
        if req.url == '/'
            req.url = '/index.html'
        if matched = req.url.match /(.+)\.html/
            res.setHeader 'Content-Type', 'text/html'
            filename = matched[1] + '.jade'
            if fs.existsSync base_dir + filename
                return res.end jade.compile(fs.readFileSync(base_dir + filename).toString(), {filename: base_dir})()
        else if matched = req.url.match /(.+)\.js/
            filename = matched[1] + '.coffee'
            if fs.existsSync base_dir + filename
                return res.end coffee.compile(fs.readFileSync(base_dir + filename).toString())
        else if matched = req.url.match /(.+)\.css/
            filename = matched[1] + '.sass'
            if fs.existsSync base_dir + filename
                return res.end styl(fs.readFileSync(base_dir + filename).toString(), {whitespace: true}).toString()
        # Fallback to real static files with Ecstatic
        ecstatic(req, res)

if require.main == module
    server = http.createServer metaserve()
    server.listen PORT, HOST, -> console.log "metaserving on #{ HOST }:#{ PORT }."
