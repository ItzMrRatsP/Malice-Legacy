return function(StateMachine, Character)
	local State = StateMachine:AddState(script.Name)

	function State:Start()
		StateMachine:AddEvent({
			Name = "IdleEvent",
			ToState = StateMachine.Idling,
			FromStates = {
				StateMachine.Walking,
			},
			Condition = function()
				if Character.Root.AssemblyLinearVelocity.Magnitude < 0.01 then
					return true
				end
			end,
		}, true)
	end

	function State:Enter()
		Character.CharacterAnimations["Idle"].Priority = Enum.AnimationPriority.Idle
		Character.CharacterAnimations["Idle"]:Play()
		Character.WalkSpeed = 1
	end

	function State:Update(dt) end

	function State:Exit() 
		Character.CharacterAnimations["Idle"]:Stop()
	end

	return State
end
