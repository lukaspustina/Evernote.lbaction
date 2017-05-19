function run(argument) {
  LaunchBar.executeAppleScriptFile('activateEvernote.applescript');
}

function runWithString(query) {
  createNewNote = LaunchBar.options.shiftKey ? 1 : 0;

  LaunchBar.executeAppleScriptFile('openNote.applescript', query, createNewNote);
}
