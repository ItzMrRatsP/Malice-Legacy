local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Global = require(ReplicatedStorage.Global)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Net = require(ReplicatedStorage.Packages.Net)
local progressCaculation = require(ReplicatedStorage.Vendors.progressCaculation)

local RNG = Random.new()
local Player = Players.LocalPlayer

local Value = Fusion.Value
local Hydrate = Fusion.Hydrate
local Spring = Fusion.Spring
local Computed = Fusion.Computed

local Sounds = ReplicatedStorage.Assets.Sounds.Emily

local BoughtsVoice = Sounds:FindFirstChild("Boughts")
local Left_Nothing_Bought = Sounds:FindFirstChild("Left_Nothing_Bought")

local ShopKeeperHandler = {}
local MultiAttributes = {}

local function getRandomSound(folder)
	local randomIndex = RNG:NextInteger(1, #folder:GetChildren())
	return folder:GetChildren()[randomIndex].Name
end

local function generateStat(value, name)
	local stat =
		ReplicatedStorage.Assets.UI.Frames:FindFirstChild("Stat"):Clone()

	stat.Main.UpgradeName.Text = `{string.split(name, "_")[1]} Upgrade`
	stat.Name = "NewStat"

	local mouseEntered = Value(false)

	Hydrate(stat.Main) {
		Position = Spring(
			Computed(function()
				return mouseEntered:get()
						and stat.Main:GetAttribute("EnterPosition")
					or stat.Main:GetAttribute("NormalPosition")
			end),
			35,
			0.85
		),
	}

	for _, currentLevel in stat.Main.UpgradeIndiciator:GetChildren() do
		if not currentLevel:IsA("Frame") then continue end
		Hydrate(currentLevel) {
			BackgroundColor3 = Spring(Computed(function()
				return value:get() >= tonumber(currentLevel.Name)
						and Color3.new(1, 1, 1)
					or Color3.new(0.1, 0.1, 0.1)
			end)),
		}
	end

	

	stat.Main.MouseEnter:Connect(function()
		mouseEntered:set(true)
	end)

	stat.Main.MouseLeave:Connect(function()
		mouseEntered:set(false)
	end)

	return stat
end

function ShopKeeperHandler:Start()
	-- local DamageMulti = Value(workspace:GetAttribute("DamageMulti"))
	-- local DefenseMulti = Value(workspace:GetAttribute("DefenseMulti"))
	-- local HealthMulti = Value(workspace:GetAttribute("HealthMulti"))
	-- local MovementSpeedMulti = Value(workspace:GetAttribute("MovementSpeedMulti"))
	-- local RollCoolDownMulti = Value(workspace:GetAttribute("RollCoolDownMulti"))

	local PlayerGui = Player.PlayerGui

	for name, attribute in workspace:GetAttributes() do
		MultiAttributes[name] = Value(attribute)

		workspace:GetAttributeChangedSignal(name):Connect(function()
			MultiAttributes[name]:set(Workspace:GetAttribute(name))
		end)
	end

	local janitor = Janitor.new()
	-- local attributes = Global.GameUtil.dicttoarr(MultiAttributes)

	Net:Connect("EnteredShop", function()
		local ShopkeeperUI = janitor:Add(
			ReplicatedStorage.Assets.UI:FindFirstChild("ShopkeeperUI"):Clone()
		)

		ShopkeeperUI.Parent = PlayerGui
		-- local randomUpgrades = generateUpgrades(attributes)

		for name, value in MultiAttributes do
			local stat = generateStat(value, name)
			stat.Parent = ShopkeeperUI.ShopButtons
		end

		-- Update ShopkeeperUI
	end)

	Net:Connect("ExitShop", function()
		-- Exit the shop
		-- We can play random audio over here after leaving!
		janitor:Cleanup()
	end)
end

return ShopKeeperHandler
