local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Vendors = ReplicatedStorage.Vendors

local DoorInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false,0)
local OrientationOffset = 120

local ZonePlus = require(Vendors.Zone)

local ShopKeeperHandler = {}

function ShopKeeperHandler.Entered(Level)
    local Shop = Level:FindFirstChild("Shop")

    if not Shop then return end

    local LeaveZone = ZonePlus.new(Shop.LeaveZone)
    local ShopKeeperZone = ZonePlus.new(Shop.ShopZone)
    local Door : BasePart = Shop:FindFirstChild("Door")
    local DoorCollider : BasePart = Shop:FindFirstChild("DoorCollider")

    local TweenDoorOpen = TweenService:Create(Door, DoorInfo, {Orientation = Door.Orientation - Vector3.new(0,OrientationOffset,0)})
    local TweenDoorClose = TweenService:Create(Door,DoorInfo, {Orientation = Door.Orientation})

    TweenDoorOpen:Play()

    LeaveZone.playerEntered:Connect(function(player)
        TweenDoorClose:Play()
        DoorCollider.CanCollide = true
        print(("%s entered the zone!"):format(player.Name))
    end)

    ShopKeeperZone.playerEntered:Connect(function(player)

    end)

    ShopKeeperZone.playerExited:Connect(function(player)

    end)
end

function ShopKeeperHandler.Left()
    
end


function ShopKeeperHandler.WithinRange()
    
end


return ShopKeeperHandler