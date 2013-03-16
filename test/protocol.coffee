"use strict"

{assert} = require 'chai'
{spy, stub} = require 'sinon'
meta = require '../src/meta'

suite "protocol:", ->
	protocol = null
	setup ->
		protocol = require '../src/protocol'

	suite 'definition:', ->
		ProtocolName = null

		setup ->
			ProtocolName = protocol.define 'ProtocolName',
	    		'documentation'
	    		[ 'aMethod', 'docstring' ]
	    		[ 'anotherMethod', 'other docstring' ]
	
		test 'protocol is defined', ->
    		assert.isObject ProtocolName
    		assert.isFunction ProtocolName.aMethod
    		assert.isFunction ProtocolName.anotherMethod
    		
    	test 'can see docs', ->
    		docs = protocol.doc ProtocolName
    		assert.strictEqual docs.name, 'ProtocolName'
    		assert.strictEqual docs.description, 'documentation'
    		assert.strictEqual docs.methods.length, 2
    		assert.strictEqual docs.methods[0].name, 'aMethod'
    		assert.strictEqual docs.methods[0].description, 'docstring'
    		assert.strictEqual docs.methods[1].name, 'anotherMethod'
    		assert.strictEqual docs.methods[1].description, 'other docstring'

   	suite 'extention:', ->
   		List = null

   		setup ->
   			List = protocol.define 'List', ['first'], ['rest']

   		suite 'null:', ->
   			setup ->
   				protocol.extend List, null,
   					['first', -> 'the first']
   					['rest', -> 'the rest']

   			test 'first', ->
   				assert.strictEqual (List.first null), 'the first'

   			test 'rest', ->
   				assert.strictEqual (List.rest null), 'the rest'

   		suite 'array:', ->
   			setup ->
   				protocol.extend List, Array,
   					['first', (arr) -> arr[0]]
   					['rest', (arr) -> arr.slice(1)]

   			test 'first', ->
   				assert.strictEqual (List.first [1, 2, 3]), 1

   			test 'rest', ->
   				assert.deepEqual (List.rest [1, 2, 3]), [2, 3]

      suite 'string:', ->
        setup ->
          protocol.extend List, "",
            ['first', (str) -> str.substr(0,1)]
            ['rest', (str) -> str.substr(1)]

        test 'first', ->
          assert.strictEqual (List.first 'hello'), 'h'

        test 'rest', ->
          assert.strictEqual (List.rest 'hello'), 'ello'


      suite 'object:', ->
        obj = null
        class MyObject
          constructor: (@first, @rest) ->

        setup ->
          protocol.extend List, MyObject,
            ['first', (obj) -> obj.first]
            ['rest', (obj) -> obj.rest]

          obj = new MyObject 'the first', 'the next'

        test 'first', ->
          assert.strictEqual (List.first obj), 'the first'

        test 'rest', ->
          assert.strictEqual (List.rest obj), 'the next'

        suite 'inheritance:', ->
          obj2 = null
          class OtherClass extends MyObject
      
          setup ->
            obj2 = new OtherClass 'the first', 'the next'

          test 'first', ->
            assert.strictEqual (List.first obj2), 'the first'

          test 'rest', ->
            assert.strictEqual (List.rest obj2), 'the next'

        suite 'overloading:', ->
          obj2 = null
          class AnotherClass extends MyObject
      
          setup ->
            protocol.extend List, AnotherClass,
              ['first', (obj) -> "it's " + obj.first]
              ['rest', (obj) -> "it's " + obj.rest]
            obj2 = new AnotherClass 'the first', 'the next'

          test 'first', ->
            assert.strictEqual (List.first obj), 'the first'
            assert.strictEqual (List.first obj2), "it's the first"

          test 'rest', ->
            assert.strictEqual (List.rest obj), 'the next'
            assert.strictEqual (List.rest obj2), "it's the next"