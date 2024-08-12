-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

-- Variables
local Global = require(ReplicatedStorage.Global)

local Janitor = require(ReplicatedStorage.Packages.Janitor)
local BehaviorTree = require(ReplicatedStorage.Vendors.BehaviorTreeCreator)
local SimplePath = require(ReplicatedStorage.Vendors.SimplePath)

local Goblin = {}

local function setPath(self, Path)
	Path.Reached:Connect(function()
		self.HasTarget = false
		self.Target = nil
	end)

	Path.Blocked:Connect(function()
		if self.HasTarget then
			Path:Run(self.Target)
		end
	end)

	Path.WaypointReached:Connect(function()
		if self.HasTarget then
			Path:Run(self.Target)
		end
	end)
end

function Goblin:Start(Entity: Model)
	local obj = {
		Entity = Entity,
		Behavior = ServerStorage.Behaviors:FindFirstChild(Entity.Name),
		hasTarget = false,
		Target = nil,
		Path = nil,
		Damage = 15,
		Radius = 5,
		DelayPerAttack = 2,
		LastestAttack = os.clock(),
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
		BehaviorTree:Create(obj.Behavior:FindFirstChild("IdleState", true), obj)

	janitor:Add(RunService.PreSimulation:Connect(function()
		EntityBrain:run(obj)

		if not obj.hasTarget then return end
		if not obj.Target then return end

		path:Run(obj.Target)
	end))

	local Humanoid = obj.Entity:FindFirstChild("Humanoid")

	janitor:Add(Humanoid.Died:Connect(function()
		return janitor:Cleanup()
	end))

	Goblin.Stop = function() -- Stops prototype ai.
		return janitor:Cleanup()
	end
end

return Goblin
