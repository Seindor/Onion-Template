import { Stun } from "../Definations/Stun";
import {
	StatusInstanceType,
	StatusInstanceOptions,
	StatusDefinition,
	StatusId,
	Modifier,
	IgnoreRule,
} from "../Types/StatusTypes";

const Definitions: Partial<Record<StatusId, StatusDefinition>> = {
	Stun: Stun,
};

const defaultStatusTemplate = (id: StatusId): StatusDefinition => ({
	id,
	defaultModifiers: [],
});

export class StatusInstance implements StatusInstanceType {
	readonly id: StatusId;
	readonly modifiers: Modifier[];
	readonly priority: number;
	readonly blacklist?: StatusId[];
	readonly ignoreList?: IgnoreRule[];
	readonly spawned: number;
	readonly duration?: number;

	readonly onAdded?: (actorId: string, statusInstance?: StatusInstance) => void;
	readonly onRemoved?: (actorId: string, statusInstance?: StatusInstance) => void;
	readonly onCheck?: (actorId: string, statusInstance?: StatusInstance) => boolean | void;

	constructor(statusId: StatusId, options?: StatusInstanceOptions) {
		const definition: StatusDefinition = Definitions[statusId]
			? { ...Definitions[statusId] }
			: defaultStatusTemplate(statusId);

		this.id = definition.id;
		this.modifiers =
			options?.customModifiers ?? (definition.defaultModifiers ? [...definition.defaultModifiers] : []);

		this.priority = options?.priority ?? 1;

		this.blacklist = definition.defaultBlacklist ?? [];
		this.ignoreList = options?.ignoreList ?? undefined;

		this.spawned = os.clock();
		this.duration = options?.duration;

		this.onAdded = options?.onAdded ?? definition.onAdded ?? undefined;
		this.onRemoved = options?.onRemoved ?? definition.onRemoved ?? undefined;
		this.onCheck = options?.onCheck ?? definition.onCheck ?? undefined;
	}

	apply(actorId: string) {
		this.onAdded?.(actorId, this);
	}

	remove(actorId: string) {
		this.onRemoved?.(actorId, this);
	}

	check(actorId: string): boolean {
		return this.onCheck?.(actorId, this) ?? true;
	}
}
