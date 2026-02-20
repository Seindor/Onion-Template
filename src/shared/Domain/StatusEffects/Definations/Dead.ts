import { StatusDefinition } from "../Types/StatusTypes";

export const Dead: StatusDefinition = {
	id: "Dead",

	defaultModifiers: [
		{ stat: "WalkSpeed", type: "Override", value: 0 },
		{ stat: "JumpPower", type: "Override", value: 0 },
	],

	onAdded: (actor) => {},
	onRemoved: (actor) => {},
	onCheck: (actor) => {
		return true;
	},
};
