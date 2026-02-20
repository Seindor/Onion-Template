import { OnStart, Service } from "@flamework/core";
import { Players, ServerScriptService } from "@rbxts/services";
import { StatusEffectsHandler } from "./StatusHandler";

@Service()
export class PlayerHandler implements OnStart {
	onStart(): void {
		const statusEffectsHandler = new StatusEffectsHandler();
		Players.PlayerAdded.Connect((Player: Player) => {
			const actorId = tostring(Player.UserId);
			Player.CharacterAdded.Connect((Character: Model) => {
				statusEffectsHandler.api.initActor(actorId);
				statusEffectsHandler.api.createStatus("Stun", undefined, true, actorId);
				print(statusEffectsHandler.api.getActor(actorId));
			});
		});
	}
}
