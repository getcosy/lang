"use stict"

do (
  root = this,
  factory = (protocol, IStream, ISeq, ISync, promise) ->

    {skip} = IStream
    {Promise, IPromise} = promise

    class Sink
      constructor: (tapper, promise) ->
        @isSink = true
        next = new Promise
        rest = null
        value = undefined
        ready = new Promise
        IPromise.when promise, (val) =>
          value = val
          tapper.promise = next
          IPromise.deliver ready
        @first = ->
          return skip if typeof value is 'undefined'
          value
        
        @rest = ->
          return rest if rest?
          rest = new Sink tapper, next

        @onReady = (fn) ->
          IPromise.when ready, fn

        @isReady = ->
          do ready.isRealised

    protocol.extend ISeq, Sink,
      ['first', (snk) -> snk.first()]
      ['rest', (snk) -> snk.rest()]

    protocol.extend ISync, Sink,
      ['ready', (snk) -> snk.isReady()]
      ['onReady', (snk, fn) -> snk.onReady fn]

    sink = (strm) ->
      throw new Error 'Not a stream' unless protocol.implements IStream, strm
      tapper = (val) ->
        try
          IPromise.deliver tapper.promise, val if tapper.promise?
      tapper.promise = new Promise
      IStream.tap strm, tapper
      new Sink tapper, tapper.promise

    sink
) ->
  if "object" is typeof exports
    protocol = require '../protocol'
    IStream = require '../protocols/IStream'
    ISeq = require '../protocols/ISeq'
    ISync = require '../protocols/ISync'
    promise = require '../promise'
    module.exports = factory protocol, IStream, ISeq, ISync, promise
  else if define?.amd
    define ['../protocol', '../protocols/IStream', '../protocols/ISeq', '../protocols/ISync', '../promise'], factory
  else
    root.cosy ?= {}
    root.cosy.lang ?= {}
    root.cosy.lang.stream.sink = factory root.cosy.lang.protocol, root.cosy.lang.protocols.IStream,
      root.cosy.lang.protocols.ISeq, root.cosy.lang.protocols.ISync, root.cosy.lang.promise
  return
