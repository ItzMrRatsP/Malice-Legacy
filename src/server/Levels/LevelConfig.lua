local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Global = require(ReplicatedStorage.Global)
local LemonSignal = require(ReplicatedStorage.Packages.LemonSignal)

local currentLevels = {}

currentLevels.generateLevel = LemonSignal.new()
currentLevels.generateNextLevel = LemonSignal.new()

currentLevels.Levels = Global.GameUtil.arrtodict {
	"LevelOne",
	"LevelTwo",
	"LevelThree",
	"LevelFour",
}

currentLevels.Maps = {
	[currentLevels.Levels.LevelOne] = workspace.Levels.LevelOne,
	[currentLevels.Levels.LevelTwo] = workspace.Levels.LevelTwo,
	[currentLevels.Levels.LevelThree] = workspace.Levels.LevelThree,
	[currentLevels.Levels.LevelFour] = workspace.Levels.LevelFour,
}

return currentLevels
