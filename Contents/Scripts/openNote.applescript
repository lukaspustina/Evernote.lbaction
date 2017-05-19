on run {query, createNewNote}
	tell application "Evernote"
		if createNewNote as integer > 0 then
			set theNote to (create note title query with text query)
		else
			set theNotes to (find notes query)
			set theNote to item 1 of theNotes
		end if
		activate
		open note window with theNote
	end tell
end run
