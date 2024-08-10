local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Global = require(ReplicatedStorage.Global)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local LevelConfig = require(script.Parent.LevelConfig)

local LevelGenerator = {}
LevelGenerator.currentMap = nil

local function spawnPlayer(CharacterModel: Model)
	if not CharacterModel then
		Global.DebugUtil(
			"Congrats, you just did the impossible! ~ nil Character model."
		)
		return
	end -- No character, idk how this is possible!

	local hmrpt = CharacterModel:FindFirstChild("HumanoidRootPart")
	hmrpt.CFrame = LevelGenerator.currentMap.Spawn.CFrame
end

LevelConfig.generateLevel:Connect(function(jan: Janitor.Janitor, level: string)
	-- Generate level
	jan:Cleanup() -- Cleanup previous level!

	jan:Add(function()
		print("INSTANT TRUE!")
		ReplicatedStorage:SetAttribute("generatingNewLevel", true)
	end)

	LevelGenerator.currentMap = jan:Add(LevelConfig.Maps[level]:Clone())
	LevelGenerator.currentMap.Parent = workspace.Levels
	LevelGenerator.currentMap:PivotTo(workspace.SpawnLevel:GetPivot())

	for _, player in Players:GetPlayers() do
		spawnPlayer(player.Character)
	end

	task.delay(1, function()
		ReplicatedStorage:SetAttribute("generatingNewLevel", false)
	end)
end)

Players.PlayerAdded:Connect(function(Player)
	Player.CharacterAdded:Connect(spawnPlayer)
end)

return LevelGenerator
