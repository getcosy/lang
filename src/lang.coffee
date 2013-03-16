"use stict"

do (
  root = this,
  factory = (protocol, tail, identity) ->
    {
      protocol
      tail
      identity
    }
) ->
  if "object" is typeof exports
    protocol = require 'protocol'
    tail = require 'tail'
    identity = require 'identity'
    module.exports = do factory protocol, tail, identity
  else if define?.amd
    define ['protocol', 'tail', 'identity'], factory
  else
    root.cosy ?= {}
    root.cosy.lang ?= {}
  return
