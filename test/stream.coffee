"use strict"

{assert} = require 'chai'
{spy, stub} = require 'sinon'
protocol = require '../src/protocol'
{IPromise} = require '../src/promise'
sequence = require '../src/sequence'
ISync = require '../src/protocols/ISync'
{ISeq, first, rest, map, filter, lazy, cons} = sequence
{when: _when} = IPromise

suite "stream", ->
    stream = null
    class SimpleStream
        constructor: ->
            @fns = []
        tap: (fn) ->
            @fns.push fn
        emit: (val) ->
            fn val for fn in @fns

    setup ->
        stream = require '../src/stream'
        protocol.extend stream.IStream, SimpleStream,
            ['tap', (s, fn) -> s.tap fn]
            ['emit', (s, val) -> s.emit val]

    suite 'IStream', ->
        test 'tap/emit', ->
            expected = {}
            emitted = null
            simple = new SimpleStream

            stream.tap simple, (val) ->
                emitted = val
            stream.emit simple, expected

            assert.strictEqual emitted, expected

    suite 'sink:', ->
        sink = simple = null

        setup ->
            simple = new SimpleStream
            sink = stream.sink simple

        test 'first is skip until emitted', ->
            assert.strictEqual (first sink), stream.skip

        test 'first is value when emitted', ->
            value = 1
            stream.emit simple, value
            assert.strictEqual (first sink), value

        test 'first is still value when emitted twice', ->
            value = 1
            value2 = 2
            stream.emit simple, value
            stream.emit simple, value2
            assert.strictEqual (first sink), value

        test 'rest returns the same sequence', ->
            assert.strictEqual (rest sink), (rest sink)

        test 'rest is next value when emitted', ->
            value = 1
            value2 = 2
            value3 = 5
            stream.emit simple, value
            assert.strictEqual (first sink), value
            stream.emit simple, value2
            assert.strictEqual (first (rest sink)), value2
            stream.emit simple, value3
            assert.strictEqual (first (rest (rest sink))), value3

    suite 'source:', ->
        simple = null

        setup ->
            simple = new SimpleStream

        test 'Simple sequence', ->
            actual = []
            expected = [1, 2, 3 ,4]
            source = stream.source expected
            stream.tap source, (val) ->
                actual.push val
            assert.deepEqual actual, expected

        test 'sink', ->
            source = stream.source stream.sink simple
            actual = []
            expected = [1, 2, 3 ,4]
            stream.tap source, (val) ->
                actual.push val

            for val in expected
                stream.emit simple, val

            assert.deepEqual actual, expected

    suite 'pipe:', ->
        src = tgt = null

        setup ->
            src = new SimpleStream
            tgt = new SimpleStream
            stream.pipe src, tgt

        test 'pipe', ->
            actual = []
            expected = [1, 2, 3 ,4]
            stream.tap tgt, (val) ->
                actual.push val

            for val in expected
                stream.emit src, val

            assert.deepEqual actual, expected

    suite 'Lazy evaluation:', ->
        suite '1 lazy sequence:', ->
            lazySequence = simple = s = null

            setup ->
                simple = new SimpleStream
                lazySequence = filter ((x)-> x&1), simple

            test 'first of an unemitted stream returns skip', ->
              assert.strictEqual (first lazySequence), stream.skip

            test 'first of an emmited stream returns val', ->
              value = 1
              stream.emit simple, value
              assert.strictEqual (first lazySequence), value

            test 'first is still value when emitted twice', ->
              value = 1
              value2 = 2
              stream.emit simple, value
              stream.emit simple, value2
              assert.strictEqual (first lazySequence), value

            test 'filter', ->
                value = 1
                value2 = 2
                value3 = 3
                stream.emit simple, value
                assert.strictEqual (first lazySequence), value
                assert.strictEqual (first (rest lazySequence)), stream.skip
                stream.emit simple, value2
                assert.strictEqual (first (rest lazySequence)), stream.skip
                stream.emit simple, value3
                assert.strictEqual (first (rest lazySequence)), value3

        suite '2 lazy sequences:', ->
            fizzbuzz = fizz = buzz = simple = null

            setup ->
                simple = new SimpleStream
                fizz = filter ((x)-> 0 is x % 3), simple
                buzz = filter ((x)-> 0 is x % 5), simple
                fizzbuzz = filter ((x)-> 0 is x % 5), fizz

            test 'fizz', ->
                stream.emit simple, 5
                assert.strictEqual (first fizz), stream.skip
                stream.emit simple, 3
                assert.strictEqual (first fizz), 3

            test 'buzz', ->
                stream.emit simple, 5
                assert.strictEqual (first buzz), 5
                stream.emit simple, 3
                assert.strictEqual (first buzz), 5

            test 'fizzbuzz', ->
                stream.emit simple, 15
                assert.strictEqual (first fizz), 15
                assert.strictEqual (first buzz), 15
                assert.strictEqual (first fizzbuzz), 15

        suite 'take:', ->
            taken = simple = null

            setup ->
                simple = new SimpleStream
                taken = sequence.take 5, simple

            test 'take empty', ->
                assert.strictEqual (first taken), stream.skip

            test 'take 1', ->
                stream.emit simple, 1
                assert.strictEqual (first taken), 1
                assert.strictEqual (first taken), 1
                assert.strictEqual (first (rest taken)), stream.skip

            test 'take 2', ->
                stream.emit simple, 1
                assert.strictEqual (first taken), 1
                stream.emit simple, 2
                assert.strictEqual (first taken), 1
                assert.strictEqual (first (rest taken)), 2

            test 'take all', ->
                current = taken
                for i in [1..5]
                    assert.strictEqual (first current), stream.skip
                    stream.emit simple, i
                    assert.strictEqual (first current), i
                    current = (rest current)
                assert.strictEqual (first current), null

        suite 'drop', ->
            dropped = simple = null

            setup ->
                simple = new SimpleStream
                dropped = sequence.drop 5, simple

            test 'dropped', ->
                for i in [1..5]
                    stream.emit simple, i
                    assert.strictEqual (first dropped), stream.skip
                stream.emit simple, 1
                assert.strictEqual (first dropped), 1

        suite 'source:', ->
            taken = simple = null

            setup ->
                simple = new SimpleStream
                taken = sequence.take 5, simple

            test 'lazy sync', ->
                actual = []
                expected = [1, 2, 3, 4, 5]

                stream.tap taken, (val) ->
                    actual.push val

                for val in expected
                    stream.emit simple, val

                stream.emit simple, 6
                assert.deepEqual actual, expected
