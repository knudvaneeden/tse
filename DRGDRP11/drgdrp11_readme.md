# DRGDRP11 — Mouse Selection and Drag-and-Drop for TSE

**README version:** 1.0.0.0.0  
**Package version:** DragDrop 1.1  
**Date and time:** 2026-09-05 14:00:27 UTC  
**Original author:** Christopher Antos  
**Original release date:** 1997-04-03

## Description

DRGDRP11 is a mouse-selection and drag-and-drop macro for The SemWare Editor (TSE). It provides mouse behavior similar to Microsoft Word for Windows: text can be selected with the mouse and a marked block can be moved or copied by dragging it to another location.

The original package states that version 1.1 works with TSE 2.5 and TSE 2.6. The included `DRAGDROP.MAC` was compiled for TSE 2.6. Users of TSE 2.5 must recompile `DRAGDROP.S` with the compatible SAL compiler.

## Package contents

| File | Purpose |
| --- | --- |
| `DRAGDROP.S` | SAL source code for the macro |
| `DRAGDROP.MAC` | Precompiled macro supplied for TSE 2.6 |
| `DRAGDROP.TXT` | Original documentation and usage notes |
| `file_id.diz` | Short archive description |

## Main features

- Move the cursor or switch editor windows with the left mouse button.
- Mark a word by clicking and holding.
- Mark a line by double-clicking.
- Mark a character stream by clicking and dragging.
- Mark a column block with **Ctrl + left-button drag**.
- Mark lines with **Alt + left-button drag** or by double-clicking and dragging.
- Move an existing marked block by dragging it.
- Copy instead of move by holding **Ctrl** while dragging.
- Overwrite destination text for a column block by holding **Alt** while dropping.
- Drag blocks between TSE windows.
- Switch to the previous or next file while a drag operation is active.
- Scroll while dragging beyond a bordered window edge.

## Requirements

- The SemWare Editor (TSE) with mouse support enabled.
- TSE 2.5 or TSE 2.6, according to the original documentation.
- A compatible SAL compiler if `DRAGDROP.S` must be compiled.

The supplied source is historical and may require changes before it can be compiled or used with much newer TSE releases.

## Installation

### Option 1: Use the supplied compiled macro with TSE 2.6

1. Extract `drgdrp11.zip` to a temporary directory.
2. Copy `DRAGDROP.MAC` to the directory from which TSE loads macros.
3. Start TSE.
4. Load `DRAGDROP.MAC` manually, or add it to TSE's AutoLoad List so it becomes active whenever TSE starts.

### Option 2: Compile the source

1. Extract `drgdrp11.zip`.
2. Open a command prompt in the extracted directory.
3. Make sure the appropriate SAL compiler is available on `PATH`, or invoke it by its full path.
4. Compile the source:

   ```bat
   sc32 DRAGDROP.S
   ```

5. Confirm that compilation creates `DRAGDROP.MAC` without errors.
6. Copy the compiled macro to the TSE macro directory.
7. Load it manually or add it to the AutoLoad List.

For TSE 2.5, use the SAL compiler supplied for that TSE version rather than the TSE 2.6 build included in the archive.

## How to run

There are two ways to start the macro:

- **Execute `DRAGDROP.MAC`:** activates the macro and displays its quick-help screen.
- **Load `DRAGDROP.MAC`:** activates its mouse definitions without displaying the help screen. This is the usual choice for the AutoLoad List.

Once loaded, use the mouse controls described below.

## Mouse controls

| Action | Result |
| --- | --- |
| Left-click | Move the cursor, or switch to another window |
| Left-click and hold | Mark the word under the mouse cursor |
| Double-click | Mark a line |
| Left-button drag | Mark a character stream, or drag an existing marked block |
| Ctrl + left-button drag | Mark a column block |
| Alt + left-button drag | Mark lines |
| Double-click and drag | Mark lines |
| Shift + left-click | Switch windows and move the cursor, or extend the selection |

Clicking outside an editor window may invoke TSE's main menu, depending on the editor configuration.

## Controls while dragging

| Key | Result |
| --- | --- |
| `Esc` | Cancel the drag operation |
| Hold `Ctrl` | Copy the marked block instead of moving it |
| Hold `Alt` | Overwrite destination text when copying or moving a column block |
| `Alt+,` | Switch to the previous file |
| `Alt+.` | Switch to the next file |

Keep the mouse button pressed while switching files during a drag.

## Optional configuration

Edit `DRAGDROP.S` before compiling to change the following settings:

- `HELP_SCREEN_KEY`: assign a key that opens the built-in mouse-reference screen. Its default value is `0`, which disables the key binding.
- `SLOP_TICKS`: delay before drag-scrolling begins.
- `DBLCLK_SLOP`: timing tolerance used to recognize a double-click.
- `COLOR_HILITE`, `COLOR_TEXT`, and `COLOR_FEEDBACK`: colors used while dragging.
- `FLOATING_FEEDBACK`: controls compilation of the floating copy/move indicator.

After changing the source, recompile it and reload the resulting macro. If TSE already has the macro loaded, unloading it or restarting TSE may be necessary before the new build is used.

## Help and troubleshooting

### The macro loads but nothing appears

This is normal when the macro is loaded rather than executed. Loading installs its mouse definitions silently. Execute the macro to display the quick-help screen.

### Drag-scrolling does not work at every edge

The original author notes that drag-scrolling depends on bordered window edges. With borderless windows, scrolling may fail in some directions. This was an intentional performance tradeoff in the original implementation.

### Drag-scrolling is too fast or too slow

The macro derives its delay from TSE's `MouseRepeatDelay`. Adjust that TSE setting or modify the `mDelay()` routine in `DRAGDROP.S`, then recompile the macro.

### Mouse actions do not work

Verify that mouse support is enabled in TSE and that `DRAGDROP.MAC` is loaded. Also check whether another loaded macro redefines the same mouse keys.

### Compilation fails in a modern TSE version

The source dates from 1997 and targets TSE 2.5/2.6. Language keywords, constants, compiler rules, or APIs may differ in later releases. Treat modernization as a separate porting task and preserve the original files as a reference copy.

## Notes and limitations

- The included compiled macro targets TSE 2.6.
- Drag-scrolling may not work correctly on borderless window edges.
- The source contains several originally undocumented TSE mouse-key codes.
- The package is legacy software; test it on copies of files before relying on it for important editing work.
- The original documentation permits modification and redistribution but says the macro must not be sold.

## Version history

| README version | Date and time | Changes |
| --- | --- | --- |
| 1.0.0.0.0 | 2026-09-05 14:00:27 UTC | Initial Markdown description, installation guide, controls, help, and troubleshooting information created from `drgdrp11.zip` |

## README version-number convention

This README uses a five-part version number. Begin with `1.0.0.0.0` and increment the final part for each documentation revision:

```text
1.0.0.0.0
1.0.0.0.1
1.0.0.0.2
1.0.0.0.3
```

The README version is separate from the original DragDrop software version, which is **1.1**.
