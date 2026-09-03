# COLOREOL — End-of-Line Overflow Indicator for TSE

**README version:** 1.0.0.0.0  
**Date and time:** 2026-09-03 00:58:40 CEST (UTC+02:00)  
**Program file:** `COLOREOL.S`  
**Original program date:** 1996-10-31  
**Original author:** B. Alex Robinson, Tranzoa Co.

## Description

`COLOREOL.S` is a resident TSE SAL macro for The SemWare Editor (TSE). It provides a visual indication when a displayed line contains text beyond the right edge of the current editing window.

For every visible line that continues past the right-hand boundary, the macro changes the display attribute of the far-right visible character. This makes horizontally clipped lines easier to recognize without moving the cursor or scrolling horizontally.

The macro performs this check while TSE is idle and updates the indicator as the screen contents change.

## Included file

- `COLOREOL.S` — TSE SAL source code.

## How it works

When the macro is loaded, it:

1. Reads TSE's current `EOFMarkerAttr` color attribute.
2. Hooks the `do_color_eol()` procedure to TSE's `_IDLE_` event.
3. Examines every row in the current window.
4. Checks whether text exists beyond the right edge of that row.
5. Applies the selected attribute to the last visible character when more text follows off-screen.
6. Restores the original cursor position, screen position, column, and horizontal offset.

When the macro is purged, its hook is removed automatically.

## Requirements

- The SemWare Editor (TSE).
- The TSE SAL compiler appropriate for the installed TSE version, such as `SC32.EXE` for TSE Pro/32.
- `COLOREOL.S` from the archive.

## Compile

Open a command prompt in the directory containing `COLOREOL.S`, then run:

```text
sc32 coloreol.s
```

If `SC32.EXE` is not on the system `PATH`, invoke it by using its full path.

A successful compilation creates the executable TSE macro, normally `COLOREOL.MAC`.

## Install and run

1. Compile `COLOREOL.S`.
2. Place the resulting `COLOREOL.MAC` in a directory where TSE can find macros.
3. Start TSE or return to the running editor.
4. Load the macro by executing:

```text
coloreol
```

5. Open a file containing lines wider than the current editing window.
6. Narrow the window or scroll horizontally as needed. The character at the far-right edge is highlighted when additional text exists beyond it.

The macro remains active after it is loaded because it installs an `_IDLE_` hook.

## Unload the macro

Purge `COLOREOL` through TSE's macro purge facility. Its `WhenPurged()` procedure calls `UnHook(do_color_eol)` so the idle hook is removed cleanly.

Depending on the installed TSE version and configuration, macro loading and purging can be performed from the Macro menu or with the corresponding TSE macro commands.

## Change the indicator color

By default, the macro uses TSE's end-of-file marker attribute:

```sal
ccolor = Query(EOFMarkerAttr)
```

To use another color, edit this assignment in `WhenLoaded()`, compile the source again, purge any already loaded copy, and reload the newly compiled macro.

## Interaction with COLORS.S

The source notes that the `COLORS.S` macro can override this macro's display changes when `COLOREOL` is hooked to `_AFTER_UPDATE_DISPLAY_`. The supplied version therefore uses the `_IDLE_` hook.

If the highlighting is missing or is immediately replaced, temporarily disable other macros that recolor the screen and test `COLOREOL` again.

## Troubleshooting

### No highlight is visible

- Confirm that `COLOREOL.MAC` compiled successfully and was loaded.
- Test with a line that extends beyond the right edge of the visible window.
- Make the editing window narrower so the overflow is easy to reproduce.
- Check whether another display-color macro is repainting the same character.
- Choose a more contrasting value for `ccolor` and recompile the macro.

### The old behavior remains after recompiling

Purge the loaded macro before loading the replacement. If necessary, restart TSE so that the newly compiled macro is loaded from disk.

### The compiler cannot find the source

Change to the directory containing `COLOREOL.S`, or supply the complete source path to the compiler.

## Notes

- The macro changes only the on-screen display attribute; it does not change the text in the file.
- No hard-coded installation directory is used.
- The indicator applies only to visible rows in the current TSE window.
- The current implementation uses `Query(EOFMarkerAttr)` as its default color source.

## Version history

| Version | Date | Description |
|---|---|---|
| 1.0.0.0.0 | 2026-09-03 | Initial Markdown documentation for the supplied `COLOREOL.S` source. |

Future documentation revisions should increment the final component sequentially:

```text
1.0.0.0.0
1.0.0.0.1
1.0.0.0.2
1.0.0.0.3
...
```

## License

No license information is included in the supplied source archive. Retain the original author information and source comments when redistributing or modifying the program, and obtain permission from the rights holder when required.
