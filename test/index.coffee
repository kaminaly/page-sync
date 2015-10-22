'use strict'
page = require 'page'
Promise = require 'bluebird'

# page-sync
require('../') page, Promise

page.Context = (path, state)->
	Context

# window moc
jsdom = require 'jsdom'
global.window = jsdom.jsdom('').defaultView
global.document = global.window.document
global.history = global.window.history


start = (ctx, next)->
	console.log ctx.path + ': start'
	next()

delay = (ctx, next)->
	console.log ctx.path + ': delay'
	setTimeout next, 1000

end = (ctx, next)->
	console.log ctx.path + ': end'
	next()

page '/', start, end
page '/delay', start, delay, end


# page sequence
page '/'
page '/delay'
page '/'
