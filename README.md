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
you have to execute `next()` when every action completes.
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
  next();
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

## License

[MIT](http://opensource.org/licenses/MIT)
