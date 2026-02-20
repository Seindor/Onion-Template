-- Compiled with roblox-ts v3.0.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Stun = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "Domain", "StatusEffects", "Definations", "Stun").Stun
local Definitions = {
	Stun = Stun,
}
local defaultStatusTemplate = function(id)
	return {
		id = id,
		defaultModifiers = {},
	}
end
local StatusInstance
do
	StatusInstance = setmetatable({}, {
		__tostring = function()
			return "StatusInstance"
		end,
	})
	StatusInstance.__index = StatusInstance
	function StatusInstance.new(...)
		local self = setmetatable({}, StatusInstance)
		return self:constructor(...) or self
	end
	function StatusInstance:constructor(statusId, options)
		local _result
		if Definitions[statusId] then
			local _object = table.clone(Definitions[statusId])
			setmetatable(_object, nil)
			_result = _object
		else
			_result = defaultStatusTemplate(statusId)
		end
		local definition = _result
		self.id = definition.id
		local _result_1 = options
		if _result_1 ~= nil then
			_result_1 = _result_1.customModifiers
		end
		local _condition = _result_1
		if _condition == nil then
			local _result_2
			if definition.defaultModifiers then
				local _array = {}
				local _length = #_array
				local _array_1 = definition.defaultModifiers
				table.move(_array_1, 1, #_array_1, _length + 1, _array)
				_result_2 = _array
			else
				_result_2 = {}
			end
			_condition = _result_2
		end
		self.modifiers = _condition
		local _result_2 = options
		if _result_2 ~= nil then
			_result_2 = _result_2.priority
		end
		local _condition_1 = _result_2
		if _condition_1 == nil then
			_condition_1 = 1
		end
		self.priority = _condition_1
		self.blacklist = definition.defaultBlacklist or {}
		local _result_3 = options
		if _result_3 ~= nil then
			_result_3 = _result_3.ignoreList
		end
		local _condition_2 = _result_3
		if _condition_2 == nil then
			_condition_2 = nil
		end
		self.ignoreList = _condition_2
		self.spawned = os.clock()
		local _result_4 = options
		if _result_4 ~= nil then
			_result_4 = _result_4.duration
		end
		self.duration = _result_4
		local _result_5 = options
		if _result_5 ~= nil then
			_result_5 = _result_5.onAdded
		end
		local _condition_3 = _result_5
		if _condition_3 == nil then
			_condition_3 = definition.onAdded or nil
		end
		self.onAdded = _condition_3
		local _result_6 = options
		if _result_6 ~= nil then
			_result_6 = _result_6.onRemoved
		end
		local _condition_4 = _result_6
		if _condition_4 == nil then
			_condition_4 = definition.onRemoved or nil
		end
		self.onRemoved = _condition_4
		local _result_7 = options
		if _result_7 ~= nil then
			_result_7 = _result_7.onCheck
		end
		local _condition_5 = _result_7
		if _condition_5 == nil then
			_condition_5 = definition.onCheck or nil
		end
		self.onCheck = _condition_5
	end
	function StatusInstance:apply(actorId)
		local _result = self.onAdded
		if _result ~= nil then
			_result(actorId, self)
		end
	end
	function StatusInstance:remove(actorId)
		local _result = self.onRemoved
		if _result ~= nil then
			_result(actorId, self)
		end
	end
	function StatusInstance:check(actorId)
		local _result = self.onCheck
		if _result ~= nil then
			_result = _result(actorId, self)
		end
		local _condition = _result
		if _condition == nil then
			_condition = true
		end
		return _condition
	end
end
return {
	StatusInstance = StatusInstance,
}
