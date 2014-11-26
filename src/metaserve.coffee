#!/usr/bin/env coffee
fs = require 'fs'
url = require 'url'
coffee = require 'coffee-script'
jade = require 'jade'
uglify = require 'uglify-js'
_ = require 'underscore'

# Reduce timestamp resolution from ms to s for last-modified
de_res = (n) -> Math.floor(n/1000)*1000

# Default options

DEFAULT_BASE_DIR = './static'
DEFAULT_COMPILERS = ->

    '\/(.*)\.html': require('./compilers/html/jade')()
    '\/js\/(.*)\.js': require('./compilers/js/coffee')()
    '\/css\/(.*)\.css': require('./compilers/css/styl')()

module.exports = metaserve = (options={}) ->

    # Support both metaserve(base_dir) and metaserve(options) syntax
    if _.isString options
        options = {base_dir: options}

    options.base_dir ||= DEFAULT_BASE_DIR
    options.compilers ||= DEFAULT_COMPILERS()

    return (req, res, next) ->
        file_url = url.parse(req.url).pathname

        # Translate index request
        if file_url.slice(-1)[0] == '/' then file_url += 'index.html'
        console.log "[#{ req.method }] #{ file_url }"

        # Loop through each of the file types to see if the url matches
        for url_match, compilers of options.compilers
            if !_.isArray compilers
                compilers = [compilers]

            # If it's a compileable file type...
            if matched = file_url.match new RegExp url_match

                # Loop through the sources
                for compiler in compilers

                    {base_dir, ext} = compiler.options
                    filename_stem = matched[1]
                    filename = base_dir + '/' + filename_stem + '.' + ext

                    # To find and compile a matching source file
                    if fs.existsSync filename
                        if compiler.shouldCompile?
                            if !compiler.shouldCompile(filename)(req, res, next)
                                #console.log "[metaserve] Skipping compiler for #{ filename }"
                                continue

                        console.log "[metaserve] Using compiler for #{ file_url } (#{ filename })"
                        return compiler.compile(filename)(req, res, next)

                    else
                        #console.log "[metaserve] File not found for #{ filename }"

        # If all else fails just use express's res.sendfile
        filename = options.base_dir + file_url
        #console.log '[normalserve] falling back with ' + filename
        if fs.existsSync filename
            res.sendfile filename
        else
            res.send 404, '404, for the file seems absent.'

# Stand-alone mode
if require.main == module
    express = require 'express'
    argv = require('yargs').argv

    HOST = argv.host || '0.0.0.0'
    PORT = argv.port || 8000
    BASE_DIR = argv._[0] || './static'

    options = base_dir: BASE_DIR

    server = express()
        .use(metaserve(options))

    server.listen PORT, HOST, -> console.log "metaserving on #{ HOST }:#{ PORT }..."

