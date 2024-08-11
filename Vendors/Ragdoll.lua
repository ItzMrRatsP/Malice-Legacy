local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Global = require(ReplicatedStorage.Global)
local Janitor = require(ReplicatedStorage.Packages.Janitor)

local Ragdoll = {}

function Ragdoll.setRagdoll(Character: Model?, removeTime: number?)
	-- Change State
	local janitor = Janitor.new()

	if not Character then
		Global.DebugUtil(
			"Character Model is invalid, please provide a valid character model"
		)
		return
	end

	local Humanoid: Humanoid? =
		Character:FindFirstChild("Humanoid") :: Humanoid?
	if not Humanoid then
		Global.DebugUtil(
			"Character Model doesn't have Humanoid, please try with another Character Model."
		)
		return
	end

	-- Now we set state
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, true) -- Ragdoll State

	janitor:Add(function()
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false) -- Remove ragdoll state

		for _, motors in Character:GetDescendants() do
			if not motors:IsA("Motor6D") then continue end
			motors.Enabled = true
		end
	end)

	for _, motors in Character:GetDescendants() do
		if not motors:IsA("Motor6D") then continue end
		motors.Enabled = false

		local attachment0 = janitor:Add(Instance.new("Attachment"))
		attachment0.Parent = motors.Part0
		attachment0.CFrame =
			motors.Part0.CFrame:ToObjectSpace(motors.Part1.CFrame)

		local attachment1 = janitor:Add(Instance.new("Attachment"))
		attachment1.Parent = motors.Part1

		local socket = janitor:Add(Instance.new("BallSocketConstraint"))
		socket.LimitsEnabled = true
		socket.TwistLimitsEnabled = true
		socket.Attachment0 = attachment0
		socket.Attachment1 = attachment1
		socket.Parent = motors.Part0
	end

	task.delay(removeTime, function()
		janitor:Destroy()
	end)
end

return Ragdoll
