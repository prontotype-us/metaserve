fs = require 'fs'
Compiler = require 'metaserve/src/compiler'

class Bouncer extends Compiler

    compile: (bounced_filename) ->
        return (req, res, next) ->
            console.log '[Bouncer] Serving bounced ' + bounced_filename
            res.sendfile bounced_filename

    shouldCompile: (bounced_filename) ->
        return (req, res, next) ->
            return !req.headers['x-skip-bouncer']?

module.exports = (options={}) -> new Bouncer(options)

