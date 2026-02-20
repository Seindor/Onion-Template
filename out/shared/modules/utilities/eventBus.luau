-- Compiled with roblox-ts v3.0.0
local LocalConnection
do
	LocalConnection = setmetatable({}, {
		__tostring = function()
			return "LocalConnection"
		end,
	})
	LocalConnection.__index = LocalConnection
	function LocalConnection.new(...)
		local self = setmetatable({}, LocalConnection)
		return self:constructor(...) or self
	end
	function LocalConnection:constructor(disconnectFn)
		self.disconnectFn = disconnectFn
		self.Connected = true
	end
	function LocalConnection:Disconnect()
		if not self.Connected then
			return nil
		end
		self.Connected = false
		self.disconnectFn()
	end
end
local EventSlot
do
	EventSlot = setmetatable({}, {
		__tostring = function()
			return "EventSlot"
		end,
	})
	EventSlot.__index = EventSlot
	function EventSlot.new(...)
		local self = setmetatable({}, EventSlot)
		return self:constructor(...) or self
	end
	function EventSlot:constructor()
		self.normal = {}
		self.staged = {}
		self.nextOrder = 0
	end
	function EventSlot:Subscribe(cb, priority, once)
		if once == nil then
			once = false
		end
		if priority == nil then
			local l = {
				cb = cb,
				once = once,
				connected = true,
			}
			local _exp = self.normal
			table.insert(_exp, l)
			return LocalConnection.new(function()
				l.connected = false
			end)
		else
			local _object = {
				cb = cb,
				once = once,
				connected = true,
				priority = priority,
			}
			local _left = "order"
			local _original = self.nextOrder
			self.nextOrder += 1
			_object[_left] = _original
			local l = _object
			local _exp = self.staged
			table.insert(_exp, l)
			table.sort(self.staged, function(a, b)
				if a.priority ~= b.priority then
					return a.priority < b.priority
				end
				return a.order < b.order
			end)
			return LocalConnection.new(function()
				l.connected = false
			end)
		end
	end
	function EventSlot:Fire(startPriority, ...)
		local args = { ... }
		for _, l in self.normal do
			if not l.connected then
				continue
			end
			task.spawn(l.cb, unpack(args))
			if l.once then
				l.connected = false
			end
		end
		for _, l in self.staged do
			if not l.connected then
				continue
			end
			if l.priority < startPriority then
				continue
			end
			task.spawn(l.cb, unpack(args))
			if l.once then
				l.connected = false
			end
		end
	end
	function EventSlot:Destroy()
		for _, l in self.normal do
			l.connected = false
		end
		for _, l in self.staged do
			l.connected = false
		end
		self.normal = {}
		self.staged = {}
	end
end
local Cache = {}
local EventBus
do
	EventBus = setmetatable({}, {
		__tostring = function()
			return "EventBus"
		end,
	})
	EventBus.__index = EventBus
	function EventBus.new(...)
		local self = setmetatable({}, EventBus)
		return self:constructor(...) or self
	end
	function EventBus:constructor(name)
		self.name = name
		self.events = {}
	end
	function EventBus:New(name)
		local _name = name
		local cached = Cache[_name]
		if cached then
			return cached
		end
		local bus = EventBus.new(name)
		local _name_1 = name
		Cache[_name_1] = bus
		return bus
	end
	function EventBus:getEvent(eventName)
		local _events = self.events
		local _eventName = eventName
		local slot = _events[_eventName]
		if not slot then
			slot = EventSlot.new()
			local _events_1 = self.events
			local _eventName_1 = eventName
			local _slot = slot
			_events_1[_eventName_1] = _slot
		end
		return slot
	end
	function EventBus:Subscribe(eventName, cb, priority)
		return self:getEvent(eventName):Subscribe(cb, priority, false)
	end
	function EventBus:Once(eventName, cb, priority)
		return self:getEvent(eventName):Subscribe(cb, priority, true)
	end
	function EventBus:SubscribeT(eventName, cb, priority)
		return self:Subscribe(eventName, cb, priority)
	end
	function EventBus:OnceT(eventName, cb, priority)
		return self:Once(eventName, cb, priority)
	end
	function EventBus:Fire(eventName, startPriority, ...)
		local args = { ... }
		local _events = self.events
		local _eventName = eventName
		local slot = _events[_eventName]
		if not slot then
			return nil
		end
		local _condition = startPriority
		if _condition == nil then
			_condition = 1
		end
		slot:Fire(_condition, unpack(args))
	end
	function EventBus:Unsubscribe(_eventName, connection)
		connection:Disconnect()
	end
	function EventBus:Destroy()
		for _, slot in self.events do
			slot:Destroy()
		end
		table.clear(self.events)
		local _name = self.name
		Cache[_name] = nil
	end
end
return {
	default = EventBus,
}
