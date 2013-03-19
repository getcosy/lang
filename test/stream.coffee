"use strict"

{assert} = require 'chai'
{spy, stub} = require 'sinon'
protocol = require '../src/protocol'
{IPromise} = require '../src/promise'
{ISeq, first, rest, map, filter} = require '../src/sequence'

{when: _when} = IPromise

suite "stream", ->
	stream = null
	class SimpleStream
		tap: (@fn) ->
		emit: (val) ->
			@fn val

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

		test 'A sink is a sequence', ->
			assert.isTrue protocol.implements ISeq, sink

		test 'first(sink) -> promise', ->
			assert.isTrue protocol.implements IPromise, first sink

		test 'calling first twice yelds same result', ->
			assert.strictEqual (first sink), (first sink)

		test 'emitting on the stream realises promise', ->
			actual = null
			(_when (first sink), (val) -> actual = val)
			stream.IStream.emit simple, 1
			assert.strictEqual actual, 1

		test 'emitting twice does not realise twice', ->
			actual = null
			(_when (first sink), (val) -> actual = val)
			stream.IStream.emit simple, 1
			stream.IStream.emit simple, 2
			assert.strictEqual actual, 1

		test 'rest(sink) is a sequence', ->
			assert.isTrue protocol.implements ISeq, (rest sink)

		test 'first(rest(sink)) -> promise', ->
			assert.isTrue protocol.implements IPromise, (first (rest sink))

		test 'emitting twice realises first rest', ->
			actual = null
			(_when (first (rest sink)), (val) -> actual = val)
			stream.IStream.emit simple, 1
			stream.IStream.emit simple, 2
			assert.strictEqual actual, 2

	suite 'sequence', ->
		simple = null
		setup ->
			simple = new SimpleStream

		test 'filter', ->
			odds = (x) -> x&1
			filtered = filter odds, simple
			# console.log filtered
			stream.IStream.emit simple, 1
			#(_when (first filtered), (val) -> assert.strictEqual val, 1)