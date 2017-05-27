rewire = require 'rewire'
sinon = require 'sinon'

chai = require 'chai'
chai.should()
chai.use require('chai-things')
expect = chai.expect

describe 'Evernote Launchbar Action', ->

  beforeEach ->
    global.LaunchBar = new MockLaunchbar
    global.Action = new MockAction
    global.File = new MockFile
    global.lbaction = rewire '../target/default.js'

    sinon.spy lbaction.Evernote, 'open'
    sinon.spy lbaction.Evernote, 'openNote'
    sinon.spy lbaction.Evernote, 'search'
    sinon.stub(lbaction.Evernote, '_evernote_search').returns [
        { title: "Result 1: " },
        { title: "Result 2: " },
        { title: "Result 3: " },
        { title: "Result 4: " }
      ]

    global.lbaction.SETTINGS_FILE = "#{__dirname}//test_settings.js"

  afterEach ->
    lbaction.Evernote._evernote_search.restore()
    lbaction.Evernote.search.restore()
    lbaction.Evernote.openNote.restore()
    lbaction.Evernote.open.restore()
    delete global.lbaction
    delete global.File
    delete global.Action
    delete global.LaunchBar

  context "run", ->
    it 'open Evernote Main Window', ->
      lbaction.run()
      expect(lbaction.Evernote.open.calledOnce).to.eql true


  context "runWithString", ->

    context "for empty String", ->

      it 'show default menu', ->
        menu = lbaction.runWithString ""
        expect(menu.length).to.eql 3

    context "for query String", ->

      it 'show search results', ->
        results = lbaction.runWithString "a search"
        expect(lbaction.Evernote.search.calledOnce).to.eql true
        expect(results.length).to.eql 4
        results.should.all.have.property 'action'


  context "openNote", ->

    context "for selected search result", ->

      it "open note window", ->
        results = lbaction.runWithString "a search"
        results.should.have.length 4
        lbaction.openNote(results[2])
        lbaction.Evernote.openNote.calledOnce.should.be.eql true




  context "helper", ->

    context "settings", ->

      it 'load settings from file', ->
        settings = lbaction.loadSettings lbaction.SETTINGS_FILE
        expect(settings.saved_searches.length).to.eql 5



class MockLaunchbar

  log: (msg) ->

  executeAppleScriptFile: (args) ->

  executeAppleScript: (args) ->


class MockAction

  path: './'


class MockFile

  readJSON: (file) ->
    fs = require 'fs'
    JSON.parse fs.readFileSync(file, 'utf8')

