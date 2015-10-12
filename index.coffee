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

            waiting = 0
            wait = ->
                waiting++
                ->
                    waiting--
                    resolve() if waiting == 0

            ctx.sync =
                done: resolve
                wait: wait

            _dispatch ctx

        .then _process

    # based on page.dispatch
    # doesn't page.js support async function? or page.js has a bug.
    # maybe `page.current` and `ctx.handled` don't work.
    # So i can't use `_dispatch = page.dispatch`.
    prevContext = null
    _dispatch = (ctx)->
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
          if !fn then return
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
            ctx.sync =
                done: ->
                wait: ->
            _dispatch ctx

