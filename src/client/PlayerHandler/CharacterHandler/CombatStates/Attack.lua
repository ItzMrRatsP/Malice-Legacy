local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Global = require(ReplicatedStorage.Global)

return function(StateMachine, Character)
	local State = StateMachine:AddState(script.Name)

	function State:Start()
		local Button1Down = false
		local LastAttack = os.clock()
		ContextActionService:BindAction("IsButtonDown", function(_, state, _)
			Button1Down = state == Enum.UserInputState.Begin
		end, true, Enum.UserInputType.MouseButton1)

		StateMachine:AddEvent({
			Name = "AttackEvent",
			ToState = StateMachine.Attack,
			FromStates = {
				StateMachine.InAction,
			},
			Condition = function(): boolean
				if Button1Down then LastAttack = os.clock() end

				return Button1Down
			end,
		}, true)

		StateMachine:AddEvent({
			Name = "InActionEvent",
			ToState = StateMachine.InAction,
			FromStates = {
				StateMachine.Attack,
			},
			Condition = function(): boolean
				return os.clock() - LastAttack >= 2
			end,
		}, true)
	end

	function State:Enter() end

	function State:Update(dt) end

	function State:Exit() end

	return State
end
