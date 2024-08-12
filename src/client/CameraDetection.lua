local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Janitor = require(ReplicatedStorage.Packages.Janitor)

local Camera = workspace.CurrentCamera

local triggerCamera = {}
local info =
	TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

local Detection = {}

local function setTransparency(part, transparency: number): Janitor.Janitor?
	local jan = Janitor.new()
	if part:HasTag("IgnoreCamTrans") then return end
	if not part:IsA("BasePart") then return end -- Just in-case

	local t = jan:Add(
		TweenService:Create(part, info, { Transparency = transparency }),
		"Cancel",
		part
	)

	t:Play()

	jan:Add(function()
		TweenService:Create(part, info, { Transparency = 0 }):Play()
	end)

	return jan
end

local function CheckInBound()
	local parts: { BasePart? } =
		workspace:GetPartBoundsInBox(Camera.CFrame, Vector3.new(5, 5, 15))

	local new = {}

	for _, part in parts do
		if not part:IsA("BasePart") then continue end
		if part.Parent:FindFirstChildOfClass("Humanoid") then continue end
		if table.find(triggerCamera, part) then continue end

		-- triggerCamera[part] = setTransparency(part, 1)
		new[part] = setTransparency(part, 0.9)
	end

	for part, janitor in triggerCamera do
		if new[part] then continue end
		janitor:Destroy()
	end

	-- print(new, triggerCamera)
	triggerCamera = new
end

function Detection:Start()
	-- Detection for camera
	RunService.RenderStepped:Connect(CheckInBound)
end

return Detection
