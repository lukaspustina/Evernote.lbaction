// LaunchBar Action Script

var maxResults = 20;

function runWithString(query)
{
  let notes = LaunchBar
    .executeAppleScriptFile('findNotes.applescript', query, maxResults, true)
    .replace(/@@\\@@/g, "\\'"); // re-escaping '; cf. findNotes.applescript
  //LaunchBar.log('Evernote Launchbar Action: suggestions.js: ' + notes);

  if (notes.length > 0) {
    results = eval(notes)
    results.sort(function(a, b){
      var left = new Date(a.date),
          right = new Date(b.date);
      if(left < right) return 1;
      if(left > right) return -1;
      return 0;
    });

    return results;
  } else {
    return [];
  }
}
