local EntityIFrames: { [number]: Instance | number } = {}
local DamageHandler = {}

local EntityStatus = require(script.Parent.EntityStatus)

local function hasActiveIFrame(entity: Instance | number): boolean?
	return not not table.find(EntityIFrames, entity)
end

function DamageHandler.AddIFrame(EntityID, Length)
	table.insert(EntityIFrames, EntityID)

	task.delay(Length, function()
		table.remove(EntityIFrames, table.find(EntityIFrames, EntityID))
	end)
end

function DamageHandler.DamageEntity(
	EntityID: Instance,
	Damage,
	DoStun,
	StunLength,
	IFrameLength
)
	local Entities = EntityStatus.Entities
	local EntityState = Entities[EntityID]

	if not EntityState then return end
	if hasActiveIFrame(EntityID) then return end

	if IFrameLength > 0 then
		DamageHandler.AddIFrame(EntityID, IFrameLength)
	end

	if DoStun then
		EntityState.CombatStateMachine:Transition(
			EntityState.CombatStateMachine.Stun
		)

		task.delay(StunLength, function()
			EntityState.CombatStateMachine:Transition(
				EntityState.CombatStateMachine.InAction
			)
		end)
	end

	local Humanoid = EntityID:FindFirstChildOfClass("Humanoid")
	if not Humanoid then return end

	Humanoid:TakeDamage(Damage)
end

return DamageHandler
