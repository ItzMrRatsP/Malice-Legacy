local PlayerHandler = {}
local RNG = Random.new()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = ReplicatedStorage.Assets

local EnemyAnimations = Assets.Animations.EnemyAnimations
local Net = require(ReplicatedStorage.Packages.Net)

local DamageHandler = require(script.Parent.DamageHandler)
local EntityStatus = require(script.Parent.EntityStatus)

function PlayerHandler:Start()
	Net:Connect("AttackRE", function(Player: Player, HumanoidModels: { Model? })
		-- Humanoi Models:
		for _, model in HumanoidModels do
			-- damage entity:
			DamageHandler.DamageEntity(model, 15, true, 0.25, 0.3)
		end
	end)
	
	Net:Connect("DodgeRE", function(Player: Player)
		
	end)
end

return PlayerHandler
