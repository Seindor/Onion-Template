-- Compiled with roblox-ts v3.0.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local createToken = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "DI", "Token.ts").createToken
local EventBus = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "Modules", "Utilities", "EventBus").default
local token = createToken("EventBus")
local function register(container)
	container:bindSingleton(token, function()
		return EventBus
	end)
end
return {
	register = register,
	token = token,
}
