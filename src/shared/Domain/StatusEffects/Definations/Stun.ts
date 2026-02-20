import { StatusInstanceType, StatusDefinition } from "../Types/StatusTypes";

export const Stun: StatusDefinition = {
	id: "Stun",

	defaultBlacklist: ["HyperArmor", "iFrame"],

	defaultModifiers: [
		{ stat: "WalkSpeed", type: "Override", value: 0 },
		{ stat: "JumpPower", type: "Override", value: 0 },
	],

	onAdded: (actorId: string, statusInstance?: StatusInstanceType) => {
		warn("Stunned", actorId, "for", statusInstance?.duration || math.huge);
	},
	onRemoved: (actorId: string, statusInstance?: StatusInstanceType) => {},
	onCheck: (actorId: string, statusInstance?: StatusInstanceType) => {},
};
