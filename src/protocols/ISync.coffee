
do (
  root = this,
  factory = (protocol) ->
    "use strict"
    ISync = protocol.define 'ISync',
      'A syncronisable object'
      ['ready', 'true if the value is ready']
      ['onReady', 'Register a callback that is triggered when ready']

    ISync
) ->
  if "object" is typeof exports
    protocol = require '../protocol'
    module.exports = factory protocol
  else if define?.amd
    define ['../protocol'], factory
  else
    root.cosy ?= {}
    root.cosy.lang ?= {}
    root.cosy.lang.protocol.ISync = factory cost.lang.protocol
  return
