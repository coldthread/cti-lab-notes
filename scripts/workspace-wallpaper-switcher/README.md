# Workspace Wallpaper Scripts
## Restore Instructions After Reinstall

**Date:** May 2026
**Machine:** HP Laptop / adaptable to others
**Requires:** Linux Mint Cinnamon, wmctrl

---

## Files in This Folder

| File | Purpose |
|------|---------|
| `workspace-wallpaper.sh` | Sets wallpaper based on current workspace number |
| `workspace-watcher.sh` | Polls for workspace changes and calls wallpaper script |

---

## Restore Sequence

### Step 1: Install wmctrl if not present

```
which wmctrl
```

If nothing returns, install it:

```
sudo apt install wmctrl
```

### Step 2: Create scripts folder if it does not exist

```
mkdir -p ~/scripts
```

### Step 3: Copy scripts

```
cp workspace-wallpaper.sh ~/scripts/
cp workspace-watcher.sh ~/scripts/
```

### Step 4: Make both scripts executable

```
chmod +x ~/scripts/workspace-wallpaper.sh
chmod +x ~/scripts/workspace-watcher.sh
```

### Step 5: Place wallpaper images

Images go in `~/Pictures/Wallpapers/`. This machine's config uses these
exact filenames, one image per workspace:

```
general.jpg
research.png
lab.png
vm.webp
```

Filenames and extensions are case sensitive and must match the array in
`workspace-wallpaper.sh` exactly. A mismatch causes silent failure. The
filenames and workspace roles are per-machine: adjust the array in the script
to match your own images and workspace layout.

### Step 6: Test manually

```
bash ~/scripts/workspace-wallpaper.sh
```

The wallpaper for the current workspace should appear. If nothing changes,
verify image filenames and paths.

### Step 7: Add watcher to Startup Applications

Go to Menu → Preferences → Startup Applications → click + → Custom Command.

Fill in:

- **Name:** Workspace Wallpaper
- **Command:** `bash /home/[yourusername]/scripts/workspace-watcher.sh`
- **Delay:** 5

Replace `[yourusername]` with your actual Linux username. Run `whoami` in a
terminal if unsure. The 5 second delay gives the desktop time to fully load
before the watcher starts.

Click Add.

### Step 8: Reboot and confirm

```
sudo reboot
```

After logging in, switch workspaces with Ctrl+Alt+Left/Right arrow. Each
workspace should show its assigned wallpaper automatically.

---

## Design Note

The watcher polls every half second rather than subscribing to a desktop
event. Polling was the deliberate simple choice: it has no dependencies beyond
wmctrl and is easy to reason about. Cinnamon can signal workspace changes over
dbus without polling, which would be the move if this ever needed to scale
past a personal tool.

---


# Workspace Wallpaper: Troubleshooting Commands
Quick command reference for the watcher and wallpaper scripts. Copy-paste ready.

Multiple watcher instances can accumulate if the script is run manually more
than once. Check for duplicates:

```
ps aux | grep workspace-watcher
```

Kill duplicates with `kill PID`. Only one watcher instance should run at a time.

If a wallpaper is not loading, check the exact filename including case and
extension:

```
ls ~/Pictures/Wallpapers/
```

The script fails silently when an image name in the array has no matching file.
More workspaces than images in the array also produces an empty wallpaper path:
keep the array length at or above your workspace count.

---

## Check How Many Watchers Are Running

```
pgrep -fc workspace-watcher
```

Returns a count. `1` is correct. `0` means the watcher is not running. `2` or
more means duplicates have accumulated.

To see the full detail (PID, start time, CPU) instead of just a count:

```
pgrep -af workspace-watcher
```

Older method, same information:

```
ps aux | grep [w]orkspace-watcher
```

The bracket around the first letter stops grep from matching its own process
line, so you see only real watchers.

---

## Kill Duplicate Watchers

Kill every watcher at once:

```
pkill -f workspace-watcher
```

Then restart a single clean instance:

```
bash ~/scripts/workspace-watcher.sh &
```

To kill one specific instance instead, get its PID from `pgrep -af` above, then:

```
kill <PID>
```

If a watcher will not die (rare), force it:

```
kill -9 <PID>
```

---

## Confirm the Watcher Survived a Reboot

After logging back in, give the 5 second startup delay time to pass, then:

```
pgrep -fc workspace-watcher
```

Expect `1`. If `0`, the Startup Applications entry did not fire: recheck the
command path and that the entry is enabled.

---

## Wallpaper Not Changing

Check the images exist with the exact names the script expects:

```
ls ~/Pictures/Wallpapers/
```

Compare against the array in the script:

```
grep 'W=(' ~/scripts/workspace-wallpaper.sh
```

The filenames and extensions must match exactly, case included. A name in the
array with no matching file fails silently.

Check which workspace number the system currently reports:

```
wmctrl -d | grep '\*' | awk '{print $1}'
```

Workspaces are zero-indexed. The first workspace is `0`, so it maps to the
first image in the array. If you have more workspaces than images, the extra
workspaces return an empty path and the wallpaper clears.

Run the wallpaper script by hand and watch for errors:

```
bash ~/scripts/workspace-wallpaper.sh
```

---

## Confirm wmctrl Is Installed

Both scripts depend on it:

```
which wmctrl
```

No output means it is missing:

```
sudo apt install wmctrl
```

---

## Stop the Watcher Entirely

To turn the feature off for the current session:

```
pkill -f workspace-watcher
```

To stop it starting at boot, remove or untick the entry in
Menu → Preferences → Startup Applications.

---

*cualli tonalli*
