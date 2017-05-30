var Evernote, SETTINGS_FILE, createNote, loadSettings, mapSavedSearch, openNote, run, runWithItem, runWithString, saved_searches, syncNow;

SETTINGS_FILE = Action.path + "/Contents/Scripts/settings.js";

Evernote = (function() {
  function Evernote() {}

  Evernote.open = function() {
    return LaunchBar.executeAppleScript("tell application \"LaunchBar\" to hide\ntell application \"Evernote\"\n  open collection window\n  activate\nend tell");
  };

  Evernote.search = function(query) {
    var i, len, r, results;
    results = Evernote._evernote_search(query, 20, true);
    for (i = 0, len = results.length; i < len; i++) {
      r = results[i];
      r.action = 'openNote';
    }
    results.sort(function(a, b) {
      var left, right;
      left = new Date(a.date);
      right = new Date(b.date);
      if (left < right) {
        1;
      }
      if (left > right) {
        -1;
      }
      return 0;
    });
    LaunchBar.log("search result: '" + (JSON.stringify(results)) + "'");
    return results;
  };

  Evernote._evernote_search = function(query, maxResults, debug) {
    var notes;
    notes = LaunchBar.executeAppleScriptFile(Action.path + "/Contents/Scripts/findNotes.applescript", query, maxResults, debug).replace(/@@\\@@/g, "\\'");
    if (notes.length > 0) {
      return eval(notes);
    } else {
      return [];
    }
  };

  Evernote.openNote = function(note) {
    LaunchBar.log("openNote: '" + (JSON.stringify(note)) + "'");
    return LaunchBar.executeAppleScript("tell application \"LaunchBar\" to hide\ntell application \"Evernote\"\n  set theNote to find note \"" + note.notelink + "\"\n  open note window with theNote\n  activate\nend tell");
  };

  Evernote.createNote = function() {
    LaunchBar.log("createNote");
    return LaunchBar.executeAppleScript("tell application \"LaunchBar\" to hide\ntell application \"Evernote\"\n  set theNote to create note with text \" \"\n  open note window with theNote\n  activate\nend tell");
  };

  Evernote.syncNow = function() {
    LaunchBar.log("syncNow");
    return LaunchBar.executeAppleScript("tell application \"LaunchBar\" to hide\ntell application \"Evernote\"\n  synchronize\nend tell");
  };

  return Evernote;

})();

run = function(query) {
  LaunchBar.log("run: '" + query + "'");
  Evernote.open();
  return LaunchBar.log("run: '" + query + "' done.");
};

runWithString = function(query) {
  LaunchBar.log("runWithString: '" + query + "'");
  LaunchBar.log(JSON.stringify(query));
  if (query.length > 0) {
    return Evernote.search(query);
  } else {
    return [
      {
        title: "Saved Searches",
        action: 'saved_searches',
        actionReturnsItems: true
      }, {
        title: "Create new Note",
        action: 'createNote',
        icon: 'com.evernote.Evernote'
      }, {
        title: "Synchronize now",
        action: 'syncNow'
      }, {
        title: "Edit Settings",
        path: SETTINGS_FILE
      }
    ];
  }
};

runWithItem = function(item) {
  LaunchBar.log("runWithItem");
  return LaunchBar.log(JSON.stringify(item));
};

saved_searches = function(argument) {
  var settings;
  LaunchBar.log("saved_searches");
  LaunchBar.log(JSON.stringify(arguments));
  settings = loadSettings(SETTINGS_FILE);
  return mapSavedSearch(settings.saved_searches);
};

loadSettings = function(settingsFile) {
  var object;
  object = (function() {
    try {
      return File.readJSON(settingsFile);
    } catch (error) {
      return {};
    }
  })();
  if (!object.debug) {
    object.debug = false;
  }
  if (!object.saved_searches) {
    object.saved_searches = [];
  }
  return object;
};

mapSavedSearch = function(saved_searches) {
  var items, ss;
  items = (function() {
    var i, len, results1;
    results1 = [];
    for (i = 0, len = saved_searches.length; i < len; i++) {
      ss = saved_searches[i];
      results1.push({
        title: ss.name,
        actionArgument: ss.search,
        action: 'runWithString',
        actionReturnsItems: true
      });
    }
    return results1;
  })();
  return items;
};

openNote = function(note) {
  return Evernote.openNote(note);
};

createNote = function() {
  return Evernote.createNote();
};

syncNow = function() {
  return Evernote.syncNow();
};

if (!LaunchBar.systemVersion) {
  module.exports = {
    Evernote: Evernote,
    run: run,
    runWithString: runWithString,
    loadSettings: loadSettings,
    mapSavedSearch: mapSavedSearch,
    openNote: openNote,
    createNote: createNote,
    syncNow: syncNow
  };
}
