-- Compiled with roblox-ts v3.0.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local ReplicatedStorage = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").ReplicatedStorage
local Container = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "DI", "Container").Container
local loadProviders = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "DI", "LoadProviders").loadProviders
local TSFolder = ReplicatedStorage:WaitForChild("TS")
local SharedContainer = Container.new()
local sharedProviders = TSFolder:WaitForChild("di"):WaitForChild("providers"):WaitForChild("shared")
local SharedRegistry = loadProviders(sharedProviders, SharedContainer)
return {
	SharedContainer = SharedContainer,
	SharedRegistry = SharedRegistry,
}
