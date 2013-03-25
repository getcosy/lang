"use strict"

{assert} = require 'chai'
{spy, stub} = require 'sinon'

suite "dispatch", ->
    dispatch = method = null
    setup ->
        {fn$} = require '../src/dispatch'
        method = fn$ {
            0: -> 0
            1: -> 1
            2: -> 2
            $: (a, b, c...) -> c.length
        }

    test 'no args', ->
        assert.strictEqual method(), 0

    test '1 arg', ->
        assert.strictEqual method(1), 1

    test '2 args', ->
        assert.strictEqual method(1, 2), 2

    test 'many args', ->
        assert.strictEqual method(1, 2, 3, 4, 5), 3
