"use stict"

do (
  root = this,
  factory = (protocol) ->
    promise = {}

    IPromise = protocol.define 'IPromise',
      ['when', 'Regester a callback with a deffered']
      ['deliver', 'Resolve a deffered']

    # Defaults
    protocol.extend IPromise, null,
      ['when', (deffered, fn) -> fn deffered],
      ['deliver', (deffered, val) ->]

    protocol.extend IPromise, "",
      ['when', (deffered, fn) -> fn deffered],
      ['deliver', (deffered, val) ->]

    protocol.extend IPromise, 1,
      ['when', (deffered, fn) -> fn deffered],
      ['deliver', (deffered, val) ->]

    protocol.extend IPromise, Object,
      ['when', (deffered, fn) -> fn deffered],
      ['deliver', (deffered, val) ->]

    promise.IPromise = IPromise
    promise
) ->
  if "object" is typeof exports
    protocol = require './protocol'
    module.exports = factory protocol
  else if define?.amd
    define ['./protocol'], factory
  else
    root.cosy ?= {}
    root.cosy.lang ?= {}
    root.cosy.lang.promise = factory root.cosy.protocol
  return
