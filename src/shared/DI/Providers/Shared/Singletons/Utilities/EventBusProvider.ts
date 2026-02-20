import { createToken } from "shared/DI/Token.ts";
import type { Container } from "shared/DI/Container";
import EventBus from "shared/Modules/Utilities/EventBus";

export const token = createToken<typeof EventBus>("EventBus");
export function register(container: Container) {
	container.bindSingleton(token, () => EventBus);
}
