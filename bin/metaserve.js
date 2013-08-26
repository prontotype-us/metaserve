#!/usr/bin/env node
// Generated by CoffeeScript 1.6.3
(function() {
  var Ecstatic, HOST, PORT, argv, coffee, fs, http, jade, metaserve, server, styl;

  http = require('http');

  fs = require('fs');

  Ecstatic = require('ecstatic');

  coffee = require('coffee-script');

  jade = require('jade');

  styl = require('styl');

  argv = require('optimist').argv;

  HOST = argv.host != null ? argv.host : '0.0.0.0';

  PORT = argv.port != null ? argv.port : 8000;

  module.exports = metaserve = function(base_dir) {
    var ecstatic;
    if (!base_dir) {
      base_dir = '.';
    }
    ecstatic = Ecstatic(base_dir);
    return function(req, res) {
      var filename, matched;
      if (req.url === '/') {
        req.url = '/index.html';
      }
      if (matched = req.url.match(/([\w\/]+).html/)) {
        res.setHeader('Content-Type', 'text/html');
        filename = matched[1] + '.jade';
        if (fs.existsSync(base_dir + filename)) {
          return res.end(jade.compile(fs.readFileSync(base_dir + filename).toString(), {
            filename: base_dir
          })());
        }
      } else if (matched = req.url.match(/([\w\/]+).js/)) {
        filename = matched[1] + '.coffee';
        if (fs.existsSync(base_dir + filename)) {
          return res.end(coffee.compile(fs.readFileSync(base_dir + filename).toString()));
        }
      } else if (matched = req.url.match(/([\w\/]+).css/)) {
        filename = matched[1] + '.sass';
        if (fs.existsSync(base_dir + filename)) {
          return res.end(styl(fs.readFileSync(base_dir + filename).toString(), {
            whitespace: true
          }).toString());
        }
      }
      return ecstatic(req, res);
    };
  };

  if (require.main === module) {
    server = http.createServer(metaserve);
    server.listen(PORT, HOST, function() {
      return console.log("metaserving on " + HOST + ":" + PORT + ".");
    });
  }

}).call(this);