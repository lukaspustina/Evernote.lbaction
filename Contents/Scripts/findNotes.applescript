-- LaunchBar Action Script

on run {query, maxResults}
	set results to {}
	
	tell application "Evernote"
		set theNotes to (find notes query)
		try
			set x to 0
			repeat maxResults as integer times
				set x to (x + 1)
				set theNote to item x of theNotes
				
				set _title to (title of theNote)
				tell me to set _label to replaceText("'", "@@\\@@", (name of (notebook of theNote))) -- nasty way to escape '; cf. suggestions.js
				-- do shell script "logger '" & _label & "'"
				set _date to ((modification date of theNote) as «class isot» as string)
				set _subtitle to ((modification date of theNote) as string)
				
				set _tagList to {}
				set _noteTags to (tags of theNote)
				repeat with x from 1 to length of _noteTags
					copy (name of (item x of _noteTags)) to the end of _tagList
				end repeat
				set saveTID to AppleScript's text item delimiters
				set AppleScript's text item delimiters to ", "
				set _tags to _tagList as text
				set AppleScript's text item delimiters to saveTID
				if not _tagList = {} then
					set _subtitle to _subtitle & " - " & _tags
				end if
				
				set res to "{" & "title:'" & _title & "',label:'" & _label & "',date:'" & _date & "',subtitle:'" & _subtitle & "',alwaysShowsSubtitle:true,icon:'com.evernote.Evernote'" & "}"
				copy res to the end of results
			end repeat
		end try
	end tell
	
	set text item delimiters to ","
	set resultsAsString to results as text
	
	return "[" & resultsAsString & "]"
end run

on replaceText(find, replace, subject)
	set saveTID to text item delimiters
	set text item delimiters to find
	set subject to text items of subject
	
	set text item delimiters to replace
	set subject to subject as text
	set text item delimiters to saveTID
	
	return subject
end replaceText