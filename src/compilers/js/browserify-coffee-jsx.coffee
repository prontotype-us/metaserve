fs = require 'fs'
browserify = require 'browserify'
coffee_reactify = require 'coffee-reactify'
browserify_shim = require 'browserify-shim'
{BrowserifyCompiler} = require 'metaserve/src/compilers/js/browserify'
require('node-cjsx').transform()

class BrowserifyCoffeeJSXCompiler extends BrowserifyCompiler

    default_options:
        base_dir: './static/js'
        ext: 'coffee'
        browserify:
            extensions: ['.coffee']

    beforeBundle: (bundler) ->
        bundler
            .transform(coffee_reactify)
            .transform(browserify_shim)

module.exports = (options={}) -> new BrowserifyCoffeeJSXCompiler(options)

