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
      md.extendable = true
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
      typeName = if any is null then 'null' else typeof any
      types[typeName] ?= ->
      types[typeName]

    getId = (dispatcher) ->
      '$__cosy_protocols' + (identity.get dispatcher)

    getDispatchMap = (dispatcher, any) ->
      any?[getId dispatcher]

    extendMethod = (proto, type, name, fn) ->
      md = meta proto[name]
      throw new Error name + ' not extendable' unless md.extendable
      type.prototype[getId proto[name]] = fn

    protoExtend = (proto, type, methods...) ->
      return protoExtend proto, (protoType type), methods... unless type instanceof Object
      type.prototype[getId proto] = true
      extendMethod proto, type, method... for method in methods

    protoExtends = (proto, type) ->
      return protoExtends proto, (protoType type) unless type instanceof Object
      type.prototype[getId proto]?

    protoImplements = (proto, any) ->
      type = any
      type = new (protoType any) unless any instanceof Object
      type[getId proto]?

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

    protocol = {
      define: protoDefine
      extend: protoExtend
      extends: protoExtends
      implements: protoImplements
      doc: protoDoc
    }
) ->
  if "object" is typeof exports
    meta = require './meta'
    identity = require './identity'
    module.exports = factory meta, identity
  else if define?.amd
    define ['./meta', './identity'], factory
  else
    root.cosy ?= {}
    root.cosy.lang ?= {}
    root.cosy.lang.protocol = factory root.cosy.lang.meta, root.cosy.lang.identity
  return
