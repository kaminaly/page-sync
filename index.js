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
      var ctx, wait, waiting;
      ctx = _contexts.shift();
      waiting = 0;
      wait = function() {
        waiting++;
        return function() {
          waiting--;
          if (waiting === 0) {
            return resolve();
          }
        };
      };
      ctx.sync = {
        done: resolve,
        wait: wait
      };
      return _dispatch(ctx);
    }).then(_process);
  };
  prevContext = null;
  _dispatch = function(ctx) {
    var i, j, nextEnter, nextExit, prev;
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
        return;
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
  return page.dispatch = function(ctx) {
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
      ctx.sync = {
        done: function() {},
        wait: function() {}
      };
      return _dispatch(ctx);
    }
  };
};
