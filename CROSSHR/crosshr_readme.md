# Crosshair for The SemWare Editor (TSE)

**README version:** 1.0.0.0.0  
**Date and time:** 2026-09-04 13:24:50 UTC  
**Macro file:** `crosshair.s`  
**Original macro version:** Crosshair 1.0  
**Original author:** Michael Durland  
**Original date:** May 20, 2004  
**Designed for:** TSE Pro 4.0 or later

## Description

Crosshair is a TSE SAL macro that displays a movable horizontal and vertical
crosshair over the editor screen. It helps you visually align text vertically
and horizontally, including text displayed in different open TSE windows.

The crosshair begins at the current cursor position. Its line segments are
drawn only over blank screen positions, so visible text is not covered. The
status bar shows the corresponding line and column while the crosshair moves.

## Archive contents

- `crosshair.s` — TSE SAL source code for the macro.
- `file_id.diz` — short description from the original archive.

## Controls

| Key | Action |
|---|---|
| `Cursor Up` | Move the crosshair up one screen row. |
| `Cursor Down` | Move the crosshair down one screen row. |
| `Cursor Left` | Move the crosshair left one screen column. |
| `Cursor Right` | Move the crosshair right one screen column. |
| `Home` | Move the crosshair to the left screen edge. |
| `End` | Move the crosshair to the right screen edge. |
| `PgUp` | Move the crosshair to the top screen edge. |
| `PgDn` | Move the crosshair to the bottom screen edge. |
| `Enter` | Close the crosshair and move the editor cursor to its location. |
| Any other key | Close the crosshair and restore the original cursor position. |

The key that closes the crosshair is consumed by the macro and is not passed
on as an editor command.

## Requirements

- The SemWare Editor Professional (TSE Pro), version 4.0 or later.
- The TSE SAL compiler, such as `sc32.exe`.
- A text-mode TSE display compatible with the screen drawing functions used by
  the macro.

## How to compile

1. Extract `crosshr.zip` to a directory of your choice.
2. Open a command prompt in the directory containing `crosshair.s`.
3. Compile the source with:

   ```bat
   sc32 crosshair.s
   ```

4. Check that compilation completes without errors. The compiler creates the
   loadable TSE macro file, normally `crosshair.mac`.

If `sc32` is not in the system `PATH`, invoke it with its complete path or copy
the source to the directory from which you normally compile TSE macros.

## How to install

1. Copy the compiled `crosshair.mac` file to a directory from which TSE loads
   macros.
2. Start or restart TSE if necessary.
3. Run the macro by entering its name through TSE's macro execution command:

   ```text
   crosshair
   ```

The exact macro directory and execution command can depend on your TSE setup.

## Recommended hotkey setup

The macro is most convenient when assigned to a free key combination in your
personal TSE configuration or autoload macro. Use `crosshair` as the macro or
command name, following the key-assignment method used by your TSE version.

Choose a key combination that does not conflict with an existing editor
command. Recompile and reload the relevant configuration macro after changing
the key definition.

## How to use

1. Place the normal editor cursor at the desired starting position.
2. Run `crosshair` or press its assigned hotkey.
3. Move the crosshair with the cursor keys, or jump to a screen edge with
   `Home`, `End`, `PgUp`, or `PgDn`.
4. Watch the status bar for the calculated line and column.
5. Press `Enter` to place the editor cursor at the crosshair location.
6. Press any other key to cancel and return the cursor to its original
   position.

## Color customization

The default crosshair color is defined in `crosshair.s` as:

```sal
integer cross_color = Color(bright black on blue)
```

Several alternative color definitions are included as commented examples in
the source. To change the color, comment out the current definition, enable or
write one preferred `cross_color` definition, and compile the macro again.

## Notes and limitations

- The guide is a temporary screen overlay; it does not change the file text.
- Crosshair segments appear only in blank screen cells. Existing characters
  remain visible and can make the guide look interrupted.
- The source estimates the usable top and bottom screen rows. Customized TSE
  screen layouts or status areas may require adjustment of `edge_top` and
  `edge_bottom` in the source.
- The macro temporarily hides the normal cursor and restores its previous
  visibility state when it closes.
- Screen positions are converted back to a buffer line and column relative to
  the cursor's original location.

## Troubleshooting

### The compiler cannot find `crosshair.s`

Change to the directory containing the extracted source, or supply its full
path to `sc32`.

### TSE cannot run the macro

Confirm that `crosshair.mac` was created successfully and is stored in a macro
directory recognized by your TSE installation.

### The crosshair overlaps a customized screen area

Edit the `edge_top`, `edge_bottom`, `edge_left`, or `edge_right` calculations
in `crosshair.s` to match your TSE layout, then recompile it.

### The crosshair is difficult to see

Select a contrasting `cross_color` value in the source and recompile the
macro.

## Version numbering

This README uses a five-part version number. Begin with `1.0.0.0.0` and
increase the final component for each revision:

- `1.0.0.0.0` — initial README release.
- `1.0.0.0.1` — first README revision.
- `1.0.0.0.2` — second README revision.
- Continue with `1.0.0.0.3`, `1.0.0.0.4`, and so on.

## License and original permission

The source header states that the macro may be used, modified, and distributed
freely. Preserve the original author information and source comments when
redistributing modified versions.

## Credits

- Crosshair macro: Michael Durland.
- Portions of the original macro were based on `ruler.s` by Glenn Alcott.

