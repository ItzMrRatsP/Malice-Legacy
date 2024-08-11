local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Global = require(ReplicatedStorage.Global)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local LevelConfig = require(ServerStorage.Server.Levels.LevelConfig)
local Levels = require(script.Parent.Levels)

local CharacterHandler = {}

function CharacterHandler:Start()
	-- Spawn Player:
	Players.PlayerAdded:Connect(function(Player)
		-- repeat
		-- 	task.wait()
		-- until ReplicatedStorage:GetAttribute("generatingNewLevel")
		local jan = Janitor.new()

		Player.CharacterAdded:Connect(function(Character)
			if not Character then
				Global.DebugUtil(
					"Wow, you did the impossible!!! or you messed up something?"
				)
				return
			end

			jan:Add(Character)

			-- Anchor
			local Humanoid = Character:FindFirstChild("Humanoid")

			jan:Add(Humanoid.Died:Connect(function()
				-- Died
				-- local arr = Global.GameUtil.dicttoarr(LevelConfig.Levels)
				-- Levels.currentLevel = arr[1]
				-- LevelConfig.generateLevel:Fire() -- Reset the ahh, levels!

				-- jan:Cleanup()
				Player:LoadCharacter()
			end))
		end)
	end)
end

return CharacterHandler
