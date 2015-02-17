defaults = (o, d) ->
    for k, v of d
        o[k] = v if !o[k]?
    return o

class Compiler

    default_options: {}

    constructor: (options={}) ->
        @options = defaults options, @default_options

    set: (options) ->
        @options[k] = v for k, v of options
        @

module.exports = Compiler

