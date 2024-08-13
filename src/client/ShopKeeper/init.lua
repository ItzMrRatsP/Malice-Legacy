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

local ShopKeeperHandler = {}
local MultiAttributes = {}

local function countFrames(Holder)
	local num = 0

	for _, frame in Holder:GetChildren() do
		if not frame:IsA("Frame") then continue end
		num += 1
	end

	return num
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

	local price = Computed(function()
		return progressCaculation(value:get(), {
			base = 400,
			quadcoef = 200,
			linearcoef = 400,
		})
	end)

	local Max = countFrames(stat.Main.UpgradeIndiciator)
	stat.Main.Upgrade:SetAttribute("Price", price:get())

	Hydrate(stat.Main.Upgrade.PriceText) {
		Text = Computed(function()
			return value:get() < Max and `${tostring(price:get())}` or "MAXED!"
		end),
	}

	stat.Main.Upgrade.MouseButton1Click:Connect(function()
		-- if ReplicatedStorage:GetAttribute("Money") < price:get() then return end
		if workspace:GetAttribute(name) >= Max then return end
		Net:RemoteEvent("UpdateMoney"):FireServer(price:get(), name)
	end)

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
