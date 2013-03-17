"use stict"

do (
  root = this,
  factory = (protocol, tail, {fn$}) ->
    ISeq = protocol.define 'ISeq',
      'A logical list'
      ['first', 'Returns the first item in the collection. If coll is null, returns null']
      ['rest', 'Returns a sequence of the items after the first. If there are no more items, returns a logical sequence for which seq returns null.']

    protocol.extend ISeq, null,
      ['first', (coll) -> null]
      ['rest', (coll) -> null]

    protocol.extend ISeq, Array,
      ['first', (coll) -> if coll.length then coll[0] else null]
      ['rest', (coll) -> coll.slice 1]

    class Sequence
      constructor: (@head, @tail) ->

    class LazySeqence extends Sequence
      constructor: (body) ->
        throw new Error 'body must be a function' unless typeof body is 'function'
        @realise = ->
          res = do body
          while res instanceof LazySeqence
            res = do res.realise
          @realise = -> res
          res

    protocol.extend ISeq, Sequence,
      ['first', (coll) -> coll.head]
      ['rest', (coll) -> coll.tail]

    seq = (coll) ->
      throw new Error 'Does not implement ISeq' unless protocol.implements ISeq, coll
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

    lazy = (body) ->
      new LazySeqence body

    empty = (colls) ->
      for coll in colls
        return false unless (first coll) is null
      true

    vec = (coll) ->
      makeVec = (coll, A = []) ->
        item = first coll
        if item is null
          return A
        else
          A.push item
          tail.recur makeVec, (rest coll), A
      tail.loop makeVec, coll

    map = (fn, colls...) ->
      return null if empty colls
      lazy ->
        firsts = []
        rests = []
        for coll in colls
          firsts.push first coll
          rests.push rest coll
        cons (fn firsts...), (map fn, rests...)

    reduce = fn$ {
      2: (fn, coll) ->
        val = (first coll)
        return (do fn) if val is null
        reduce fn, val, (rest coll)
      3: (fn, val, coll) ->
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
      lazy ->
        f = first coll
        r = rest coll
        if pred f
          cons f, (filter pred, r)
        else
          filter pred, r

    take = (n, coll) ->
      lazy ->
        return null unless n
        return null if empty [coll]
        cons (first coll), (take n-1, rest coll)

    drop = (n, coll) ->
      lazy ->
        return coll unless n
        return null if empty [coll]
        drop n-1, rest coll

    partition = fn$ {
      2: (n, coll) ->
        partition n, n, coll
      3: (n, step, coll) ->
        lazy ->
          return null if empty [coll]
          cons (take n, coll), (partition n, step, (drop step, coll))
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
      drop
      partition
    }
) ->
  if "object" is typeof exports
    protocol = require './protocol'
    tail = require './tail'
    dispatch = require './dispatch'
    module.exports = factory protocol, tail, dispatch
  else if define?.amd
    define ['./protocol', './tail', './dispatch'], factory
  else
    root.cosy ?= {}
    root.cosy.lang ?= {}
    root.cosy.lang.sequence = factory root.cosy.protocol,
      root.cosy.tail, root.cosy.dispatch
  return
