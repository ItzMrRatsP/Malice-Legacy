local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local EntityStatus = require(ServerStorage.EntityStatus)

local PlayerHandler = {}

PlayerHandler.Players = {}


function playerAdded(Player: Player)
	EntityStatus.New(Player.UserId)

	PlayerHandler.Players[Player.UserId] = {}
end

local function playerRemoving(Player: Player)
	EntityStatus.Clear(Player)

end

function PlayerHandler:Start()
	-- Starts player data
	Players.PlayerAdded:Connect(playerAdded)
	Players.PlayerRemoving:Connect(playerRemoving)

	for _, player in Players:GetPlayers() do
		playerAdded(player)
	end
end

return PlayerHandler
