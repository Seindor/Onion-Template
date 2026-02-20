-- Compiled with roblox-ts v3.0.0
local StatusEffectsFacade
do
	StatusEffectsFacade = setmetatable({}, {
		__tostring = function()
			return "StatusEffectsFacade"
		end,
	})
	StatusEffectsFacade.__index = StatusEffectsFacade
	function StatusEffectsFacade.new(...)
		local self = setmetatable({}, StatusEffectsFacade)
		return self:constructor(...) or self
	end
	function StatusEffectsFacade:constructor(service)
		self.service = service
	end
	function StatusEffectsFacade:initActor(actorId)
		self.service:initActor(actorId)
	end
	function StatusEffectsFacade:createStatus(statusName, options, autoAdd, actorId)
		return self.service:createStatus(statusName, options, autoAdd, actorId)
	end
	function StatusEffectsFacade:addStatus(actorId, newStatus)
		self.service:addStatus(actorId, newStatus)
	end
	function StatusEffectsFacade:getActor(actorId)
		return self.service:getActor(actorId)
	end
	function StatusEffectsFacade:removeStatus(actorId, statusName)
		self.service:removeStatus(actorId, statusName)
	end
	function StatusEffectsFacade:checkStatuses(actorId, statuses, ignoreList)
		return self.service:checkStatuses(actorId, statuses, ignoreList)
	end
end
return {
	StatusEffectsFacade = StatusEffectsFacade,
}
