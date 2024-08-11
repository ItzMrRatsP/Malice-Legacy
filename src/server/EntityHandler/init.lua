local EntityHandler = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local CollectionService = game:GetService("CollectionService")

print("Working")

local EntityStatus = require(script.EntityStatus)
local NPCHandler = require(script.PlayerHandler)
local PlayerHandler = require(script.PlayerHandler)

EntityHandler.Players = {}

function playerAdded(Player: Player)
	EntityAdded(Player.UserId, true)
	EntityHandler.Players[Player.UserId] = {}
end

function EntityAdded(ID, IsPlayer: boolean?)
	EntityStatus.New(ID, IsPlayer or false)
end

local function playerRemoving(Player: Player)
	EntityStatus.Clear(Player)
end

function EntityHandler:Start()
	Players.PlayerAdded:Connect(playerAdded)
	Players.PlayerRemoving:Connect(playerRemoving)

	for _, player in Players:GetPlayers() do
		playerAdded(player)
	end

	local Enemies = CollectionService:GetTagged("Enemy")

	for _, Enemy in Enemies do
		EntityAdded(Enemy, false)
	end

	CollectionService:GetInstanceAddedSignal("Enemy"):Connect(EntityAdded, false)

	PlayerHandler:Start()
end

return EntityHandler
