-- Create Controller UI
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer

local ControllerUI = {}

function ControllerUI:Start()
    local GUI = ReplicatedStorage.Assets.UI:FindFirstChild("ControllerBinds")
    if not GUI then return end

    GUI = GUI:Clone()
    GUI.Parent = Player.PlayerGui
end

return ControllerUI