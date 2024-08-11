local Components = script:WaitForChild("Components"):GetChildren()

function  Components:Start()
    for _, Component : ModuleScript in Components do
        if not Component:IsA("ModuleScript") then continue end
    
        require(Component)
    end 
end
