var Evernote,SETTINGS_FILE,loadSettings,run,runWithItem,runWithString,saved_searches,search;SETTINGS_FILE=Action.path+'/Contents/Scripts/settings.js';Evernote=(function(){function e(){}e.open=function(){return LaunchBar.executeAppleScript("tell application \"LaunchBar\" to hide\ntell application \"Evernote\"\n  open collection window\n  activate\nend tell")};return e})();run=function(e){LaunchBar.log("run: '"+e+"'");Evernote.open();return LaunchBar.log("run: '"+e+"' done.")};runWithString=function(e){LaunchBar.log("runWithString: '"+e+"'");LaunchBar.log(JSON.stringify(e));if(e.length>0){return[{title:"Result 1: "+e},{title:"Result 2: "+e},{title:"Result 3: "+e},{title:"Result 4: "+e}]}else{return[{title:"Saved Searches",action:'saved_searches',actionReturnsItems:!0},{title:"Create new Note"},{title:"Edit Settings",path:SETTINGS_FILE}]}};runWithItem=function(e){LaunchBar.log("runWithItem");return LaunchBar.log(JSON.stringify(e))};saved_searches=function(e){var t;LaunchBar.log("saved_searches");LaunchBar.log(JSON.stringify(arguments));t=loadSettings(SETTINGS_FILE);return t.saved_searches};search=function(e){return[{title:"Result 1: "+e},{title:"Result 2: "+e},{title:"Result 3: "+e},{title:"Result 4: "+e}]};loadSettings=function(e){var t;t=File.readJSON(e);return t};LaunchBar.systemVersion||(module.exports={Evernote:Evernote,run:run,runWithString:runWithString,loadSettings:loadSettings})