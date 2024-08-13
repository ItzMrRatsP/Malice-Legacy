local ServerStorage = game:GetService("ServerStorage")
local MoneyStats = require(ServerStorage.Server.MoneyStats)

return function(_, amount: number)
	-- Generates next level
	if not amount then return "NO AMOUNT SHOWN YET!" end

	MoneyStats.UpdateMoney:Fire(amount)
	return `CASH SET TO {amount}`
end
