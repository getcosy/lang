"use strict"

{assert} = require 'chai'
{spy, stub} = require 'sinon'

suite "identity:", ->
    identity = null

    setup ->
        identity = require '../src/identity'

    suite 'only objects have identity:', ->
        vals = [ "string", 1, 0.9, true, false ]
        for val in vals
            do (val, type = typeof val) ->
                test type + 's have null identity', ->
                    any = val
                    assert.strictEqual identity.get(val), null

        test 'objects have idenitiy', ->
            assert.isNotNull identity.get({})

        test 'an object is equal to itself', ->
            obj = {}
            assert.strictEqual identity.get(obj), identity.get(obj)

        test 'two object are not equal', ->
            obj1 = {}
            obj2 = {}
            assert.notEqual identity.get(obj1), identity.get(obj2)
