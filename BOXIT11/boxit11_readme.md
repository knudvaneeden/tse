# BoxIt 0.11 for TSE

**README version:** 1.0.0.0.0  
**Archive:** `boxit11.zip`  
**Original BoxIt version:** 0.11 (23 November 1994)

## Description

BoxIt is a TSE SAL macro that draws a configurable box around a marked column block in The SemWare Editor (TSE). You can choose which sides are drawn, set a separate gap on each side, and select single, double, ASCII, eraser, or user-defined line characters.

The archive contains:

- `BOXIT.S` — SAL source code.
- `BOXIT.MAC` — precompiled historical macro.
- `BOXIT.DOC` — original documentation.
- `FILE_ID.DIZ` — short release description.

## Installation

1. Extract `boxit11.zip` to a working directory.
2. Copy `BOXIT.S` to your TSE macro/source directory if desired.
3. Compile `BOXIT.S` with the SAL compiler used by your TSE installation. For example, from a command prompt:

   ```text
   sc32 BOXIT.S
   ```

4. Start TSE and execute or load the compiled `BOXIT.MAC` macro.
5. To load BoxIt automatically whenever TSE starts, add `BOXIT` to TSE's macro AutoLoad List.

The supplied `BOXIT.MAC` is an old precompiled version. Recompiling `BOXIT.S` is recommended when using a newer TSE release.

## How to draw a box

1. Open a text file in TSE.
2. Mark the text area with a **column block**. BoxIt does not support ordinary line or stream blocks.
3. Keep the cursor somewhere inside the marked block.
4. Press `Alt+F12` to open the BoxIt menu.
5. Configure the side toggles, gaps, and line type.
6. Select **BoxIt!** from the menu, or press `F12`, to draw the box.

The current settings remain active, so another marked column block can be boxed immediately with `F12`.

## Main options

### Side Toggles

Enable or disable the top, bottom, left, and right sides individually. The Global option can turn all sides on or off, or invert all current side settings.

### Gap Settings

Set the space between the marked block and each side of the box. A global gap sets all four sides together; individual settings override the top, bottom, left, or right gap.

### Line Type

Available styles include:

- Single
- Double Top
- Double Side
- Double Both
- ASCII (`+`, `-`, and `|`)
- Eraser
- User-defined character

## Keyboard reference

| Key | Action |
|---|---|
| `Alt+F12` | Open the BoxIt menu bar |
| `F12` | Draw the box using the current settings |
| `Ctrl+G`, then `G` | Set the global gap |
| `Ctrl+G`, then `T` | Set the top gap |
| `Ctrl+G`, then `B` | Set the bottom gap |
| `Ctrl+G`, then `L` | Set the left gap |
| `Ctrl+G`, then `R` | Set the right gap |
| `Ctrl+S`, then `G` | Change the global side setting |
| `Ctrl+S`, then `T` | Toggle the top side |
| `Ctrl+S`, then `B` | Toggle the bottom side |
| `Ctrl+S`, then `L` | Toggle the left side |
| `Ctrl+S`, then `R` | Toggle the right side |

If these keys conflict with existing TSE assignments, edit the `keydef` section near the end of `BOXIT.S` and recompile it.

## Erasing a box

1. Mark the existing box as a column block.
2. Place the cursor inside the marked block.
3. Open the BoxIt menu with `Alt+F12`.
4. Select the **Eraser** line type.
5. Set the global gap to `0`.
6. Turn all side toggles on.
7. Press `F12` or select **BoxIt!**.

## Troubleshooting

### No Column Block In File

Create a column block in the current file. A line or stream block is not accepted.

### Cursor Not In Block

Move the cursor inside the marked column block and run BoxIt again.

### Cannot Insert Box At or Before Beginning of Line

The selected left edge and left gap would place the box before column 1. Move the block farther to the right or reduce the left gap.

### A shortcut does not work

Another macro or TSE command may already use that key. Change the bindings in the `keydef` section of `BOXIT.S`, then recompile and reload the macro.

## Version history

| README version | Date | Changes |
|---|---|---|
| 1.0.0.0.0 | 2026-08-31 | Initial Markdown description, installation instructions, usage guide, keyboard reference, and troubleshooting information for BoxIt 0.11. |

Future README revisions should increment the final component: `1.0.0.0.1`, `1.0.0.0.2`, and so on.
