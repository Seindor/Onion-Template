import { StatusInstance } from "../Aggregates/StatusInstance";
import { StatusId, StatusInstanceOptions } from "../Types/StatusTypes";

const Definitions = {
	Stun: 1,
};

export class StatusEffectsService {
	private readonly statusEffectsMap = new Map<string, StatusInstance[]>();

	initActor(actorId: string) {
		if (this.statusEffectsMap.has(actorId)) {
			warn(`Overwrited StatusEffects for ${actorId}.`);
			this.statusEffectsMap.delete(actorId);
		}
		this.statusEffectsMap.set(actorId, []);
	}

	private canApplyStatus(actorId: string, incoming: StatusInstance): boolean {
		const list = this.statusEffectsMap.get(actorId);
		if (!list) return true;

		for (const existing of list) {
			const existingId = existing.id as StatusId;

			const isBlacklisted = incoming.blacklist?.includes(existingId) ?? false;

			if (!isBlacklisted) continue;

			const ignoreRule = incoming.ignoreList?.find((rule) => rule.id === existingId);

			if (ignoreRule) {
				if (ignoreRule.maxPriority === undefined) {
					continue;
				}

				if (existing.priority <= ignoreRule.maxPriority) {
					continue;
				}
			}

			return false;
		}

		return true;
	}

	public createStatus(
		statusName: StatusId,
		options?: StatusInstanceOptions,
		autoAdd?: boolean,
		actorId?: string,
	): StatusInstance {
		const status = new StatusInstance(statusName, options ?? undefined);

		if (autoAdd) {
			if (!actorId) {
				warn(`actorId is nil, status not added!`);
				return status;
			} else {
				this.addStatus(actorId, status);
			}
		}

		return status;
	}

	public addStatus(actorId: string, newStatus: StatusInstance) {
		if (!this.canApplyStatus(actorId, newStatus)) {
			warn(`${newStatus.id} Blocked by blacklist.`);
			return;
		}

		const list = this.statusEffectsMap.get(actorId);

		if (!list) {
			warn(`Cannot find map for ${actorId}, status not added.`);
			return;
		}

		const existingIndex = list.findIndex((status) => status.id === newStatus.id);

		if (existingIndex !== -1) {
			const existing = list[existingIndex];

			if (newStatus.priority > existing.priority) {
				this.removeStatus(actorId, existing.id);
			} else if (newStatus.priority < existing.priority) {
				return;
			} else {
				const now = os.clock(); //потом заменю на какой-то компонент времени наверное
				const oldRemaining =
					existing.duration !== undefined ? existing.spawned + existing.duration - now : math.huge;

				const newRemaining = newStatus.duration !== undefined ? newStatus.duration : math.huge;

				if (newRemaining <= oldRemaining) {
					return;
				}

				this.removeStatus(actorId, existing.id);
			}
		}

		list.push(newStatus);
		newStatus.apply(actorId);
	}

	public getActor(actorId: string): StatusInstance[] | undefined {
		const list = this.statusEffectsMap.get(actorId);

		if (!list) {
			return undefined;
		}

		return list;
	}

	public removeStatus(actorId: string, statusName: StatusId) {
		const list = this.statusEffectsMap.get(actorId);

		if (!list) {
			warn(`Cannot find map for ${actorId}, status not added.`);
			return;
		}

		const existingIndex = list.findIndex((status) => status.id === statusName);

		if (existingIndex !== 1) {
			const existing = list[existingIndex];
			existing.remove(actorId);
			list.remove(existingIndex);
		}
	}

	public checkStatuses(actorId: string, statuses: StatusId[], ignoreList?: StatusId[]): boolean {
		const list = this.statusEffectsMap.get(actorId);

		if (!list) {
			warn(`Cannot find map for ${actorId}`);
			return false;
		}

		for (const statusId of statuses) {
			const existingIndex = list.findIndex((status) => status.id === statusId);

			if (existingIndex !== -1) {
				const existing = list[existingIndex];
				existing.check(actorId);

				if (ignoreList?.includes(existing.id)) {
					continue;
				}

				return true;
			}
		}

		return false;
	}
}
