local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")

local Global = require(ReplicatedStorage.Global)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local LevelConfig = require(script.Parent.LevelConfig)
local SpawnEntity = require(ServerStorage.Server.SpawnEntity)

local LevelGenerator = {}
LevelGenerator.currentMap = nil

local oldLightness = {}

local lightInfo = TweenInfo.new(3.5, Enum.EasingStyle.Linear)

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

local function setLightBrightness(map: Model, brightness: number)
	for _, lights in map:GetDescendants() do
		if not lights:IsA("PointLight") then continue end

		-- if lights.Brightness == brightness then continue end

		oldLightness[lights] = lights.Brightness
		TweenService:Create(lights, lightInfo, { Brightness = brightness })
			:Play()
	end
end

local function revertBrightness()
	for light, brightness in oldLightness do
		TweenService:Create(light, lightInfo, { Brightness = brightness })
			:Play()
		oldLightness[light] = nil
	end
end

LevelConfig.generateLevel:Connect(function(jan: Janitor.Janitor, level: string)
	-- Generate level
	jan:Cleanup() -- Cleanup previous level!
	SpawnEntity.despawnLevelEntity:Fire()

	jan:Add(function()
		ReplicatedStorage:SetAttribute("generatingNewLevel", true)
	end)

	LevelGenerator.currentMap = jan:Add(LevelConfig.Maps[level]:Clone())
	LevelGenerator.currentMap.Parent = workspace.Levels
	LevelGenerator.currentMap:PivotTo(workspace.SpawnLevel:GetPivot())

	setLightBrightness(LevelGenerator.currentMap, 0)

	for _, player in Players:GetPlayers() do
		spawnPlayer(player.Character)
	end

	task.delay(1, function()
		SpawnEntity.spawnLevelEntity:Fire()
		ReplicatedStorage:SetAttribute("generatingNewLevel", false)
		revertBrightness()
	end)
end)

Players.PlayerAdded:Connect(function(Player)
	Player.CharacterAdded:Connect(spawnPlayer)
end)

return LevelGenerator
