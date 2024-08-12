local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Global = require(ReplicatedStorage.Global)

local Assets = ReplicatedStorage.Assets
local EnemyAnimations = Assets.Animations.EnemyAnimations.Stuns:GetChildren()

local RNG = Random.new()

return function(StateMachine, Id)
	local State = StateMachine:AddState(script.Name)
	local LastStunAnimation = 1
	local defaultWalkSpeed = 0

	function State:Start() end

	function State:Enter()
		-- Enter Stun State

		local model = Id

		if typeof(model) == "number" then
			model = Players:GetPlayerByUserId(model).Character
		end

		if not model:IsA("Model") then return end

		local Humanoid = model:FindFirstChildOfClass("Humanoid")
		if not Humanoid then
			Global.DebugUtil(
				`No humanoid exist in the given entity model {Id.Name}`
			)
			return
		end

		defaultWalkSpeed = Humanoid.WalkSpeed
		Humanoid.WalkSpeed = 0

		local Animator = Humanoid:FindFirstChildOfClass("Animator")
		if not Animator then
			Global.DebugUtil(
				`No animator exist in the given entity humanoid {Id.Name}`
			)
			return
		end

		if LastStunAnimation > #EnemyAnimations then LastStunAnimation = 1 end

		local RandomStun =
			Animator:LoadAnimation(EnemyAnimations[LastStunAnimation])

		LastStunAnimation += 1
		RandomStun:Play(0.1, 1)
	end

	function State:Update(dt) end

	function State:Exit()
		local model = Id

		if typeof(model) == "number" then
			model = Players:GetPlayerByUserId(model).Character
		end

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
