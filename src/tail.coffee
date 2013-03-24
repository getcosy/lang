
do (
  root = this,
  factory = () ->
    "use strict"
    tail = {}

    class Recur
      constructor: (fn, args) ->
        @loop = ->
          fn args...

    tail.recur = (fn, args...) ->
      new Recur fn, args

    tail.loop = (fn, args...) ->
      result = fn args...
      while result instanceof Recur
        result = do result.loop
      result

    tail
) ->
  if "object" is typeof exports
    module.exports = do factory
  else if define?.amd
    define factory
  else
    root.cosy ?= {}
    root.cosy.lang ?= {}
    root.cosy.lang.tail = do factory
  return
