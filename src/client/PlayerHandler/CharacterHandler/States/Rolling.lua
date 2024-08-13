local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Net = require(ReplicatedStorage.Packages.Net)

-- WE NEED TO REMOVE THE FUCKING VELOCITY!!!!!!
local Roll = Net:RemoteEvent("RollRE")

return function(StateMachine, Character)
	local janitor = Janitor.new()
	local State = StateMachine:AddState(script.Name)
	local LastRoll = os.clock()
	local Force = 25
	local Debounce = false

	local Cooldown = (1/workspace:GetAttribute("Roll_Multi"))

	workspace:GetAttributeChangedSignal("Roll_Multi"):Connect(function()
		Cooldown = (1/workspace:GetAttribute("Roll_Multi"))
	end)

	function State:Start()
		StateMachine:AddEvent({
			Name = "RollEvent",
			ToState = StateMachine.Rolling,
			FromStates = {
				StateMachine.Idling,
				StateMachine.Walking,
			},
			Condition = function(): boolean
				if Character.CombatStateMachine.CurrentState.Name == "Attack" then
					return false
				end
				return UserInputService:IsKeyDown(Enum.KeyCode.Space)
					and not Debounce
			end,
		}, true)

		StateMachine:AddEvent({
			Name = "RollToIdleEvent",
			ToState = StateMachine.Idling,
			FromStates = {
				StateMachine.Rolling,
			},
			Condition = function(): boolean
				return os.clock() - LastRoll >= 0.5
			end,
		}, true)
	end

	function State:Enter()
		LastRoll = os.clock()
		Roll:FireServer()
		Debounce = true

		Character.MovementTilt:Disable()
		Character.CanLook = false
		Character.WalkSpeed = 0

		local BodyVelocity = janitor:Add(Instance.new("BodyVelocity"))
		BodyVelocity.Velocity = Character.Root.CFrame.LookVector * Force
		BodyVelocity.MaxForce = Vector3.one * math.huge
		BodyVelocity.Parent = Character.Root

		Character.CharacterAnimations["Roll"]:Play(0.1, 1, 1)
	end

	function State:Update(dt) end

	function State:Exit()
		Character.CanLook = true
		Character.MovementTilt:Enable()

		janitor:Cleanup()

		task.delay(Cooldown, function()
			Debounce = false
		end)
	end

	return State
end
