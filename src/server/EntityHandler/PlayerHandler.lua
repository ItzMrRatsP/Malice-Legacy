local PlayerHandler = {}
local RNG = Random.new()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = ReplicatedStorage.Assets

local Effects = Assets.Effects
local Sounds = Assets.Sounds
local BreakSound = Sounds.Breakable

local function getRandomPositionWithinRadius(radius)
	local x = RNG:NextInteger(-radius, radius)
	local y = RNG:NextInteger(-radius, radius)
	local z = RNG:NextInteger(-radius, radius)
	return Vector3.new(x, y, z)
end

local function summonWoodenParts(position, radius, partCount, impulseStrength)
	for i = 1, partCount do
		local part = Instance.new("Part")
		part.Size = Vector3.new(1, 0.5, 3)
		part.Position = position + getRandomPositionWithinRadius(radius)
		part.Anchored = false
		part.Material = Enum.Material.Plastic
		part.MaterialVariant = "Wood2"
		part.Parent = workspace

		part:ApplyImpulse(getRandomPositionWithinRadius(impulseStrength))

		task.delay(3, function()
			part:Destroy()
		end)
	end
end

local function summonClayShards(Size, Target)
	local ClayShards : Model = Assets.Debris:Clone()

	ClayShards:ScaleTo(Size * 0.15)

	ClayShards:PivotTo(Target)
	ClayShards.Parent = workspace
end


-- Example usage: Summon 10 wooden parts in a radius of 20 studs with an impulse strength of 50
local examplePosition = Vector3.new(0, 50, 0) -- Example position (above the ground)
summonWoodenParts(examplePosition, 20, 10, 50)

local EnemyAnimations = Assets.Animations.EnemyAnimations
local PlayerAnimations = Assets.Animations.CharacterAnimations

local Net = require(ReplicatedStorage.Packages.Net)

local DamageHandler = require(script.Parent.DamageHandler)
local EntityStatus = require(script.Parent.EntityStatus)

function PlayerHandler:Start()
	Net:Connect(
		"AttackRE",
		function(
			Player: Player,
			HumanoidModels: { Model? },
			Breakables: { BasePart? }
		)
			local Character = Player.Character

			local RootPart: BasePart =
				Character:WaitForChild("HumanoidRootPart")
			-- Humanoi Models:

			for _, Part in Breakables do
				if Part:HasTag("Door") then
					Part.Anchored = false
					local PlayerRootPart = Player.Character:WaitForChild("HumanoidRootPart")
					local Door = BreakSound.Door:Clone()

					Door.Parent = Part

					Door:Play()

					Part:ApplyImpulse(PlayerRootPart.CFrame.LookVector * 100)
					continue
				end
				if Part:HasTag("Pot") then
					print("Pot")
					task.spawn(function()
						local Dust = Effects.Dust:Clone()
						local Particle: ParticleEmitter = Dust.Parc

						local PotBreak = BreakSound.PotBreak:Clone()

						PotBreak.Parent = Part
						print("Pot")
						Dust.Parent = workspace

						Dust.CFrame = Part.CFrame
						Dust.Size = Part.Size

						summonClayShards(Part.Size.Magnitude, Part.CFrame)

						Particle.Enabled = true
						task.wait(0.2)

						Particle.Enabled = false
						task.wait(1)
						--Dust:Destroy()
					end)
				end

				if Part:HasTag("Box") then
					print("Box")
					task.spawn(function()
						local Dust = Effects.Dust:Clone()
						local Particle: ParticleEmitter = Dust.Parc
						Dust.Parent = workspace

						local BoxBreak = BreakSound.BoxBreak:Clone()

						BoxBreak.Parent = Part

						Dust.CFrame = Part.CFrame
						Dust.Size = Part.Size

						summonWoodenParts(Part.Position, 5, 5, 15)
						Particle.Enabled = true
						task.wait(0.2)

						Particle.Enabled = false
						task.wait(1)
						--Dust:Destroy()
					end)
				end

				Part:Destroy()
			end

			for _, model in HumanoidModels do
				-- damage entity:
				DamageHandler.DamageEntity(
					model,
					15,
					true,
					0.25,
					0.3,
					{ RootPart.CFrame.LookVector, 1, 1 }
				)
			end
		end
	)

	Net:Connect("RollRE", function(Player: Player)
		DamageHandler.AddIFrame(Player.UserId, 0.5)
		print("Rolled")
	end)
end

return PlayerHandler
