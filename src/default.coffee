# Launchbar Evernote Action

## Public

SETTINGS_FILE = ""
SETTINGS = []

run = (query) ->
  log "run: '#{query}'"
  Evernote.open()
  log "run: '#{query}' done."


runWithString = (query) ->
  log "runWithString: '#{query}'"
  log JSON.stringify(query)

  if query.length >= SETTINGS.query_min_len
    search_results = Evernote.search query, SETTINGS.max_results, SETTINGS.debug
    mapSearchResults search_results
  else
    [
      { title: "Saved Searches", action: 'saved_searches', actionReturnsItems: true, icon: 'search.png' },
      { title: "Create new Note", action: 'createNote', icon:'com.evernote.Evernote' },
      { title: "Synchronize now", action: 'syncNow', icon: 'sync.png' },
      { title: "Edit Settings", path: SETTINGS_FILE, icon: 'settings.png' }
    ]


## Private

handleNote = (note) ->
  Evernote.handleNote note


createNote = () ->
  Evernote.createNote()


syncNow = () ->
  Evernote.syncNow()


saved_searches = (argument) ->
  log("saved_searches")
  log(JSON.stringify(arguments))

  mapSavedSearch(SETTINGS.saved_searches)


mapSavedSearch = (saved_searches) ->
  items = ( {title: ss.name, actionArgument: ss.search, action: 'runWithString', actionReturnsItems: true, icon: 'search.png', subtitle: ss.search, alwaysShowsSubtitle: true } for ss in saved_searches)
  items


mapSearchResults = (search_results) ->
  results = []

  # Post process: Add Launchbar display information
  for r in search_results
    result = {}

    result.title = r.title
    result.label = r.notebook
    result.date = r.date
    date = new Date(r.date)
    s_date = LaunchBar.formatDate date,
      relativeDateFormatting: true
      timeStyle: 'short'
      dateStyle: 'medium'
    result.subtitle = if r.tags && Object.keys(r.tags).length > 0
      "#{s_date} - #{r.tags}"
    else
      "#{s_date}"
    result.action = 'handleNote'
    result.alwaysShowsSubtitle = true
    result.icon = 'com.evernote.Evernote'
    result.notelink = r.notelink

    results.push result

  # Postprocess: Sort by modification date
  results.sort (a, b) ->
    left = new Date(a.date)
    right = new Date(b.date)
    if left < right
      return 1
    if left > right
      return -1
    return 0

  results


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
  if not object.query_min_len
    object.query_min_len = 3

  object


log = (msg) ->
  if SETTINGS.debug
    LaunchBar.log msg


class Evernote
  @open: ->
    log "@open"
    LaunchBar.executeAppleScript """
      tell application "LaunchBar" to hide
      tell application "Evernote"
        open collection window
        activate
      end tell
    """
    log "@open: done"


  @search: (query, maxResults, debug) ->
    log "@search: '#{query}, #{maxResults}, #{debug}'"
    results = Evernote._evernote_search query, maxResults, debug
    log "search result: '#{JSON.stringify results}'"
    log "@search: done"
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
    if LaunchBar.options.commandKey
      Evernote._copy_note_link note
    else
      Evernote._open_note note
    log "@handleNote: done"


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
    log "@_open_note: done"


  @_copy_note_link: (note) ->
    log "@_copy_note_link: '#{JSON.stringify note}'"
    LaunchBar.executeAppleScript """
      tell application "LaunchBar" to hide
      set the clipboard to "#{note.notelink}"
    """
    log "@_copy_note_link: done"


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
    log "createNote: done"


  @syncNow: () ->
    log "syncNow"
    LaunchBar.executeAppleScript """
      tell application "LaunchBar" to hide
      tell application "Evernote"
        synchronize
      end tell
    """
    log "syncNow: done"


init = () ->
  if LaunchBar && LaunchBar.systemVersion
    SETTINGS_FILE = "#{Action.path}/Contents/Scripts/settings.js"
  else
    module.exports =
      Evernote: Evernote
      run: run
      runWithString: runWithString
      loadSettings: loadSettings
      mapSavedSearch: mapSavedSearch
      mapSearchResults: mapSearchResults
      handleNote: handleNote
      createNote: createNote
      syncNow: syncNow

  SETTINGS = loadSettings(SETTINGS_FILE)

init()

