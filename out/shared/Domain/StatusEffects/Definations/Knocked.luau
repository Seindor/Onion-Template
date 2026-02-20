-- Compiled with roblox-ts v3.0.0
local Knocked = {
	id = "Knocked",
	defaultModifiers = { {
		stat = "WalkSpeed",
		type = "Override",
		value = 0,
	}, {
		stat = "JumpPower",
		type = "Override",
		value = 0,
	} },
	onAdded = function(actor) end,
	onRemoved = function(actor) end,
	onCheck = function(actor)
		return true
	end,
}
return {
	Knocked = Knocked,
}
