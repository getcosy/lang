// Generated by CoffeeScript 1.4.0

(function(root, factory) {
  var ISeq, IStream, ISync, promise, protocol, _base, _ref, _ref1;
  if ("object" === typeof exports) {
    protocol = require('../protocol');
    IStream = require('../protocols/IStream');
    ISeq = require('../protocols/ISeq');
    ISync = require('../protocols/ISync');
    promise = require('../promise');
    module.exports = factory(protocol, IStream, ISeq, ISync, promise);
  } else if (typeof define !== "undefined" && define !== null ? define.amd : void 0) {
    define(['../protocol', '../protocols/IStream', '../protocols/ISeq', '../protocols/ISync', '../promise'], factory);
  } else {
    if ((_ref = root.cosy) == null) {
      root.cosy = {};
    }
    if ((_ref1 = (_base = root.cosy).lang) == null) {
      _base.lang = {};
    }
    root.cosy.lang.stream.sink = factory(root.cosy.lang.protocol, root.cosy.lang.protocols.IStream, root.cosy.lang.protocols.ISeq, root.cosy.lang.protocols.ISync, root.cosy.lang.promise);
  }
})(this, function(protocol, IStream, ISeq, ISync, promise) {
  "use strict";

  var IPromise, Promise, Sink, sink, skip;
  skip = IStream.skip;
  Promise = promise.Promise, IPromise = promise.IPromise;
  Sink = (function() {

    function Sink(tapper, promise) {
      var next, ready, rest, value,
        _this = this;
      this.isSink = true;
      next = new Promise;
      rest = null;
      value = void 0;
      ready = new Promise;
      IPromise.when(promise, function(val) {
        value = val;
        tapper.promise = next;
        return IPromise.deliver(ready);
      });
      this.first = function() {
        if (typeof value === 'undefined') {
          return skip;
        }
        return value;
      };
      this.rest = function() {
        if (rest != null) {
          return rest;
        }
        return rest = new Sink(tapper, next);
      };
      this.onReady = function(fn) {
        return IPromise.when(ready, fn);
      };
      this.isReady = function() {
        return ready.isRealised();
      };
    }

    return Sink;

  })();
  protocol.extend(ISeq, Sink, [
    'first', function(snk) {
      return snk.first();
    }
  ], [
    'rest', function(snk) {
      return snk.rest();
    }
  ]);
  protocol.extend(ISync, Sink, [
    'ready', function(snk) {
      return snk.isReady();
    }
  ], [
    'onReady', function(snk, fn) {
      return snk.onReady(fn);
    }
  ]);
  sink = function(strm) {
    var tapper;
    if (protocol["implements"](ISeq, strm)) {
      return strm;
    }
    if (!protocol["implements"](IStream, strm)) {
      throw new Error('Not a stream');
    }
    tapper = function(val) {
      try {
        if (tapper.promise != null) {
          return IPromise.deliver(tapper.promise, val);
        }
      } catch (_error) {}
    };
    tapper.promise = new Promise;
    IStream.tap(strm, tapper);
    return new Sink(tapper, tapper.promise);
  };
  return sink;
});
