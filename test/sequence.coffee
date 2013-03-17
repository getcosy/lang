"use strict"

{assert} = require 'chai'
{spy, stub} = require 'sinon'

suite "sequence", ->
    sequence = null
    first = rest = cons = lazy = null
    setup ->
        sequence = require '../src/sequence'
        {first, rest, cons, lazy} = sequence

    suite 'ISeq:', ->
        test 'has first', ->
            assert.isFunction first

        test 'has rest', ->
            assert.isFunction rest

        suite 'null:', ->
            test 'first(null)', ->
                assert.isNull first null

            test 'rest(null)', ->
                assert.isNull rest null

        suite 'Array:', ->
            arr = null

            setup ->
                arr = [1, 2, 3, 4]

            test 'first(Array)', ->
                assert.strictEqual (first arr), 1

            test 'rest(Array)', ->
                assert.deepEqual (rest arr), [2, 3, 4]

    suite 'cons', ->
        test 'car', ->
            assert.strictEqual (first (cons 1, [2])), 1

        test 'cadr', ->
            assert.strictEqual (first (rest (cons 1, [2]))), 2

    suite 'lazy', ->
        called = numbers = null

        setup ->
            called = false
            numbers = (start) ->
                lazy ->
                    called = true
                    cons start, numbers start + 1

        test 'lazy does not invoke body', ->
            assert.isObject (numbers 0)
            assert.isFalse called

        test 'car', ->
            assert.strictEqual (first (numbers 0)), 0

        test 'cadr', ->
            assert.strictEqual (first (rest (numbers 0))), 1
