local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local LemonSignal = require(ReplicatedStorage.Packages.LemonSignal)

local GameTimer = {}

GameTimer.Janitor = Janitor.new()
GameTimer.Time = 60 * 10
GameTimer.RemoveTimer = LemonSignal.new()
GameTimer.StartTimer = LemonSignal.new()

function GameTimer:Start()
	self.StartTimer:Connect(function(time: number)
		ReplicatedStorage:SetAttribute(
			"FinishTime",
			workspace:GetServerTimeNow() + self.Time
		)
	end)

	self.RemoveTimer:Connect(function()
		ReplicatedStorage:SetAttribute("FinishTime", nil)
	end)
end

return GameTimer
