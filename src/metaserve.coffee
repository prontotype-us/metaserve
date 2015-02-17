#!/usr/bin/env coffee
fs = require 'fs'
url = require 'url'
_ = require 'underscore'

# Reduce timestamp resolution from ms to s for last-modified
de_res = (n) -> Math.floor(n/1000)*1000

# Default options
VERBOSE = process.env.METASERVE_VERBOSE?
DEFAULT_BASE_DIR = './static'
DEFAULT_COMPILERS = ->
    html: require('metaserve-html-jade')()
    js: require('metaserve-js-coffee')()
    css: require('metaserve-css-styl')()

module.exports = metaserve = (options={}) ->

    # Support both metaserve(base_dir) and metaserve(options) syntax
    if _.isString options
        options = {base_dir: options}

    # Fill in default options
    options.base_dir ||= DEFAULT_BASE_DIR
    options.compilers ||= DEFAULT_COMPILERS()

    return (req, res, next) ->
        file_url = url.parse(req.url).pathname

        # Translate directory requests to index.html requests
        if file_url.slice(-1)[0] == '/' then file_url += 'index.html'
        console.log "[#{ req.method }] #{ file_url }"

        # Loop through each of the file types to see if the url matches
        for url_match, compilers of options.compilers

            # The URL pattern may just be an extension
            if !url_match.match '\/'
                url_match = '\/(.*)\.' + url_match

            # Compilers may be singular or a prioritized array
            compilers = [compilers] if !_.isArray compilers

            # If it's a compileable file type...
            if matched = file_url.match new RegExp url_match

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
                            if !compiler.shouldCompile(filename)(req, res, next)
                                console.log "[metaserve] Skipping compiler for #{ filename }" if VERBOSE
                                continue

                        # Execute the compiler and let it handle the rest
                        console.log "[metaserve] Using compiler for #{ file_url } (#{ filename })" if VERBOSE
                        return compiler.compile(filename)(req, res, next)

                    else
                        console.log "[metaserve] File not found for #{ filename }" if VERBOSE

        # If all else fails just use express's res.sendfile
        filename = options.base_dir + file_url
        if fs.existsSync filename
            console.log '[normalserve] Falling back with ' + filename if VERBOSE
            res.sendfile filename
        else
            res.send 404, '404. Could not find ' + file_url

# Stand-alone mode
if require.main == module
    express = require 'express'
    argv = require('yargs').argv

    HOST = argv.host || process.env.METASERVE_HOST || '0.0.0.0'
    PORT = argv.port || process.env.METASERVE_PORT || 8000
    BASE_DIR = argv['base-dir'] || process.env.METASERVE_BASE_DIR || './static'

    app = express()
    app.use(metaserve(base_dir: BASE_DIR))

    app.listen PORT, HOST, -> console.log "Metaserving on http://#{HOST}:#{PORT}/"

