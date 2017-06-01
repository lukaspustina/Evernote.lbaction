# Launchbar Evernote Action

## Public

loadSettings = (settingsFile) ->
  object = try
    File.readJSON(settingsFile)
  catch
    {}

  if not object.debug
    object.debug = false

  if not object.saved_searches
    object.saved_searches = []

  if not object.max_results
    object.max_results = 20

  object


SETTINGS_FILE = "#{Action.path}/Contents/Scripts/settings.js"
SETTINGS = loadSettings(SETTINGS_FILE)


log = (msg) ->
  if SETTINGS.debug
    LaunchBar.log msg


saved_searches = (argument) ->
  log("saved_searches")
  log(JSON.stringify(arguments))

  mapSavedSearch(SETTINGS.saved_searches)


mapSavedSearch = (saved_searches) ->
  items = ( {title: ss.name, actionArgument: ss.search, action: 'runWithString', actionReturnsItems: true }for ss in saved_searches)
  items


handleNote= (note) ->
  Evernote.handleNote note


createNote = () ->
  Evernote.createNote()


syncNow = () ->
  Evernote.syncNow()


run = (query) ->
  log "run: '#{query}'"
  Evernote.open()
  log "run: '#{query}' done."


runWithString = (query) ->
  log "runWithString: '#{query}'"
  log JSON.stringify(query)
  #createNewNote = LaunchBar.options.shiftKey ? 1 : 0

  if query.length > 0
    Evernote.search query, SETTINGS.max_results, SETTINGS.debug
  else
    [
      { title: "Saved Searches", action: 'saved_searches', actionReturnsItems: true },
      { title: "Create new Note", action: 'createNote', icon:'com.evernote.Evernote' },
      { title: "Synchronize now", action: 'syncNow' },
      { title: "Edit Settings", path: SETTINGS_FILE }
    ]


## Private

class Evernote
  @open: ->
    LaunchBar.executeAppleScript """
      tell application "LaunchBar" to hide
      tell application "Evernote"
        open collection window
        activate
      end tell
    """


  @search: (query, maxResults, debug) ->
    results = Evernote._evernote_search query, maxResults, debug

    # Postprocess: Add action
    for r in results
      r.action = 'handleNote'

    # Postprocess: Sort by modification date
    results.sort (a, b) ->
      left = new Date(a.date)
      right = new Date(b.date)
      if left < right
        1
      if left > right
        -1
      0

    log "search result: '#{JSON.stringify results}'"
    results


  @_evernote_search: (query, maxResults, debug) ->
    notes = LaunchBar
      .executeAppleScriptFile "#{Action.path}/Contents/Scripts/findNotes.applescript", query, maxResults, debug
      .replace /@@\\@@/g, "\\'" # re-escaping '; cf. findNotes.applescript
    if notes.length > 0
      eval(notes)
    else
      []


  @handleNote: (note) ->
    log "@handleNote"
    Evernote._open_note note


  @_open_note: (note) ->
    log "@_open_note: '#{JSON.stringify note}'"
    LaunchBar.executeAppleScript """
      tell application "LaunchBar" to hide
      tell application "Evernote"
        set theNote to find note "#{note.notelink}"
        open note window with theNote
        activate
      end tell
    """


  @createNote: () ->
    log "createNote"
    LaunchBar.executeAppleScript """
      tell application "LaunchBar" to hide
      tell application "Evernote"
        set theNote to create note with text " "
        open note window with theNote
        activate
      end tell
    """


  @syncNow: () ->
    log "syncNow"
    LaunchBar.executeAppleScript """
      tell application "LaunchBar" to hide
      tell application "Evernote"
        synchronize
      end tell
    """


# Export for testing only, when not running in real LaunchBar context
if not LaunchBar.systemVersion
  module.exports =
    Evernote: Evernote
    run: run
    runWithString: runWithString
    loadSettings: loadSettings
    mapSavedSearch: mapSavedSearch
    handleNote: handleNote
    createNote: createNote
    syncNow: syncNow

