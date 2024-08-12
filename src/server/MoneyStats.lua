local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LemonSignal = require(ReplicatedStorage.Packages.LemonSignal)

local MoneyStats = {}
MoneyStats.UpdateMoney = LemonSignal.new()

local DefaultMoney = 100
local Name = "Money"

function MoneyStats:Start()
	-- Create Stat in replicatedStorage
	ReplicatedStorage:SetAttribute(Name, DefaultMoney)

	self.UpdateMoney:Connect(function(NewValue: number)
		ReplicatedStorage:SetAttribute(
			Name,
			ReplicatedStorage:GetAttribute(Name) + NewValue
		)
	end)
end

return MoneyStats
