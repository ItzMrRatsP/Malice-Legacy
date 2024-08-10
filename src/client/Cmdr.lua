local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Cmdr = {}

function Cmdr:Init()
	self.Main = require(ReplicatedStorage:WaitForChild("CmdrClient"))
end

function Cmdr:Start()
	self.Main:SetActivationKeys { Enum.KeyCode.F2 }
end

return Cmdr
