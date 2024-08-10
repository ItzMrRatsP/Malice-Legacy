local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local DataTemplate = require(ReplicatedStorage.Global.Config.DataTemplate)
local ProfileService = require(ReplicatedStorage.Packages.ProfileService)

local PlayerData = {}

PlayerData.Players = {}

PlayerData.profileData =
	ProfileService.GetProfileStore("PlayerData-Test4", DataTemplate.Main)

function playerAdded(Player: Player)
	-- Start Player Data Loading
	
	local playerProfile =
		PlayerData.profileData:LoadProfileAsync(Player.UserId .. "-KEY")

	PlayerData.Players[Player] = {}
	
	if not playerProfile then
		-- warn("PLAYER PROFILE IS INVALID")
		return
	end

	playerProfile:AddUserId(Player.UserId)
	playerProfile:Reconcile()

	playerProfile:ListenToRelease(function()
		PlayerData.Players[Player].Profile = nil
		Player:Kick()
	end)

	-- Rest of data
	if not Player:IsDescendantOf(Players) then
		Player:Kick(
			"Failed to load player profile, please rejoin to fix the issue."
		)
		return
	end

	PlayerData.Players[Player].Profile = playerProfile
end

local function playerRemoving(Player: Player)
	local playerProfile = 	PlayerData.Players[Player].Profile

	if not playerProfile then
		-- warn("NO PROFILE FOUND FOR THE PLAYER!")
		return
	end

	playerProfile:Release()
end

function PlayerData:Start()
	-- Starts player data
	Players.PlayerAdded:Connect(playerAdded)
	Players.PlayerRemoving:Connect(playerRemoving)
end

return PlayerData
