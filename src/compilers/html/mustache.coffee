fs = require 'fs'
mustache = require 'mustache'
Compiler = require 'metaserve/src/compiler'

# TODO: Pass something other than req.query to populate the template
class MustacheCompiler extends Compiler

    options:
        base_dir: './views'
        ext: 'mustache'

    compile: (mustache_filename) ->
        return (req, res, next) ->
            fs.readFile mustache_filename, (err, file) ->
                res.setHeader 'Content-Type', 'text/html'
                res.end mustache.render(file.toString(), req.query)

module.exports = (options={}) -> new MustacheCompiler().set(options)

