local PlayerHandler = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.Packages.Net)

local EntityStatus = require(script.Parent.EntityStatus)

function PlayerHandler:Start()

    Net:Connect("AttackRE", function(Player: Player, HumanoidModels: { Model? })
		-- Humanoi Models:
		for _, model in HumanoidModels do
			local Entities = EntityStatus.Entities
			print(Entities)
			-- damage entity:
			local Humanoid = model:FindFirstChildOfClass("Humanoid")
			print(model)
			if not Entities[model] then continue end
			if not Humanoid then
				warn("WIZARD OF OZ DIDNT LIKE NO HUMANOID OBJECT!!!")
				continue
			end

			Humanoid:TakeDamage(15)
		end
	end)
end

return PlayerHandler