local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local CharacterTable = {}

local MovementTilt = {}
MovementTilt.__index = MovementTilt

local function Slerp(angle1, angle2, t)
	local theta = angle2 - angle1
	angle1 += if theta > math.pi then 2*math.pi elseif theta < -math.pi then -2*math.pi else 0
	return angle1 + (angle2 - angle1) * t
end

function MovementTilt.Init()
	local self = setmetatable({}, MovementTilt)
	self.Enabled = true
	
	self.Connection = RunService.RenderStepped:Connect(function(dt)
		
		for _, player in Players:GetPlayers() do
			local OtherCharacter = player.Character
   
			if not OtherCharacter then continue end
			local Root = OtherCharacter:WaitForChild("HumanoidRootPart")
            local Humanoid = OtherCharacter.Humanoid
			if (Humanoid.RootPart.Position - Root.Position).Magnitude > 30 then continue end
			
			if not CharacterTable[OtherCharacter] then
				CharacterTable[OtherCharacter] = {
					Humanoid = OtherCharacter.Humanoid,
					Torso = OtherCharacter.Torso,
					Root = Root,
					rootJoint = Root.RootJoint,
					rootJointC0 = Root.RootJoint.C0,
					leftHip = OtherCharacter.Torso["Left Hip"],
					rightHip = OtherCharacter.Torso["Right Hip"],
					leftHipC0 = OtherCharacter.Torso["Left Hip"].C0,
					rightHipC0 = OtherCharacter.Torso["Right Hip"].C0,
					neck = OtherCharacter.Torso.Neck,
					neckC0 = OtherCharacter.Torso.Neck.C0,
					TorsoAngle = 0,
					DesiredAngle = 0
				}
			end
			
			local CharacterTable = CharacterTable[OtherCharacter]
			
			local moveInput = CharacterTable.Humanoid.MoveDirection

			local lastRootCF = CharacterTable.Root.CFrame
			local desiredAngle
			local offset = lastRootCF.Rotation:PointToObjectSpace(moveInput) * Vector3.new(1,0,1)

			if moveInput.Magnitude < 0.01 or not self.Enabled then
				CharacterTable.rootJoint.C0 = CharacterTable.rootJointC0
				CharacterTable.leftHip.C0 = CharacterTable.leftHipC0
				CharacterTable.rightHip.C0 = CharacterTable.rightHipC0
				desiredAngle = 0
			else
				desiredAngle = -math.atan2(-offset.X, -offset.Z)
				
				if math.abs(desiredAngle) > 2*math.pi/4 + 0.1 then
					desiredAngle = math.sign(desiredAngle) * (math.abs(desiredAngle) - math.pi)
				end

			end
			
			CharacterTable.TorsoAngle = Slerp(CharacterTable.TorsoAngle, desiredAngle, 1 - math.pow(2, -10 * dt))
			local torso = CharacterTable.Torso
			local rotation = CFrame.Angles(0, -CharacterTable.TorsoAngle /2, 0)
			CharacterTable.leftHip.C0 = rotation * CharacterTable.leftHipC0
			CharacterTable.rightHip.C0 = rotation * CharacterTable.rightHipC0
			CharacterTable.rootJoint.C0 = CFrame.Angles(0, -CharacterTable.TorsoAngle/2, 0) * CharacterTable.rootJointC0
		end
		
	end)
	
	return self
end

function MovementTilt:Disable()
	self.Enabled = false

end

function MovementTilt:Enable()
	self.Enabled = true
end

function MovementTilt:Destroy()
	self.Connection:Disconnect()
end

return MovementTilt

