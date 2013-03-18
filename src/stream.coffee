"use stict"

do (
  root = this,
  factory = (protocol) ->
    IStream = protocol.define 'IStream',
      ['tap', 'Register on emit']
      ['emit', 'Emit a value']

    stream = {
      IStream
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
    root.cosy.lang.stream = factory root.cosy.protocol
  return
