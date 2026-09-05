# DRAGDROP for The SemWare Editor (TSE)

**Documentation version:** 1.0.0.0.0  
**Created:** 2026-09-05 13:51:57 UTC  
**Original macro date:** 1994-10-03  
**Original author:** Christopher Antos

## Description

`DRAGDROP` is a TSE SAL macro that adds mouse-based text selection and drag-and-drop editing similar to Microsoft Word for Windows.

The macro can:

- Move the cursor or switch between editor windows with the mouse.
- Select words, character blocks, column blocks, and line blocks.
- Move or copy a selected block by dragging it.
- Drag selected text between TSE windows.
- Overwrite destination text when dragging a column block.
- Scroll the editor window while dragging near a boxed window edge.
- Change to the previous or next file while a drag operation is active.

## Included files

| File | Description |
| --- | --- |
| `DRAGDROP.S` | SAL source code for the macro. |
| `DRAGDROP.MAC` | Precompiled TSE macro. |
| `DRAGDROP.TXT` | Original documentation and usage notes. |

## Requirements

- The SemWare Editor (TSE) with mouse support enabled.
- The SAL compiler (`SC32`) only if you want to rebuild `DRAGDROP.MAC` from `DRAGDROP.S`.
- Boxed editor windows are recommended because drag-scrolling depends on window borders.

This is an older macro. Keep a backup of the supplied working files before modifying or recompiling them for a newer TSE release.

## Installation

1. Extract `dragdrop.zip` to a directory of your choice.
2. Copy `DRAGDROP.MAC` to a directory from which TSE can load macros.
3. Start TSE.
4. Load `DRAGDROP.MAC` in TSE.
5. Optionally add `DRAGDROP.MAC` to the TSE AutoLoad List so it is loaded every time TSE starts.

Loading the macro activates its mouse definitions without displaying the help screen.

## How to compile the source

The archive already contains a compiled macro. To rebuild it, open a command prompt in the directory containing `DRAGDROP.S` and run:

```bat
sc32 DRAGDROP.S
```

If compilation succeeds, the compiler creates or updates `DRAGDROP.MAC`. Load that compiled file in TSE or add it to the AutoLoad List.

## How to run it

There are two common ways to use the macro.

### Run once and show help

Execute `DRAGDROP.MAC` as a TSE macro. Its `Main()` procedure opens the **Mouse Reference** help screen.

### Load for normal use

Load `DRAGDROP.MAC`, or place it in the TSE AutoLoad List. The mouse commands then become active without automatically displaying help.

## Mouse controls

| Action | Result |
| --- | --- |
| Left-click in the current window | Move the cursor to the mouse position. |
| Left-click in another window | Make that window current. Hold the button to move the cursor there too. |
| Left-click outside a window | Invoke the key configured by `MAINMENU_KEY`; the supplied default is `Escape`. |
| Left-click and hold | Mark the word under the mouse cursor. |
| Left-click and drag | Select a character/stream block, or drag an existing selected block. |
| Double-click | Mark a line. |
| Double-click and drag | Select a line block. |
| `Ctrl` + left-click and drag | Select a column block. |
| `Alt` + left-click and drag | Select a line block. |
| `Shift` + left-click | Switch windows and move the cursor. |

## Drag-and-drop controls

1. Select a block of text.
2. Click inside the selected block and begin dragging.
3. Move the mouse to the required destination, including another TSE window if desired.
4. Release the mouse button to move the block.

Modifiers available while dragging:

| Key | Effect |
| --- | --- |
| `Ctrl` | Copy the block instead of moving it. |
| `Alt` | Use overwrite mode. This is particularly useful for column blocks. |
| `Escape` | Cancel the drag operation. |
| `Alt+,` | Switch to the previous file while continuing the drag. |
| `Alt+.` | Switch to the next file while continuing the drag. |

Keep the mouse button held while using `Alt+,` or `Alt+.`.

## Configuration

The main settings are near the beginning of `DRAGDROP.S`.

### Main-menu key

The supplied source contains:

```text
constant MAINMENU_KEY = <Escape>
```

If your TSE main menu uses another key, change `MAINMENU_KEY` to that key and recompile the source.

### Help-screen key

The supplied source contains:

```text
constant HELP_SCREEN_KEY = 0
```

The value `0` disables the dedicated help key. Assign a TSE key value to `HELP_SCREEN_KEY` and recompile if you want to open the Mouse Reference screen with a key.

### Drag-scrolling delay

The macro uses TSE's `MouseRepeatDelay` setting through its `mDelay()` procedure. If scrolling is too fast or too slow on your system, adjust `mDelay()` or use a fixed delay value, then recompile.

### Feedback colors

`COLOR_HILITE`, `COLOR_TEXT`, and `COLOR_FEEDBACK` control visual feedback during a drag operation. A value of `0` for the first two settings uses the corresponding TSE menu colors.

## Troubleshooting

### Mouse actions do not work

- Confirm that mouse support is enabled in TSE.
- Confirm that `DRAGDROP.MAC` is loaded.
- If using AutoLoad, verify that the macro appears in the TSE AutoLoad List.
- Check whether another loaded macro replaces the same mouse key definitions.

### Clicking outside a window does not open the expected menu

Edit `MAINMENU_KEY` in `DRAGDROP.S` so it matches the key that opens your TSE main menu, then rebuild the macro.

### Drag-scrolling does not work at every edge

Use boxed/bordered editor windows. The original implementation intentionally relies on bordered edges for acceptable scrolling performance. With borderless windows, some drag-scrolling directions may not work.

### Scrolling speed is incorrect

Adjust TSE's `MouseRepeatDelay`, or tune the `mDelay()` procedure in the source and recompile.

### The macro does not compile in a newer TSE version

The source dates from 1994 and the supplied compiled file dates from 1995. Newer SAL compilers may report compatibility errors. Review obsolete syntax or renamed built-ins against the documentation for your installed TSE version. Until the source is adapted, try the supplied `DRAGDROP.MAC` after keeping a backup.

## Version numbering

This README uses a five-part version number. Increase the last component for each documentation revision:

```text
1.0.0.0.0  Initial README
1.0.0.0.1  First revision
1.0.0.0.2  Second revision
1.0.0.0.3  Third revision
```

Continue with `1.0.0.0.4`, `1.0.0.0.5`, and so on. Increase an earlier component only for a larger release or structural change.

## License and distribution note

The original documentation states that the macro may be modified, customized, distributed, or deleted, but not sold. It was released as free software by its original author. Preserve the original author information and documentation when redistributing it.

## Original author

Christopher Antos  
Original contact listed in the archive: `chrisant@microsoft.com`

Because this contact information is historical, it may no longer be current.
