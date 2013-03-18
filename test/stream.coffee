"use strict"

{assert} = require 'chai'
{spy, stub} = require 'sinon'
protocol = require '../src/protocol'
{map} = require '../src/sequence'

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

	# suite 'Sequence', ->
	# 	test 'lazy-seq', ->
	# 		emitted = null
	# 		simple = new SimpleStream
	# 		mappedSimple = map ((x) -> 2*x), simple

	# 		stream.IStream.tap mappedSimple, (val) ->
	# 			emitted = val

	# 		stream.IStream.emit simple, 1

	# 		assert.strictEqual emitted, 2
