local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.Packages.Net)

local Combat = {}

-- Test Combat
function Combat:Start()
	Net:Connect("AttackRE", function(Player: Player, HumanoidModels: { Model? })
		-- Humanoi Models:
		for _, models in HumanoidModels do
			-- damage entity:
			local Humanoid = models:FindFirstChildOfClass("Humanoid")

			if not Humanoid then
				warn("WIZARD OF OZ DIDNT LIKE NO HUMANOID OBJECT!!!")
				continue
			end

			Humanoid:TakeDamage(15)
		end
	end)
end

return Combat
