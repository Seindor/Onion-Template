-- Compiled with roblox-ts v3.0.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local StatusEffectsFacade = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "Domain", "StatusEffects", "Api", "StatusEffectsFacade").StatusEffectsFacade
local StatusEffectsService = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "Domain", "StatusEffects", "Services", "StatusEffectsService").StatusEffectsService
local StatusEffectsHandler
do
	StatusEffectsHandler = setmetatable({}, {
		__tostring = function()
			return "StatusEffectsHandler"
		end,
	})
	StatusEffectsHandler.__index = StatusEffectsHandler
	function StatusEffectsHandler.new(...)
		local self = setmetatable({}, StatusEffectsHandler)
		return self:constructor(...) or self
	end
	function StatusEffectsHandler:constructor()
		self.service = StatusEffectsService.new()
		self.api = StatusEffectsFacade.new(self.service)
	end
end
return {
	StatusEffectsHandler = StatusEffectsHandler,
}
