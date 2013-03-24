
do (
  root = this,
  factory = (protocol) ->
    "use strict"
    ISeq = protocol.define 'ISeq',
      'A logical list'
      ['first', 'Returns the first item in the collection. If coll is null, returns null']
      ['rest', 'Returns a sequence of the items after the first. If there are no more items, returns a logical sequence for which seq returns null.']

    ISeq
) ->
  if "object" is typeof exports
    protocol = require '../protocol'
    module.exports = factory protocol
  else if define?.amd
    define ['../protocol'], factory
  else
    root.cosy ?= {}
    root.cosy.lang ?= {}
    root.cosy.lang.protocol.ISeq = factory cost.lang.protocol
  return
