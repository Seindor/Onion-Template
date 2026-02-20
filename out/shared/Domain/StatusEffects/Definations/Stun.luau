-- Compiled with roblox-ts v3.0.0
local Stun = {
	id = "Stun",
	defaultBlacklist = { "HyperArmor", "iFrame" },
	defaultModifiers = { {
		stat = "WalkSpeed",
		type = "Override",
		value = 0,
	}, {
		stat = "JumpPower",
		type = "Override",
		value = 0,
	} },
	onAdded = function(actorId, statusInstance)
		local _exp = actorId
		local _result = statusInstance
		if _result ~= nil then
			_result = _result.duration
		end
		local _condition = _result
		if not (_condition ~= 0 and _condition == _condition and _condition) then
			_condition = math.huge
		end
		warn("Stunned", _exp, "for", _condition)
	end,
	onRemoved = function(actorId, statusInstance) end,
	onCheck = function(actorId, statusInstance) end,
}
return {
	Stun = Stun,
}
