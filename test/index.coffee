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
	ctx.sync.done()

wait = (ctx, next)->
	console.log ctx.path + ': wait'
	done1 = ctx.sync.wait()
	setTimeout ->
		console.log ctx.path + ': wait done1'
		done1()
	, 300

	done2 = ctx.sync.wait()
	setTimeout ->
		console.log ctx.path + ': wait done2 maybe end'
		done2()
	, 1000

	done3 = ctx.sync.wait()
	setTimeout ->
		console.log ctx.path + ': wait done3'
		done3()
	, 600

	next()


page '/', start, end
page '/delay', start, delay, end
page '/wait', start, wait
page '/wait_and_end', start, wait, end


# page sequence
page '/'
page '/delay'
page '/wait'
page '/wait_and_end'
page '/'

