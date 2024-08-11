local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Global = require(ReplicatedStorage.Global)
local Janitor = require(ReplicatedStorage.Packages.Janitor)

local spawnEntity = {}
local spawnTag = "NPCSpawn" -- Tag for all spawn points!

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
	npc.Parent = workspace.Entity

	-- Spawn title:
	local humanoid = npc:FindFirstChild("Humanoid")
	if not humanoid then return end

	janitor:Add(
		humanoid.Died:Connect(function()
			janitor:Destroy()
			task.delay(
				npc:GetAttribute("respawnTime") or 0.35,
				createNPC,
				spawn,
				name
			)
		end),

		"Disconnect"
	)
end

function spawnEntity:Start()
	for _, spawns in CollectionService:GetTagged(spawnTag) do
		local entityName = spawns:GetAttribute("Name")
		if not entityName then continue end

		createNPC(spawns, entityName)
	end
end

return spawnEntity
