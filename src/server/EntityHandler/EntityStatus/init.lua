--Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Global = require(ReplicatedStorage.Global)

local Assets = ReplicatedStorage:WaitForChild("Assets")

local Clothing = Assets:WaitForChild("Clothing")

local Pants = Clothing.Pants
local Shirt = Clothing.Shirt

--Vars
local Entities = {}

local EntityStatus = {}

EntityStatus.Entities = Entities

local function removeClothingAndBodyAccessories(character)
	for _, item in pairs(character:GetChildren()) do
		if
			item:IsA("Accessory")
			and item.AccessoryType ~= Enum.AccessoryType.Hat
		then
			item:Destroy()
		end

		if
			item:IsA("Shirt")
			or item:IsA("Pants")
			or item:IsA("ShirtGraphic")
		then
			item:Destroy()
		end
	end
end

function EntityStatus.New(Id, IsPlayer)
	Entities[Id] = {
		ReadyToBattle = false,
		IsPlayer = IsPlayer,
		CombatStateMachine = Global.StateMachine.newFromFolder(
			script.CombatStates,
			Id
		),
	}

	local Entity = Entities[Id]

	if not IsPlayer then
		local Humanoid: Humanoid = Id:FindFirstChildOfClass("Humanoid")
		Humanoid.BreakJointsOnDeath = false
	end

	if IsPlayer then
		local Player = Players:GetPlayerByUserId(Id)
		local Character = Player.Character

		local function CharacterAdded(InCharacter)
			if not InCharacter then return end
			local Appearance = Players:GetHumanoidDescriptionFromUserId(Id)
			local Humanoid: Humanoid =
				InCharacter:FindFirstChildOfClass("Humanoid")
			Humanoid:ApplyDescription(Appearance)

			removeClothingAndBodyAccessories(InCharacter)

			local PantsClone = Pants:Clone()
			local ShirtsClone = Shirt:Clone()

			ShirtsClone.Parent = InCharacter
			PantsClone.Parent = InCharacter
		end

		CharacterAdded(Character)

		Player.CharacterAdded:Connect(CharacterAdded)
	end

	Entity.CombatStateMachine:Start(Entity.CombatStateMachine.InAction)
end

function EntityStatus.Remove(Id)
	Entities[Id] = nil
end

function EntityStatus.Update(Player)
	if Entities[Player.UserId] then
		Entities[Player.UserId].Health:Update(Player)
	end
end

function EntityStatus.UpdateAll(Player)
	for id, _ in pairs(Entities) do
		if id == Player.UserId then continue end

		Entities[id].Health:Update(Player)
	end
end

function EntityStatus.Clear(Player)
	Entities[Player.UserId] = nil
end

return EntityStatus
