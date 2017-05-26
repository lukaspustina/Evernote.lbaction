rewire = require 'rewire'
expect = require('chai').expect

describe 'Evernote Launchbar Action', ->

  beforeEach ->
    global.LaunchBar = new MockLaunchbar
    global.Action = new MockAction
    global.File = new MockFile
    global.lbaction = rewire '../target/default.js'
    global.lbaction.SETTINGS_FILE = "#{__dirname}//test_settings.js"

  afterEach ->
    delete global.lbaction
    delete global.File
    delete global.Action
    delete global.LaunchBar

  context "runWithString", ->

    context "for empty String", ->

      it 'show default menu', ->
        menu = lbaction.runWithString ""
        expect(menu.length).to.eql 3

  context "Helper", ->

    context "Settings", ->

      it 'load settings from file', ->
        settings = lbaction.loadSettings lbaction.SETTINGS_FILE
        expect(settings.saved_searches.length).to.eql 5



class MockLaunchbar

  log: (msg) ->

  executeAppleScriptFile: (args) ->


class MockAction

  path: './'


class MockFile

  readJSON: (file) ->
    fs = require 'fs'
    JSON.parse fs.readFileSync(file, 'utf8')

