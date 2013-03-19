"use stict"

do (
  root = this,
  factory = (protocol) ->
    IPromise = protocol.define 'IPromise',
      ['when', 'Regester a callback with a deffered']
      ['deliver', 'Resolve a deffered']

    # Defaults
    protocol.extend IPromise, null,
      ['when', (deffered, fn) -> fn deffered],
      ['deliver', (deffered, val) ->]

    protocol.extend IPromise, "",
      ['when', (deffered, fn) -> fn deffered],
      ['deliver', (deffered, val) ->]

    protocol.extend IPromise, 1,
      ['when', (deffered, fn) -> fn deffered],
      ['deliver', (deffered, val) ->]

    protocol.extend IPromise, Object,
      ['when', (deffered, fn) -> fn deffered],
      ['deliver', (deffered, val) ->]

    class Promise
      constructor: ->
        listeners = []
        realised = false
        val = null
        @addListener = (fn) ->
          return fn val if realised
          listeners.push fn
        @realise = (realisedVal) ->
          throw new Error 'Already realised' if realised
          val = realisedVal
          realised = true
          for listener in listeners
            listener val

    protocol.extend IPromise, Promise,
      ['when', (prom, fn) -> prom.addListener fn]
      ['deliver', (prom, val) -> prom.realise val]

    promise = {
      IPromise,
      Promise,
    }
) ->
  if "object" is typeof exports
    protocol = require './protocol'
    module.exports = factory protocol
  else if define?.amd
    define ['./protocol'], factory
  else
    root.cosy ?= {}
    root.cosy.lang ?= {}
    root.cosy.lang.promise = factory root.cosy.protocol
  return
