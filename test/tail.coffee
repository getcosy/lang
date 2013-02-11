"use strict"

{assert} = require 'chai'
{spy, stub} = require 'sinon'

suite "tail", ->
	tail = null
	setup ->
		tail = require '../src/tail'

	test 'not a loop returns', ->
		ret = tail.loop ->
			1
		assert.equal ret, 1

	test 'simple loop returns last val', ->
		fn = (count) ->
			if (count)
				tail.recur fn, count - 1
			else
				"done"
		ret = tail.loop fn, 10
		assert.equal ret, "done"

	test 'call stack does not grow', ->
		fn = (count) ->
			if (count)
				tail.recur fn, count - 1
			else
				throw new Error
		try
			tail.loop fn, 1
		catch e
			stack2 = (e.stack.split /\n/).length

		try
			tail.loop fn, 100
		catch e
			stack100 = (e.stack.split /\n/).length

		assert.equal stack100, stack2
