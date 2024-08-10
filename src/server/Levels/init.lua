local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Global = require(ReplicatedStorage.Global)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local LevelConfig = require(script.LevelConfig)
local LevelGenerator = require(script.LevelGenerator)

local Levels = {}
Levels.currentLevel = LevelConfig.Levels.LevelOne

function Levels:Start()
	local jan = Janitor.new()

	jan:Add(function()
		ReplicatedStorage:SetAttribute("generatingNewLevel", true)
	end)

	LevelConfig.generateLevel:Fire(jan, self.currentLevel)

	LevelConfig.generateNextLevel:Connect(function()
		local levels = Global.GameUtil.dicttoarr(LevelConfig.Levels)
		if not levels[self.currentLevel + 1] then return end

		self.currentLevel = levels[self.currentLevel + 1]

		LevelConfig.generateLevel:Fire(jan, self.currentLevel)
	end)
end

return Levels
