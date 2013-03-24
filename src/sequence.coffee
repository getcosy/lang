
do (
  root = this,
  factory = (protocol, tail, {fn$}, ISeq, ISync, IStream, sink, promise) ->
    "use strict"
    {skip} = IStream
    {IPromise, Promise} = promise
    protocol.extend ISeq, null,
      ['first', (coll) -> null]
      ['rest', (coll) -> null]

    protocol.extend ISeq, Array,
      ['first', (coll) -> if coll.length then coll[0] else null]
      ['rest', (coll) -> coll.slice 1]

    class Sequence
      constructor: (@head, @tail) ->

    protocol.extend ISeq, Sequence,
      ['first', (coll) -> coll.head]
      ['rest', (coll) -> coll.tail]

    class LazySeqence extends Sequence
      constructor: (body, coll) ->
        throw new Error 'body must be a function' unless typeof body is 'function'
        @realised = false
        @realise = ->
          if coll? and (first coll) is skip
            return (cons skip, @) if coll?.isSink
            coll = (rest coll)
          res = body coll
          while res instanceof LazySeqence
            res = do res.realise

          unless (first res) is skip
            @realised = true
            @realise = -> res
          res

    class SyncedLazySequence extends LazySeqence
      constructor: (body, coll) ->
        super body, coll
        ready = new Promise
        ISync.onReady coll, =>
          do @realise
          IPromise.deliver ready if @realised

        @onReady = (fn) ->
          IPromise.when ready, fn

    protocol.extend ISync, SyncedLazySequence,
      ['ready', (s) -> s.realised]
      ['onReady', (s, fn) -> s.onReady fn]

    seq = (coll) ->
      unless protocol.implements ISeq, coll
        if (protocol.implements IStream, coll)
          coll = sink coll
        else
          throw new Error 'Does not implement ISeq'

      return do coll.realise if coll instanceof LazySeqence
      coll

    cons = (item, coll) ->
      throw new Error 'Does not implement ISeq' unless protocol.implements ISeq, coll
      new Sequence item, coll

    first = (coll) ->
      ISeq.first seq coll

    rest = (coll) ->
      seq coll
      ISeq.rest seq coll

    lazy = fn$ {
      1: (body) ->
        new LazySeqence body
      2: (coll, body) ->
        coll = seq coll
        if protocol.implements ISync, coll
          new SyncedLazySequence body, coll
        else
          new LazySeqence body, coll
    }

    empty = (colls) ->
      for coll in colls
        return false unless (first coll) is null
      true

    vec = (coll) ->
      throw new Error 'Cannot vec a sink' if coll?.isSink
      makeVec = (coll, A = []) ->
        item = first coll
        if item is null
          return A
        else
          A.push item
          tail.recur makeVec, (rest coll), A
      tail.loop makeVec, coll

    map = fn$ {
      0: (fn, coll) ->
        return null if empty colls
        lazy coll, (coll) ->
          cons (fn (first coll)), (map fn, (rest coll))
      $: (fn, colls...) ->
        return null if empty colls
        lazy ->
          firsts = []
          rests = []
          for coll in colls
            throw new Error 'Cannot multi map a sink' if coll?.isSink
            firsts.push first coll
            rests.push rest coll
          cons (fn firsts...), (map fn, rests...)
    }

    reduce = fn$ {
      2: (fn, coll) ->
        val = (first coll)
        return (do fn) if val is null
        reduce fn, val, (rest coll)
      3: (fn, val, coll) ->
        throw new Error 'Cannot reduce a sink' if coll?.isSink
        doReduce = (fn, val, coll) ->
          if empty [coll]
            val
          else
            nextVal = fn val, (first coll)
            tail.recur doReduce, fn, nextVal, (rest coll)
        tail.loop doReduce, fn, val, coll
    }

    filter = (pred, coll) ->
      return null if empty [coll]
      lazy (coll), (coll) ->
        f = first coll
        r = rest coll
        if pred f
          cons f, (filter pred, r)
        else
          filter pred, r

    take = (n, coll) ->
      return null unless n
      return null if empty [coll]
      lazy coll, (coll) ->
        cons (first coll), (take n-1, rest coll)

    takeWhile = (pred, coll) ->
      return null if empty [coll]
      return null unless pred first coll
      lazy coll, (coll) ->
        cons (first coll), (takeWhile pred, rest coll)

    drop = (n, coll) ->
      return coll unless n
      return null if empty [coll]
      lazy coll, (coll) ->
        drop n-1, rest coll

    dropWhile = (pred, coll) ->
      return null if empty [coll]
      return coll unless pred first coll
      lazy coll, (coll) ->
        dropWhile pred, rest coll

    partition = fn$ {
      2: (n, coll) ->
        partition n, n, coll
      3: (n, step, coll) ->
        return null if empty [coll]
        lazy coll, (coll) ->
          cons (take n, coll), (partition n, step, (drop step, coll))
    }

    concat = fn$ {
      0: () ->
        lazy -> null
      1: (x) ->
        x
      2: (x, y) ->
        lazy x, (x) ->
          if empty [x]
            y
          else
            cons (first x), (concat (rest x), y)
      $: (x, y, z...) ->
        concat (concat x, y), z...
    }

    sequence = {
      ISeq
      first
      rest
      cons
      lazy
      vec
      map
      reduce
      filter
      take
      takeWhile
      drop
      dropWhile
      partition
      concat
    }
) ->
  if "object" is typeof exports
    protocol = require './protocol'
    tail = require './tail'
    dispatch = require './dispatch'
    ISeq = require './protocols/ISeq'
    ISync = require './protocols/ISync'
    IStream = require './protocols/IStream'
    sink = require './stream/sink'
    promise = require './promise'
    module.exports = factory protocol, tail, dispatch, ISeq, ISync, IStream, sink, promise
  else if define?.amd
    define ['./protocol', './tail', './dispatch', './protocols/ISeq', './protocols/ISync', './protocols/IStream', './stream/sink', './promise'], factory
  else
    root.cosy ?= {}
    root.cosy.lang ?= {}
    root.cosy.lang.sequence = factory root.cosy.protocol,
      root.cosy.tail, root.cosy.dispatch, root.cosy.protocols.ISeq, root.cosy.protocols.ISync,
      root.cosy.protocols.IStream, root.cosy.stream.sink, root.cosy.lang.promise
  return
