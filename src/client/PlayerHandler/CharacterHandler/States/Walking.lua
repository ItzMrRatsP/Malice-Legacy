return function(StateMachine, Character)
	local State = StateMachine:AddState(script.Name)

	function State:Start() 
        StateMachine:AddEvent({
			Name = "WalkEvent",
			ToState = StateMachine.Walking,
			FromStates = {
				StateMachine.Idling
			},
			Condition = function()
				if Character.Root.AssemblyLinearVelocity.Magnitude > 0.2 then return true end
			end,
		}, true)
	end

	function State:Enter() 
		Character.CharacterAnimations["Walk"]:Play(1,1,0.2)
	end

	function State:Update(dt) 
        Character.WalkSpeed += (16 - Character.WalkSpeed) * (1 - math.pow(5, -1.1 * dt))

		local offset = Character.Root.CFrame.Rotation:PointToObjectSpace(Character.Humanoid.MoveDirection) * Vector3.new(1,0,1)

		local desiredAngle = -math.atan2(-offset.X, -offset.Z)
		if math.abs(desiredAngle) > 2*math.pi/4 + 0.1 then
			desiredAngle = math.sign(desiredAngle) * (math.abs(desiredAngle) - math.pi)
			Character.CharacterAnimations["Walk"]:AdjustSpeed(Character.WalkSpeed/-20)
		else
			Character.CharacterAnimations["Walk"]:AdjustSpeed(Character.WalkSpeed/20)
		end
	end

	function State:Exit()
		Character.CharacterAnimations["Walk"]:Stop(0.2)
	end

	return State
end
