#!/usr/bin/env coffee
fs = require 'fs'
url = require 'url'
util = require 'util'
path = require 'path'

# Reduce timestamp resolution from ms to s for last-modified
de_res = (n) -> Math.floor(n/1000)*1000

# IsA helpers
isArray = (a) -> Array.isArray(a)
isString = (s) -> typeof s == 'string'

# Set unset values of an object from a default object
defaults = (o, d) ->
    o_ = {}
    for k, v of o
        o_[k] = v
    for k, v of d
        o_[k] = v if !o[k]?
    return o_

# Default config

VERBOSE = process.env.METASERVE_VERBOSE?
DEFAULT_STATIC_DIR = '.'
DEFAULT_COMPILERS =
    html: require 'metaserve-html-pug'
    js: require 'metaserve-js-coffee-reactify'
    css: require 'metaserve-css-postcss'

# Middleware for use in Express app

module.exports = metaserve_middleware = (config={}, compilers={}) ->

    # Support both metaserve(static_dir) and metaserve(config) syntax
    if isString config
        config = {static_dir: config}

    # Fill in default config
    compilers = defaults compilers, DEFAULT_COMPILERS
    config.static_dir ||= DEFAULT_STATIC_DIR

    return (req, res, next) ->
        file_path = url.parse(req.url).pathname

        # Translate directory requests to index.html requests
        if file_path.slice(-1)[0] == '/' then file_path += 'index.html'

        metaserve_compile compilers, file_path, config, {req}, (err, response) ->
            if err
                res.send 500, err

            else if typeof response == 'string'
                if file_path.endsWith '.js'
                    res.setHeader 'Content-Type', 'application/javascript'
                else if file_path.endsWith '.css'
                    res.setHeader 'Content-Type', 'text/css'
                else if file_path.endsWith '.html'
                    res.setHeader 'Content-Type', 'text/html'
                res.end response

            else if response?.compiled
                if response.content_type
                    res.setHeader 'Content-Type', response.content_type
                res.end response.compiled

            else
                # If all else fails just use express's res.sendFile
                filename = config.static_dir + file_path
                if fs.existsSync filename
                    console.log '[normalserve] Falling back with ' + filename if VERBOSE
                    res.sendFile filename, {root: process.cwd()}
                else
                    console.log '[normalserve] Could not find ' + filename if VERBOSE
                    next()

# Compiling a given a set of compilers, file, and config

metaserve_compile = (all_compilers, file_path, config, context, cb) ->
    console.log '[metaserve_compile] file_path=', file_path, 'config=', config if VERBOSE

    # Loop through each of the file types to see if the url matches
    for path_match, compilers of all_compilers

        if path_match == '*'
            path_match = '.*'

        # The URL pattern may just be an extension
        else if !path_match.match('\/')
            path_match = '\/(.*)\.' + path_match
        path_match = new RegExp path_match

        # Compilers may be singular or a prioritized array
        compilers = [compilers] if !isArray compilers
        compilers = compilers.filter (c) -> c? # Filter out non-compilers

        # If it's a compileable file type...
        if matched = file_path.match path_match

            # Loop through the sources
            for compiler in compilers

                # Build the corresponding source file's filename
                ext = compiler.ext
                static_dir = config.static_dir or '.'
                filename_stem = matched[1]

                # If ext is "+something", add onto the path
                if ext[0] == '+'
                    filename = path.join static_dir, file_path + '.' + ext.slice(1)

                # Otherwise replace existing extension
                else
                    filename = path.join static_dir, filename_stem + '.' + ext

                # Try finding and compiling the source file
                if fs.existsSync filename

                    # Set up config to pass to compiler
                    compiler_config = defaults config[ext] or {}, compiler.default_config
                    compiler_config.bouncing = config.bouncing
                    compiler_config.static_dir = static_dir

                    compiler_context = Object.assign {}, config.globals, context

                    if compiler.shouldCompile?
                        if !compiler.shouldCompile(filename, compiler_config, compiler_context)
                            console.log "[metaserve] Skipping compiler for #{filename}" if VERBOSE
                            continue

                    # Execute the compiler and let it handle the rest
                    console.log "[metaserve] Using compiler for #{file_path} (#{filename})" if VERBOSE
                    return compiler.compile filename, compiler_config, compiler_context, cb

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
    STATIC_DIR = argv['static-dir'] || process.env.METASERVE_STATIC_DIR || '.'

    # Use a specific config or config.json
    CONFIG_FILE = argv.c || argv.config
    IS_SPECIFIC_CONFIG = CONFIG_FILE?
    CONFIG_FILE ||= 'config.json'

    try
        config = JSON.parse fs.readFileSync CONFIG_FILE, 'utf8'
        console.log "Using config:", util.inspect(config, {depth: null, colors: true}) if VERBOSE
    catch e
        if IS_SPECIFIC_CONFIG # Only error if specific config fails
            console.log "Could not read config: #{CONFIG_FILE}"
            process.exit 1
        else
            config = {}

    config.static_dir ||= STATIC_DIR

    HTML_COMPILER = argv.html || 'pug'
    JS_COMPILER = argv.js || 'coffee-reactify'
    CSS_COMPILER = argv.css || 'postcss'

    compilers =
        html: require "metaserve-html-#{HTML_COMPILER}"
        js: require "metaserve-js-#{JS_COMPILER}"
        css: require "metaserve-css-#{CSS_COMPILER}"

    # Bounce the file_path passed with the --bounce flag

    if file_path = argv.bounce
        if !file_path.startsWith '/'
            file_path = '/' + file_path

        config.bouncing = true

        metaserve_compile compilers, file_path, config, {}, (err, response) ->
            if response?.compiled?
                if typeof argv.out == 'boolean' # No output filename, just print it
                    console.log response.compiled
                else
                    bounced_filename = argv.out or path.join config.static_dir, file_path + '.bounced'
                    fs.writeFileSync bounced_filename, response.compiled
                    console.log "[metaserve] Bounced to #{bounced_filename}"

            else if err?
                console.log "[metaserve] Bouncing failed", err

            else
                console.log "[metaserve] Bouncing failed, make sure path #{file_path} exists"

    else
        app = express()
        app.use (req, res, next) ->
            console.log "[#{req.method}] #{req.path}"
            next()
        app.use(metaserve_middleware(config, compilers))
        app.listen PORT, HOST, -> console.log "Metaserving on http://#{HOST}:#{PORT}/"

