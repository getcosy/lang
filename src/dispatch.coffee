"use stict"

do (
  root = this,
  factory = () ->
    fn$ = (def) ->
      return (args...) ->
        return (def[args.length] args...) if def[args.length]?
        return def.$ args... if def.$?
        throw new Error 'No default for this function'

    dispatch = {
      fn$
    }
) ->
  if "object" is typeof exports
    module.exports = do factory
  else if define?.amd
    define factory
  else
    root.cosy ?= {}
    root.cosy.lang ?= {}
    root.cosy.lang.dispatch = do factory
  return
