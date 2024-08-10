local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Global = require(ReplicatedStorage.Global)

local SceneManager = {}

function SceneManager:Init()
	SceneManager.StateMachine = Global.StateMachine.newFromFolder(script.Scenes)
end

function SceneManager:Start() end

return SceneManager
