"use strict"

{assert} = require 'chai'
{spy, stub} = require 'sinon'
protocol = require '../src/protocol'
{IPromise} = require '../src/promise'
{ISeq, first, rest, map, filter, lazy, cons} = require '../src/sequence'

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

            stream.IStream.tap simple, (val) ->
                emitted = val
            stream.IStream.emit simple, expected

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
            stream.IStream.emit simple, value
            assert.strictEqual (first sink), value

        test 'first is still value when emitted twice', ->
            value = 1
            value2 = 2
            stream.IStream.emit simple, value
            stream.IStream.emit simple, value2
            assert.strictEqual (first sink), value

        test 'rest returns the same sequence', ->
            assert.strictEqual (rest sink), (rest sink)

        test 'rest is next value when emitted', ->
            value = 1
            value2 = 2
            value3 = 5
            stream.IStream.emit simple, value
            assert.strictEqual (first sink), value
            stream.IStream.emit simple, value2
            assert.strictEqual (first (rest sink)), value2
            stream.IStream.emit simple, value3
            assert.strictEqual (first (rest (rest sink))), value3

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
              stream.IStream.emit simple, value
              assert.strictEqual (first lazySequence), value

            test 'first is still value when emitted twice', ->
              value = 1
              value2 = 2
              stream.IStream.emit simple, value
              stream.IStream.emit simple, value2
              assert.strictEqual (first lazySequence), value

            test 'filter', ->
                value = 1
                value2 = 2
                value3 = 3
                stream.IStream.emit simple, value
                assert.strictEqual (first lazySequence), value
                assert.strictEqual (first (rest lazySequence)), stream.skip
                stream.IStream.emit simple, value2
                assert.strictEqual (first (rest lazySequence)), stream.skip
                stream.IStream.emit simple, value3
                assert.strictEqual (first (rest lazySequence)), value3

        suite '2 lazy sequences:', ->
            fizzbuzz = fizz = buzz = simple = null

            setup ->
                simple = new SimpleStream
                fizz = filter ((x)-> 0 is x % 3), simple
                buzz = filter ((x)-> 0 is x % 5), simple
                fizzbuzz = filter ((x)-> 0 is x % 5), fizz

            test 'fizz', ->
                stream.IStream.emit simple, 5
                assert.strictEqual (first fizz), stream.skip
                stream.IStream.emit simple, 3
                assert.strictEqual (first fizz), 3

            test 'buzz', ->
                stream.IStream.emit simple, 5
                assert.strictEqual (first buzz), 5
                stream.IStream.emit simple, 3
                assert.strictEqual (first buzz), 5

            test 'fizzbuzz', ->
                stream.IStream.emit simple, 15
                assert.strictEqual (first fizz), 15
                assert.strictEqual (first buzz), 15
                assert.strictEqual (first fizzbuzz), 15
