"use strict"

{assert} = require 'chai'
{spy, stub} = require 'sinon'

suite "lang", ->
	lang = null
	modules = [
		'dispatch'
		'identity'
		'meta'
		'promise'
		'protocol'
		'sequence'
		'stream'
		'tail'
	]

	setup ->
		lang = require '../src/lang'

	for module in modules
		test module, ->
			assert.isObject lang[module]
