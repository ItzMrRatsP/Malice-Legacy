--!strict

local function nop(key: any, new: any, old: any) end

local meta = {}

function meta.__newindex(t, k, v)
	local old = t.Value[k]
	t.Value[k] = v
	t.Changed(t, k, v, old)
end

function meta.__index(t, k)
	return t.Value[k]
end

--[=[
	@class TableValue
]=]
local TableValue = {}

--[=[
	@within TableValue
	@return T & { Value: T, Changed: (key: any, new: any, old: any) -> () }

	Returns a new proxy table to interface with the `.Value` table. Does not modify the `.Value` table or its metatable.

	The callback is optional, if it is defined it will automatically update the fields in the table at initialization.

	```lua
	local person = TableValue.new {
		name = 'Jim',
		age = 9,
	}

	function person.Changed(tab, key: string, new, old)
		print(tab, key, new, old)
	end

	person.age += 1
	-- print('age', 10, 9)

	person.Value.age += 1
	-- No callback fires, this is how you can perform silent changes!

	local monster = TableValue.new({
		type = 'large',
		health = 100,
		secret = 'Loves chocolate'
	}, function(tab, key: string, new, old)
		print(tab, key, new, old)
	end)
	-- print('health', 100, nil)
	-- print('type', "large", nil)
	-- print('secret', 'Loves chocolate', nil)

	monster.health -= 10
	-- print('health', 90, 100)

	monster.Value.secret ..= ' but is lactose intolerant'
	-- No callback fires, this is how you can perform silent changes!

	```

	If the callback doesn't suit your fancy, you can make a small wrapper for it to use a signal instead!

	```lua
	function MyValue.signal(tab: { [any]: any })
		local self = TableValue.new(tab)

		self.Signal = Signal.new()

		function self.Changed(tab, key, new, old)
			self.Signal:Fire(key, new, old)
		end

		return self
	end

	local person = MyValue.new {
		name = 'Jim',
		age = 9,
	}

	person.Signal:Connect(function(key: string, new, old)
		print(key, new, old)
	end)

	person.age += 1
	-- print('age', 10, 9)

	person.Value.age += 1
	-- No event fires, this is how you can perform silent changes!
	```
]=]
function TableValue.new<T>(tab: T, changed: (tab: T, key: any, new: any, old: any) -> ()?)
	local self = {} :: T & { Value: T, Changed: typeof(nop) }
	self.Value = tab
	self.Changed = nop

	setmetatable(self, meta)

	if changed then
		self.Changed = changed
		for key, value in tab do
			changed(self, key, value, nil)
		end
	end

	return self
end

--[=[
	@within TableValue

	Mimics `table.insert`, except the index always comes last. By nature not as optimal as `table.insert` on a regular table.

	```lua
	local myArray = TableValue.new {}

	function myArray.Changed(_, index, value)
		print(index, value)
	end

	TableValue.insert(myArray, 'World')
	-- print(1, 'World')

	TableValue.insert(myArray, 'Hello', 1)
	-- print(2, 'World')
	-- print(1, 'Hello')

	print(myArray.Value)
	-- { 'Hello', 'World' }
	```
]=]
function TableValue.insert<T>(tab: { Value: { T } }, value: T, index: number?)
	if index then
		for i = #tab.Value, index, -1 do
			tab[i + 1] = tab.Value[i]
		end
		tab[index] = value
	else
		tab[#tab.Value + 1] = value
	end
end

--[=[
	@within TableValue
	@return T

	Mimics `table.remove`. By nature not as optimal as `table.remove` on a regular table.

	```lua
	local myArray = TableValue.new { 3, 'hi', Vector3.zero }

	function myArray.Changed(_, index, value)
		print(index, value)
	end

	TableValue.remove(myArray, 2)
	-- print(2, Vector3.zero)
	-- print(3, nil)

	TableValue.remove(myArray, 1)
	-- print(1, Vector3.zero)
	-- print(2, nil)

	print(myArray.Value)
	-- { Vector3.zero }
	```
]=]
function TableValue.remove<T>(tab: { Value: { T } }, index: number?)
	if index then
		local value = tab.Value[index]
		for i = index, #tab.Value do
			tab[i] = tab.Value[i + 1]
		end
		return value
	else
		local value = tab.Value[#tab.Value]
		tab[#tab.Value] = nil
		return value
	end
end

return TableValue
