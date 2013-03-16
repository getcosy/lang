"use stict"

do (
  root = this,
  factory = () ->
    meta = {}
    nextId = 0

    _meta = (obj) ->
      unless obj.__cosy_meta?
        if 'function' is typeof Object.defineProperty
          Object.defineProperty obj, '__cosy_meta',
            enumerable: false,
            configurable: false,
            writable: false,
            value: {_ns: {}}
        else
          obj.__cosy_meta = {_ns: {}}
        

      obj.__cosy_meta

    meta.get = (any) ->
      return _meta(any) if any instanceof Object
      null

    meta.ns = (any, ns) ->
      metaData = meta.get(any)
      if metaData?
        metaData._ns[ns] ?= {}
        metaData._ns[ns]
      else
        null

    meta
) ->
  if "object" is typeof exports
    module.exports = do factory
  else if define?.amd
    define factory
  else
    root.cosy ?= {}
    root.cosy.meta = do factory
  return
