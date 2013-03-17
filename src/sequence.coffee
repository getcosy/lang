"use stict"

do (
  root = this,
  factory = (protocol) ->
    ISeq = protocol.define 'ISeq',
      'A logical list'
      ['first', 'Returns the first item in the collection. If coll is null, returns null']
      ['rest', 'Returns a sequence of the items after the first. If there are no more items, returns a logical sequence for which seq returns null.']

    protocol.extend ISeq, null,
      ['first', (coll) -> null]
      ['rest', (coll) -> null]

    protocol.extend ISeq, Array,
      ['first', (coll) -> coll[0]]
      ['rest', (coll) -> coll.slice 1]

    class Sequence
      constructor: (@head, @tail) ->

    class LazySeqence extends Sequence
      constructor: (body) ->
        throw new Error unless typeof body is 'function'
        @realise = ->
          res = do body
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

    sequence = {
      ISeq
      first
      rest
      cons
      lazy
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
    root.cosy.lang.sequence = factory root.cosy.protocol
  return
