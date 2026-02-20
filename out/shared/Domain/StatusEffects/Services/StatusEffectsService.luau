-- Compiled with roblox-ts v3.0.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local StatusInstance = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "Domain", "StatusEffects", "Aggregates", "StatusInstance").StatusInstance
local Definitions = {
	Stun = 1,
}
local StatusEffectsService
do
	StatusEffectsService = setmetatable({}, {
		__tostring = function()
			return "StatusEffectsService"
		end,
	})
	StatusEffectsService.__index = StatusEffectsService
	function StatusEffectsService.new(...)
		local self = setmetatable({}, StatusEffectsService)
		return self:constructor(...) or self
	end
	function StatusEffectsService:constructor()
		self.statusEffectsMap = {}
	end
	function StatusEffectsService:initActor(actorId)
		local _statusEffectsMap = self.statusEffectsMap
		local _actorId = actorId
		if _statusEffectsMap[_actorId] ~= nil then
			warn(`Overwrited StatusEffects for {actorId}.`)
			local _statusEffectsMap_1 = self.statusEffectsMap
			local _actorId_1 = actorId
			_statusEffectsMap_1[_actorId_1] = nil
		end
		local _statusEffectsMap_1 = self.statusEffectsMap
		local _actorId_1 = actorId
		_statusEffectsMap_1[_actorId_1] = {}
	end
	function StatusEffectsService:canApplyStatus(actorId, incoming)
		local _statusEffectsMap = self.statusEffectsMap
		local _actorId = actorId
		local list = _statusEffectsMap[_actorId]
		if not list then
			return true
		end
		for _, existing in list do
			local existingId = existing.id
			local _result = incoming.blacklist
			if _result ~= nil then
				_result = table.find(_result, existingId) ~= nil
			end
			local _condition = _result
			if _condition == nil then
				_condition = false
			end
			local isBlacklisted = _condition
			if not isBlacklisted then
				continue
			end
			local _ignoreRule = incoming.ignoreList
			if _ignoreRule ~= nil then
				-- ▼ ReadonlyArray.find ▼
				local _callback = function(rule)
					return rule.id == existingId
				end
				local _result_1
				for _i, _v in _ignoreRule do
					if _callback(_v, _i - 1, _ignoreRule) == true then
						_result_1 = _v
						break
					end
				end
				-- ▲ ReadonlyArray.find ▲
				_ignoreRule = _result_1
			end
			local ignoreRule = _ignoreRule
			if ignoreRule then
				if ignoreRule.maxPriority == nil then
					continue
				end
				if existing.priority <= ignoreRule.maxPriority then
					continue
				end
			end
			return false
		end
		return true
	end
	function StatusEffectsService:createStatus(statusName, options, autoAdd, actorId)
		local status = StatusInstance.new(statusName, options or nil)
		if autoAdd then
			if not (actorId ~= "" and actorId) then
				warn(`actorId is nil, status not added!`)
				return status
			else
				self:addStatus(actorId, status)
			end
		end
		return status
	end
	function StatusEffectsService:addStatus(actorId, newStatus)
		if not self:canApplyStatus(actorId, newStatus) then
			warn(`{newStatus.id} Blocked by blacklist.`)
			return nil
		end
		local _statusEffectsMap = self.statusEffectsMap
		local _actorId = actorId
		local list = _statusEffectsMap[_actorId]
		if not list then
			warn(`Cannot find map for {actorId}, status not added.`)
			return nil
		end
		-- ▼ ReadonlyArray.findIndex ▼
		local _callback = function(status)
			return status.id == newStatus.id
		end
		local _result = -1
		for _i, _v in list do
			if _callback(_v, _i - 1, list) == true then
				_result = _i - 1
				break
			end
		end
		-- ▲ ReadonlyArray.findIndex ▲
		local existingIndex = _result
		if existingIndex ~= -1 then
			local existing = list[existingIndex + 1]
			if newStatus.priority > existing.priority then
				self:removeStatus(actorId, existing.id)
			elseif newStatus.priority < existing.priority then
				return nil
			else
				local now = os.clock()
				local oldRemaining = if existing.duration ~= nil then existing.spawned + existing.duration - now else math.huge
				local newRemaining = if newStatus.duration ~= nil then newStatus.duration else math.huge
				if newRemaining <= oldRemaining then
					return nil
				end
				self:removeStatus(actorId, existing.id)
			end
		end
		local _newStatus = newStatus
		table.insert(list, _newStatus)
		newStatus:apply(actorId)
	end
	function StatusEffectsService:getActor(actorId)
		local _statusEffectsMap = self.statusEffectsMap
		local _actorId = actorId
		local list = _statusEffectsMap[_actorId]
		if not list then
			return nil
		end
		return list
	end
	function StatusEffectsService:removeStatus(actorId, statusName)
		local _statusEffectsMap = self.statusEffectsMap
		local _actorId = actorId
		local list = _statusEffectsMap[_actorId]
		if not list then
			warn(`Cannot find map for {actorId}, status not added.`)
			return nil
		end
		-- ▼ ReadonlyArray.findIndex ▼
		local _callback = function(status)
			return status.id == statusName
		end
		local _result = -1
		for _i, _v in list do
			if _callback(_v, _i - 1, list) == true then
				_result = _i - 1
				break
			end
		end
		-- ▲ ReadonlyArray.findIndex ▲
		local existingIndex = _result
		if existingIndex ~= 1 then
			local existing = list[existingIndex + 1]
			existing:remove(actorId)
			table.remove(list, existingIndex + 1)
		end
	end
	function StatusEffectsService:checkStatuses(actorId, statuses, ignoreList)
		local _statusEffectsMap = self.statusEffectsMap
		local _actorId = actorId
		local list = _statusEffectsMap[_actorId]
		if not list then
			warn(`Cannot find map for {actorId}`)
			return false
		end
		for _, statusId in statuses do
			-- ▼ ReadonlyArray.findIndex ▼
			local _callback = function(status)
				return status.id == statusId
			end
			local _result = -1
			for _i, _v in list do
				if _callback(_v, _i - 1, list) == true then
					_result = _i - 1
					break
				end
			end
			-- ▲ ReadonlyArray.findIndex ▲
			local existingIndex = _result
			if existingIndex ~= -1 then
				local existing = list[existingIndex + 1]
				existing:check(actorId)
				local _result_1 = ignoreList
				if _result_1 ~= nil then
					local _id = existing.id
					_result_1 = table.find(_result_1, _id) ~= nil
				end
				if _result_1 then
					continue
				end
				return true
			end
		end
		return false
	end
end
return {
	StatusEffectsService = StatusEffectsService,
}
