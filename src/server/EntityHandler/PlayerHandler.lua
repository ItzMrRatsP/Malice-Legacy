local PlayerHandler = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = ReplicatedStorage.Assets

local EnemyAnimations = Assets.Animations.EnemyAnimations
local Net = require(ReplicatedStorage.Packages.Net)

local EntityStatus = require(script.Parent.EntityStatus)

function PlayerHandler:Start()

    Net:Connect("AttackRE", function(Player: Player, HumanoidModels: { Model? })
		-- Humanoi Models:
		for _, model in HumanoidModels do
			local Entities = EntityStatus.Entities
			-- damage entity:
			local Humanoid : Humanoid = model:FindFirstChildOfClass("Humanoid")
			local EntityState = Entities[model]
			if not EntityState then continue end
			if not Humanoid then
				warn("WIZARD OF OZ DIDNT LIKE NO HUMANOID OBJECT!!!")
				continue
			end
			Humanoid.Animator:LoadAnimation(EnemyAnimations:GetChildren()[math.random(1,3)]):Play()

			Humanoid:TakeDamage(15)
			EntityState.CombatStateMachine:Transition(EntityState.CombatStateMachine.Stun)

			--remove this and move it to the damage module and stuff
			task.delay(0.5, function()
				EntityState.CombatStateMachine:Transition(EntityState.CombatStateMachine.InAction) 
			end)

		end
	end)
end

return PlayerHandler