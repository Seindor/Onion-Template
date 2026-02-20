import { StatusEffectsFacade } from "shared/Domain/StatusEffects/Api/StatusEffectsFacade";
import { StatusEffectsService } from "shared/Domain/StatusEffects/Services/StatusEffectsService";

export class StatusEffectsHandler {
	public readonly service: StatusEffectsService;
	public readonly api: StatusEffectsFacade;

	constructor() {
		this.service = new StatusEffectsService();
		this.api = new StatusEffectsFacade(this.service);
	}
}
