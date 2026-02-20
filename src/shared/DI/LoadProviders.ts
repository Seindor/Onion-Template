import type { Container } from "./Container";
import { toPascal } from "./Case";

type RegistryTree = Record<string, unknown>;

function setPath(root: RegistryTree, path: readonly string[], value: unknown) {
	let currentrent: RegistryTree = root;

	for (let i = 0; i < path.size() - 1; i++) {
		const k = path[i];
		const Next = currentrent[k];

		if (typeOf(Next) !== "table") {
			currentrent[k] = {};
		}

		currentrent = currentrent[k] as RegistryTree;
	}

	currentrent[path[path.size() - 1]] = value;
}

function getPath(root: RegistryTree, path: readonly string[]) {
	let currentrent: unknown = root;
	for (const k of path) {
		if (typeOf(currentrent) !== "table") return undefined;
		currentrent = (currentrent as RegistryTree)[k];
	}
	return currentrent;
}

function normalizeLifetime(seg: string) {
	const s = string.lower(seg);
	if (s === "singletons") return "Singleton";
	if (s === "scoped") return "Scoped";
	if (s === "transients") return "Transient";
	return toPascal(seg);
}

function keysFromModule(rootFolder: Instance, mod: ModuleScript): string[] {
	const stack = new Array<string>();
	let cur = mod.Parent;
	while (cur && cur !== rootFolder) {
		stack.push(cur.Name);
		cur = cur.Parent;
	}

	const parts = new Array<string>();
	for (let i = stack.size() - 1; i >= 0; i--) {
		parts.push(stack[i]);
	}

	if (parts.size() > 0) {
		parts[0] = normalizeLifetime(parts[0]);
		for (let i = 1; i < parts.size(); i++) {
			parts[i] = toPascal(parts[i]);
		}
	}

	let leaf = mod.Name;
	const lower = string.lower(leaf);
	if (string.sub(lower, -8) === "provider") {
		leaf = string.sub(leaf, 1, leaf.size() - 8);
	}
	parts.push(toPascal(leaf));

	return parts;
}

export function loadProviders<T extends object>(rootFolder: Instance, container: Container): T {
	const registry: RegistryTree = {};

	for (const instance of rootFolder.GetDescendants()) {
		if (!instance.IsA("ModuleScript")) continue;

		const mod = require(instance) as unknown as {
			register?: (c: Container) => void;
			token?: unknown;
			default?: { register?: (c: Container) => void; token?: unknown };
		};

		const register = mod.register ?? mod.default?.register;
		const token = mod.token ?? mod.default?.token;

		if (typeOf(register) !== "function" || token === undefined) continue;

		register!(container);

		const keys = keysFromModule(rootFolder, instance);
		if (getPath(registry, keys) !== undefined) error(`DI: duplicate registry path: ${keys.join(".")}`);
		setPath(registry, keys, token);
	}

	return registry as unknown as T;
}
