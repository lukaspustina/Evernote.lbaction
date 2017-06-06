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
    sinon.spy lbaction.Evernote, 'handleNote'
    sinon.spy lbaction.Evernote, 'createNote'
    sinon.spy lbaction.Evernote, 'search'
    sinon.spy lbaction.Evernote, 'syncNow'
    sinon.stub(lbaction.Evernote, '_open_note')
    sinon.stub(lbaction.Evernote, '_copy_note_link')
    sinon.stub(lbaction.Evernote, '_evernote_search').returns [
        { title: "Result 1: " },
        { title: "Result 2: " },
        { title: "Result 3: " },
        { title: "Result 4: " }
      ]

    global.lbaction.SETTINGS_FILE = "#{__dirname}/test_settings.js"

  afterEach ->
    lbaction.Evernote._evernote_search.restore()
    lbaction.Evernote._copy_note_link.restore()
    lbaction.Evernote._open_note.restore()
    lbaction.Evernote.syncNow.restore()
    lbaction.Evernote.search.restore()
    lbaction.Evernote.createNote.restore()
    lbaction.Evernote.handleNote.restore()
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
        expect(menu.length).to.eql 4

    context "for query string smaller than query_min_len", ->

      it 'do not search', ->
        lbaction.runWithString "a"
        lbaction.runWithString "aa"
        expect(lbaction.Evernote.search.calledOnce).to.eql false

    context "for query String", ->

      it 'show search results', ->
        results = lbaction.runWithString "a search"
        expect(lbaction.Evernote.search.calledOnce).to.eql true
        expect(results.length).to.eql 4
        results.should.all.have.property 'title'
        results.should.all.have.property 'label'
        results.should.all.have.property 'subtitle'
        results.should.all.have.property 'action'
        results.should.all.have.property 'alwaysShowsSubtitle'
        results.should.all.have.property 'icon'
        results.should.all.have.property 'notelink'


  context "handleNote", ->

    context "open note", ->

      context "for selected search result", ->

        it "open note window with selected note", ->
          results = lbaction.runWithString "a search"
          results.should.have.length 4
          lbaction.handleNote(results[2])
          lbaction.Evernote.handleNote.calledOnce.should.be.eql true
          lbaction.Evernote._open_note.calledOnce.should.be.eql true

    context "copy note link", ->

      context "for selected search result", ->

        beforeEach ->
          global.LaunchBar.options =
            commandKey: true

        afterEach ->
          global.LaunchBar.options = {}

        it "copy note link of selected note", ->
          results = lbaction.runWithString "a search"
          results.should.have.length 4
          lbaction.handleNote(results[2])
          lbaction.Evernote.handleNote.calledOnce.should.be.eql true
          lbaction.Evernote._copy_note_link.calledOnce.should.be.eql true


  context "createNote", ->

      it "open note window with new note", ->
        lbaction.createNote()
        lbaction.Evernote.createNote.calledOnce.should.be.eql true


  context "syncNow", ->

      it "synchronize now", ->
        lbaction.syncNow()
        lbaction.Evernote.syncNow.calledOnce.should.be.eql true


  context "saved search", ->

    it 'run search for saved search', ->
      settings = lbaction.loadSettings lbaction.SETTINGS_FILE
      results = lbaction.runWithString settings.saved_searches[0].search
      expect(lbaction.Evernote.search.calledOnce).to.eql true
      expect(results.length).to.eql 4
      results.should.all.have.property 'action'


  context "helper", ->

    context "settings", ->

      context "no settings file", ->

        it 'load settings from file', ->
          settings = lbaction.loadSettings "no such file"
          settings.debug.should.be.eql false
          settings.max_results.should.be.eql 20
          settings.query_min_len.should.be.eql 3
          settings.saved_searches.length.should.be.eql 0

      context "empty settings", ->

        beforeEach ->
          global.lbaction.SETTINGS_FILE = "#{__dirname}/test_settings_empty.js"

        it 'load settings from file', ->
          settings = lbaction.loadSettings lbaction.SETTINGS_FILE
          settings.debug.should.be.eql false
          settings.max_results.should.be.eql 20
          settings.query_min_len.should.be.eql 3
          settings.saved_searches.length.should.be.eql 0

      context "full settings", ->

        it 'load settings from file', ->
          settings = lbaction.loadSettings lbaction.SETTINGS_FILE
          settings.debug.should.be.eql true
          settings.max_results.should.be.eql 30
          settings.query_min_len.should.be.eql 3
          settings.saved_searches.length.should.be.eql 5

    context "saved searches", ->

      it "map saved search to menu item", ->
        saved_searches = [ { name: 'A saved search', search: 'intitle:"A title"' } ]
        items = lbaction.mapSavedSearch saved_searches
        items[0].title.should.be.eql saved_searches[0].name
        items[0].actionArgument.should.be.eql saved_searches[0].search
        items[0].action.should.be.eql 'runWithString'
        items[0].actionReturnsItems.should.be.eql true


class MockLaunchbar

  options: {}

  log: (msg) ->

  executeAppleScriptFile: (args) ->

  executeAppleScript: (args) ->

  formatDate: (date, args) ->
    date


class MockAction

  path: './'


class MockFile

  readJSON: (file) ->
    fs = require 'fs'
    JSON.parse fs.readFileSync(file, 'utf8')

