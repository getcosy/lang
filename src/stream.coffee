"use stict"

do (
  root = this,
  factory = (protocol, ISeq, {Promise, IPromise}) ->
    IStream = protocol.define 'IStream',
      ['tap', 'Register on emit']
      ['emit', 'Emit a value']

    skip = {}

    class Sink
      constructor: (tapper, promise) ->
        @isSink = true
        next = new Promise
        rest = null
        value = undefined
        IPromise.when promise, (val) ->
          value = val
          tapper.promise = next

        @first = ->
          return skip if typeof value is 'undefined'
          value
        
        @rest = ->
          return rest if rest?
          rest = new Sink tapper, next

    protocol.extend ISeq, Sink,
      ['first', (snk) -> snk.first()]
      ['rest', (snk) -> snk.rest()]

    sink = (strm) ->
      tapper = (val) ->
        try
          IPromise.deliver tapper.promise, val if tapper.promise?
      tapper.promise = new Promise
      IStream.tap strm, tapper
      new Sink tapper, tapper.promise

    stream = {
      IStream
      sink
      skip
    }
) ->
  if "object" is typeof exports
    protocol = require './protocol'
    ISeq = require './protocols/ISeq'
    promise = require './promise'
    module.exports = factory protocol, ISeq, promise
  else if define?.amd
    define ['./protocol', './protocols/ISeq', './promise'], factory
  else
    root.cosy ?= {}
    root.cosy.lang ?= {}
    root.cosy.lang.stream = factory root.cosy.lang.protocol,
      root.cosy.lang.protocols.ISeq, root.cosy.lang.promise
  return
