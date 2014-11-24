_ = require 'underscore'

class Compiler

    default_options: {}

    constructor: (options={}) ->
        @options = _.defaults options, @default_options

    set: (options) ->
        @options[k] = v for k, v of options
        @

module.exports = Compiler

