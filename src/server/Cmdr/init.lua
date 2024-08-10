local ReplicatedStorage = game:GetService("ReplicatedStorage")
local mainCmdr = require(ReplicatedStorage.Packages.Cmdr)

local Cmdr = {}

function Cmdr:Start()
	-- mainCmdr:RegisterDefaultCommands()
	mainCmdr:RegisterCommandsIn(script.Commands)
	mainCmdr:RegisterHooksIn(script.Hooks)
end

return Cmdr
