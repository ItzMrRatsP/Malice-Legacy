local ComponentHandler = {}

local Components = script:WaitForChild("Components"):GetChildren()

function ComponentHandler:Start()
	for _, Component: ModuleScript in Components do
		if not Component:IsA("ModuleScript") then continue end
		require(Component)
	end
end

return ComponentHandler