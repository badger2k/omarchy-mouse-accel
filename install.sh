#!/usr/bin/env bash
# Installs an Omarchy keyboard shortcut that toggles mouse acceleration and
# keeps the choice across Hyprland reloads and reboots. Run as your user.
set -euo pipefail

(( EUID != 0 )) || { echo "Run as your user, not root"; exit 1; }
cd "$(dirname "$0")"

KEY="SUPER + CTRL + M"
BINDINGS=~/.config/hypr/bindings.lua

install -Dm755 toggle-mouse-accel.sh ~/.local/bin/toggle-mouse-accel.sh

if ! grep -q 'toggle-mouse-accel.sh' "$BINDINGS" 2>/dev/null; then
  printf '\no.bind("%s", "Toggle mouse acceleration", "~/.local/bin/toggle-mouse-accel.sh")\n' "$KEY" >> "$BINDINGS"
  hyprctl reload >/dev/null && hyprctl configerrors
fi

echo "Installed. Toggle with $KEY or ~/.local/bin/toggle-mouse-accel.sh"
