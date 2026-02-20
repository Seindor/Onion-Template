import { StatusInstance } from "../Aggregates/StatusInstance";

export const StatusIds = ["Stun", "Knocked", "Dead", "HyperArmor", "iFrame"] as const;
export type StatusId = (typeof StatusIds)[number];

export const StatModifierTypes = ["Override", "Add", "Multiply", "ClampMax", "ClampMin"] as const;
export type StatModifierType = (typeof StatModifierTypes)[number];

export type ControlLevel = number;

export const ActorStats = ["WalkSpeed", "JumpPower", "Gravity"] as const;
export type ActorStat = (typeof ActorStats)[number];

export interface Modifier {
	stat: ActorStat;
	type: StatModifierType;
	value: number | boolean | string;
}

export interface StatusDefinition {
	id: StatusId;

	defaultBlacklist?: StatusId[];

	defaultModifiers?: Modifier[];

	onAdded?: (actorId: string, statusInstance?: StatusInstance) => void;
	onRemoved?: (actorId: string, statusInstance?: StatusInstance) => void;
	onCheck?: (actorId: string, statusInstance?: StatusInstance) => boolean | void;
}

export interface IgnoreRule {
	id: StatusId;
	maxPriority?: number;
}

export interface StatusInstanceType {
	id: string;
	modifiers: Modifier[];
	priority: number;
	blacklist?: StatusId[];
	ignoreList?: IgnoreRule[];
	spawned: number;
	duration?: number;

	onAdded?: (actorId: string, statusInstance?: StatusInstance) => void;
	onRemoved?: (actorId: string, statusInstance?: StatusInstance) => void;
	onCheck?: (actorId: string, statusInstance?: StatusInstance) => boolean | void;
}

export interface StatusInstanceOptions {
	priority?: number;
	duration?: number;

	customModifiers?: Modifier[];
	ignoreList?: IgnoreRule[];

	onAdded?: (actorId: string, statusInstance?: StatusInstance) => void;
	onRemoved?: (actorId: string, statusInstance?: StatusInstance) => void;
	onCheck?: (actorId: string, statusInstance?: StatusInstance) => boolean | void;
}
