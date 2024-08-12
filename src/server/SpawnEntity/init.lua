local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Global = require(ReplicatedStorage.Global)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local LemonSignal = require(ReplicatedStorage.Packages.LemonSignal)

local spawnEntity = {}

spawnEntity.spawnLevelEntity = LemonSignal.new()
spawnEntity.despawnLevelEntity = LemonSignal.new()

local spawnedEntity = {}
local spawnTag = "SpawnEntity" -- Tag for all spawn points!

local Brains = script.Brains

local function addAI(Name: string, EntityModel: Model)
	if not Brains:FindFirstChild(Name) then return end

	local brain = require(Brains:FindFirstChild(Name))
	brain:Start(EntityModel)
end

local function createNPC(spawn: BasePart, name: string)
	local janitor = Janitor.new()

	local targetEntity =
		ReplicatedStorage.Assets.Entity:FindFirstChild(name, true)
	if not targetEntity then
		Global.DebugUtil(
			"Seems like entity is not valid member of path://ReplicatedStorage/Assets/Entity"
		)
		return
	end

	local npc = janitor:Add(targetEntity:Clone(), "Destroy")
	npc:PivotTo(spawn.CFrame)
	npc.Parent = workspace.Enemies

	table.insert(spawnedEntity, janitor)
	addAI(name, npc) -- Spawns the AI

	-- Spawn title:
	local humanoid = npc:FindFirstChild("Humanoid")
	if not humanoid then return end

	janitor:Add(
		humanoid.Died:Connect(function()
			task.wait(2)
			table.remove(spawnedEntity, table.find(spawnedEntity, janitor))
			if janitor.Destroy then janitor:Destroy() end
		end),

		"Disconnect"
	)
end

function spawnEntity:Start()
	self.spawnLevelEntity:Connect(function()
		for _, spawns in CollectionService:GetTagged(spawnTag) do
			local entityName = spawns:GetAttribute("Name")
			if not entityName then return end

			createNPC(spawns, entityName)
		end
	end)

	self.despawnLevelEntity:Connect(function()
		for _, janitor in spawnedEntity do
			if janitor.Destroy then janitor:Destroy() end
		end
	end)
end

return spawnEntity
