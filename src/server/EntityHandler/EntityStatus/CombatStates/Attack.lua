return function(StateMachine, Id)
	local State = StateMachine:AddState(script.Name)

	function State:Start()
	end

	function State:Enter() end

	function State:Update(dt) end

	function State:Exit() end

	return State
end
