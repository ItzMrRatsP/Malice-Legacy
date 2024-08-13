local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Global = require(ReplicatedStorage.Global)

local Assets = ReplicatedStorage.Assets

local Effects = Assets.Effects
local Blood: ParticleEmitter = Effects.Blood

local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Net = require(ReplicatedStorage.Packages.Net)
local jan = Janitor.new()
local Attack = Net:RemoteEvent("AttackRE")

local function isHumanoid(Part)
	local HumanoidModel: Model = Part:FindFirstAncestorOfClass("Model")
	if
		not HumanoidModel
		or not HumanoidModel:FindFirstChildOfClass("Humanoid")
	then
		return
	end

	return HumanoidModel
end

local function createHitbox(root: BasePart?): BasePart?
	if not root then
		Global.DebugUtil("NO ROOTPART DETECTED, WIZARD OF OZ IS MAD!!")
		return
	end

	local hb = Instance.new("Part")
	hb.Name = "Hitbox"
	hb.Color = Color3.new(1, 0, 0)
	hb.CanCollide = false
	hb.CanTouch = false
	hb.CanQuery = false
	hb.Massless = true
	hb.Transparency = 1
	hb.Material = Enum.Material.Neon
	hb.Size = Vector3.new(7, 5, 7)
	hb.CFrame = root.CFrame * CFrame.new(0, 0, -5)
	hb.Parent = workspace

	Global.GameUtil.weld(root, hb) -- Weld
	return hb
end

return function(StateMachine, Character)
	local State = StateMachine:AddState(script.Name)
	local AttackNumber = 1

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
				if
					Character.MovementStateMachine.CurrentState.Name
					== "Rolling"
				then
					return false
				end
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
				return os.clock() - LastAttack >= 0.5
			end,
		}, true)
	end

	function State:Enter()
		if AttackNumber > 3 then AttackNumber = 1 end

		Character.CharacterAnimations["1"].Looped = false
		Character.CharacterAnimations["2"].Looped = false
		Character.CharacterAnimations["3"].Looped = false
		Character.CharacterAnimations["4"].Looped = false

		Character.CharacterAnimations["1"].Priority =
			Enum.AnimationPriority.Action
		Character.CharacterAnimations["2"].Priority =
			Enum.AnimationPriority.Action
		Character.CharacterAnimations["3"].Priority =
			Enum.AnimationPriority.Action
		Character.CharacterAnimations["4"].Priority =
			Enum.AnimationPriority.Action

		local Params = OverlapParams.new()
		Params.FilterType = Enum.RaycastFilterType.Exclude
		Params.FilterDescendantsInstances = { Character.CharacterInstance }

		local hb = jan:Add(createHitbox(Character.Root))
		local Parts = workspace:GetPartsInPart(hb, Params)

		local DoorOpen = false

		for _, part: BasePart in Parts do
			if part:HasTag("Door") and part.Anchored then DoorOpen = true end
		end

		if not DoorOpen then
			Character.CharacterAnimations[tostring(AttackNumber)]:Play(
				0.1,
				1,
				1
			)
			Global.GameUtil.playSound(`Swoosh{AttackNumber}`, Character.Root)

			AttackNumber += 1
		else
			Character.CharacterAnimations["Kick"].Looped = false
			Character.CharacterAnimations["Kick"]:Play(0.1, 1, 1)
		end

		if AttackNumber <= 2 then
			task.wait(0.25)
		else
			task.wait(0.1)
		end

		Character.Trail1.Enabled = true
		Character.Trail2.Enabled = true

		local Params = OverlapParams.new()
		Params.FilterType = Enum.RaycastFilterType.Exclude
		Params.FilterDescendantsInstances = { Character.CharacterInstance }

		local hb = jan:Add(createHitbox(Character.Root))
		local Parts = workspace:GetPartsInPart(hb, Params)

		local humanoids = {}
		local Breakables = {}

		for _, part: BasePart in Parts do
			if part:HasTag("Breakable") then
				table.insert(Breakables, part)
				continue
			end
			local HumanoidModel = isHumanoid(part)
			if not HumanoidModel then continue end
			if not HumanoidModel:HasTag("Enemy") then continue end
			if table.find(humanoids, HumanoidModel) then continue end

			table.insert(humanoids, HumanoidModel)

			Global.GameUtil.playSound("SwordImpact", HumanoidModel)

			local BloodClone = jan:Add(Blood:Clone(), "Destroy")
			BloodClone.Parent = HumanoidModel.HumanoidRootPart
			BloodClone:Emit(50)
		end

		Attack:FireServer(humanoids, Breakables)

		task.delay(
			Character.CharacterAnimations[tostring(AttackNumber)].Length - 0.25,
			function()
				Character.Trail1.Enabled = false
				Character.Trail2.Enabled = false
			end
		)
	end

	function State:Update(dt) end

	function State:Exit()
		jan:Cleanup()
	end

	return State
end
