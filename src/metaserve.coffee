#!/usr/bin/env coffee
fs = require 'fs'
url = require 'url'
util = require 'util'

# Reduce timestamp resolution from ms to s for last-modified
de_res = (n) -> Math.floor(n/1000)*1000

# IsA helpers
isArray = (a) -> Array.isArray(a)
isString = (s) -> typeof s == 'string'

bouncedExtension = (filename) ->
    parts = filename.split('.')
    parts.splice(-1, 0, 'bounced')
    parts.join('.')

# Default options
VERBOSE = process.env.METASERVE_VERBOSE?
DEFAULT_BASE_DIR = './static'
DEFAULT_COMPILERS = ->
    html: require('metaserve-html-jade')()
    js: require('metaserve-js-coffee-reactify')()
    css: require('metaserve-css-styl')()

module.exports = metaserve = (options={}) ->

    # Support both metaserve(base_dir) and metaserve(options) syntax
    if isString options
        options = {base_dir: options}

    # Fill in default options
    options.base_dir ||= DEFAULT_BASE_DIR
    options.compilers ||= DEFAULT_COMPILERS()

    return (req, res, next) ->
        file_url = url.parse(req.url).pathname

        # Translate directory requests to index.html requests
        if file_url.slice(-1)[0] == '/' then file_url += 'index.html'

        metaserve_compile file_url, options, (err, response) ->
            if err
                res.send 500, err

            else if typeof response == 'string'
                if file_url.endsWith '.js' then res.setHeader 'Content-Type', 'text/javascript'
                if file_url.endsWith '.css' then res.setHeader 'Content-Type', 'text/css'
                res.end response

            else if response?.compiled
                if response.content_type
                    res.setHeader 'Content-Type', response.content_type
                res.end response.compiled

            else
                # If all else fails just use express's res.sendfile
                filename = options.base_dir + file_url
                if fs.existsSync filename
                    console.log '[normalserve] Falling back with ' + filename if VERBOSE
                    res.sendfile filename
                else
                    console.log '[normalserve] Could not find ' + filename if VERBOSE
                    next()

metaserve_compile = (file_url, options, cb) ->

    # Loop through each of the file types to see if the url matches
    for url_match, compilers of options.compilers

        # The URL pattern may just be an extension
        if !url_match.match '\/'
            url_match = '\/(.*)\.' + url_match
        url_match = new RegExp url_match

        # Compilers may be singular or a prioritized array
        compilers = [compilers] if !isArray compilers
        compilers = compilers.filter (c) -> c? # Filter out non-compilers

        # If it's a compileable file type...
        if matched = file_url.match url_match

            # Loop through the sources
            for compiler in compilers

                # Build the corresponding source file's filename
                {base_dir, ext} = compiler.options
                base_dir ||= options.base_dir
                filename_stem = matched[1]
                filename = base_dir + '/' + filename_stem + '.' + ext

                # Try finding and compiling the source file
                if fs.existsSync filename
                    if compiler.shouldCompile?
                        if !compiler.shouldCompile(filename)
                            console.log "[metaserve] Skipping compiler for #{filename}" if VERBOSE
                            continue

                    # Execute the compiler and let it handle the rest
                    console.log "[metaserve] Using compiler for #{file_url} (#{filename})" if VERBOSE
                    return compiler.compile filename, cb

                else
                    console.log "[metaserve] File not found for #{filename}" if VERBOSE

    # Fallback if nothing matched
    cb null

# Stand-alone mode
if require.main == module
    express = require 'express'
    argv = require('minimist')(process.argv)

    HOST = argv.host || process.env.METASERVE_HOST || '0.0.0.0'
    PORT = argv.port || process.env.METASERVE_PORT || 8000
    CONFIG_FILE = argv.c || argv.config || './config.json'
    BASE_DIR = argv['base-dir'] || process.env.METASERVE_BASE_DIR || './static'

    HTML_COMPILER = argv.html || 'jade'
    JS_COMPILER = argv.js || 'coffee-reactify'
    CSS_COMPILER = argv.css || 'styl'

    try
        config = JSON.parse fs.readFileSync CONFIG_FILE, 'utf8'
        console.log "Using config:", util.inspect(config, {depth: null, colors: true})
    catch e
        config = {}

    compilers =
        html: require("metaserve-html-#{HTML_COMPILER}")(config.html)
        js: require("metaserve-js-#{JS_COMPILER}")(config.js)
        css: require("metaserve-css-#{CSS_COMPILER}")(config.css)

    options = {base_dir: BASE_DIR, compilers}

    if filename = argv.bounce
        console.log "[metaserve] Bouncing #{filename} ..."
        metaserve_compile filename, options, (err, response) ->
            if response?.compiled?
                bounced_filename = bouncedExtension filename
                fs.writeFileSync BASE_DIR + bounced_filename, response.compiled
                console.log "[metaserve] Wrote to #{bounced_filename}"

            else if err?
                console.log "[metaserve] Bouncing failed", err

            else
                console.log "[metaserve] Bouncing failed, make sure .#{filename} exists"

    else
        app = express()
        app.use(metaserve(options))
        app.get '/', (req, res) -> res.render 'index'
        app.listen PORT, HOST, -> console.log "Metaserving on http://#{HOST}:#{PORT}/"

