// LaunchBar Action Script

var maxResults = 20;

function runWithString(query)
{
  notes = LaunchBar
    .executeAppleScriptFile('findNotes.applescript', query, maxResults)
    .replace(/@@\\@@/g, "\\'"); // re-escaping '; cf. findNotes.applescript
  //LaunchBar.log(notes)

  results = eval(notes)
  results.sort(function(a, b){
    var left = new Date(a.date),
        right = new Date(b.date);
    if(left < right) return 1;
    if(left > right) return -1;
    return 0;
  });

  return results
}
