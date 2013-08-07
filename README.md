metaserve
=========

quickly serve metalanguage-heavy static sites without continual recompilation

## Installation

Clone this repository and `npm install -g`

## Usage

### As a standalone server

Within directory that has a bunch of **.jade**, **.sass** and **.coffee** files, run `metaserve`. 

Optional arguments are `--host` and `--port`. Defaults to 0.0.0.0:8000.

### As a module

Use as a fallback in a standard `http` server

``` javascript
var metaserve = require('metaserve');

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

## Currently supported

* [CoffeeScript](http://coffeescript.org/)
* [Jade](https://github.com/visionmedia/jade)
* [Styl](https://github.com/visionmedia/styl)
