-- Compiled with roblox-ts v3.0.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Reflect = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Reflect
local Service = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Service
local Players = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").Players
local StatusEffectsHandler = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "Application", "Handlers", "StatusHandler").StatusEffectsHandler
local PlayerHandler
do
	PlayerHandler = setmetatable({}, {
		__tostring = function()
			return "PlayerHandler"
		end,
	})
	PlayerHandler.__index = PlayerHandler
	function PlayerHandler.new(...)
		local self = setmetatable({}, PlayerHandler)
		return self:constructor(...) or self
	end
	function PlayerHandler:constructor()
	end
	function PlayerHandler:onStart()
		local statusEffectsHandler = StatusEffectsHandler.new()
		Players.PlayerAdded:Connect(function(Player)
			Player.CharacterAdded:Connect(function(Character)
				local actorId = tostring(Player.UserId)
				statusEffectsHandler.api:initActor(actorId)
				statusEffectsHandler.api:createStatus("Stun", nil, true, actorId)
				print((statusEffectsHandler.api:getActor(actorId)))
			end)
		end)
	end
	do
		-- (Flamework) PlayerHandler metadata
		Reflect.defineMetadata(PlayerHandler, "identifier", "shared/Application/Handlers/PlayerHandler@PlayerHandler")
		Reflect.defineMetadata(PlayerHandler, "flamework:implements", { "$:flamework@OnStart" })
	end
end
-- (Flamework) PlayerHandler decorators
Reflect.decorate(PlayerHandler, "$:flamework@Service", Service, {})
return {
	PlayerHandler = PlayerHandler,
}
