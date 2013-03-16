"use strict"

{assert} = require 'chai'
{spy, stub} = require 'sinon'

suite "meta:", ->
    meta = null

    setup ->
        meta = require '../src/meta'

    suite 'only objects have meta data:', ->
        vals = [ "string", 1, 0.9, true, false ]
        for val in vals
            do (val, type = typeof val) ->
                test type + 's have null meta', ->
                    any = val
                    assert.strictEqual meta.get(val), null

        test 'objects have meta data', ->
            assert.isNotNull meta.get({})

        test 'functions have meta data', ->
            assert.isNotNull meta.get(->)

        test 'meta data is an object', ->
            assert.isObject meta.get({})

        test 'same object has identital meta', ->
            obj = {}
            assert.strictEqual meta.get(obj), meta.get(obj)

        test 'meta data is immutable', ->
            obj = {}
            meta.get(obj)
            assert.throws ->
                obj.__cosy_meta = {}

    suite 'Namespaces:', ->
        obj = ns1 = ns2 = null

        setup ->
            obj = {}
            ns1 = 'ns1'
            ns2 = 'ns2'

        test 'objects can have meta namespace', ->
            assert.isObject meta.ns(obj, ns1)

        test 'object ns is not root meta data', ->
            assert.notEqual meta.get(obj), meta.ns(obj, ns1)

        test 'different namespaces are different', ->
            assert.notEqual meta.ns(obj, ns2), meta.ns(obj, ns1)

    if 'function' is typeof Object.defineProperty
        test 'meta hides its inner workings', ->
            obj =
                a: true
            meta.get(obj)
            props = 0
            props += 1 for own prop of obj
            assert.equal props, 1
