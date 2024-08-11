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
		local Character = Player.Character

		local RootPart : BasePart = Character:WaitForChild("HumanoidRootPart")
		-- Humanoi Models:
		for _, model in HumanoidModels do
			-- damage entity:
			DamageHandler.DamageEntity(model, 15, true, 0.25, 0.3, {RootPart.CFrame.LookVector, 5, 1})
		end
	end)
	
	Net:Connect("RollRE", function(Player: Player)
		DamageHandler.AddIFrame(Player.UserId, 0.25)
		print("Rolled")
	end)
end

return PlayerHandler
