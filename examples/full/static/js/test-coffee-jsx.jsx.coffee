$ = require 'jquery'
React = require 'react'

Avatar = React.createClass
    render: ->
        <img src={@props.face.image_urls.normal} />

$.getJSON 'http://uifaces.com/api/v1/random', (face) ->
    React.render <Avatar face={face} />, $('#face')[0]

