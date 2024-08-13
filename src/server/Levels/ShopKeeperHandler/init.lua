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
local LemonSignal = require(ReplicatedStorage.Packages.LemonSignal)
local Net = require(ReplicatedStorage.Packages.Net)
local ShopKeeper = require(ReplicatedStorage.Client.ShopKeeper)
local ZonePlus = require(Vendors.Zone)

local EnteredRemote = Net:RemoteEvent("EnteredShop")
local ExitRemote = Net:RemoteEvent("ExitShop")
local Dialogue = Net:RemoteEvent("Dialogue")

local RNG = Random.new()

local ShopKeeperHandler = {}

ShopKeeperHandler.playBought = LemonSignal.new()
ShopKeeperHandler.AlreadyGreeted = false
ShopKeeperHandler.BoughtSomething = false

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
	local Left_Nothing_Bought = Sounds:FindFirstChild("Left_Nothing_Bought")
	local BoughtsVoice = Sounds:FindFirstChild("Boughts")

	local audioJanitor = Janitor.new()

	ShopKeeperHandler.playBought:Connect(function()
		-- ShopKeeper
		if not Shop.ShopZone then return end
		audioJanitor:Cleanup()

		local randomSound = getRandomSound(BoughtsVoice)
		Global.GameUtil.playSound(randomSound, Shop.ShopZone, audioJanitor)

		ShopKeeperHandler.BoughtSomething = true
	end)

	local LeaveZone = ZonePlus.new(Shop.LeaveZone)
	local ShopKeeperZone = ZonePlus.new(Shop.ShopZone)
	local Door: BasePart = Shop:FindFirstChild("Door")
	local DoorCollider: BasePart = Shop:FindFirstChild("DoorCollider")

	local Camera = Shop:FindFirstChild("Camera")
	local TweenDoorClose =
		TweenService:Create(Door, DoorInfo, { Orientation = Door.Orientation })
	local Orientation = Door.Orientation - Vector3.new(0, OrientationOffset, 0)
	local TweenDoorOpen = TweenService:Create(Door, DoorInfo, {
		Orientation = Orientation,
	})


	LeaveZone.playerEntered:Connect(function(player)
		TweenDoorClose:Play()
		DoorCollider.CanCollide = true

		audioJanitor:Cleanup()

		if not PlayedLeave then
			local randomSound = getRandomSound(LeavingVoice)
			Global.GameUtil.playSound(randomSound, Shop.ShopZone, audioJanitor)
			PlayedLeave = true
		end

		Shop:SetAttribute("Left", true)

		print(("%s entered the zone!"):format(player.Name))
	end)

	ShopKeeperZone.playerEntered:Connect(function(player)
		Dialogue:FireAllClients("Hello!")
		EnteredRemote:FireClient(player, Camera, Shop.ShopZone)
		TweenDoorOpen:Play()
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
