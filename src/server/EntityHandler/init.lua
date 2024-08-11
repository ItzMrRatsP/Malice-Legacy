local EntityHandler = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local EntityStatus = require(script.EntityStatus)

EntityStatus.Players = {}

function playerAdded(Player: Player)
	EntityStatus.New(Player.UserId)

	EntityStatus.Players[Player.UserId] = {}
end

local function playerRemoving(Player: Player)
	EntityStatus.Clear(Player)

end

function  EntityHandler:Start()
	Players.PlayerAdded:Connect(playerAdded)
	Players.PlayerRemoving:Connect(playerRemoving)

	for _, player in Players:GetPlayers() do
		playerAdded(player)
	end
end

return EntityHandler