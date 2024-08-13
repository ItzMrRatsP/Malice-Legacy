local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Packages = ReplicatedStorage:FindFirstChild("Packages")
local Vendors = ReplicatedStorage:FindFirstChild("Vendors")
local Assets = ReplicatedStorage:FindFirstChild("Assets")

local CameraDetection = require(ReplicatedStorage.Client.CameraDetection)
local Global = require(ReplicatedStorage.Global)
local Janitor = require(Packages.Janitor)
local MovementTilt = require(script.MovementTilt)
local Net = require(ReplicatedStorage.Packages.Net)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Spring = require(Vendors.Spring)

local CutsceneModel = workspace:WaitForChild("CutscenePart")

local CutsceneFolder = CutsceneModel:WaitForChild("CutsceneFolder")
local CameraRig = CutsceneFolder:WaitForChild("CameraRig")
local CutScenePlayer = CutsceneFolder:WaitForChild("CutScenePlayer")

local CharacterHandler = {}
CharacterHandler.__index = CharacterHandler

local CutsceneAnimations =
	ReplicatedStorage.Assets.Animations.CutsceneAnimations
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

	self.Trail1 = self.CharacterInstance.Sword.Blade.NewTrail
	self.Trail2 = self.CharacterInstance.Sword.Blade.NewTrail2

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
	self.CustomCamera = nil
	self.CutsceneCamera = false
	self.CanLook = true

	local CameraAnimator: Animator = CameraRig:WaitForChild("Humanoid").Animator
	local PlayerAnimator: Animator =
		CutScenePlayer:WaitForChild("Humanoid").Animator

	local CameraAnimation =
		CameraAnimator:LoadAnimation(CutsceneAnimations.CameraAnimation)
	local PlayerAnimation =
		PlayerAnimator:LoadAnimation(CutsceneAnimations.PlayerAnimation)

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

	self.LerpSpeed = 0.1

	Net:Connect("EnteredShop", function(CameraPart)
		self.CustomCamera = CameraPart.CFrame
	end)

	Net:Connect("ExitShop", function()
		self.CustomCamera = nil
	end)

	Net:Connect("CutsceneStarted", function()
		local ShirtClone = self.CharacterInstance:WaitForChild("Shirt"):Clone()
		local PantClone = self.CharacterInstance:WaitForChild("Pants"):Clone()

		ShirtClone.Parent = CutScenePlayer
		PantClone.Parent = CutScenePlayer

		local BodyColors = self.CharacterInstance:WaitForChild("BodyColors")
		BodyColors.Parent = CutScenePlayer

		for _, Object: BasePart in self.CharacterInstance:GetChildren() do
			if Object:IsA("Accessory") then
				local AccessoryClone = Object:Clone()
				if not AccessoryClone.Handle then continue end
				AccessoryClone.Handle.AccessoryWeld.Part1 =
					CutScenePlayer:WaitForChild("Head")
				AccessoryClone.Parent = CutScenePlayer
			end
		end

		CameraAnimation.Looped = false
		PlayerAnimation.Looped = false
		CameraDetection.Enabled = false

		CameraAnimation:Play()
		PlayerAnimation:Play()

		self.CustomCamera = CameraRig:WaitForChild("Torso")
		self.LerpSpeed = 1

		ReplicatedStorage:SetAttribute("generatingNewLevel", false)

		Promise.fromEvent(CameraAnimation.Stopped, function()
			ReplicatedStorage:SetAttribute("generatingNewLevel", true)
			self.CustomCamera = nil
			self.LerpSpeed = 0.1
			CameraDetection.Enabled = true

			task.delay(2, function()
				ReplicatedStorage:SetAttribute("generatingNewLevel", false)
			end)

			return true
		end)
	end)

	self.MovementStateMachine:Start(self.MovementStateMachine.Idling)
	self.CombatStateMachine:Start(self.CombatStateMachine.InAction)
	return self
end

function CharacterHandler:Update(dt)
	self.Humanoid.WalkSpeed = self.WalkSpeed
	self.CharacterInstance.Torso.CanCollide = false
	self.CharacterInstance.Head.CanCollide = false
	local PositionGoal = self.Root.Position + self.Root.CFrame.UpVector * 25

	local CameraPos = self.PosSpring.p

	if not self.CustomCamera then
		Camera.CFrame = CFrame.new(CameraPos)
			* CFrame.Angles(math.rad(-90), 0, 0)
		self.PosSpring.t = PositionGoal
	else
		if typeof(self.CustomCamera) == "CFrame" then
			Camera.CFrame =
				Camera.CFrame:Lerp(self.CustomCamera, self.LerpSpeed)
		else
			Camera.CFrame =
				Camera.CFrame:Lerp(self.CustomCamera.CFrame, self.LerpSpeed)
		end
	end

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
