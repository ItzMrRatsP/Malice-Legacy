local Players = game:GetService("Players")

local UpdateHealth = {}

local function Update(Character: Model)
    local Humanoid = Character:FindFirstChild("Humanoid")
    if not Humanoid then return end

    Humanoid.MaxHealth += workspace:GetAttribute("Health_Multi") * 2.5
end

local function OnPlayerAdded(Player: Player)
    Player.CharacterAdded:Connect(Update)
end

function UpdateHealth:Start()
    Players.PlayerAdded:Connect(OnPlayerAdded)

    workspace:GetAttributeChangedSignal("Health_Multi"):Connect(function()
        print("UPDATE HEALTH!!!")

        for _, player in Players:GetPlayers() do
            if not player.Character then continue end
            Update(player.Character)
        end
    end)
end

return UpdateHealth