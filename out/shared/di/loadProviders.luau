-- Compiled with roblox-ts v3.0.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local toPascal = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "DI", "Case").toPascal
local function setPath(root, path, value)
	local currentrent = root
	for i = 0, #path - 2 do
		local k = path[i + 1]
		local Next = currentrent[k]
		if typeof(Next) ~= "table" then
			currentrent[k] = {}
		end
		currentrent = currentrent[k]
	end
	currentrent[path[#path]] = value
end
local function getPath(root, path)
	local currentrent = root
	for _, k in path do
		local _currentrent = currentrent
		if typeof(_currentrent) ~= "table" then
			return nil
		end
		currentrent = currentrent[k]
	end
	return currentrent
end
local function normalizeLifetime(seg)
	local s = string.lower(seg)
	if s == "singletons" then
		return "Singleton"
	end
	if s == "scoped" then
		return "Scoped"
	end
	if s == "transients" then
		return "Transient"
	end
	return toPascal(seg)
end
local function keysFromModule(rootFolder, mod)
	local stack = {}
	local cur = mod.Parent
	while cur and cur ~= rootFolder do
		local _name = cur.Name
		table.insert(stack, _name)
		cur = cur.Parent
	end
	local parts = {}
	for i = #stack - 1, 0, -1 do
		local _arg0 = stack[i + 1]
		table.insert(parts, _arg0)
	end
	if #parts > 0 then
		parts[1] = normalizeLifetime(parts[1])
		for i = 1, #parts - 1 do
			parts[i + 1] = toPascal(parts[i + 1])
		end
	end
	local leaf = mod.Name
	local lower = string.lower(leaf)
	if string.sub(lower, -8) == "provider" then
		leaf = string.sub(leaf, 1, #leaf - 8)
	end
	local _arg0 = toPascal(leaf)
	table.insert(parts, _arg0)
	return parts
end
local function loadProviders(rootFolder, container)
	local registry = {}
	for _, instance in rootFolder:GetDescendants() do
		if not instance:IsA("ModuleScript") then
			continue
		end
		local mod = require(instance)
		local _condition = mod.register
		if _condition == nil then
			local _result = mod.default
			if _result ~= nil then
				_result = _result.register
			end
			_condition = _result
		end
		local register = _condition
		local _condition_1 = mod.token
		if _condition_1 == nil then
			local _result = mod.default
			if _result ~= nil then
				_result = _result.token
			end
			_condition_1 = _result
		end
		local token = _condition_1
		if typeof(register) ~= "function" or token == nil then
			continue
		end
		register(container)
		local keys = keysFromModule(rootFolder, instance)
		if getPath(registry, keys) ~= nil then
			error(`DI: duplicate registry path: {table.concat(keys, ".")}`)
		end
		setPath(registry, keys, token)
	end
	return registry
end
return {
	loadProviders = loadProviders,
}
