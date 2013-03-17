"use stict"

do (
  root = this,
  factory = (protocol) ->
    sequence = {}

    ISeq = protocol.define 'ISeq',
      'A logical list'
      ['first', 'Returns the first item in the collection. If coll is null, returns null']
      ['rest', 'Returns a sequence of the items after the first. If there are no more items, returns a logical sequence for which seq returns null.']
      ['conj', 'Returns a new seq where item is the first element and seq is the rest.']

    protocol.extend ISeq, null,
      ['first', (coll) -> null]
      ['rest', (coll) -> null]
      ['conj', (coll, item) -> [item]]

    protocol.extend ISeq, Array,
      ['first', (coll) -> coll[0]]
      ['rest', (coll) -> coll.slice 1]
      ['conj', (coll, item) -> coll.concat [item]]

    sequence.ISeq = ISeq
    sequence
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
