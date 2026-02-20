type Connection = { Disconnect(): void; Connected: boolean };
type Callback = (...args: unknown[]) => void;

type Listener = {
	cb: Callback;
	once: boolean;
	connected: boolean;
};

type PriorityListener = Listener & {
	priority: number;
	order: number;
};

class LocalConnection implements Connection {
	public Connected = true;

	constructor(private disconnectFn: () => void) {}

	public Disconnect() {
		if (!this.Connected) return;
		this.Connected = false;
		this.disconnectFn();
	}
}

class EventSlot {
	private normal: Listener[] = [];

	private staged: PriorityListener[] = [];
	private nextOrder = 0;

	public Subscribe(cb: Callback, priority?: number, once = false): Connection {
		if (priority === undefined) {
			const l: Listener = { cb, once, connected: true };
			this.normal.push(l);

			return new LocalConnection(() => {
				l.connected = false;
			});
		} else {
			const l: PriorityListener = { cb, once, connected: true, priority, order: this.nextOrder++ };
			this.staged.push(l);

			this.staged.sort((a, b) => {
				if (a.priority !== b.priority) return a.priority < b.priority;
				return a.order < b.order;
			});

			return new LocalConnection(() => {
				l.connected = false;
			});
		}
	}

	public Fire(startPriority: number, ...args: unknown[]) {
		for (const l of this.normal) {
			if (!l.connected) continue;
			task.spawn(l.cb, ...args);
			if (l.once) l.connected = false;
		}

		for (const l of this.staged) {
			if (!l.connected) continue;
			if (l.priority < startPriority) continue;

			task.spawn(l.cb, ...args);
			if (l.once) l.connected = false;
		}
	}

	public Destroy() {
		for (const l of this.normal) l.connected = false;
		for (const l of this.staged) l.connected = false;
		this.normal = [];
		this.staged = [];
	}
}

const Cache = new Map<string, EventBus>();
export type EventBusStatic = typeof EventBus;
export default class EventBus {
	private events = new Map<string, EventSlot>();

	private constructor(private name: string) {}

	public static New(name: string) {
		const cached = Cache.get(name);
		if (cached) return cached;

		const bus = new EventBus(name);
		Cache.set(name, bus);
		return bus;
	}

	private getEvent(eventName: string) {
		let slot = this.events.get(eventName);
		if (!slot) {
			slot = new EventSlot();
			this.events.set(eventName, slot);
		}
		return slot;
	}

	public Subscribe(eventName: string, cb: Callback, priority?: number): Connection {
		return this.getEvent(eventName).Subscribe(cb, priority, false);
	}

	public Once(eventName: string, cb: Callback, priority?: number): Connection {
		return this.getEvent(eventName).Subscribe(cb, priority, true);
	}

	public SubscribeT<Args extends unknown[]>(
		eventName: string,
		cb: (...args: Args) => void,
		priority?: number,
	): Connection {
		return this.Subscribe(eventName, cb as unknown as Callback, priority);
	}

	public OnceT<Args extends unknown[]>(
		eventName: string,
		cb: (...args: Args) => void,
		priority?: number,
	): Connection {
		return this.Once(eventName, cb as unknown as Callback, priority);
	}

	public Fire(eventName: string, startPriority?: number, ...args: unknown[]) {
		const slot = this.events.get(eventName);
		if (!slot) return;

		slot.Fire(startPriority ?? 1, ...args);
	}

	public Unsubscribe(_eventName: string, connection: Connection) {
		connection.Disconnect();
	}

	public Destroy() {
		for (const [, slot] of this.events) slot.Destroy();
		this.events.clear();
		Cache.delete(this.name);
	}
}
