"use strict"

{assert} = require 'chai'
{spy, stub} = require 'sinon'

suite "protocol", ->
	protocol = null

	setup ->
		protocol = require '../src/protocol'

	suite 'definition', ->
		test 'requires name', ->
			assert.throws ->
				protocol.define null

		test 'requires array def', ->
			assert.throws ->
				protocol.define 'protocol', null
			assert.throws ->
				protocol.define 'protocol', 'doc', null

		suite 'def args', ->
			test 'name must be string', ->
				assert.throws ->
					protocol.define 'protocol', 'doc', [null]

			test 'arg list must be array', ->
				assert.throws ->
					protocol.define 'protocol', 'doc', ['method', null]

			test 'method created', ->
				proto = protocol.define 'protocol', 'doc', ['method', ['self']]
				assert.isFunction proto.method

	test 'extend requires proto', ->
		assert.throws ->
			protocol.extend {}

	suite 'extension', ->
		proto = null

		setup ->
			proto = protocol.define 'proto',
				[ 'simple', ['self'] ]
				[ 'multi', ['self'], ['self', 'extra'] ]

		test 'extend simple', ->
			protocol.extend proto, null,
				['simple', (self) -> ]