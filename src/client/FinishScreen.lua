local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer

local FinishScreen = {}

function FinishScreen:Start()
	ReplicatedStorage:GetAttributeChangedSignal("Finished"):Connect(function()
		local newValue = ReplicatedStorage:GetAttribute("Finished")
		if not newValue then return end


		local FinishUI =
			ReplicatedStorage.Assets.UI:FindFirstChild("FinishScreen"):Clone()
		FinishUI.Parent = Player.PlayerGui

		TweenService:Create(
			FinishUI.Background,
			TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
			{
				GroupTransparency = 0,
			}
		):Play()
	end)
end

return FinishScreen
