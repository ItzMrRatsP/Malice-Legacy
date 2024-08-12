local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Global = require(ReplicatedStorage.Global)

local Assets = ReplicatedStorage.Assets
local EnemyAnimations = Assets.Animations.EnemyAnimations.Movement


return function(StateMachine, Id)
	local State = StateMachine:AddState(script.Name)

    if typeof(Id) == "number" then return end
    if not Id:IsA("Model") then return end

    local Humanoid = Id:FindFirstChildOfClass("Humanoid")
    if not Humanoid then
        return
    end

    local Animator = Humanoid:FindFirstChildOfClass("Animator")
    if not Animator then
        return
    end

    local Track = Animator:LoadAnimation(EnemyAnimations.Walk)

	function State:Start()

	end

	function State:Enter()
		Track:Play(0.2,1,1.5)
	end

	function State:Update(dt) 
		
	end

	function State:Exit()
        Track:Stop()
	end

	return State
end
