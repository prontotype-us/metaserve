fs = require 'fs'
jade = require 'jade'
Compiler = require 'metaserve/src/compiler'

class JadeCompiler extends Compiler

    options:
        base_dir: './views'
        ext: 'jade'

    compile: (jade_filename) ->
        options = @options
        return (req, res, next) ->
            fs.readFile jade_filename, (err, file_str) ->
                res.setHeader 'Content-Type', 'text/html'
                res.end jade.compile(file_str, {filename: options.base_dir + '/_.jade'})()

module.exports = (options={}) -> new JadeCompiler().set(options)

