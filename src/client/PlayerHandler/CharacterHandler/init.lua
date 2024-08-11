local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Packages = ReplicatedStorage:FindFirstChild("Packages")
local Vendors = ReplicatedStorage:FindFirstChild("Vendors")
local Assets = ReplicatedStorage:FindFirstChild("Assets")

local Global = require(ReplicatedStorage.Global)
local Janitor = require(Packages.Janitor)
local MovementTilt = require(script.MovementTilt)
local Net = require(ReplicatedStorage.Packages.Net)
local Spring = require(Vendors.Spring)

local CharacterHandler = {}
CharacterHandler.__index = CharacterHandler

local Camera = workspace.CurrentCamera
local Mouse = Players.LocalPlayer:GetMouse()

local HumanoidDisabledStates = {
	Enum.HumanoidStateType.Jumping,
	Enum.HumanoidStateType.Swimming,
	Enum.HumanoidStateType.Climbing,
	Enum.HumanoidStateType.Ragdoll,
	Enum.HumanoidStateType.FallingDown,
}

local function DisableStates(Humanoid, States)
	for _, State in States do
		Humanoid:SetStateEnabled(State, false)
	end
end

function CharacterHandler.new(Character, PlayerHandler)
	local self = setmetatable({}, CharacterHandler)

	self.Janitor = Janitor.new()

	self.Handler = PlayerHandler
	self.CharacterInstance = Character
	self.Humanoid = self.CharacterInstance:WaitForChild("Humanoid")
	self.Animator = self.Humanoid:WaitForChild("Animator")
	self.Root = self.CharacterInstance:WaitForChild("HumanoidRootPart")

	self.MovementTilt = MovementTilt.Init()

	self.CharacterAnimations = {}

	for _, Animation in
		ReplicatedStorage.Assets.Animations.CharacterAnimations:GetDescendants()
	do
		if not Animation:IsA("Animation") then continue end
		self.CharacterAnimations[Animation.Name] =
			self.Animator:LoadAnimation(Animation)
	end

	self.PosSpring = Spring.new(Vector3.new())
	Camera.CameraType = Enum.CameraType.Scriptable
	Camera.FieldOfView = 60

	self.PosSpring.s = 15
	self.PosSpring.d = 0.6
	self.CanLook = true

	self.WalkSpeed = 1

	self.MovementStateMachine = self.Janitor:Add(
		Global.StateMachine.newFromFolder(script.States, self),
		"Destroy"
	)

	self.CombatStateMachine = self.Janitor:Add(
		Global.StateMachine.newFromFolder(script.CombatStates, self),
		"Destroy"
	)

	DisableStates(self.Humanoid, HumanoidDisabledStates)

	RunService.PreRender:Connect(function(DT)
		self:Update(DT)
	end)

	self.MovementStateMachine:Start(self.MovementStateMachine.Idling)
	self.CombatStateMachine:Start(self.CombatStateMachine.InAction)
	return self
end

function CharacterHandler:Update(dt)
	self.Humanoid.WalkSpeed = self.WalkSpeed

	local PositionGoal = self.Root.Position + self.Root.CFrame.UpVector * 25

	local CameraPos = self.PosSpring.p
	self.PosSpring.t = PositionGoal

	Camera.CFrame = CFrame.new(CameraPos) * CFrame.Angles(math.rad(-90), 0, 0)

	if self.CanLook then
		local RootPos, MousePos = self.Root.Position, Mouse.Hit.Position
		self.Root.CFrame = self.Root.CFrame:Lerp(
			CFrame.new(RootPos, Vector3.new(MousePos.X, RootPos.Y, MousePos.Z)),
			dt * 5 * 3
		)
	end
end

function CharacterHandler:Destroy()
	self.Janitor:Destroy()
	self = nil
end

return CharacterHandler
