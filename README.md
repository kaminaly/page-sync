# page-sync [![NPM version](https://badge.fury.io/js/page-sync.svg)](http://badge.fury.io/js/page-sync)
This adds sync feature to [page.js](https://github.com/visionmedia/page.js).

## Install

```bash
$ npm install page-sync
```


## Usage

### setup
```js
var page = require('page');
// You can choose your favorit Promise implementation.
var Promise = require('bluebird');

var pageSync = require('page-sync')
pageSync(page, Promise);
```

### example
you have to execute `ctx.sync.done()` when your sequence completes.
```js
var start = function(ctx, next) {
  console.log(ctx.path + ': start');
  next();
}

var delay = function(ctx, next) {
  console.log(ctx.path + ': delay');
  setTimeout(next, 1000);
}

var end = function(ctx, next) {
  console.log(ctx.path + ': end');
  ctx.sync.done();
}

page('/a', start, delay, end);
page('/b', start, delay, end);

// page moves
page('/a');
page('/b');

// output
// /a: start
// /a: delay
// /a: end
// /b: start
// /b: delay
// /b: end
```

### wait
if you need multiple async function, you can use `ctx.sync.wait()` instead of using `ctx.sync.done()`.
```js
var wait = function(ctx, next) {
  console.log(ctx.path + ': wait');
  var done1 = ctx.sync.wait();
  setTimeout(function() {
    console.log(ctx.path + ': wait done1');
    done1();
  }, 300);
  var done2 = ctx.sync.wait();
  setTimeout(function() {
    console.log(ctx.path + ': wait done2 maybe end');
    done2();
  }, 1000);
  var done3 = ctx.sync.wait();
  setTimeout(function() {
    console.log(ctx.path + ': wait done3');
    done3();
  }, 600);
}

page('/a', wait);
page('/b', wait);

// page moves
page('/a');
page('/b');

// output
// /a: wait
// /a: wait done1
// /a: wait done3
// /a: wait done2 maybe end
// /b: wait
// /b: wait done1
// /b: wait done3
// /b: wait done2 maybe end
```

## License

[MIT](http://opensource.org/licenses/MIT)
