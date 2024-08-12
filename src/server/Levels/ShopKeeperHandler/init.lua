local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Vendors = ReplicatedStorage.Vendors

local DoorInfo = TweenInfo.new(
	1,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.InOut,
	0,
	false,
	0
)
local OrientationOffset = 120

local Global = require(ReplicatedStorage.Global)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Net = require(ReplicatedStorage.Packages.Net)
local ZonePlus = require(Vendors.Zone)

local EnteredRemote = Net:RemoteEvent("EnteredShop")
local ExitRemote = Net:RemoteEvent("ExitShop")

local RNG = Random.new()

local ShopKeeperHandler = {}
ShopKeeperHandler.AlreadyGreeted = false

local function getRandomSound(folder)
	local randomIndex = RNG:NextInteger(1, #folder:GetChildren())
	return folder:GetChildren()[randomIndex].Name
end

function ShopKeeperHandler.Entered(Level)
	local Shop = Level:FindFirstChild("Shop")

	if not Shop then return end
	local Played = false
	local PlayedLeave = false
	local Sounds = ReplicatedStorage.Assets.Sounds.Emily

	-- All Emily Sounds:
	local GreetingVoice = Sounds:FindFirstChild("Greetings")
	local LeavingVoice = Sounds:FindFirstChild("Leaving")
	local Greetings_AgainVoice = Sounds:FindFirstChild("Greetings_Again")

	local audioJanitor = Janitor.new()

	local LeaveZone = ZonePlus.new(Shop.LeaveZone)
	local ShopKeeperZone = ZonePlus.new(Shop.ShopZone)
	local Door: BasePart = Shop:FindFirstChild("Door")
	local DoorCollider: BasePart = Shop:FindFirstChild("DoorCollider")

	local Camera = Shop:FindFirstChild("Camera")

	local TweenDoorOpen = TweenService:Create(Door, DoorInfo, {
		Orientation = Door.Orientation - Vector3.new(0, OrientationOffset, 0),
	})
	local TweenDoorClose =
		TweenService:Create(Door, DoorInfo, { Orientation = Door.Orientation })

	TweenDoorOpen:Play()

	LeaveZone.playerEntered:Connect(function(player)
		TweenDoorClose:Play()
		DoorCollider.CanCollide = true

		audioJanitor:Cleanup()

		if not PlayedLeave then
			local randomSound = getRandomSound(LeavingVoice)
			Global.GameUtil.playSound(randomSound, Shop.ShopZone, audioJanitor)
			PlayedLeave = true
		end

		print(("%s entered the zone!"):format(player.Name))
	end)

	ShopKeeperZone.playerEntered:Connect(function(player)
		EnteredRemote:FireClient(player, Camera, Shop.ShopZone)
		print(ShopKeeperHandler.AlreadyGreeted)

		if Played then return end
		Played = true

		audioJanitor:Cleanup()

		local greeting = if ShopKeeperHandler.AlreadyGreeted
			then Greetings_AgainVoice
			else GreetingVoice
		local randomSound = getRandomSound(greeting)
		Global.GameUtil.playSound(randomSound, Shop.ShopZone, audioJanitor)

		ShopKeeperHandler.AlreadyGreeted = true
	end)

	ShopKeeperZone.playerExited:Connect(function(player)
		ExitRemote:FireClient(player, Shop.ShopZone)
	end)
end

return ShopKeeperHandler
