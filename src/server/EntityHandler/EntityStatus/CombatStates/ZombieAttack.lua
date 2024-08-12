local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Global = require(ReplicatedStorage.Global)

local Assets = ReplicatedStorage.Assets
local EnemyAnimations = Assets.Animations.EnemyAnimations.M1:GetChildren()


return function(StateMachine, Id)
	local State = StateMachine:AddState(script.Name)
	local defaultWalkSpeed 

	function State:Start()



	end

	function State:Enter()
		print("Attacked")
		local model = Id

		if typeof(Id) == "number" then return end
		if not model:IsA("Model") then return end

		local Humanoid = model:FindFirstChildOfClass("Humanoid")
		if not Humanoid then
			return
		end

		defaultWalkSpeed = Humanoid.WalkSpeed
		Humanoid.WalkSpeed = 0

		local Animator = Humanoid:FindFirstChildOfClass("Animator")
		if not Animator then
			return
		end


        local ZombieAttackNumber = math.random(1,2) -- SUE ME

        local Track = Animator:LoadAnimation(EnemyAnimations[ZombieAttackNumber])
		Track.Looped = false

		Track:Play()
	end

	function State:Update(dt) 
		
	end

	function State:Exit()
		local model = Id

		if typeof(Id) == "number" then return end
		
		if not model:IsA("Model") then return end

		local Humanoid = model:FindFirstChildOfClass("Humanoid")
		if not Humanoid then
			Global.DebugUtil(
				`No humanoid exist in the given entity model {Id.Name}`
			)
			return
		end

		Humanoid.WalkSpeed = defaultWalkSpeed
	end

	return State
end
