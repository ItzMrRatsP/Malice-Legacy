local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Global = require(ReplicatedStorage.Global)
local LemonSignal = require(ReplicatedStorage.Packages.LemonSignal)

local currentLevels = {}

currentLevels.generateLevel = LemonSignal.new()
currentLevels.generateNextLevel = LemonSignal.new()

currentLevels.Levels = Global.GameUtil.arrtodict { "LevelOne", "LevelTwo" } -- ["LevelOne"] = "LevelOne"
currentLevels.Maps = {
	[currentLevels.Levels.LevelOne] = ReplicatedStorage.Assets.Levels.LevelOne,
	[currentLevels.Levels.LevelTwo] = ReplicatedStorage.Assets.Levels.LevelTwo,
}

return currentLevels
