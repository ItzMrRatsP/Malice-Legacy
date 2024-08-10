-- Loads server
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Global = require(ReplicatedStorage.Global)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Modules = Global.LocalFolder

local InitializeModules = {}
local Inits = {}

for _, module: ModuleScript in Modules:GetChildren() do
	if not module:IsA("ModuleScript") then continue end
	table.insert(
		Inits,
		Promise.try(function()
			return require(module)
		end)
			:andThen(function(result)
				if typeof(result) ~= "table" then return end
				if result.Init then result:Init() end

				table.insert(InitializeModules, result)
			end)
			:catch(function(err)
				Global.DebugUtil(err)
			end)
	)
end

Promise.allSettled(Inits):await()
local StartedModules = {}

for _, module in InitializeModules do
	table.insert(
		StartedModules,
		Promise.try(function()
			if module.Start then module:Start() end
		end):catch(Global.DebugUtil)
	)
end

Promise.allSettled(StartedModules):await()
