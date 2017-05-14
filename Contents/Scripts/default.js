function run(argument) {
}

function runWithString(query) {
  createNewNote = LaunchBar.options.shiftKey ? 1 : 0;

  LaunchBar.executeAppleScriptFile('openNote.scpt', query, createNewNote);
}
