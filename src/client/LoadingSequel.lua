local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Player = Players.LocalPlayer

-- Fusion
local Hydrate = Fusion.Hydrate
local Value = Fusion.Value
local Computed = Fusion.Computed

local OutInfo =
	TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

local InInfo =
	TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

-- Loading Sheet
local Margin = 5
local Offset = 200 -- Offset
local Frames = 3
local WaitPerFrame = 0.05

local loadingSequel = {}
loadingSequel.Janitor = Janitor.new()

function loadingSequel:Start()
	ReplicatedStorage:GetAttributeChangedSignal("generatingNewLevel")
		:Connect(function()
			if not ReplicatedStorage:GetAttribute("generatingNewLevel") then
				self.Janitor:Cleanup() -- cleanup janitor
				return
			end

			local LoadingUI = ReplicatedStorage.Assets.UI.LoadingUI:Clone()
			LoadingUI.Parent = Player.PlayerGui

			self.Janitor:Add(function()
				-- Add the janitor
				local TweenOut = TweenService:Create(
					LoadingUI.Background,
					OutInfo,
					{ GroupTransparency = 1 }
				)

				TweenOut:Play()
				TweenOut.Completed:Wait()
				LoadingUI:Destroy()
			end)

			local TweenIn = TweenService:Create(
				LoadingUI.Background,
				InInfo,
				{ GroupTransparency = 0 }
			)

			TweenIn:Play()

			self.Janitor:Add(task.spawn(function()
				local currentFrame = Value(0)

				Hydrate(LoadingUI.Background.Logo) {
					ImageRectOffset = Computed(function()
						return Vector2.new(
							(currentFrame:get() % Frames) * (Offset + Margin)
						)
					end),
				}

				while true do
					currentFrame:set(currentFrame:get() + 1)
					task.wait(WaitPerFrame)
				end
			end))
		end)
end

return loadingSequel
