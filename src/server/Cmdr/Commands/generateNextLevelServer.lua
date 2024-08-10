local ServerStorage = game:GetService("ServerStorage")
local LevelConfig = require(ServerStorage.Server.Levels.LevelConfig)

return function(_)
	-- Generates next level
	LevelConfig.generateNextLevel:Fire()
end
