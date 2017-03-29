metaserve
=========

metaserve makes web application prototyping quicker by compiling and serving assets built with meta-languages<sup>[\[1\]](#notes)</sup> such as CoffeeScript, Jade, and Styl (currently the [full list](#supported-languages)).

Use [as a command](#as-a-command) or [as middleware](#as-middleware) to handle requests for e.g. `js/myapp.js` by run-time-compiling the `js/myapp.coffee` source file into Javascript. Similar to (but less contrived than) the Rails Asset Pipeline.

Metaserve is based on a collection of plugins, which by default support Jade (to HTML), CoffeeScript (to Javascript), and Sass (to CSS) to support [the Prontotype stack](https://github.com/prontotype-us/stack). New languages are easily added with a simple [plugin architecture](#writing-plugins).

## As a command

**Install** with `npm install -g metaserve`

**Use** within a directory that has a bunch of **.jade**, **.sass** and **.coffee**.
Run `metaserve` with optional arguments `--host` and `--port`. Defaults to 0.0.0.0:8000.

## As middleware

**Install** with `npm install metaserve`

**Use** by supplying a base directory, then hooking it in as Express/Connect middleware...

``` javascript
var express = require('express');
var metaserve = require('metaserve');

app = express();
app.use(metaserve('./app'));
app.listen(8550);
```

... or as a fallback method in a standard `http` server:

``` javascript
var http = require('http');
var metaserve = require('metaserve')('./app');

var server = http.createServer(function(req, res) {
    if (req.url === '/dogs') {
        return res.end('woof');
    } else {
        return metaserve(req, res);
    }
});

server.listen(8550);
```

## Writing Plugins

A plugin is simply a Javascript module with a few fields:

* `ext`
    * The extension that this plugin will match, e.g. "coffee"
* `default_config` (optional)
    * Default config which will be extended and passed in as the `config` argument to the `compiler` function
* `compiler(filename, config, context, cb)`
    * A function that should transform some source file and call back with an object `{content_type, compiled}` 

Here's a simple plugin that responds with a message about the filename:

```javascript
module.exports = {
    ext: 'fakeout',

    compile: function(filename, config, context, cb) {
        return cb(null, {
            content_type: 'text/plain',
            compiled: "you asked for " + filename + " but too bad"
        });
    }
};
```

By passing an object of compilers to the metaserve middleware, paths that match the extension key (here "txt") will be run through this plugin:

```javascript
app.use(metaserve('./app', {
    txt: require('./fakeout-plugin')
}));
```

## Default Plugins
* [metaserve-js-coffee-reactify](https://github.com/prontotype-us/metaserve-js-coffee-reactify): Javascript via [CoffeeScript](http://coffeescript.org/) with [React (JSX) support](https://github.com/jsdf/coffee-reactify)
* [metaserve-css-styl](https://github.com/prontotype-us/metaserve-css-styl): CSS via [Styl](https://github.com/visionmedia/styl) with several [Rework](https://github.com/reworkcss/rework) plugins
* [metaserve-html-jade](https://github.com/prontotype-us/metaserve-html-jade): HTML via [Jade](https://github.com/visionmedia/jade)

---

#### Notes

1. Not to be confused with [the real definition of a Metalanguage](http://en.wikipedia.org/wiki/Metalanguage).
