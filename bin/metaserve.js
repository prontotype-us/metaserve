#!/usr/bin/env node
// Generated by CoffeeScript 1.6.2
(function() {
  var Ecstatic, HOST, PORT, argv, coffee, de_res, fs, http, jade, metaserve, server, styl, uglify;

  http = require('http');

  fs = require('fs');

  Ecstatic = require('ecstatic');

  coffee = require('coffee-script');

  jade = require('jade');

  styl = require('styl');

  uglify = require('uglify-js');

  de_res = function(n) {
    return Math.floor(n / 1000) * 1000;
  };

  module.exports = metaserve = function(base_dir, opts) {
    var ecstatic, file_types;

    if (opts == null) {
      opts = {};
    }
    if (!base_dir) {
      base_dir = '.';
    }
    file_types = {
      html: {
        content_type: 'text/html',
        compilers: {
          jade: function(file_str) {
            return jade.compile(file_str, {
              filename: base_dir
            })();
          }
        }
      },
      js: {
        content_type: 'text/javascript',
        compilers: {
          coffee: function(file_str) {
            return coffee.compile(file_str);
          }
        },
        minify: function(compiled_str) {
          return uglify.minify(compiled_str, {
            fromString: true
          }).code;
        }
      },
      css: {
        content_type: 'text/css',
        compilers: {
          sass: function(file_str) {
            return styl(file_str, {
              whitespace: true
            }).toString();
          }
        }
      }
    };
    ecstatic = Ecstatic({
      root: base_dir,
      handleError: false
    });
    return function(req, res) {
      var compiled_str, compiler, ext, file_stats, file_str, filename, matched, metadata, uext, _ref;

      if (req.url === '/') {
        req.url = '/index.html';
      }
      for (ext in file_types) {
        metadata = file_types[ext];
        if (matched = req.url.match(new RegExp('(.+)\.' + ext))) {
          _ref = metadata.compilers;
          for (uext in _ref) {
            compiler = _ref[uext];
            filename = matched[1] + '.' + uext;
            if (fs.existsSync(base_dir + filename)) {
              file_stats = fs.statSync(base_dir + filename);
              if (Date.parse(req.headers['if-modified-since']) >= de_res(file_stats.mtime.getTime())) {
                res.statusCode = 304;
                return res.end();
              }
              file_str = fs.readFileSync(base_dir + filename).toString();
              compiled_str = compiler(file_str);
              if (opts.minify && metadata.minify) {
                compiled_str = metadata.minify(compiled_str);
              }
              res.setHeader('last-modified', (new Date(file_stats.mtime)).toUTCString());
              res.setHeader('cache-control', "max-age=" + (opts.max_age || 3600));
              res.setHeader('content-type', metadata.content_type || 'application/octet-stream');
              return res.end(compiled_str);
            }
          }
        }
      }
      return ecstatic(req, res);
    };
  };

  if (require.main === module) {
    argv = require('optimist').argv;
    HOST = argv.host != null ? argv.host : '0.0.0.0';
    PORT = argv.port != null ? argv.port : 8000;
    server = http.createServer(metaserve());
    server.listen(PORT, HOST, function() {
      return console.log("metaserving on " + HOST + ":" + PORT + ".");
    });
  }

}).call(this);
