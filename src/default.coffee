
SETTINGS_FILE = "#{Action.path}/Contents/Scripts/settings.js"

class Evernote
  @open: ->
    LaunchBar.executeAppleScript """
      tell application "LaunchBar" to hide
      tell application "Evernote"
        open collection window
        activate
      end tell
    """

  @search = (query) ->
    results = Evernote._evernote_search query, 20, true

    # Postprocess: Add action
    for r in results
      r.action = 'openNote'

    # Postprocess: Sort by modification date
    results.sort (a, b) ->
      left = new Date(a.date)
      right = new Date(b.date)
      if left < right
        1
      if left > right
        -1
      0

    LaunchBar.log "search result: '#{JSON.stringify results}'"
    results


  @_evernote_search: (query, maxResults, debug) ->
    notes = LaunchBar
      .executeAppleScriptFile "#{Action.path}/Contents/Scripts/findNotes.applescript", query, maxResults, debug
      .replace /@@\\@@/g, "\\'" # re-escaping '; cf. findNotes.applescript
    if notes.length > 0
      eval(notes)
    else
      []


  @openNote: (note) ->
    LaunchBar.log "openNote: '#{JSON.stringify note}'"
    LaunchBar.executeAppleScript """
      tell application "LaunchBar" to hide
      tell application "Evernote"
        set theNote to find note "#{note.notelink}"
        open note window with theNote
        activate
      end tell
    """


run = (query) ->
  LaunchBar.log "run: '#{query}'"
  Evernote.open()
  LaunchBar.log "run: '#{query}' done."


runWithString = (query) ->
  LaunchBar.log "runWithString: '#{query}'"
  LaunchBar.log JSON.stringify(query)
  #createNewNote = LaunchBar.options.shiftKey ? 1 : 0

  #LaunchBar.executeAppleScriptFile('openNote.applescript', query, createNewNote)

  if query.length > 0
    Evernote.search query
  else
    [
      { title: "Saved Searches", action: 'saved_searches', actionReturnsItems: true },
      { title: "Create new Note" },
      { title: "Edit Settings", path: SETTINGS_FILE }
    ]


runWithItem = (item) ->
  LaunchBar.log("runWithItem")
  LaunchBar.log(JSON.stringify(item))


saved_searches = (argument) ->
  LaunchBar.log("saved_searches")
  LaunchBar.log(JSON.stringify(arguments))
  settings = loadSettings(SETTINGS_FILE)

  settings.saved_searches


loadSettings = (settingsFile) ->
  object = File.readJSON(settingsFile)
  object


openNote = (note) ->
  Evernote.openNote note


# Export for testing only, when not running in real LaunchBar context
if not LaunchBar.systemVersion
  module.exports =
    Evernote: Evernote
    run: run
    runWithString: runWithString
    loadSettings: loadSettings
    openNote: openNote

