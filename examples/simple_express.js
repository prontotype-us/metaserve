var metaserve = require('metaserve');
var express = require('express');

app = express();

app.use(app.router);
app.use(metaserve('./static'));

app.get('/dogs', function(req, res) {
    return res.end('woof');
});

app.listen(8550);
