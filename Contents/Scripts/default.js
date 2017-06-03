var Evernote, SETTINGS, SETTINGS_FILE, createNote, handleNote, loadSettings, log, mapSavedSearch, mapSearchResults, run, runWithString, saved_searches, syncNow;

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
  if (!object.max_results) {
    object.max_results = 20;
  }
  if (!object.query_min_len) {
    object.query_min_len = 3;
  }
  return object;
};

SETTINGS_FILE = Action.path + "/Contents/Scripts/settings.js";

SETTINGS = loadSettings(SETTINGS_FILE);

log = function(msg) {
  if (SETTINGS.debug) {
    return LaunchBar.log(msg);
  }
};

saved_searches = function(argument) {
  log("saved_searches");
  log(JSON.stringify(arguments));
  return mapSavedSearch(SETTINGS.saved_searches);
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

mapSearchResults = function(search_results) {
  var date, i, len, r, result, results, s_date;
  results = [];
  for (i = 0, len = search_results.length; i < len; i++) {
    r = search_results[i];
    result = {};
    result.title = r.title;
    result.label = r.notebook;
    result.date = r.date;
    date = new Date(r.date);
    s_date = LaunchBar.formatDate(date, {
      relativeDateFormatting: true,
      timeStyle: 'short',
      dateStyle: 'medium'
    });
    result.subtitle = r.tags && Object.keys(r.tags).length > 0 ? s_date + " - " + r.tags : "" + s_date;
    result.action = 'handleNote';
    result.alwaysShowsSubtitle = true;
    result.icon = 'com.evernote.Evernote';
    results.push(result);
  }
  results.sort(function(a, b) {
    var left, right;
    left = new Date(a.date);
    right = new Date(b.date);
    if (left < right) {
      return 1;
    }
    if (left > right) {
      return -1;
    }
    return 0;
  });
  return results;
};

handleNote = function(note) {
  return Evernote.handleNote(note);
};

createNote = function() {
  return Evernote.createNote();
};

syncNow = function() {
  return Evernote.syncNow();
};

run = function(query) {
  log("run: '" + query + "'");
  Evernote.open();
  return log("run: '" + query + "' done.");
};

runWithString = function(query) {
  var search_results;
  log("runWithString: '" + query + "'");
  log(JSON.stringify(query));
  if (query.length >= SETTINGS.query_min_len) {
    search_results = Evernote.search(query, SETTINGS.max_results, SETTINGS.debug);
    return mapSearchResults(search_results);
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

Evernote = (function() {
  function Evernote() {}

  Evernote.open = function() {
    log("@open");
    LaunchBar.executeAppleScript("tell application \"LaunchBar\" to hide\ntell application \"Evernote\"\n  open collection window\n  activate\nend tell");
    return log("@open: done");
  };

  Evernote.search = function(query, maxResults, debug) {
    var results;
    log("@search: '" + query + ", " + maxResults + ", " + debug + "'");
    results = Evernote._evernote_search(query, maxResults, debug);
    log("search result: '" + (JSON.stringify(results)) + "'");
    log("@search: done");
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

  Evernote.handleNote = function(note) {
    log("@handleNote");
    if (LaunchBar.options.commandKey) {
      Evernote._copy_note_link(note);
    } else {
      Evernote._open_note(note);
    }
    return log("@handleNote: done");
  };

  Evernote._open_note = function(note) {
    log("@_open_note: '" + (JSON.stringify(note)) + "'");
    LaunchBar.executeAppleScript("tell application \"LaunchBar\" to hide\ntell application \"Evernote\"\n  set theNote to find note \"" + note.notelink + "\"\n  open note window with theNote\n  activate\nend tell");
    return log("@_open_note: done");
  };

  Evernote._copy_note_link = function(note) {
    log("@_copy_note_link: '" + (JSON.stringify(note)) + "'");
    LaunchBar.executeAppleScript("tell application \"LaunchBar\" to hide\nset the clipboard to \"" + note.notelink + "\"");
    return log("@_copy_note_link: done");
  };

  Evernote.createNote = function() {
    log("createNote");
    LaunchBar.executeAppleScript("tell application \"LaunchBar\" to hide\ntell application \"Evernote\"\n  set theNote to create note with text \" \"\n  open note window with theNote\n  activate\nend tell");
    return log("createNote: done");
  };

  Evernote.syncNow = function() {
    log("syncNow");
    LaunchBar.executeAppleScript("tell application \"LaunchBar\" to hide\ntell application \"Evernote\"\n  synchronize\nend tell");
    return log("syncNow: done");
  };

  return Evernote;

})();

if (!LaunchBar.systemVersion) {
  module.exports = {
    Evernote: Evernote,
    run: run,
    runWithString: runWithString,
    loadSettings: loadSettings,
    mapSavedSearch: mapSavedSearch,
    mapSearchResults: mapSearchResults,
    handleNote: handleNote,
    createNote: createNote,
    syncNow: syncNow
  };
}
