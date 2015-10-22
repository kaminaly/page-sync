'use strict'

isReady = false

module.exports = (page, Promise)->
    throw new Error 'require page.js and Promise' if !page or !Promise
    return if isReady
    isReady = true

    _contexts = []
    _isProcessing = false

    _push = (ctx)->
        # TODO optimize _contexts
        _contexts.push ctx
        # console.log 'page push', _contexts.length

    _process = ->
        if _contexts.length == 0
            _isProcessing = false
            return

        new Promise (resolve, reject)->
            ctx = _contexts.shift()
            # console.log 'page shift', _contexts.length

            _dispatch ctx, resolve

        .then _process

    # based on page.dispatch
    # doesn't page.js support async function? or page.js has a bug.
    # maybe `page.current` and `ctx.handled` don't work.
    # So i can't use `_dispatch = page.dispatch`.
    prevContext = null
    _dispatch = (ctx, done = ->)->
        prev = prevContext
        i = 0
        j = 0

        prevContext = ctx

        nextExit = ->
            fn = page.exits[j++]
            if !fn then return nextEnter()
            fn prev, nextExit

        nextEnter = ->
            fn = page.callbacks[i++]
            if !fn then return done()
            fn ctx, nextEnter

        if prev
            nextExit()
        else
            nextEnter()

    page.sync = true
    page.dispatch = (ctx)->
        if page.sync
            if ctx.path != page.current
                ctx.handled = false
            _push ctx
            if !_isProcessing
                _isProcessing = true
                _process()
        else
            _dispatch ctx

    # multiple route matching bug fix.
    page.Route.prototype.middleware = (fn)->
        self = this
        (ctx, next)->
            if !ctx.match && self.match ctx.path, ctx.params
                ctx.match = self.path

            if ctx.match == self.path
                fn ctx, next
            else
                next()

    return
