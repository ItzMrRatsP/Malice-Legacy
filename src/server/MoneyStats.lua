local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local LemonSignal = require(ReplicatedStorage.Packages.LemonSignal)
local Net = require(ReplicatedStorage.Packages.Net)
local ShopKeeperHandler = require(ServerStorage.Server.Levels.ShopKeeperHandler)

local MoneyStats = {}
MoneyStats.UpdateMoney = LemonSignal.new()

local DefaultMoney = 100
local Name = "Money"

function MoneyStats:Start()
	-- Create Stat in replicatedStorage
	ReplicatedStorage:SetAttribute(Name, DefaultMoney)

	self.UpdateMoney:Connect(function(NewValue: number)
		ReplicatedStorage:SetAttribute(Name, math.ceil(NewValue))
	end)

	Net:Connect("UpdateMoney", function(_, Remove: number, name: string)
		if ReplicatedStorage:GetAttribute(Name) < Remove then return end

		ReplicatedStorage:SetAttribute(
			Name,
			ReplicatedStorage:GetAttribute(Name) - Remove
		)

		local getCurrentLevel = workspace:GetAttribute(name)

		workspace:SetAttribute(name, getCurrentLevel + 1)
		ShopKeeperHandler.playBought:Fire()
	end)
end

return MoneyStats
