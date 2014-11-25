fs = require 'fs'
browserify = require 'browserify'
React = require 'react'
Compiler = require 'metaserve/src/compiler'

class BrowserifyCompiler extends Compiler

    default_options:
        base_dir: './static/js'
        ext: 'js'

    compile: (coffee_filename) ->
        options = @options
        return (req, res, next) =>

            try
                console.log '[Browserify compiler] Going to compile ' + coffee_filename
                bundler = browserify(options.browserify)
                @beforeBundle? bundler
                bundler.add(coffee_filename).bundle().pipe(res)

            catch e
                console.log '[Browserify compiler] ERROR ' + e
                res.send 500, e.toString()

module.exports = (options={}) -> new BrowserifyCompiler(options)
module.exports.BrowserifyCompiler = BrowserifyCompiler

