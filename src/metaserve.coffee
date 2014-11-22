#!/usr/bin/env coffee
http = require 'http'
fs = require 'fs'
url = require 'url'
send = require 'send'
coffee = require 'coffee-script'
jade = require 'jade'
styl = require 'styl'
uglify = require 'uglify-js'

# Reduce millisecond resolution to second resolution for last-modified
de_res = (n) -> Math.floor(n/1000)*1000

module.exports = metaserve = (base_dir, opts={}) ->
    base_dir = '.' if !base_dir

    # Define the relevant file extensions, what their content-type should be and
    # what their uncompressed versions might look like
    file_types =
        html:
            content_type: 'text/html'
            compilers:
                jade: (file_str) ->
                    jade.compile(file_str, {filename: base_dir + '/_.jade'})()
        js:
            content_type: 'text/javascript'
            compilers:
                coffee: (file_str) ->
                    coffee.compile(file_str, {bare: true})
            minify: (compiled_str) ->
                uglify.minify(compiled_str, {fromString: true}).code
        css:
            content_type: 'text/css'
            compilers:
                sass: (file_str) ->
                    styl(file_str, {whitespace: true}).toString()

    return (req, res, next) ->
        console.log "[#{ req.method }] #{ req.url }"

        # Translate index request
        if req.url == '/' then req.url = '/index.html'

        # Loop through each of the file types to see if the url matches
        for ext, metadata of file_types
            if matched = req.url.match new RegExp '(.+)\.' + ext

                # If it's a supported file type, loop through relevant extensions
                for uext, compiler of metadata.compilers
                    filename = matched[1] + '.' + uext

                    # If this uncompiled extension version exists, compile
                    if fs.existsSync base_dir + filename
                        file_stats = fs.statSync base_dir + filename

                        # Check for 304
                        if (Date.parse(req.headers['if-modified-since']) >= de_res(file_stats.mtime.getTime()))
                            res.statusCode = 304
                            return res.end()

                        # Read and compile the file
                        file_str = fs.readFileSync(base_dir + filename).toString()
                        compiled_str = compiler(file_str)

                        # Minify if desired
                        if opts.minify && metadata.minify
                            compiled_str = metadata.minify compiled_str

                        # Set necessary headers
                        res.setHeader('last-modified', (new Date(file_stats.mtime)).toUTCString())
                        res.setHeader('cache-control', "max-age=#{ opts.max_age or 3600 }")
                        res.setHeader('content-type', metadata.content_type || 'application/octet-stream')

                        # Respond with compiled source
                        return res.end compiled_str

        # If all else fails just do a fs.readFile
        filepath = base_dir + url.parse(req.url).pathname
        fs.readFile filepath, (err, file) ->
            if err?
                res.writeHead(404, {'Content-Type': 'text/plain'})
                res.end("Error: #{ err }")
            else
                res.end(file)

# Stand-alone mode
if require.main == module
    argv = require('optimist').argv

    HOST = argv.host || '0.0.0.0'
    PORT = argv.port || 8000
    BASE_DIR = argv._[0] || '.'
    console.log BASE_DIR

    server = http.createServer metaserve(BASE_DIR)
    server.listen PORT, HOST, -> console.log "metaserving on #{ HOST }:#{ PORT }."

