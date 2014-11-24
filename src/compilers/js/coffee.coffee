fs = require 'fs'
coffee = require 'coffee-script'
Compiler = require 'metaserve/src/compiler'

class CoffeeScriptCompiler extends Compiler

    default_options:
        base_dir: './static/js'
        ext: 'coffee'
        coffee_options:
            bare: true

    compile: (coffee_filename) ->
        options = @options
        return (req, res, next) ->
            console.log '[Coffee compiler] Trying to compile ' + coffee_filename
            file_str = fs.readFileSync(coffee_filename).toString()
            res.setHeader 'Content-Type', 'text/javascript'
            res.end coffee.compile(file_str, options.coffee_options)

module.exports = (options={}) -> new CoffeeScriptCompiler(options)

# TODO: Minification option
# uglify = require 'uglify-js'
# uglify.minify(compiled_str, {fromString: true}).code

