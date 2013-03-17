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

    suite 'cons:', ->
        test 'car', ->
            assert.strictEqual (first (cons 1, [2])), 1

        test 'cadr', ->
            assert.strictEqual (first (rest (cons 1, [2]))), 2

    suite 'lazy:', ->
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

    suite 'vec:', ->
        vec = null

        setup ->
            {vec} = sequence

        test 'array', ->
            assert.deepEqual (vec [1, 2, 3, 4]), [1, 2, 3, 4]

        test 'cons', ->
            assert.deepEqual (vec (cons 1, [2])), [1, 2]

    suite 'map:', ->
        map = vec = null

        setup ->
            {map, vec} = sequence

        test '1 arg', ->
            fn = (x) -> x*2
            result = (map fn, [1, 2, 3])
            assert.deepEqual (vec result), [2, 4, 6]

        test '2 args', ->
            fn = (x, y) -> x+y
            result = (map fn, [1, 2, 3], [4, 5, 6])
            assert.deepEqual (vec result), [5, 7, 9]

    suite 'reduce:', ->
        reduce = fn = null

        setup ->
            {reduce} = sequence
            fn = (x, y) ->
                return 0 unless x?
                x + y

        test 'empty coll', ->
            assert.strictEqual (reduce fn, []), 0

        test 'val & empty coll', ->
            assert.strictEqual (reduce fn, 1, []), 1

        test 'std coll', ->
            assert.strictEqual (reduce fn, [1, 2, 3, 4]), 10

        test 'val & std coll', ->
            assert.strictEqual (reduce fn, 5, [1, 2, 3, 4]), 15

    suite 'filter:', ->
        filter = vec = isOdd = null

        setup ->
            {filter, vec} = sequence
            isOdd = (x) ->
                x & 1

        test 'odds', ->
            odds = (filter isOdd, [1, 2, 3, 4, 5])
            assert.deepEqual (vec odds), [1, 3, 5]

    test 'take', ->
        {take, vec} = sequence
        taken = (take 3, [1, 2, 3, 4, 5, 6])
        assert.deepEqual (vec taken), [1, 2, 3]

    test 'drop', ->
        {drop, vec} = sequence
        taken = (drop 3, [1, 2, 3, 4, 5, 6])
        assert.deepEqual (vec taken), [4, 5, 6]

    suite 'partition', ->
        partition = vec = null
        setup ->
            {partition, vec} = sequence

        test 'no step', ->
            windows = (partition 3, [1, 2, 3, 4, 5, 6])
            assert.deepEqual (vec first windows), [1, 2, 3]
            assert.deepEqual (vec first rest windows), [4, 5, 6]

        test 'step', ->
            windows = (partition 4, 3, [1, 2, 3, 4, 5, 6])
            assert.deepEqual (vec first windows), [1, 2, 3, 4]
            assert.deepEqual (vec first rest windows), [4, 5, 6]
