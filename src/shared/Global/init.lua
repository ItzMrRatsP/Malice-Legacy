-- All global variables
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local Util = script.Util
local Services = script.Services
local Enums = script.Enums

return {
	GameUtil = require(Util.GameUtil),
	DebugUtil = require(Util.DebugUtil),
	StateMachine = require(Util.StateMachine),
	UIUtil = require(Util.UIUtil),

	-- Folders
	Enums = Enums,
	Services = Services,

	LocalFolder = if RunService:IsServer() -- LocalFolder
		then ServerStorage.Server
		else ReplicatedStorage.Client,
}
