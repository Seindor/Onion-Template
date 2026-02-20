export type Token<T = unknown> = {
	readonly __brand: "DI_TOKEN";
	readonly name: string;
	readonly __type?: T;
};

export type TokenType<TToken extends Token> = TToken["__type"];

export function createToken<T>(name: string): Token<T> {
	return { __brand: "DI_TOKEN", name } as Token<T>;
}
