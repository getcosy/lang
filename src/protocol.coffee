"use stict"

do (
  root = this,
  factory = () ->
    protocol = {}

    dispatch = (dispatcher, type, args...) ->
      throw new Error "Unknown arg count #{args.length} for #{dispatcher.proto.name}.#{dispatcher.name}" unless dispatcher.params[args.length]?
      if 'object' is typeof type
        throw new Error "Protocol #{type.___protocols[dispatcher.proto.name]} not implemented for this type" unless type.prototype?.__cosy?.protocols[dispatcher.proto.name]?
        methods = type.prototype.__cosy.protocols[dispatcher.proto.name]
        throw new Error "Arg count #{args.length} not implemented for this type" unless methods[args.length]?
        return methods[args.length] args...
      else
        for predicate in dispatcher.params[args.length]?.predicates
          if predicate fn
            throw new Error "Arg count #{args.length} not implemented for this type" unless predicate?.methods[args.length]?
            return predicate.methods[args.length] args...
      throw new Error "Method #{dispatcher.proto.name}.#{dispatcher.name} not implemented for this type"

    createDispatcher = (proto, name, doc, params...) ->
      dispatcher = (args...) ->
        dispatch dispatcher, args...
      dispatcher.proto = proto
      dispatcher.name = name
      dispatcher.doc = doc
      dispatcher.params = []
      for paramList in params
        throw new Error "Must have at least one param" unless paramList?.length
        throw new Error "Already dispatching on #{paramList.length} params" if dispatcher.params[paramList.length]
        dispatcher.params[paramList.length-1] = paramList
      dispatcher

    defineMethod = (proto, name, args...) ->
      throw new Error "Method name must be a string" unless "string" is typeof name
      throw new Error "Method #{name} already defined" if "function" is typeof proto.methods?[name]
      throw new Error "Protocol methods cannot only have a name" unless args.length
      if "string" is typeof args[args.length-1]
        doc = args.shift()
      throw new Error "Must have at least one parameter list" unless args.length
      proto[name] = createDispatcher proto, name, doc, args...
      return

    class Protocol
      constructor: (@name, methods, @doc) ->
        throw new Error 'name must be a string' unless typeof @name is 'string'
        for method in methods
          throw new Error "method spec must be an array" unless method?.length
          defineMethod @, method...

    protocol.define = (name, args...) ->
      doc = args.shift() if "string" is typeof args[0]
      new Protocol name, args, doc

    getArgs = (fn) ->
      throw new Error 'Not a function' unless typeof fn is 'function'
      matches = fn.toString().match /\(([^)]*)\)/
      args = []
      for match in matches?[1].split /, */
        args.push match if match
      args

    extendObject = (proto, object, dispatcher) ->
      c = object.prototype?.__cosy = {}
      p = c?.protocols = {}
      p?[proto.name] = []

    extendFn = (proto, fn, dispatcher) ->
      args = getArgs dispatcher
      console.log args

    class Predicate

    protocol.extend = (proto, predicate, args...) ->
      throw new Error 'Not a protocol' unless proto instanceof Protocol
      for arg in args
        throw new Error 'Method definition must be an array' unless arg.length?
        methodName = arg.shift()
        dispatcher = proto[methodName]
        console.log dispatcher
        throw new Error "Unknown method #{methodName}" unless dispatcher?
        if 'function' is typeof predicate
          if predicate instanceof Predicate
            methods = extendFn proto, predicate.test, dispatcher
          else
            methods = extendObject proto, predicate, dispatcher
        else if 'string' is typeof predicate
          predicateFn = (type) ->
            predicate is typeof type
          methods = extendFn proto, predicateFn, dispatcher
        else
          predicateFn = (type) ->
            predicate is type
          methods = extendFn proto, predicateFn, dispatcher
        for implementation in arg
          argLength = (getArgs implementation).length - 1
          throw new Error "Method of #{args.length} already defined " unless methods[argLength]
          methods[argLength] = implementation

    protocol
) ->
  if "object" is typeof exports
    module.exports = do factory
  else if define?.amd
    define factory
  else
    root.cosy ?= {}
    root.cosy.protocol = do factory
  return
