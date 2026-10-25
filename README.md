# omarchy-mouse-accel

A keyboard shortcut on [Omarchy](https://omarchy.org/) that toggles mouse
acceleration on and off, and makes the choice stick.

```bash
git clone https://github.com/badger2k/omarchy-mouse-accel
cd omarchy-mouse-accel
./install.sh
```

The script is safe to run more than once.

Then press **`SUPER + CTRL + M`** to switch. A notification shows the active
mode.

## Why

The obvious way to toggle acceleration is at runtime:

```bash
hyprctl eval 'hl.config({ input = { accel_profile = "flat" } })'
```

That works until something reloads Hyprland. Omarchy runs `hyprctl reload`
when you switch themes, unplug a monitor, or refresh a config, and the reload
re-reads `~/.config/hypr/input.lua`. If `accel_profile` is not set there, the
mouse silently falls back to the default `adaptive` profile.

This script writes the chosen profile into `input.lua`, so every reload,
monitor change, and reboot restores it.

## What it does

- **`flat`** disables acceleration (linear pointer movement).
- **`adaptive`** restores Hyprland's default acceleration.

Each press reads the current profile with `hyprctl getoption`, writes the other
one into `~/.config/hypr/input.lua`, and reloads Hyprland. The write is atomic,
so the config watcher never sees a partial file.

Installed files:

| File | Purpose |
|------|---------|
| `~/.local/bin/toggle-mouse-accel.sh` | The toggle |
| `~/.config/hypr/input.lua` | Its `accel_profile` line is kept in sync |
| `~/.config/hypr/bindings.lua` | Gets one `o.bind(...)` line appended if it isn't there yet |

## Notes

- The setting is per input device, and Hyprland applies it to mouses and
  touchpads alike.
- `accel_profile = "flat"` can be set by hand instead if you never want to
  toggle; this repo exists for toggling.
- `omarchy refresh hyprland` resets `input.lua` to defaults, so press the
  shortcut once more after that.
- Requires `python3` and `jq`, both present on a stock Omarchy install.

## Uninstall

```bash
rm ~/.local/bin/toggle-mouse-accel.sh
# then remove the "Toggle mouse acceleration" line from ~/.config/hypr/bindings.lua
```
