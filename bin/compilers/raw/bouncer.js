// Generated by CoffeeScript 1.7.1
(function() {
  var Bouncer, Compiler, fs,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  fs = require('fs');

  Compiler = require('metaserve/src/compiler');

  Bouncer = (function(_super) {
    __extends(Bouncer, _super);

    function Bouncer() {
      return Bouncer.__super__.constructor.apply(this, arguments);
    }

    Bouncer.prototype.compile = function(bounced_filename) {
      return function(req, res, next) {
        console.log('[Bouncer] Serving bounced ' + bounced_filename);
        return res.sendfile(bounced_filename);
      };
    };

    Bouncer.prototype.shouldCompile = function(bounced_filename) {
      return function(req, res, next) {
        return req.headers['x-skip-bouncer'] == null;
      };
    };

    return Bouncer;

  })(Compiler);

  module.exports = function(options) {
    if (options == null) {
      options = {};
    }
    return new Bouncer(options);
  };

}).call(this);