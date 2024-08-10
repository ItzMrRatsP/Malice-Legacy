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

function GameUtil.arrtodict(arr: { any })
	local dict = {}

	for index, value in arr do
		dict[value] = index
	end

	return dict
end

function GameUtil.search<T>(array, predict: (T) -> boolean)
	local final = {}

	for index, value in array do
		if not predict(value) then continue end
		final[index] = value
	end

	return final
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
