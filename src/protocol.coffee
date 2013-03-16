"use stict"

do (
  root = this,
  factory = (_meta, identity) ->
    protocol = {}

    meta = (obj) ->
      _meta.ns(obj, 'protocol')

    createDispatcher = (name, doc, opts) ->
      fn = (any, args...) ->
        type = any
        type = new (protoType any) unless any instanceof Object
        method = getDispatchMap(fn, type)
        if method
          method any, args...
        else
          throw new Error 'method not implemented'
      md = meta(fn)
      md.name = name
      md.doc = doc
      fn

    defineMethod = (proto, name, opts...) ->
      doc = null
      if 'string' is typeof opts[opts.length - 1]
        doc = opts.pop()
      proto[name] = createDispatcher name, doc, opts

    class Protocol
      constructor: (name, doc, defs) ->
        md = meta(@)
        md.name = name
        md.doc = doc
        defineMethod @, def... for def in defs

    protoDefine =  (name, defs...) ->
      doc = null
      if 'string' is typeof defs[0]
        doc = defs.shift()

      new Protocol name, doc, defs

    types = {}

    protoType = (any) ->
      typeName = typeof any
      types[typeName] ?= ->
      types[typeName]

    getId = (dispatcher) ->
      '$__cosy_protocols_' + (identity.get dispatcher)

    getDispatchMap = (dispatcher, any) ->
      any?[getId dispatcher]

    extendMethod = (proto, type, name, fn) ->
      type.prototype[getId proto[name]] = fn

    protoExtend = (proto, type, methods...) ->
      return protoExtend proto, (protoType type), methods... unless type instanceof Object
      extendMethod proto, type, method... for method in methods

    methodDoc = (method) ->
      md = meta(method)
      doc =
        name: md.name
        description: md.doc
      doc

    protoDoc = (proto) ->
      md = meta(proto)
      doc =
        name: md.name
        description: md.doc
        methods: []

      doc.methods.push methodDoc proto[method] for own method of proto
      doc

    protocol.define = protoDefine
    protocol.extend = protoExtend
    protocol.doc = protoDoc

    protocol
) ->
  if "object" is typeof exports
    meta = require './meta'
    identity = require './identity'
    module.exports = factory meta, identity
  else if define?.amd
    define ['./meta', './identity'], factory
  else
    root.cosy.protocol = factory root.cosy.lang.meta, root.cosy.lang.identity
  return
