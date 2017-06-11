-- LaunchBar Action Script

on run {query, maxResults, debug}
	set results to {}

	set _debug to false
	if debug is equal to "true" then
		set _debug to true
	end if

	-- Debug
	logger("searching with query " & query & " and returning up to  " & maxResults, _debug)

	try
		tell application "Evernote"
			set theNotes to (find notes query)
			set x to 0

			-- if number of notes is less than maxResults, an exception is thrown; that's okay, we deal with it.
			repeat maxResults as integer times
				set x to (x + 1)
				set theNote to item x of theNotes

				set _title to (title of theNote)
				try
					tell me to set _title_enc to replaceText("'", "@@\\@@", _title) -- nasty way to escape '; cf. default.js

					-- Debug
					tell me to logger("found note with title  " & _title_enc, _debug)

					tell me to set _notebook to replaceText("'", "@@\\@@", (name of (notebook of theNote))) -- nasty way to escape '; cf. default.js
					-- do shell script "logger '" & _notebook & "'"
					set _date to ((modification date of theNote) as «class isot» as string)
					set _moddate to ((modification date of theNote) as string)
          set _notelink to ((note link of theNote) as string)

					set _tagList to {}
					set _noteTags to (tags of theNote)
					repeat with x from 1 to length of _noteTags
            tell me to set _tag to replaceText("'", "@@\\@@", (name of (item x of _noteTags))) -- nasty way to escape '; cf. default.js
						copy _tag to the end of _tagList
					end repeat
					set saveTID to AppleScript's text item delimiters
					set AppleScript's text item delimiters to ", "
					set _tags to _tagList as text
					set AppleScript's text item delimiters to saveTID

					set res to "{" & "title:'" & _title_enc & "',notebook:'" & _notebook & "',date:'" & _date & "',tags:'" & _tags & "',notelink:'" & _notelink & "'}"

					-- Debug
					tell me to logger("adding to results: " & res & "'", _debug)

					copy res to the end of results
				on error msg
					logger("failed because " & msg, true)
				end try
			end repeat
		end tell
	on error msg
		do shell script "logger Evernote LbAction failed because " & msg
	end try

	-- Debug
	logger("finished search with " & (length of results) & " results.", _debug)

	try
		set text item delimiters to ","
		set resultsAsString to results as text
		-- Debug
		logger("returning " & (length of results) & " results.", _debug)

		return "[" & resultsAsString & "]"
	on error msg
		logger("logger Evernote LbAction failed to create resultsAsString " & msg, true)
	end try

	return "[]"
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

on logger(_text, _debug)
	try
		if _debug is true then
			do shell script "logger 'Evernote Launchbar Action " & _text & "'"
		end if
	end try
end logger
