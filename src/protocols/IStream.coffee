
do (
  root = this,
  factory = (protocol) ->
    "use strict"
    IStream = protocol.define 'IStream',
      ['tap', 'Register on emit']
      ['emit', 'Emit a value']

    IStream.skip = {skip:true}

    IStream
) ->
  if "object" is typeof exports
    protocol = require '../protocol'
    module.exports = factory protocol
  else if define?.amd
    define ['../protocol'], factory
  else
    root.cosy ?= {}
    root.cosy.lang ?= {}
    root.cosy.lang.protocol.IStream = factory cost.lang.protocol
  return
