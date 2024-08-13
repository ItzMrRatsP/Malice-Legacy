local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local MenuPlaceID = 18892236729
local OnDeath = {}

function OnDeath:Start() -- On Humanoid Died
	Players.PlayerAdded:Connect(function(Player)
		Player.CharacterAdded:Connect(function(Character: Model)
			local Humanoid = Character:FindFirstChild("Humanoid")
			if not Humanoid then return end

			Humanoid.Died:Connect(function()
				TeleportService:TeleportAsync(MenuPlaceID, { Player })
			end)
		end)
	end)
end

return OnDeath
