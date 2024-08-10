local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Packages = ReplicatedStorage:FindFirstChild("Packages")
local Assets = ReplicatedStorage:FindFirstChild("Assets")

local Global = require(ReplicatedStorage.Global)
local Janitor = require(Packages.Janitor)
local MovementTilt = require(script.MovementTilt)
local Spring = require(Packages.Spring)

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
	self.Root = self.Humanoid.RootPart

	self.MovementTilt = MovementTilt.Init()

	self.CharacterAnimations = {}

	for _, Animation in
		ReplicatedStorage.Assets.Animations.CharacterAnimations:GetChildren()
	do
		if not Animation:IsA("Animation") then continue end
		self.CharacterAnimations[Animation.Name] =
			self.Animator:LoadAnimation(Animation)
	end

	self.PosSpring = Spring.new(Vector3.new())

	self.CameraPart = Assets.Target:Clone()
	Camera.CameraSubject = self.CameraPart

	self.PosSpring.s = 4
	self.PosSpring.d = 0.6

	self.WalkSpeed = 1

	self.MovementStateMachine = self.Janitor:Add(
		Global.StateMachine.newFromFolder(script.States, self),
		"Destroy"
	)

	DisableStates(self.Humanoid, HumanoidDisabledStates)

	RunService.PreRender:Connect(function(DT)
		self:Update(DT)
	end)

	self.MovementStateMachine:Start(self.MovementStateMachine.Idling)
	return self
end

function CharacterHandler:Update(dt)
	self.Humanoid.WalkSpeed = self.WalkSpeed
	local Goal = self.Root.CFrame

	local PositionGoal = Goal.Position

	local CameraPos = self.PosSpring.p
	self.PosSpring.t = PositionGoal

	self.CameraPart.CFrame = CFrame.new(CameraPos)
	local RootPos, MousePos = self.Root.Position, Mouse.Hit.Position
	self.Root.CFrame = self.Root.CFrame:Lerp(
		CFrame.new(RootPos, Vector3.new(MousePos.X, RootPos.Y, MousePos.Z)),
		dt * 5 * 3
	)
end

function CharacterHandler:Destroy()
	self.Janitor:Destroy()
	self = nil
end

return CharacterHandler
