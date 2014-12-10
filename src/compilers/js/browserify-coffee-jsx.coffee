fs = require 'fs'
browserify = require 'browserify'
coffee_reactify = require 'coffee-reactify'
{BrowserifyCompiler} = require 'metaserve/src/compilers/js/browserify'
require('node-cjsx').transform()

class BrowserifyCoffeeJSXCompiler extends BrowserifyCompiler

    default_options:
        base_dir: './static/js'
        ext: 'coffee'
        browserify:
            extensions: ['.coffee']
        browserify_shim: false

    beforeBundle: (bundler) ->
        bundler = bundler.transform(coffee_reactify)
        if @options.browserify_shim
            bundler = bundler.transform require 'browserify-shim'
        bundler = bundler.transform {global: true}, 'uglifyify'
        return bundler

module.exports = (options={}) -> new BrowserifyCoffeeJSXCompiler(options)

