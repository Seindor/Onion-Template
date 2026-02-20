const fs = require("node:fs");
const path = require("node:path");

const PROJECT_ROOT = process.cwd();

const targets = [
  {
    providersRoot: "src/shared/DI/Providers/Shared",
    outFile: "src/shared/DI/Generated/SharedRegistryShape.ts",
    typeName: "SharedRegistryShape",
  },
];

function walk(dir) {
  const out = [];
  for (const name of fs.readdirSync(dir)) {
    const p = path.join(dir, name);
    const st = fs.statSync(p);
    if (st.isDirectory()) out.push(...walk(p));
    else out.push(p);
  }
  return out;
}

function pascal(s) {
  return s
    .replace(/[-_]+/g, " ")
    .split(" ")
    .filter(Boolean)
    .map((x) => x[0].toUpperCase() + x.slice(1))
    .join("");
}

function normalizeLifetime(seg) {
  const s = seg.toLowerCase();
  if (s === "singletons") return "Singleton";
  if (s === "scoped") return "Scoped";
  if (s === "transients") return "Transient";
  return pascal(seg);
}

function providerKeysFromFile(providersRootAbs, fileAbs) {
  const rel = path.relative(providersRootAbs, fileAbs); // singletons/utilities/eventBusProvider.ts
  const parts = rel.split(path.sep);

  const file = parts.pop();
  const base = file.replace(/\.[^.]+$/, "");
  const clean = base.replace(/Provider$/i, "");
  const leaf = pascal(clean);

  const keys = parts.map((p, i) => (i === 0 ? normalizeLifetime(p) : pascal(p)));
  keys.push(leaf);
  return keys;
}

function setTree(tree, keys, value) {
  let cur = tree;
  for (let i = 0; i < keys.length - 1; i++) {
    const k = keys[i];
    cur[k] = cur[k] ?? {};
    cur = cur[k];
  }
  const last = keys[keys.length - 1];
  if (cur[last]) throw new Error(`Duplicate registry path: ${keys.join(".")}`);
  cur[last] = value;
}

function emitType(tree, indent = 0) {
  const pad = "  ".repeat(indent);
  const entries = Object.entries(tree).sort(([a], [b]) => a.localeCompare(b));
  return `{\n${entries
    .map(([k, v]) => {
      if (typeof v === "string") return `${pad}  ${k}: ${v};`;
      return `${pad}  ${k}: ${emitType(v, indent + 1)};`;
    })
    .join("\n")}\n${pad}}`;
}

for (const t of targets) {
  const providersRootAbs = path.join(PROJECT_ROOT, t.providersRoot);
  if (!fs.existsSync(providersRootAbs)) continue;

  const outAbs = path.join(PROJECT_ROOT, t.outFile);
  const outDir = path.dirname(outAbs);

  const files = walk(providersRootAbs).filter((f) => f.endsWith("Provider.ts"));
  const tree = {};
  const imports = [];
  let idx = 0;

  for (const fileAbs of files) {
    const keys = providerKeysFromFile(providersRootAbs, fileAbs);

    const relImport = path
      .relative(outDir, fileAbs)
      .replace(/\\/g, "/")
      .replace(/\.ts$/, "");

    const alias = `__token${idx++}`;
    imports.push(`import type { token as ${alias} } from "${relImport}";`);
    setTree(tree, keys, `typeof ${alias}`);
  }

  const content =
`/* AUTO-GENERATED. DO NOT EDIT. */
${imports.join("\n")}

export type ${t.typeName} = ${emitType(tree)};
`;

  fs.mkdirSync(outDir, { recursive: true });
  fs.writeFileSync(outAbs, content);
}
