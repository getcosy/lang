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

