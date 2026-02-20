import { ReplicatedStorage } from "@rbxts/services";
import { Container } from "shared/DI/Container";
import { loadProviders } from "shared/DI/LoadProviders";
import { SharedRegistryShape } from "./Generated/SharedRegistryShape";

const TSFolder = ReplicatedStorage.WaitForChild("TS");

export const SharedContainer = new Container();

const sharedProviders = TSFolder.WaitForChild("di").WaitForChild("providers").WaitForChild("shared") as Folder;
export const SharedRegistry = loadProviders(sharedProviders, SharedContainer) as SharedRegistryShape;
