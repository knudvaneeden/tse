# NAMSTATE

**Version:** 1.0.0.0.1  
**Package date and time:** 2026-09-23 20:51:37 UTC

NAMSTATE saves and restores a named TSE editor state through TSE's `state` macro. You can keep several state files by entering different filenames. The original `NAMSTATE.SI` by Dave Guyer (1995) is included for people who already use its UI include and key bindings. `namstate.s` is a standalone version with a `Main()` help message and an INI setting.

## Package contents

| File | Purpose |
| --- | --- |
| `namstate.s` | Standalone SAL source with a save/restore prompt and Ctrl+Alt+Shift+N shortcut. |
| `NAMSTATE.SI` | Unchanged original UI include; binds Alt+Shift+S to save and Alt+Shift+R to restore. |
| `namstate.ini` | Controls the standalone macro's startup Warn box. |
| `namstate_readme.md` | These instructions. |

## Build and run the standalone macro

1. Extract the archive and compile `namstate.s` with `sc32 namstate.s` to create `namstate.mac`.
2. Keep `namstate.ini` beside `namstate.mac`. Load and execute `namstate.mac` in TSE, or press **Ctrl+Alt+Shift+N** after loading it. If `silent=false`, acknowledge the introductory `Warn()` box. The macro then continues to its action prompt.
3. Enter **S** to save, or **R** to restore. Accept the suggested `tsestate.dat` or enter another path. A save confirmation appears after invoking TSE's `state` macro.
4. To restore with a file picker, choose **R**, then clear the suggested filename. The picker opens in the macro's directory. Canceling either prompt or the picker does nothing. You may also execute the public procedures `mSaveState` and `mRestoreState` directly.

The `state` macro must be available to TSE. The default state filename and `namstate.ini` are resolved relative to `namstate.mac`, without `LoadDir()`. Restoring a state changes the editor session, so save any work you want to keep first. If Ctrl+Alt+Shift+N is already assigned, change the binding at the end of `namstate.s` and recompile.

## Original UI include and hotkeys

For the original key driven version, add `#include ["NAMSTATE.SI"]` in the appropriate procedure area of your TSE UI source, compile that UI, and use **Alt+Shift+S** to save or **Alt+Shift+R** to restore. The original include contains its own key declarations; place those in the key assignment area if your UI layout requires it. It is preserved unchanged and does not read `namstate.ini` or display the standalone macro's startup Warn box.

## Configuration

In `namstate.ini` beside `namstate.mac`:

```ini
[namstate]
silent=false
```

With `silent=false` (the default), executing `Main()` shows an informative `Warn()` box, then asks whether to save or restore. Set `silent=true` to suppress that box; the save/restore prompt still appears. This does not suppress save confirmation or errors from TSE's `state` macro.

## Version history

- **1.0.0.0.1 — 2026-09-23 20:51:37 UTC:** Use paths relative to the compiled macro; continue after the introductory warning into a save/restore choice; add Ctrl+Alt+Shift+N.
- **1.0.0.0.0 — 2026-09-23 20:38:12 UTC:** Packaged the original include, added a standalone entry point and INI controlled startup message, and documented usage.
