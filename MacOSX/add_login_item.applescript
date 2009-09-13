on run argv
	tell application "System Events"
		make new login item with properties {path:item 1 of argv, hidden:false} at end
	end tell
	
	return true
end run