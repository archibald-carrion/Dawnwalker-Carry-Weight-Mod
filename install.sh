#!/usr/bin/env bash
# Installs UE4SS v4.0.0 + the InfiniteCarryWeight mod into The Blood of Dawnwalker (Heroic/GOG)
# and adds the WINEDLLOVERRIDES env var Heroic needs so Proton loads UE4SS.
set -euo pipefail

GAME="$HOME/Games/Heroic/The Blood of Dawnwalker/Dawnwalker/Binaries/Win64"
HCFG="$HOME/.config/heroic/GamesConfig/1889754300.json"
HERE="$(cd "$(dirname "$0")" && pwd)"
TMP="$(mktemp -d)"

if pgrep -x heroic >/dev/null; then echo "Close Heroic first (it overwrites its config on exit)."; exit 1; fi

echo "Downloading UE4SS v4.0.0..."
curl -sSL -o "$TMP/ue4ss.zip" https://github.com/UE4SS-RE/RE-UE4SS/releases/download/v4.0.0/UE4SS_v4.0.0.zip
curl -sSL -o "$TMP/cfg.zip"   https://github.com/UE4SS-RE/RE-UE4SS/releases/download/v4.0.0/zCustomGameConfigs.zip
unzip -q "$TMP/ue4ss.zip" -d "$TMP/ue4ss"
unzip -q "$TMP/cfg.zip"   -d "$TMP/cfg"

cp "$TMP/ue4ss/dwmapi.dll" "$GAME/"
cp -r "$TMP/ue4ss/ue4ss" "$GAME/"
cp -r "$TMP/cfg/TheBloodOfDawnwalker/." "$GAME/ue4ss/"     # official Dawnwalker signatures/settings

cp -r "$HERE/InfiniteCarryWeight" "$GAME/ue4ss/Mods/"
grep -q "InfiniteCarryWeight" "$GAME/ue4ss/Mods/mods.txt" || \
  sed -i '1i InfiniteCarryWeight : 1' "$GAME/ue4ss/Mods/mods.txt"

cp "$HCFG" "$HCFG.bak"
python3 - "$HCFG" <<'EOF'
import json, sys
p = sys.argv[1]; c = json.load(open(p)); g = c["1889754300"]
env = [e for e in (g.get("enviromentOptions") or []) if e.get("key") != "WINEDLLOVERRIDES"]
env.append({"key": "WINEDLLOVERRIDES", "value": "dwmapi=n,b"})
g["enviromentOptions"] = env
json.dump(c, open(p, "w"), indent=2)
EOF

rm -rf "$TMP"
echo "Done. Launch the game from Heroic, load a save, then check:"
echo "  grep InfiniteCarry \"$GAME/ue4ss/UE4SS.log\""
