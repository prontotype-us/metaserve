metaserve = require('metaserve')
express = require('express')

app = express()

app.use app.router # Handle the custom routes
app.use metaserve('./static') # Fall back to metaserve

app.get '/dogs', (req, res) ->
    res.end 'woof'

app.listen 8550
