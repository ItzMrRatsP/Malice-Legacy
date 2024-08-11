local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Global = require(ReplicatedStorage.Global)

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
	hb.Transparency = 0.6
	hb.Material = Enum.Material.Neon
	hb.Size = Vector3.new(7, 5, 7)
	hb.CFrame = root.CFrame * CFrame.new(0, 0, -5)
	hb.Parent = workspace

	Global.GameUtil.weld(root, hb) -- Weld

	return hb
end

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
				return os.clock() - LastAttack >= 0.5
			end,
		}, true)
	end

	function State:Enter()
		local Params = OverlapParams.new()
		Params.FilterType = Enum.RaycastFilterType.Include
		Params.FilterDescendantsInstances = { workspace.Enemies }

		local hb = jan:Add(createHitbox(Character.Root))
		local Parts = workspace:GetPartsInPart(hb, Params)
		local humanoids = {}

		for _, part: BasePart in Parts do
			local HumanoidModel = isHumanoid(part)
			if not HumanoidModel then continue end

			if table.find(humanoids, HumanoidModel) then continue end

			table.insert(humanoids, HumanoidModel)
			print(`Humanoid {HumanoidModel} was detected`)
		end

		Attack:FireServer(humanoids)
	end

	function State:Update(dt) end

	function State:Exit()
		jan:Cleanup()
	end

	return State
end
