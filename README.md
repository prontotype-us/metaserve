metaserve
=========

metaserve makes web application prototyping quicker by compiling and serving assets built with meta-languages<sup>[\[1\]](#notes)</sup> such as CoffeeScript, Jade, or Styl (currently the [full list](#supported-languages)).

Use [as a command](#as-a-command) or [as a module](#as-a-module) to handle requests such as `http://localhost:8550/js/events.js` by run-time-compiling the CoffeeScript source `./static/js/events.coffee` into Javascript and serving it to the browser. Somewhat similar to but less robust/contrived than Rails Asset Pipeline.

## As a command

**Install** by cloning this repository and `npm install -g`

**Use** within a directory that has a bunch of **.jade**, **.sass** and **.coffee**.
Run `metaserve` with optional arguments `--host` and `--port`. Defaults to 0.0.0.0:8000.

## As a module

### Installation

**Install** by cloning this repository and `npm install -g`

**Use** by supplying a base directory, then hooking it in as Express/Connect middleware...

``` javascript
var metaserve = require('metaserve');
var express = require('express');

app = express();

app.use(app.router);
app.use(metaserve('./static'));

app.get('/dogs', function(req, res) {
    return res.end('woof');
});

app.listen(8550);
```

... or as a fallback in a standard `http` server:

``` javascript
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
```

## Supported Languages

* [CoffeeScript](http://coffeescript.org/)
* [Jade](https://github.com/visionmedia/jade)
* [Styl](https://github.com/visionmedia/styl)

---

#### Notes

1. Not to be confused with [the real definition of a Metalanguage](http://en.wikipedia.org/wiki/Metalanguage).
