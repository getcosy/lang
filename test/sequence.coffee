"use strict"

{assert} = require 'chai'
{spy, stub} = require 'sinon'

suite "sequence", ->
    sequence = null
    setup ->
        sequence = require '../src/sequence'

    suite 'ISeq:', ->
        first = rest = conj = null

        setup ->
            {first, rest, conj} = sequence.ISeq

        test 'has first', ->
            assert.isFunction first

        test 'has rest', ->
            assert.isFunction rest

        test 'has conj', ->
            assert.isFunction conj

        suite 'null:', ->
            test 'first(null)', ->
                assert.isNull first null

            test 'rest(null)', ->
                assert.isNull rest null

            test 'conj(null, item)', ->
                assert.deepEqual (conj null, 1), [1]

        suite 'Array:', ->
            arr = null

            setup ->
                arr = [1, 2, 3, 4]

            test 'first(Array)', ->
                assert.strictEqual (first arr), 1

            test 'rest(Array)', ->
                assert.deepEqual (rest arr), [2, 3, 4]

            test 'conj(Array, seq)', ->
                assert.deepEqual (conj arr, 5), [1, 2, 3, 4, 5]
