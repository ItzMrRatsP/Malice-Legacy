local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local GameTimer = require(ServerStorage.Server.GameTimer)
local Global = require(ReplicatedStorage.Global)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local LevelConfig = require(script.LevelConfig)
local LevelGenerator = require(script.LevelGenerator)
local MoneyStats = require(ServerStorage.Server.MoneyStats)
local Net = require(ReplicatedStorage.Packages.Net)
local ShopKeeperHandler = require(script.ShopKeeperHandler)

Net:RemoteEvent("CutsceneStarted2")
local Levels = {}
Levels.currentLevel = LevelConfig.Levels.LevelOne

function Levels:Start()
	local jan = Janitor.new()

	for _, map in LevelConfig.Maps do
		map.Parent = ReplicatedStorage.Assets.Levels
	end

	-- jan:Add(function()
	-- 	ReplicatedStorage:SetAttribute("generatingNewLevel", true)
	-- end)

	-- ReplicatedStorage:SetAttribute("generatingNewLevel", true)
	LevelConfig.generateLevel:Fire(jan, self.currentLevel)

	task.delay(2, function()
		Net:RemoteEvent("CutsceneStarted"):FireAllClients()
	end)

	LevelConfig.generateNextLevel:Connect(function()
		local levels = Global.GameUtil.dicttoarr(LevelConfig.Levels)
		if not levels[self.currentLevel + 1] then return end

		local serverTimeNow = workspace:GetServerTimeNow()
		local toAdd = ReplicatedStorage:GetAttribute("FinishTime")
			- serverTimeNow

		MoneyStats.UpdateMoney:Fire(
			ReplicatedStorage:GetAttribute("Money") + toAdd
		)
		GameTimer.StartTimer:Fire()

		self.currentLevel = levels[self.currentLevel + 1]
		LevelConfig.generateLevel:Fire(jan, self.currentLevel)

		-- Just some shopkeeper stuff :idk:
		ShopKeeperHandler.BoughtSomething = false
		ShopKeeperHandler.Entered(LevelGenerator.currentMap)
	end)
end

return Levels
