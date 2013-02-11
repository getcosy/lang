"use stict"

do (
  root = this,
  factory = (protocol, tail) ->
    {
      protocol
      tail
    }
) ->
  if "object" is typeof exports
    protocol = require 'protocol'
    tail = require 'tail'
    module.exports = do factory protocol, tail
  else if define?.amd
    define ['protocol', 'tail'], factory
  else
    root.cosy ?= {}
    root.cosy.lang ?= {}
  return
