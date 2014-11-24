fs = require 'fs'
browserify = require 'browserify'
coffee_reactify = require 'coffee-reactify'
React = require 'react'
require('node-cjsx').transform()
Compiler = require 'metaserve/src/compiler'

class CoffeeJSXCompiler extends Compiler

    default_options:
        base_dir: './static/js'
        ext: 'coffee'
        browserify_options:
            extensions: ['.coffee']

    compile: (coffee_filename) ->
        options = @options
        return (req, res, next) ->
            try
                console.log '[coffee/JSX Compiler] Going to compile ' + coffee_filename
                bundler = browserify(options.browserify_options)
                bundler.transform coffee_reactify
                bundler.add(coffee_filename).bundle().pipe(res)
            catch e
                console.log '[coffee/JSX Compiler] ERROR ' + e
                res.send 500, e.toString()

module.exports = (options={}) -> new CoffeeJSXCompiler(options)

