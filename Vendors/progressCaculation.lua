local properties = {
	base = 100,
	linearcoef = 30,
	quadcoef = 15,
} -- Default Properties, it can be replaced with custom ones.

return function(x: number, customProp: typeof(properties)): number?
	if typeof(x) ~= "number" then return end

	local metaProp = setmetatable(customProp, { __index = properties })
	return metaProp.base
		+ metaProp.linearcoef * (x - 1)
		+ metaProp.quadcoef * ((x - 1) ^ 2)
end
