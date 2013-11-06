#!/usr/bin/env coffee
http = require 'http'
fs = require 'fs'
Ecstatic = require 'ecstatic'
coffee = require 'coffee-script'
jade = require 'jade'
styl = require 'styl'

module.exports = metaserve = (base_dir) ->
    base_dir = '.' if !base_dir

    # Define the relevant file extensions, what their content-type should be and
    # what their uncompressed versions might look like
    file_types =
        html:
            content_type: 'text/html'
            compilers:
                jade: (file_str) ->
                    jade.compile(file_str, {filename: base_dir})()
        js:
            content_type: 'text/javascript'
            compilers:
                coffee: (file_str) ->
                    coffee.compile(file_str)
        css:
            content_type: 'text/css'
            compilers:
                sass: (file_str) ->
                    styl(file_str, {whitespace: true}).toString()

    ecstatic = Ecstatic base_dir
    return (req, res) ->
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
                        # Read and compile the file
                        file_str = fs.readFileSync(base_dir + filename).toString()
                        compiled_str = compiler(file_str)

                        # Respond with compiled source
                        return res.end compiled_str

        # If all else fails let Ecstatic handle it
        ecstatic(req, res)

# Stand-alone mode
if require.main == module
    argv = require('optimist').argv

    HOST = if argv.host? then argv.host else '0.0.0.0'
    PORT = if argv.port? then argv.port else 8000

    server = http.createServer metaserve()
    server.listen PORT, HOST, -> console.log "metaserving on #{ HOST }:#{ PORT }."
