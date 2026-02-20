-- Compiled with roblox-ts v3.0.0
local function toPascal(input)
	local s = (string.gsub(input, "[-_]+", " "))
	s = (string.gsub(s, "(%l)(%u)", "%1 %2"))
	local parts = string.split(s, " ")
	local out = ""
	for _, p in parts do
		if #p == 0 then
			continue
		end
		local lower = string.lower(p)
		out ..= string.upper(string.sub(lower, 1, 1)) .. string.sub(lower, 2)
	end
	return out
end
return {
	toPascal = toPascal,
}
