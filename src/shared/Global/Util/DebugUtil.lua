local RunService = game:GetService("RunService")

return function(...)
	if not RunService:IsStudio() then return end -- Only studio can uses the debug.
	return warn(
		`[Studio Debug] Content: {...}` -- Debug content
	)
end
