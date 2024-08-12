local RunService = game:GetService("RunService")

----------------------------------------------------------------------------------------------------------------
--// State //---------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
local State = {}
function State:__index(index)
	return State[index] or self._StateArray[self._StateLookup[index]]
end

function State:Start() end
function State:Enter() end
function State:Exit() end
function State:Destroy() end

function State:AddState(name)
	return self.Machine:AddState(name, self)
end
----------------------------------------------------------------------------------------------------------------
--// State Machine  //------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
local StateMachine = {}
function StateMachine:__index(index)
	return StateMachine[index] or self._StateArray[self._StateLookup[index]]
end

local function GetCommonAncestorIndex(state1, state2)
	local commonAncestorIndex = 0
	for i = 1, math.min(#state1._Ancestors, #state2._Ancestors) do
		local ancestor1, ancestor2 = state1._Ancestors[i], state2._Ancestors[i]
		if ancestor1 ~= ancestor2 then break end
		commonAncestorIndex += 1
	end

	return commonAncestorIndex
end

local RequireStates
function RequireStates(parentInstance, parentState, ...)
	for _, childInstance in ipairs(parentInstance:GetChildren()) do
		if not childInstance:IsA("ModuleScript") then continue end
		local State = require(childInstance)(parentState, ...)
		RequireStates(childInstance, State)
	end
end
local StartStateChildren
function StartStateChildren(state)
	for _, child in ipairs(state._StateArray) do
		child:Start()
		StartStateChildren(child)
	end
end

local DestroyStateChildren
function DestroyStateChildren(state)
	for _, child in ipairs(state._StateArray) do
		child:Destroy()
		DestroyStateChildren(child)
	end
end

function StateMachine.new()
	local self = setmetatable({
		_StateLookup = {},
		_StateArray = {},
		_Events = {},
	}, StateMachine)

	if RunService:IsClient() then
		self.Connection = RunService.PreRender:Connect(function(dt)
			self:Update(dt)
		end)
	else
		self.Connection = RunService.PreSimulation:Connect(function(dt)
			self:Update(dt)
		end)
	end

	return self
end

function StateMachine.newFromFolder(statesFolder, ...)
	local self = StateMachine.new()
	RequireStates(statesFolder, self, ...)
	return self
end

function StateMachine:AddState(name, parent)
	local nameType = typeof(name)
	if nameType ~= "string" then
		error(`Invalid state name, expecting "string" got "{nameType}"`)
	end

	local state = setmetatable({
		Machine = self,
		Name = name,
		_StateLookup = {},
		_StateArray = {},
		_Ancestors = {},
	}, State)

	if parent then
		for i, ancestor in ipairs(self._Ancestors) do
			state._Ancestors[i] = ancestor
		end
		table.insert(state._Ancestors, self)
	else
		parent = self
	end

	local lookupValue = #parent._StateArray + 1
	parent._StateLookup[name] = lookupValue
	parent._StateArray[lookupValue] = state

	return state
end

function StateMachine:Start(initialState)
	self.LastState = initialState.Name
	StartStateChildren(self)
	self.CurrentState = initialState
	for _, ancestor in ipairs(self.CurrentState._Ancestors) do
		ancestor:Enter()
	end
	self.CurrentState:Enter()
end

function StateMachine:Transition(nextState)
	local commonAncestorIndex =
		GetCommonAncestorIndex(self.CurrentState, nextState)
	self.Transitioning = true
	self.CurrentState:Exit()
	for i = #self.CurrentState._Ancestors, commonAncestorIndex + 1, -1 do
		local ancestor = self.CurrentState._Ancestors[i]
		ancestor:Exit()
	end

	self.LastState = self.CurrentState
	self.CurrentState = nextState
	for i = commonAncestorIndex + 1, #nextState._Ancestors do
		local ancestor = nextState._Ancestors[i]
		ancestor:Enter()
	end
	self.CurrentState:Enter()
	self.Transitioning = false
end

function StateMachine:AddEvent(eventTable, startEnabled)
	local nameType = typeof(eventTable.Name)
	if nameType ~= "string" then
		error(`Invalid event name, expecting "string" got "{nameType}"`)
	elseif self._Events[eventTable.Name] then
		error(`Event already exists with name "{eventTable.Name}"`)
	end
	for I, FromState in eventTable.FromStates do
		eventTable.FromStates[FromState.Name] = FromState
	end

	for I, FromState in eventTable.FromStates do
		if type(I) == "number" then eventTable.FromStates[I] = nil end
	end

	local event = {
		Name = eventTable.Name,
		_Enabled = false,
		FromStates = eventTable.FromStates,
		ToState = eventTable.ToState,
		Condition = eventTable.Condition or function()
			return true
		end,
	}

	self._Events[eventTable.Name] = event
	if startEnabled then self:EnableEvent(eventTable.Name, true) end

	return
end

function StateMachine:ChangeToStateEvent(EventName, ToState)
	if not self._Events[EventName] then return end
	self._Events[EventName].ToState = ToState
end

function StateMachine:EnableEvent(eventName, enable)
	local event = self._Events[eventName]
	if not event then error(`No event exists with name "{eventName}"`) end

	event.Enabled = enable == nil or enable == true
end

function StateMachine:FireEvent(event, ...)
	if not event then error(`No event exists with "{event}"`) end

	if
		not (
			event.Enabled
			and event.FromStates[self.CurrentState.Name]
			and event.Condition(...)
		)
	then
		return
	end

	self:Transition(event.ToState)
end

function StateMachine:Update(dt)
	if not self.CurrentState then return end

	for _, Event in self._Events do
		self:FireEvent(Event)
	end

	if
		type(self.CurrentState) ~= "function"
		and self.CurrentState.Update
		and not self.Transitioning
	then
		self.CurrentState:Update(dt)
	end
end

function StateMachine:Destroy()
	if self.CurrentState then
		self.CurrentState:Exit()
		for i = #self.CurrentState._Ancestors, 1, -1 do
			local ancestor = self.CurrentState._Ancestors[i]
			ancestor:Exit()
		end
	end
	self.Connection:Disconnect()
	DestroyStateChildren(self)
end

return StateMachine
