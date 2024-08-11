--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Global = require(ReplicatedStorage.Global)
--Modules

--Vars
local Entities = {}

local EntityStatus = {}

EntityStatus.Entities = Entities

function EntityStatus.New(Id)
	Entities[Id] = {
		ReadyToBattle = false,
		Downed = false,
		CombatStateMachine = Global.StateMachine.newFromFolder(
			script.CombatStates
		),
	}

	local Entity = Entities[Id]

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
