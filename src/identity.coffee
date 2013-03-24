
do (
  root = this,
  factory = () ->
    "use strict"
    identity = {}
    nextId = 0

    _id = (obj) ->
      unless obj.__cosy_id?
        id = '$__cosy_id#' + nextId
        nextId += 1

        if 'function' is typeof Object.defineProperty
          Object.defineProperty obj, '__cosy_id',
            enumerable: false,
            configurable: false,
            writable: false,
            value: id
        else
          obj.__cosy_id = id
        

      obj.__cosy_id

    identity.get = (any) ->
      return _id(any) if any instanceof Object
      null

    identity
) ->
  if "object" is typeof exports
    module.exports = do factory
  else if define?.amd
    define factory
  else
    root.cosy ?= {}
    root.cosy.lang ?= {}
    root.cosy.lang.identity = do factory
  return
