var http = require('http');
var metaserve = require('metaserve')('./static');

var server = http.createServer(function(req, res) {
    if (req.url === '/dogs') {
        return res.end('woof');
    } else {
        return metaserve(req, res);
    }
});

server.listen(8550);
