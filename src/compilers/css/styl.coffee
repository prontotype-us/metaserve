fs = require 'fs'
styl = require 'styl'
rework_color = require 'rework-color-function'
rework_colors = require 'rework-plugin-colors'
rework_variant = require 'rework-variant'
rework_shade = require 'rework-shade'
rework_import = require 'rework-import'
Compiler = require 'metaserve/src/compiler'

# Reduce timestamp resolution from ms to s for last-modified
de_res = (n) -> Math.floor(n/1000)*1000

class StylCompiler extends Compiler

    default_options:
        base_dir: './static/css'
        ext: 'sass'
        vars: {}

    compile: (sass_filename) ->
        options = @options
        return (req, res, next) ->

            variant = rework_variant(options.vars)
            pre_transformer = (sass_src) ->
                styl(sass_src, {whitespace: true})
                    .use(rework_import({path: options.base_dir, transform: pre_transformer}))
                    .toString()

            transformer = (sass_src) ->
                styl(pre_transformer(sass_src))
                    .use(variant) # For variable replacement
                    .use(rework_colors()) # rgba(#xxx, 0.x) transformers
                    .use(rework_color) # color tint functions
                    .toString()

            # Read and compile source
            sass_src = fs.readFileSync(sass_filename).toString()
            compiled = transformer sass_src

            res.setHeader 'Content-Type', 'text/css'
            res.end compiled

module.exports = (options={}) ->
    new StylCompiler(options)

