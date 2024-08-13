local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LemonSignal = require(ReplicatedStorage.Packages.LemonSignal)

local Player = Players.LocalPlayer

local StatHandler = {}
StatHandler.StartStats = LemonSignal.new()

local function convertToTime()
	if not ReplicatedStorage:GetAttribute("FinishTime") then return "SAFE" end

	local FinishTime = ReplicatedStorage:GetAttribute("FinishTime")
	local CurrentTime = workspace:GetServerTimeNow()
	local TimeLeft = FinishTime - CurrentTime

	if TimeLeft <= 0 then return "TIMES UP!" end

	return string.format(
		"%02d:%02d",
		math.floor(TimeLeft / 60) % 60,
		TimeLeft % 60
	)
end

function StatHandler:Start()
	local PlayerGui = Player.PlayerGui

	self.StartStats:Connect(function()
		-- Start the stats
		local Gui = ReplicatedStorage.Assets.UI.StatUI:Clone()
		Gui.Parent = PlayerGui
		Gui.Name = "Stats"

		RunService.RenderStepped:Connect(function(dt)
			Gui.Background.CurrentMoney.Amount.Text =
				ReplicatedStorage:GetAttribute("Money")
			Gui.Background.CurrentTime.Timer.Text = convertToTime()
		end)
	end)
end

return StatHandler
