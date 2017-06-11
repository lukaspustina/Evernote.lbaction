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
    sinon.spy lbaction.Evernote, 'createNote'
    sinon.spy lbaction.Evernote, 'search'
    sinon.spy lbaction.Evernote, 'syncNow'
    sinon.stub(lbaction.Evernote, 'open_search_window')
    sinon.stub(lbaction.Evernote, 'open_note')
    sinon.stub(lbaction.Evernote, 'copy_note_link')
    sinon.stub(lbaction.Evernote, '_evernote_search').returns [
        { title: "Result 1: " },
        { title: "Result 2: " },
        { title: "Result 3: " },
        { title: "Result 4: " }
      ]

    global.lbaction.SETTINGS_FILE = "#{__dirname}/test_settings.js"

  afterEach ->
    lbaction.Evernote._evernote_search.restore()
    lbaction.Evernote.copy_note_link.restore()
    lbaction.Evernote.open_note.restore()
    lbaction.Evernote.open_search_window.restore()
    lbaction.Evernote.syncNow.restore()
    lbaction.Evernote.search.restore()
    lbaction.Evernote.createNote.restore()
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
        results.should.all.have.property 'query'


  context "handle search result", ->

    context "open note", ->

      context "for selected search result", ->

        it "open note window with selected note", ->
          results = lbaction.runWithString "a search"
          results.should.have.length 4
          lbaction.handleSearchResult(results[2], "a search")
          lbaction.Evernote.open_note.calledOnce.should.be.eql true

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
          lbaction.handleSearchResult(results[2], "a search")
          lbaction.Evernote.copy_note_link.calledOnce.should.be.eql true


    context "open collection window", ->

      context "for query", ->

        beforeEach ->
          global.LaunchBar.options =
            commandKey: true
            shiftKey: true

        afterEach ->
          global.LaunchBar.options = {}

        it "open collection window for query", ->
          results = lbaction.runWithString "a search"
          results.should.have.length 4
          lbaction.handleSearchResult(results[2], "a search")
          lbaction.Evernote.open_search_window.calledOnce.should.be.eql true


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


  context "favorite ntoes", ->

    it 'open favorite note', ->
      settings = lbaction.loadSettings lbaction.SETTINGS_FILE
      favorites = lbaction.mapFavorites settings.favorites
      results = lbaction.openNote favorites[0]
      lbaction.Evernote.open_note.calledOnce.should.be.eql true


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
          settings.favorites.length.should.be.eql 2

    context "saved searches", ->

      it "map saved search to menu item", ->
        saved_searches = [ { name: 'A saved search', search: 'intitle:"A title"' } ]
        items = lbaction.mapSavedSearch saved_searches
        items[0].title.should.be.eql saved_searches[0].name
        items[0].actionArgument.should.be.eql saved_searches[0].search
        items[0].action.should.be.eql 'runWithString'
        items[0].actionReturnsItems.should.be.eql true

    context "favorite notes", ->

      it "map favorite not to menu item", ->
        favorites = [ { name: 'A saved search', note_link: 'evernote://...' } ]
        items = lbaction.mapFavorites favorites
        items[0].title.should.be.eql favorites[0].name
        items[0].notelink.should.be.eql favorites[0].note_link
        items[0].action.should.be.eql 'openNote'
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

