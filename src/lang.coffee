
do (
  root = this,
  factory = (dispatch, identity, meta, promise, protocol, sequence, stream, tail) ->
    "use strict"
    {
      dispatch
      identity
      meta
      promise
      protocol
      sequence
      stream
      tail
    }
) ->
  if "object" is typeof exports
    dispatch = require './dispatch'
    identity = require './identity'
    meta = require './meta'
    promise = require './promise'
    protocol = require './protocol'
    sequence = require './sequence'
    stream = require './stream'
    tail = require './tail'
    module.exports = factory dispatch, identity, meta, promise, protocol, sequence, stream, tail
  else if define?.amd
    define [ './dispatch', './identity', './meta', './promise', './protocol', './sequence', './stream', './tail' ], factory
  else
    root.cosy ?= {}
    root.cosy.lang ?= {}
  return
