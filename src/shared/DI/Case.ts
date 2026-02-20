export function toPascal(input: string) {
	let s = string.gsub(input, "[-_]+", " ")[0];

	s = string.gsub(s, "(%l)(%u)", "%1 %2")[0];

	const parts = string.split(s, " ");
	let out = "";
	for (const p of parts) {
		if (p.size() === 0) continue;
		const lower = string.lower(p);
		out += string.upper(string.sub(lower, 1, 1)) + string.sub(lower, 2);
	}
	return out;
}
