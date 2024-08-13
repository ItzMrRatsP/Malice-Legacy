local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local EntityIFrames: { [number]: Model | number } = {}
local DamageHandler = {}

local EntityStatus = require(script.Parent.EntityStatus)
local KnockbackHandler = require(ReplicatedStorage.Vendors.Knockback)
local Ragdoll = require(ReplicatedStorage.Vendors.Ragdoll)

local function hasActiveIFrame(entity: Model | number): boolean?
	return not not table.find(EntityIFrames, entity)
end

local tweenInfo =
	TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
local fadeOutTweenInfo =
	TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

function DamageHandler.AddIFrame(EntityID, Length)
	local Entities = EntityStatus.Entities

	local EntityState = Entities[EntityID]

	if not EntityState then return end

	local Model = EntityID

	if EntityState.IsPlayer then
		Model = Players:GetPlayerByUserId(EntityID).Character
	end

	if not Model then return end

	local highlight = Instance.new("Highlight")
	highlight.OutlineTransparency = 1
	highlight.FillTransparency = 1
	highlight.Parent = Model

	local tween =
		TweenService:Create(highlight, tweenInfo, { OutlineTransparency = 0 })
	tween:Play()

	table.insert(EntityIFrames, EntityID)

	task.delay(Length, function()
		local fadeOutTween = TweenService:Create(
			highlight,
			fadeOutTweenInfo,
			{ OutlineTransparency = 1 }
		)
		fadeOutTween:Play()

		-- Remove the highlight after the tween completes
		fadeOutTween.Completed:Connect(function()
			highlight:Destroy()
		end)

		table.remove(EntityIFrames, table.find(EntityIFrames, EntityID))
	end)
end

function DamageHandler.DamageEntity(
	EntityID,
	Damage,
	DoStun,
	StunLength,
	IFrameLength,
	KnockBackParams
)
	local Entities = EntityStatus.Entities
	local EntityState = Entities[EntityID]

	if EntityState.IsPlayer then
		-- print("ITS PLAYER!")s
		local PlayerModel = Players:GetPlayerByUserId(EntityID).Character
		EntityID = PlayerModel
	end

	local Humanoid = EntityID:FindFirstChildOfClass("Humanoid")
	if not Humanoid then return end
	if Humanoid.Health <= 0 then return end

	if not EntityState then return end
	if hasActiveIFrame(EntityID) then return end

	if IFrameLength > 0 then DamageHandler.AddIFrame(EntityID, IFrameLength) end

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

	Humanoid:TakeDamage(Damage * workspace:GetAttribute("Damage_Multi"))
	
	local CurrentHealth = Humanoid.Health
	if CurrentHealth <= 0 then Ragdoll.setRagdoll(EntityID, 100) end

	if not KnockBackParams then return end
	KnockbackHandler.Apply(EntityID, table.unpack(KnockBackParams))
end

return DamageHandler
