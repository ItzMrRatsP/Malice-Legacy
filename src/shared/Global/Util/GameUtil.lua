local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RNG = Random.new()

local DebugUtil = require(script.Parent.DebugUtil)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Promise = require(ReplicatedStorage.Packages.Promise)
local GameUtil = {}

function GameUtil.debounce(callback)
	return function(...)
		local db = false
		db = true

		task.spawn(function(...)
			callback(...)
			db = false
		end, ...)
	end
end

function GameUtil:getRandom(tab: { [number]: any }): { any }?
	if self.countDict(tab) <= 0 then return end
	if self.countDict(tab) == 1 then return tab[1] end

	local randomIndex = RNG:NextInteger(1, self.countDict(tab))
	return tab[randomIndex]
end

function GameUtil.weld(b1: BasePart?, b2: BasePart?)
	-- check
	if not b1 or not b2 then
		DebugUtil("YOU FORGOT TO INCLUDE BASEPART1 OR BASEPART2!!!")
		return
	end

	local weld = Instance.new("Weld")
	weld.Part0 = b1
	weld.Part1 = b2
	weld.C0 = b1.CFrame:ToObjectSpace(b2.CFrame)
	weld.Parent = b1
end

function GameUtil.arrtodictsorted(arr: { any }): { [any]: number }
	local t = {}

	for index, value in arr do
		t[value] = index
	end

	return t
end

function GameUtil.getIndex(arr: { any })
	local t = {}

	for index, _ in arr do
		t[index] = index
	end

	return t
end

function GameUtil.getKeys(arr: { [any]: any }): { [number]: any }
	local keys = {}

	for key, _ in arr do
		table.insert(keys, key)
	end

	return keys -- {[A] = B} -> {A}
end

function GameUtil.getValues(arr: { [any]: any }): { [number]: any }
	local values = {}

	for _, value in arr do
		table.insert(values, value)
	end

	return values -- {[A] = B} -> {B}
end

function GameUtil.dicttoarr(arr: { any })
	local t = {}

	for _, value in arr do
		table.insert(t, value)
	end

	return t
end

function GameUtil.arrtodict(arr: { any })
	local dict = {}

	for index, value in arr do
		dict[value] = index
	end

	return dict
end

function GameUtil.playSound(name: string, attachTo, janitor: Janitor.Janitor?)
	local Sound = ReplicatedStorage.Assets.Sounds:FindFirstChild(name, true)
	if not Sound then return end

	local clonedSound = Sound:Clone()
	if janitor and janitor.Add then janitor:Add(clonedSound) end
	clonedSound.Parent = attachTo

	clonedSound:Play()

	Promise.fromEvent(clonedSound.Stopped, function()
		if not clonedSound then return true end
		clonedSound:Destroy()

		return true
	end)
end

function GameUtil.search<T>(array, predict: (T) -> boolean)
	local final = {}

	for index, value in array do
		if not predict(value) then continue end
		final[index] = value
	end

	return final
end

function GameUtil.countDict(dict)
	local num = 0

	for _, _ in dict do
		num += 1
	end

	return num
end

function GameUtil.getbiggestValue<T>(
	array,
	predict: (current: T, new: T) -> boolean
)
	local result = nil

	for _, value in array do
		if not result then
			result = value
			continue
		end

		if not predict(result, value) then continue end
		result = value
	end

	return result
end

function GameUtil.getSmallestValue<T>(
	array,
	predict: (current: T, new: T) -> boolean
)
	local result = nil

	for _, value in array do
		if not result then
			result = value
			continue
		end

		if not predict(result, value) then continue end
		result = value
	end

	return result
end

return GameUtil
