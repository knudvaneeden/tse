# MSWHEEL

Version: 1.0.0.0.0  
Date and time: 2026-09-23 10:11 UTC

MSWHEEL adds mouse wheel support to TSE/32. The original macro and DLL are by Chris Antos. Loading the macro starts wheel handling; running it with `-menu` opens a configuration menu for Ctrl, Alt, Shift and Grey cursor key modifiers.

## Files

- `mswheel.s`: SAL source, modified to show a startup help message when run directly.
- `mswheel.dll`: original wheel support DLL.
- `mswheel.mac`: original precompiled macro, supplied for reference. **Recompile the modified source** for the message and INI option to take effect.
- `mswheel.ini`: controls the help message.
- `read.me` and `file_id.diz`: original package information.

## Install and run

1. Place `mswheel.s` and `mswheel.dll` together where TSE can find the macro and DLL. The original installation instructions put the compiled `.mac` in `tse32\mac` and the DLL in `tse32`.
2. Compile `mswheel.s` with the SAL compiler for your installed TSE/32 version, for example `sc32 mswheel.s`. Use the newly compiled `mswheel.mac`; the included original binary predates these changes and may be incompatible with newer TSE versions.
3. Place `mswheel.ini` in TSE's **startup directory** (the directory returned by `Query(StartUpPath)`). This is where the modified macro reads it.
4. Load `mswheel.mac` in TSE to activate wheel support. Optionally add it through **Macro > AutoLoadList** to load it each time TSE starts.
5. From TSE's **Execute macro** prompt, run `mswheel -menu` to configure the key modifiers. Run `mswheel` without parameters to see the help message.

## Configuration

In `mswheel.ini`, under `[MSWHEEL]`, set `silent=false` (the default) to display the `Warn()` message when the macro is run without parameters. Set `silent=true` to suppress that message. The setting does not disable mouse wheel support and does not suppress initialization errors when opening the configuration menu.

The modifier settings selected in the menu are stored by the original macro in TSE's profile (`tse.ini`), in section `[TSEWheel]`: `Alt`, `Ctrl`, `Shift`, and `Grey`. Their original defaults are Alt off, Ctrl on, Shift off, Grey off. The menu writes these settings and applies them immediately.

## Notes

- The wheel support DLL is a 32-bit Windows component. Recompile source for your TSE release; this package does not include a newly compiled `.mac`.
- Mouse wheel handling starts when the macro loads (`WhenLoaded()`), whether or not the direct-run help message appears.
- A macro using `Dos()` or `Shell()` can temporarily suspend wheel handling through `MSWHEEL_DisableWheel()` and restore it through `MSWHEEL_EnableWheel()`.
