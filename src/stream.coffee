
do (
  root = this,
  factory = (protocol, IStream, sequence, ISync, sink) ->
    "use strict"
    {skip} = IStream

    class Source
      constructor: (seq) ->
        @fns = []
        initialised = false
        init = ->
          initialised = true
          if protocol.implements ISync, seq
            ISync.onReady seq, emitSync
          else
            do emitAll
        emitSync = ->
          value = (sequence.first seq)
          emit value unless value is skip
          seq = (sequence.rest seq)
          ISync.onReady seq, emitSync
        emitAll = ->
          while f = (sequence.first seq)
            unless f is skip
              emit f
              seq = sequence.rest seq
        emit = (val) =>
          fn val for fn in @fns
        @tap = (fn) =>
          @fns.push fn
          do init unless initialised

    protocol.extend IStream, Source,
      ['tap', (s, fn) -> s.tap fn]
      ['emit', (s, val) -> throw new Error 'Cannot emit to a source']

    source = (seq) ->
      return seq if protocol.implements IStream, seq
      throw new Error 'Not a sequence' unless protocol.implements sequence.ISeq, seq
      new Source seq

    tap = (s, fn) ->
      s = source s
      IStream.tap s, fn

    emit = (s, val) ->
      IStream.emit s, val

    pipe = (src, tgt) ->
      src = source src
      src.tap (val) ->
        emit tgt, val

    stream = {
      IStream
      sink
      source
      skip
      tap
      emit
      pipe
    }
) ->
  if "object" is typeof exports
    protocol = require './protocol'
    IStream = require './protocols/IStream'
    sequence = require './sequence'
    ISync = require './protocols/ISync'
    sink = require './stream/sink'
    module.exports = factory protocol, IStream, sequence, ISync, sink
  else if define?.amd
    define ['./protocol', './protocols/IStream', './sequence', './protocols/ISync', './stream/sink'], factory
  else
    root.cosy ?= {}
    root.cosy.lang ?= {}
    root.cosy.lang.stream = factory root.cosy.lang.protocol, root.cosy.lang.protocols.IStream,
      root.cosy.lang.sequence, root.cosy.lang.protocols.ISync, root.cosy.lang.stream.sink
  return
