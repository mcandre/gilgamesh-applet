on run argv
	tell application "System Events"
		set oldItems to every login item whose path contains item 1 of argv
		repeat with oldItem in oldItems
			delete oldItem
		end repeat
	end tell
	
	return true
end run