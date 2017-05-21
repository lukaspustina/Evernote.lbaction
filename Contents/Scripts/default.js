
let SETTINGS_FILE = Action.path + '/Contents/Scripts/settings.js'

function runWithString(query) {
  LaunchBar.log("runWithStrings");
  LaunchBar.log(JSON.stringify(query));
  //createNewNote = LaunchBar.options.shiftKey ? 1 : 0;

  //LaunchBar.executeAppleScriptFile('openNote.applescript', query, createNewNote);

  if (query.length > 0) {
    return [
      { title: "Result 1: " + query },
      { title: "Result 2: " + query },
      { title: "Result 3: " + query },
      { title: "Result 4: " + query }
    ];
  } else {
    return [
      { title: "Saved Searches", action: 'saved_searches', actionReturnsItems: true },
      { title: "Create new Note" },
      { title: "Edit Settings", path: SETTINGS_FILE }
    ];
  }

}

function runWithItem(item) {
  LaunchBar.log("runWithItem");
  LaunchBar.log(JSON.stringify(item));
}

function saved_searches(argument) {
  LaunchBar.log("saved_searches");
  LaunchBar.log(JSON.stringify(arguments));
  settings = loadSettings(SETTINGS_FILE);

  return settings.saved_searches;
}

function search(query) {
  return [
    { title: "Result 1: " + query },
    { title: "Result 2: " + query },
    { title: "Result 3: " + query },
    { title: "Result 4: " + query }
  ];
}

function loadSettings(settingsFile) {
  let object = File.readJSON(settingsFile);
  return object;
}
