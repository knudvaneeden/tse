# MENUCOLR

Version: 1.0.0.0.2  
Updated: 2026-09-22 13:02:00 CEST  
Original author: Carlo Hogeveen

## Description

MENUCOLR is a TSE SAL macro for the graphical Windows version of The SemWare Editor Professional. It changes the two color-table entries used as TSE menu backgrounds so that they use the corresponding Windows system colors:

- Normal menu background: the Windows menu color.
- Selected menu item background: the Windows highlight color.

This can make TSE menus fit the active Windows color scheme more closely. The result depends on the combination of the Windows and TSE color settings.

MENUCOLR does not change a menu background color when that color-table entry is also used as TSE's normal text background. This safeguard helps avoid making the editing area unreadable. Because TSE has a limited number of shared color-table entries, changing a menu color can still affect other screen elements that use the same entry.

## Requirements

- The graphical Windows version of TSE Pro 4.0 or later.
- The TSE SAL compiler suitable for the installed TSE version.

In a supported console-mode TSE version, the macro does not change the colors. On TSE versions older than 4.0, it reports that TSE 4.0 or later is required.

## Package contents

- `MenuColr.s` - TSE SAL source code.
- `menucolr.ini` - configuration file.
- `menucolr_readme.md` - this documentation.
- `File_Id.diz` - original short package description.

## Configuration

Keep `menucolr.ini` in the same directory as the compiled MENUCOLR macro. Its setting is:

```ini
silent=false
```

- `silent=false` shows an informative `Warn()` box when the macro starts.
- `silent=true` suppresses that informative box.

The default is `silent=false`. The startup path calls `Main()` to display the informational message. This setting does not disable the menu-color update performed when the macro is loaded.

## Compile and run

1. Extract all package files into one directory.
2. Place `MenuColr.s` and `menucolr.ini` in the TSE macro directory, or another directory from which TSE loads macros.
3. Compile the source with the TSE SAL compiler, for example:

   ```text
   sc32 MenuColr.s
   ```

4. Confirm that `MenuColr.mac` was created without compiler errors.
5. Keep `menucolr.ini` in the same directory as `MenuColr.mac`.
6. Load or execute `MenuColr.mac` in TSE. When loaded in graphical TSE, it applies the Windows menu colors and refreshes the display.
7. To apply the colors automatically at every TSE start, add `MenuColr` to TSE's Macro AutoLoad List.

When the macro starts and `silent=false`, it displays a short explanation of what it does. Set `silent=true` to start it without that informational box.

## Uninstall

Remove `MenuColr` from TSE's Macro AutoLoad List, then remove its files if they are no longer needed. Restart TSE or restore the desired TSE color configuration to undo the active color-table changes.

## Notes

- The macro obtains the INI path from its own macro location; no fixed installation path is used.
- The source retains its original support logic for TSE 4.0 and newer GUI versions.
- TSE may share one color-table entry among several interface attributes, so a change intended for menus can also affect another interface element.

## Version history

### 1.0.0.0.2 - 2026-09-22 13:02:00 CEST

- Changed `WhenLoaded()` to call `Main()`, so the informative message appears when MENUCOLR starts.
- Retained `silent=true` as the way to suppress the startup message.

### 1.0.0.0.1 - 2026-09-22 12:56:00 CEST

- Corrected the Boolean helper declaration from unsupported `integer func` syntax to the TSE SAL-compatible `integer proc` form.

### 1.0.0.0.0 - 2026-09-22 12:44:45 CEST

- Added this Markdown description, help, requirements, configuration, and run instructions.
- Added `menucolr.ini` with the default `silent=false` setting.
- Added an informative `Main()` message that can be disabled with `silent=true`.
- Preserved the original MENUCOLR color-changing behavior and source history.
