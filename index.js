// Generated by CoffeeScript 1.10.0
'use strict';
var isReady;

isReady = false;

module.exports = function(page, Promise) {
  var _contexts, _dispatch, _isProcessing, _process, _push, prevContext;
  if (!page || !Promise) {
    throw new Error('require page.js and Promise');
  }
  if (isReady) {
    return;
  }
  isReady = true;
  _contexts = [];
  _isProcessing = false;
  _push = function(ctx) {
    return _contexts.push(ctx);
  };
  _process = function() {
    if (_contexts.length === 0) {
      _isProcessing = false;
      return;
    }
    return new Promise(function(resolve, reject) {
      var ctx;
      ctx = _contexts.shift();
      return _dispatch(ctx, resolve);
    }).then(_process);
  };
  prevContext = null;
  _dispatch = function(ctx, done) {
    var i, j, nextEnter, nextExit, prev;
    if (done == null) {
      done = function() {};
    }
    prev = prevContext;
    i = 0;
    j = 0;
    prevContext = ctx;
    nextExit = function() {
      var fn;
      fn = page.exits[j++];
      if (!fn) {
        return nextEnter();
      }
      return fn(prev, nextExit);
    };
    nextEnter = function() {
      var fn;
      fn = page.callbacks[i++];
      if (!fn) {
        return done();
      }
      return fn(ctx, nextEnter);
    };
    if (prev) {
      return nextExit();
    } else {
      return nextEnter();
    }
  };
  page.sync = true;
  page.dispatch = function(ctx) {
    if (page.sync) {
      if (ctx.path !== page.current) {
        ctx.handled = false;
      }
      _push(ctx);
      if (!_isProcessing) {
        _isProcessing = true;
        return _process();
      }
    } else {
      return _dispatch(ctx);
    }
  };
  page.Route.prototype.middleware = function(fn) {
    var self;
    self = this;
    return function(ctx, next) {
      if (!ctx.match && self.match(ctx.path, ctx.params)) {
        ctx.match = self.path;
      }
      if (ctx.match === self.path) {
        return fn(ctx, next);
      } else {
        return next();
      }
    };
  };
};
