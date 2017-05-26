
SETTINGS_FILE = Action.path + '/Contents/Scripts/settings.js'

runWithString = (query) ->
  LaunchBar.log("runWithString")
  LaunchBar.log(JSON.stringify(query))
  #createNewNote = LaunchBar.options.shiftKey ? 1 : 0

  #LaunchBar.executeAppleScriptFile('openNote.applescript', query, createNewNote)

  if query.length > 0
    [
      { title: "Result 1: " + query },
      { title: "Result 2: " + query },
      { title: "Result 3: " + query },
      { title: "Result 4: " + query }
    ]
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

search = (query) ->
  [
    { title: "Result 1: " + query },
    { title: "Result 2: " + query },
    { title: "Result 3: " + query },
    { title: "Result 4: " + query }
  ]

loadSettings = (settingsFile) ->
  object = File.readJSON(settingsFile)
  object


# Export for testing only, when not running in real LaunchBar context
if not LaunchBar.systemVersion
  module.exports = { runWithString: runWithString }

