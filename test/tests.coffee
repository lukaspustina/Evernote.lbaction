rewire = require 'rewire'
expect = require('chai').expect

describe 'Evernote Launchbar Action', ->

  beforeEach ->
    global.LaunchBar = new MockLaunchbar
    global.Action = new MockAction
    global.lbaction = rewire '../target/default.js'

  afterEach ->
    delete global.lbaction
    delete global.Action
    delete global.LaunchBar

  context "runWithString", ->

    context "empty String", ->

      it 'show default menu', ->
        menu = lbaction.runWithString ""
        expect(menu.length).to.eql 3


class MockLaunchbar

  log: (msg) ->

  executeAppleScriptFile: (args) ->


class MockAction

  path: './'

