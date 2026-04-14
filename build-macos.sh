#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TAURI_CONF="$SCRIPT_DIR/apps/screenpipe-app-tauri/src-tauri/tauri.conf.json"

echo "=== screenpipe macOS build ==="

# --- Patches ---
echo "[patch] Fixing productName and identifier..."

if command -v jq &>/dev/null; then
  tmp=$(mktemp)
  jq '.productName = "screenpipe" | .identifier = "screenpi.pe"' "$TAURI_CONF" > "$tmp" && mv "$tmp" "$TAURI_CONF"
else
  sed -i '' 's/"productName": "screenpipe - Development"/"productName": "screenpipe"/' "$TAURI_CONF"
  sed -i '' 's/"identifier": "screenpi.pe.dev"/"identifier": "screenpi.pe"/' "$TAURI_CONF"
fi

# Add more patches here as needed:
# echo "[patch] Fixing XYZ..."
# sed -i '' 's/old/new/' "$SOME_FILE"

echo "[patch] Done."

# --- Build ---
echo "[build] Installing dependencies..."
cd "$SCRIPT_DIR/apps/screenpipe-app-tauri"
bun install

echo "[build] Building Tauri app (metal + apple-intelligence)..."
bun tauri build --features metal,apple-intelligence

echo ""
echo "=== Build complete ==="
ls -lh "$SCRIPT_DIR/apps/screenpipe-app-tauri/src-tauri/target/release/bundle/dmg/"*.dmg 2>/dev/null
