"use stict"

do (
  root = this,
  factory = (protocol, ISeq, {Promise, IPromise}) ->
    IStream = protocol.define 'IStream',
      ['tap', 'Register on emit']
      ['emit', 'Emit a value']

    class Sink
      constructor: (tapper, promise) ->
        @isSink = true
        next = new Promise
        IPromise.when promise, ->
          tapper.promise = next

        @first = ->
          promise
        
        @rest = ->
          new Sink tapper, next

    protocol.extend ISeq, Sink,
      ['first', (snk) -> snk.first()]
      ['rest', (snk) -> snk.rest()]

    sink = (strm) ->
      tapper = (val) ->
        IPromise.deliver tapper.promise, val if tapper.promise?
      tapper.promise = new Promise
      IStream.tap strm, tapper
      new Sink tapper, tapper.promise

    stream = {
      IStream
      sink
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
