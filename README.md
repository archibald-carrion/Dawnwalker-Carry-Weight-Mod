# Dawnwalker Carry Weight Mod

A small [UE4SS](https://github.com/UE4SS-RE/RE-UE4SS) Lua mod for **The Blood of Dawnwalker** that raises the player's carry weight limit to 999,999. So you "never" become over-encumbered.

- No game files are modified (the `.pak`/`.ucas` archives stay untouched)
- Only the player's inventory is changed. Chests, NPCs and loot bags are left alone
- Re-applies automatically if the game recalculates your limit (level-up, gear change, loading a save)
- Remove it at any time and the game goes back to normal

Tested with game build `dw1-pc-gog-265636-shipping-patch3` (Unreal Engine 5.5.4, GOG) and UE4SS v4.0.0, on Linux through Heroic and Proton.
My main rig runs Cachy OS and I have not tested it on Windows, if you have tested it and want to add your own pr with correct script go ahead!

## How it works

The game's `InventoryComponent` (`/Script/DogwoodInventory`) has a `WeightLimit` float, (for example my Coen's inventory was `200` before installing the mod). Once you are in-game, the mod finds the player's inventory component, sets `WeightLimit` to 999,999, and checks it again every 3 seconds. It also hooks `GetWeightLimit` and `CanExceedWeightLimit` so that UI and script callers see the raised limit.

Inventories with a limit of `0` are skipped. Chests, NPCs and loot bags have `0`.

## Requirements

- The Blood of Dawnwalker (PC)
- [UE4SS v4.0.0](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/v4.0.0) or newer, plus its `TheBloodOfDawnwalker` config from `zCustomGameConfigs.zip`

## Installation

### Windows
My main rig runs Cachy OS and I have not tested it on Windows, if you have tested it and want to add your own pr with correct script/steps go ahead!

### Linux (Heroic, GOG version)

Close Heroic, then run:

```bash
./install.sh
```

The script downloads UE4SS v4.0.0, installs it together with the mod, and adds `WINEDLLOVERRIDES=dwmapi=n,b` to the game's Heroic settings. It assumes the default Heroic install path (`~/Games/Heroic/The Blood of Dawnwalker`) and the GOG app ID `1889754300`. Edit the variables at the top of the script if your setup is different.
You can find your game's GOG ID in the name of the goggame-<ID>.info file in the game's install folder, or in Heroic's config folder as ~/.config/heroic/GamesConfig/<ID>.json.

### Linux (Steam / Proton)
I own Blood of the Dawnwalker on Gog and I have not tested it on Steam, if you have tested it and want to add your own pr with correct script/steps go ahead!


## Checking that it works

Load a save, wait a few seconds, then look in `Win64/ue4ss/UE4SS.log` for a line like:

```
[InfiniteCarry] Set WeightLimit on InventoryComponent ...BP_PlayerCharacter_C_....Inventory Component: 200.0 -> 999999.0
```

On my installation I used the following command and got the following output:

```
❯ grep InfiniteCarry ~/Games/Heroic/"The Blood of Dawnwalker"/Dawnwalker/Binaries/Win64/ue4ss/UE4SS.log

[2026-11-15 16:49:18.8733863] Starting Lua mod 'InfiniteCarryWeight'
[2026-11-15 16:49:18.8743434] [Lua] [InfiniteCarry] Loaded v2
[2026-11-15 16:49:21.8865112] [Lua] [InfiniteCarry] In-game detected, scanning
[2026-11-15 16:49:21.8865331] [Lua] [InfiniteCarry] Looking up class InventoryComponent
[2026-11-15 16:49:21.8865650] [Lua] [InfiniteCarry]   found /Script/DogwoodInventory.InventoryComponent
[2026-11-15 16:49:21.8866081] [Lua] [InfiniteCarry]   property WeightLimit (FloatProperty)
[2026-11-15 16:49:21.8866636] [Lua] [InfiniteCarry]   property OnWeightExceededChanged (MulticastInlineDelegateProperty)
[2026-11-15 16:49:21.8866805] [Lua] [InfiniteCarry]   property bWeightExceeded (BoolProperty)
[2026-11-15 16:49:21.8867359] [Lua] [InfiniteCarry]   function HasWeightlessJunk
[2026-11-15 16:49:21.8867444] [Lua] [InfiniteCarry]   function GetWeightLimit
[2026-11-15 16:49:21.8867654] [Lua] [InfiniteCarry] Hooked /Script/DogwoodInventory.InventoryComponent:GetWeightLimit
[2026-11-15 16:49:21.8867970] [Lua] [InfiniteCarry]   function GetCurrentWeight
[2026-11-15 16:49:21.8868165] [Lua] [InfiniteCarry]   function CanExceedWeightLimit
[2026-11-15 16:49:21.8868300] [Lua] [InfiniteCarry] Hooked /Script/DogwoodInventory.InventoryComponent:CanExceedWeightLimit
[2026-11-15 16:49:21.8868418] [Lua] [InfiniteCarry] Looking up class InventorySubsystem
[2026-11-15 16:49:21.8869008] [Lua] [InfiniteCarry]   found /Script/DogwoodInventory.InventorySubsystem
[2026-11-15 16:49:21.8869892] [Lua] [InfiniteCarry] Looking up class DogwoodInventorySettings
[2026-11-15 16:49:21.8869979] [Lua] [InfiniteCarry]   found /Script/DogwoodInventory.DogwoodInventorySettings
[2026-11-15 16:49:21.8870950] [Lua] [InfiniteCarry] Looking up class InventoryBlueprintFunctionLibrary
[2026-11-15 16:49:21.8871033] [Lua] [InfiniteCarry]   found /Script/DogwoodInventory.InventoryBlueprintFunctionLibrary
[2026-11-15 16:49:21.8871335] [Lua] [InfiniteCarry]   function GetArmorWeightProficiencyPenalty
[2026-11-15 16:49:21.8871457] [Lua] [InfiniteCarry] Looking up class DogwoodStatsSettings
[2026-11-15 16:49:21.8928050] [Lua] [InfiniteCarry]   found /Script/DogwoodStats.DogwoodStatsSettings
[2026-11-15 16:49:21.8928842] [Lua] [InfiniteCarry] Looking up class DogwoodStatsBlueprintFunctionLibrary
[2026-11-15 16:49:21.8979923] [Lua] [InfiniteCarry]   found /Script/DogwoodStats.DogwoodStatsBlueprintFunctionLibrary
[2026-11-15 16:49:21.8980157] [Lua] [InfiniteCarry] Scan complete: 1 limit properties targeted
[2026-11-15 16:49:57.7500338] [Lua] [InfiniteCarry] Set WeightLimit on InventoryComponent /Game/_Dawnwalker/Cutscenes/VS/CS004/CS004_wakeUp_part2_LS.CS004_wakeUp_part2_LS:MovieScene_0.BP_PlayerCharacter_0.Inventory Component: 200.0 -> 999999.0
[2026-11-15 16:49:57.7500715] [Lua] [InfiniteCarry] Set WeightLimit on InventoryComponent /Game/Map_Blockout_Valley/Blockout_Valley.Blockout_Valley:PersistentLevel.BP_PlayerCharacter_C_2147479942.Inventory Component: 200.0 -> 999999.0
❯ 

```


## Uninstall

- **Disable the mod only:** set `InfiniteCarryWeight : 0` in `ue4ss/Mods/mods.txt`.
- **Remove everything**: delete `dwmapi.dll` and the `ue4ss` folder from Win64. On Linux you can also remove the `WINEDLLOVERRIDES` setting (Heroic: Game Settings → Advanced → Environment Variables), but leaving it should be harmless.

If you remove the mod while carrying more than 200 weight, you will be over-encumbered until you drop or sell items. Your save should not be affected otherwise.

## Troubleshooting

- **The game crashes at startup after a game update:** UE4SS probably doesn't support the new build yet. Delete `dwmapi.dll` to play unmodded, and wait for a UE4SS update.
- **No `[InfiniteCarry]` lines in the log:** check that the `dwmapi` override is set (Linux) and that `mods.txt` contains `InfiniteCarryWeight : 1`.

Back up your saves before trying any mod. They live in `%LOCALAPPDATA%\Dawnwalker\Saved\` (on Windows; inside the Wine prefix on Linux).

## Credits

- [UE4SS-RE](https://github.com/UE4SS-RE/RE-UE4SS) for UE4SS and the Dawnwalker game config

This is a fan-made mod, not affiliated with or endorsed by Rebel Wolves or Bandai Namco.
