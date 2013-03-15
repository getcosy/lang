"use stict"

do (
  root = this,
  factory = () ->
    identity = {}
    nextId = 0

    id = (obj) ->
      unless obj.__cosy_id?
        obj.__cosy_id = '$__cosy_id' + nextId
        nextId += 1

      obj.__cosy_id

    identity.get = (any) ->
      return id(any) if 'object' == typeof any
      null

    identity
) ->
  if "object" is typeof exports
    module.exports = do factory
  else if define?.amd
    define factory
  else
    root.cosy ?= {}
    root.cosy.identity = do factory
  return
