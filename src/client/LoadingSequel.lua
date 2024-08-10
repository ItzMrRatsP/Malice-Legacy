local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Player = Players.LocalPlayer

-- Fusion
local Hydrate = Fusion.Hydrate
local Value = Fusion.Value
local Computed = Fusion.Computed

-- Loading Sheet
local Margin = 5
local Offset = 200 -- Offset
local Frames = 3
local WaitPerFrame = 0.05

local loadingScreen = {}
loadingScreen.Janitor = Janitor.new()

function loadingScreen:Start()
	ReplicatedStorage:GetAttributeChangedSignal("generatingNewLevel")
		:Connect(function()
			if not ReplicatedStorage:GetAttribute("generatingNewLevel") then
				self.Janitor:Cleanup() -- cleanup janitor
				return
			end

			local LoadingUI =
				self.Janitor:Add(ReplicatedStorage.Assets.UI.LoadingUI:Clone())
			LoadingUI.Parent = Player.PlayerGui

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

return loadingScreen
