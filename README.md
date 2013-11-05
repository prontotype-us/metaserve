metaserve
=========

metaserve makes web application prototyping quicker by compiling and serving assets built with meta-languages<sup>[\[1\]](#notes)</sup> such as CoffeeScript, Jade, or Styl (currently the [full list](#supported-languages)).

Use [as a command](#as-a-command) or [as a module](#as-a-module) to handle requests such as `http://localhost:8550/js/events.js` by run-time-compiling `./app/static/js/events.coffee` and serving it to the browser. Somewhat similar to but less robust/contrived than Rails Asset Pipeline.

## As a command

**Install** by cloning this repository and `npm install -g`

**Use** within a directory that has a bunch of **.jade**, **.sass** and **.coffee**.
Run `metaserve` with optional arguments `--host` and `--port`. Defaults to 0.0.0.0:8000.

## As a module

### Installation

**Install** by cloning this repository and `npm install -g`

**Use** as a fallback in a standard `http` server

``` javascript
var metaserve = require('metaserve')('./static');

http.createServer(function(req, res) {
    if (req.url == "/dogs") {
        // Handle the custom route
        return show_dogs();
    } else {
        // Fall back to metaserve
        metaserve(req, res);
    }
});
```

## Supported Languages

* [CoffeeScript](http://coffeescript.org/)
* [Jade](https://github.com/visionmedia/jade)
* [Styl](https://github.com/visionmedia/styl)

---

#### Notes

1. Not to be confused with [the real definition of a Metalanguage](http://en.wikipedia.org/wiki/Metalanguage).
