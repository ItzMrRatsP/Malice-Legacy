local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local CharacterHandler = require(script.CharacterHandler)


local PlayerHandler = {
	Character = nil
}

local function OnCharacterRemove()
	if PlayerHandler.Character then
		PlayerHandler.Character:Destroy()
		PlayerHandler.Character = nil
	end
end

local function OnCharacterAdded(Character)
	OnCharacterRemove()

	PlayerHandler.Character = CharacterHandler.new(Character, PlayerHandler)
end

function PlayerHandler:Init()
	
end

function PlayerHandler:Start() 
	if LocalPlayer.Character then
		OnCharacterAdded(LocalPlayer.Character)
	end

	LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)
	
	LocalPlayer.CharacterRemoving:Connect(OnCharacterRemove)
end

-- :Start | :Init
return PlayerHandler
