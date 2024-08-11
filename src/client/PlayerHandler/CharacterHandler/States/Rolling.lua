local UserInputService = game:GetService("UserInputService")

return function(StateMachine, Character)
	local State = StateMachine:AddState(script.Name)
	local LastRoll = os.clock()

	function State:Start()

		StateMachine:AddEvent({
			Name = "RollToIdleEvent",
			ToState = StateMachine.InAction,
			FromStates = {
				StateMachine.Attack,
			},
			Condition = function(): boolean
				return os.clock() - LastRoll >= 0.5
			end,
		}, true)
	end

	function State:Enter()
		LastRoll = os.clock()
		Character.WalkSpeed = 1
	end

	function State:Update(dt) end

	function State:Exit() end

	return State
end
