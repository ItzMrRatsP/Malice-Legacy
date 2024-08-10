local ServerStorage = game:GetService("ServerStorage")
local PlayerData = require(ServerStorage.Server:WaitForChild("PlayerData"))

return function(_, players: { Player }, amount: number)
	for _, player in players do
		local profile = PlayerData.Players[player].Profile
		if not profile then continue end

		profile.Data.cash.value = amount
	end

	return "Successfully changed all players data to given amount."
end
