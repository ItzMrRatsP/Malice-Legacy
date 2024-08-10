local groupId = 34692920

return function(registry)
	registry:RegisterHook("BeforeRun", function(context)
		if
			context.Group == "devs"
			and context.Executor:GetRankInGroup(groupId) <= 240
		then
			return "You need developer rank in the group to get access to this command."
		end
	end)
end
