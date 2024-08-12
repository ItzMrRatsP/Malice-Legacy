-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

-- Variables
local BehaviorTree = require(ReplicatedStorage.Vendors.BehaviorTreeCreator)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local SimplePath = require(ReplicatedStorage.Vendors.SimplePath)

local Ghoul = {}

local function setPath(self, Path)
	Path.Reached:Connect(function()
		self.hasTarget = false
		self.Target = nil
	end)

	Path.Blocked:Connect(function()
		if self.hasTarget then Path:Run(self.Target.PrimaryPart) end
	end)

	Path.WaypointReached:Connect(function()
		if self.hasTarget then Path:Run(self.Target.PrimaryPart) end
	end)
end

function Ghoul:Start(Entity: Model)
	local delayPerAttack = 2

	local obj = {
		Entity = Entity,
		Behavior = ServerStorage.Behaviors:FindFirstChild(Entity.Name),
		hasTarget = false,
		Target = nil,
		Path = nil,
		Damage = 15,
		Radius = 20,
		AttackRadius = 2.5,
		DelayPerAttack = delayPerAttack,
		LatestAttack = os.clock() - delayPerAttack,
	}

	local janitor = Janitor.new()
	local path = SimplePath.new(obj.Entity, {
		AgentHeight = 2,
		AgentRadius = 5,
		AgentCanJump = true,
		AgentCanClimb = false,
		WaypointSpacing = 1,
		Costs = {
			Padding = math.huge,
		},
	}, { JUMP_WHEN_STUCK = false })

	obj.Path = path
	setPath(obj, obj.Path) -- Set path.

	local EntityBrain =
		BehaviorTree:Create(obj.Behavior:FindFirstChild("WalkState", true))

	janitor:Add(RunService.PreSimulation:Connect(function()
		EntityBrain:run(obj)

		if not obj.hasTarget then return end
		if not obj.Target then return end

		path:Run(obj.Target.PrimaryPart)
	end))

	local Humanoid = obj.Entity:FindFirstChild("Humanoid")

	janitor:Add(Humanoid.Died:Connect(function()
		janitor:Cleanup()
	end))

	janitor:Add(obj.Entity.Destroying:Connect(function()
		janitor:Cleanup()
	end))
end

return Ghoul
