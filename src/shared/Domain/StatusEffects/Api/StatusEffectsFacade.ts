import { StatusInstance } from "../Aggregates/StatusInstance";
import { StatusEffectsService } from "../Services/StatusEffectsService";
import { StatusId, StatusInstanceOptions } from "../Types/StatusTypes";

export class StatusEffectsFacade {
	constructor(private readonly service: StatusEffectsService) {}

	public initActor(actorId: string) {
		this.service.initActor(actorId);
	}

	public createStatus(
		statusName: StatusId,
		options?: StatusInstanceOptions,
		autoAdd?: boolean,
		actorId?: string,
	): StatusInstance {
		return this.service.createStatus(statusName, options, autoAdd, actorId);
	}

	public addStatus(actorId: string, newStatus: StatusInstance) {
		this.service.addStatus(actorId, newStatus);
	}

	public getActor(actorId: string): StatusInstance[] | undefined {
		return this.service.getActor(actorId);
	}

	public removeStatus(actorId: string, statusName: StatusId) {
		this.service.removeStatus(actorId, statusName);
	}

	public checkStatuses(actorId: string, statuses: StatusId[], ignoreList?: StatusId[]): boolean {
		return this.service.checkStatuses(actorId, statuses, ignoreList);
	}
}
