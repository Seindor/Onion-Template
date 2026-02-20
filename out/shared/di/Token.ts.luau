-- Compiled with roblox-ts v3.0.0
local function createToken(name)
	return {
		__brand = "DI_TOKEN",
		name = name,
	}
end
return {
	createToken = createToken,
}
