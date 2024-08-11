
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Net = require(ReplicatedStorage.Packages.Net)
local Janitor = require(ReplicatedStorage.Packages.Janitor)

-- WE NEED TO REMOVE THE FUCKING VELOCITY!!!!!!
local Roll = Net:RemoteEvent("RollRE")


return function(StateMachine, Character)
	local janitor = Janitor.new()
	local State = StateMachine:AddState(script.Name)
	local LastRoll = os.clock()
	local Force = 30
	local Debounce = false

	function State:Start()
		StateMachine:AddEvent({
			Name = "RollEvent",
			ToState = StateMachine.Rolling,
			FromStates = {
				StateMachine.Idling,
				StateMachine.Walking,
			},
			Condition = function(): boolean
				return UserInputService:IsKeyDown(Enum.KeyCode.Space) and not Debounce
			end,
		}, true)

		StateMachine:AddEvent({
			Name = "RollToIdleEvent",
			ToState = StateMachine.Idling,
			FromStates = {
				StateMachine.Rolling,
			},
			Condition = function(): boolean
				return os.clock() - LastRoll >= 0.25
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
	end

	function State:Update(dt) end

	function State:Exit() 
		Character.CanLook = true
		Character.MovementTilt:Enable()

		janitor:Cleanup()

		task.delay(1, function()
			Debounce = false
		end)
	end

	return State
end
