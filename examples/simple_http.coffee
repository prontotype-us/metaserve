http = require('http')
metaserve = require('metaserve')('./static')

server = http.createServer (req, res) ->
    if req.url is '/dogs'
        # Handle the custom route
        res.end('woof')
    else
        # Fall back to metaserve
        metaserve req, res

server.listen 8550
