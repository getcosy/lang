"use strict"

{assert} = require 'chai'
{spy, stub} = require 'sinon'

suite "promise", ->
    promise = null
    setup ->
        promise = require '../src/promise'

    suite 'IPromise:', ->
        _when = deliver = null

        setup ->
            {when: _when, deliver} = promise.IPromise

        test 'has when', ->
            assert.isFunction _when

        test 'has deliver', ->
            assert.isFunction deliver

        suite 'Defaults:', ->
            vals = [null, 1, "string", {}]

            for val in vals
                test val, ->
                    deliveredVal = _when val, (newVal) -> newVal
                    assert.strictEqual deliveredVal, val
