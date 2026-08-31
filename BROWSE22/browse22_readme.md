# BROWSE v2.2 for The SemWare Editor

**README version:** 1.0.0.0.0  
**BROWSE release:** 2.2 (April 4, 1997)  
**Original author:** David Daniel Anderson  
**License:** Public Domain

## Description

BROWSE is a TSE SAL macro that turns The SemWare Editor (TSE) into a read-only text-file browser modeled after Vern Buerg's **LIST Plus**. It is intended for quickly viewing and searching files without accidentally editing them. You can switch from BROWSE mode to normal TSE editing mode immediately.

The supplied release was written for TSE Pro 2.5 and updated for the 32-bit TSE Pro 2.6. Because it is an older macro, minor compatibility changes may be required when compiling it with a much newer SAL compiler.

## Files in `browse22.zip`

| File | Purpose |
|---|---|
| `BROWSE.S` | Main TSE SAL source code |
| `BROWSE.INI` | Runtime configuration settings |
| `BROWSE.KEY` | Key definitions included during compilation |
| `BROWSE.HLP` | Online help included during compilation |
| `BROWSE.DOC` | Original documentation and installation notes |
| `BROWSE.SI` | Optional UI include that prompts before entering BROWSE mode |
| `FILE_ID.DIZ` | Short package description |

## Installation

1. Extract `browse22.zip`.
2. Copy these files to your TSE macro directory:

   - `BROWSE.S`
   - `BROWSE.INI`
   - `BROWSE.KEY`
   - `BROWSE.HLP`

3. Compile `BROWSE.S` with the SAL compiler appropriate for your TSE installation. For a current 32-bit TSE installation, this will normally be:

   ```text
   sc32 browse.s
   ```

   Older TSE releases may use:

   ```text
   sc browse.s
   ```

4. Confirm that compilation creates `BROWSE.MAC`.
5. Keep `BROWSE.MAC` and `BROWSE.INI` together in a directory searched by TSE. The source, key, and help files are only needed again if you want to recompile the macro.

If upgrading from an earlier BROWSE version, preserve your old `BROWSE.INI`, compare its values with the new file, and transfer your preferred settings without changing the setting names.

## How to run BROWSE

From a Windows command prompt, substitute the actual name or full path of your TSE executable where necessary.

Start TSE directly in BROWSE mode:

```text
g32.exe -ebrowse
```

Open a particular file in BROWSE mode:

```text
g32.exe filename.txt -ebrowse
```

If your TSE executable is named `e32.exe` or `e.exe`, use that filename instead. The original documentation gives these older examples:

```text
e -eBROWSE
e filename -eBROWSE
```

You can also run the macro from inside TSE with its macro-execution command, or bind it to a key in your TSE UI configuration:

```sal
<Ctrl b> ExecMacro("browse")
```

After changing a UI source file, rebuild the TSE UI in the normal way for your installation.

## Optional confirmation prompt

To request confirmation before switching into BROWSE mode:

1. Copy `BROWSE.SI` to the TSE `UI` directory.
2. Add this line before the key assignments in your `.UI` file:

   ```sal
   #include ["browse.si"]
   ```

3. Edit the key assignment in `BROWSE.SI` if desired.
4. Recompile/burn the UI configuration into TSE using the procedure appropriate for your version.

## Essential keys

Press `F1` while BROWSE is active to display the complete built-in key reference.

| Key | Action |
|---|---|
| `F1` | Display BROWSE help |
| Arrow keys | Scroll through the file |
| `Home` / `End` | Go to the beginning/end of the file |
| `PgUp` / `PgDn` | Move one page up/down |
| `F` or `\` | Find text forward, ignoring case |
| `S` or `/` | Find exact-case text forward |
| `F3` / `F9` | Repeat find forward/backward |
| `G` or `Alt+F` | Prompt for another file |
| `Ctrl+PgUp` / `Ctrl+PgDn` | Move to the previous/next loaded file |
| `W` | Toggle wrapping of long lines |
| `Alt+H` | Toggle text/hex display |
| `Tab` | Set the tab interval |
| `Ctrl+O` | Open BROWSE configuration |
| `E` | Leave BROWSE mode and edit the loaded file(s) |
| `Esc` | Exit to DOS or switch to editing, depending on the state |
| `X` | Exit and clear the screen |
| `F10` | Exit while preserving the screen |

## Configuration

Press `Ctrl+O` in BROWSE mode to change options interactively. Settings include the ruler and status displays, tab width, tab expansion, scroll amount and delay, find-row position, beep behavior, text or hex display, colors, shell access, and modem port.

The settings are stored in `BROWSE.INI`. You may edit this file manually, but:

- Do not rename any setting.
- Keep only the setting name, equals sign, and value on a setting line.
- Put comments on separate lines.
- Use `1` for true and `0` for false.

## Troubleshooting

### TSE cannot find BROWSE

Verify that `BROWSE.MAC` is in the TSE macro search path. Keep `BROWSE.INI` in the same macro directory or another directory searched by TSE.

### Compilation reports missing help or key definitions

Place `BROWSE.KEY` and `BROWSE.HLP` beside `BROWSE.S` before compiling. They are included by the source during compilation.

### The macro compiles differently with a modern TSE release

BROWSE v2.2 dates from 1997. Consult the compiler's exact error lines and update obsolete SAL syntax only as needed. Keep an unchanged copy of the original ZIP for reference.

### Settings are not retained

Check that `BROWSE.INI` exists in the macro search path and is writable. Press `Ctrl+O` to inspect the active options; `Alt+C` writes/clones the current options and toggles.

## Version history for this README

| Version | Changes |
|---|---|
| 1.0.0.0.0 | Initial README with description, installation, operation, key reference, configuration, and troubleshooting information. |

Future README revisions should increment only the final component: `1.0.0.0.1`, `1.0.0.0.2`, and so on.
