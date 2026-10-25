#!/usr/bin/env bash
set -euo pipefail

# Toggle mouse acceleration and persist the choice in Hyprland's config, so that
# `hyprctl reload` (theme switch, monitor replug, ...) and reboots keep it.

CONFIG="$HOME/.config/hypr/input.lua"

current=$(hyprctl getoption input:accel_profile -j | jq -r '.str')

if [ "$current" = "flat" ]; then
    new_profile="adaptive"
    label="Enabled"
else
    new_profile="flat"
    label="Disabled"
fi

python3 - "$CONFIG" "$new_profile" <<'PY'
import os
import re
import sys
import tempfile

path, profile = sys.argv[1], sys.argv[2]

with open(path) as f:
    lines = f.readlines()

pattern = re.compile(r'^(\s*)(--\s*)?accel_profile\s*=.*$')
for i, line in enumerate(lines):
    m = pattern.match(line)
    if m:
        lines[i] = f'    accel_profile = "{profile}",\n'
        break
else:
    sys.exit(f"toggle-mouse-accel: no accel_profile line found in {path}")

# Write atomically so Hyprland's config watcher never reads a partial file.
fd, tmp = tempfile.mkstemp(dir=os.path.dirname(path), prefix=".input.lua.")
with os.fdopen(fd, "w") as f:
    f.writelines(lines)
os.replace(tmp, path)
PY

hyprctl reload >/dev/null

applied=$(hyprctl getoption input:accel_profile -j | jq -r '.str')
if [ "$applied" = "$new_profile" ]; then
    notify-send "Mouse Acceleration" "$label"
else
    notify-send -u critical "Mouse Acceleration" "Failed to apply $new_profile (got $applied)"
fi
