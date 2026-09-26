# OS2CMD

**Version:** 1.0.0.0.1  
**Prepared:** 26 September 2026, 13:20 CEST  
**Original author:** Carlo Hogeveen (September 1996)

## Changes in 1.0.0.0.1

Corrected the SAL `GetText` call in `Main()` to supply its start position and length.

## Description

OS2CMD runs an OS/2 command from TSE Pro and opens its captured screen output in a TSE buffer. The original macro was tested with TSE Pro 2.5 under OS/2 Warp. It requires Henk Kelder's `hstart.exe` (supplied inside `HSTART05.ZIP`); that utility requires OS/2 2.1 or newer. This package preserves the original OS/2 command logic. It does **not** run OS/2 commands on Windows TSE.

`Ctrl+1` starts a foreground task; `Ctrl+2` starts a background task. The macro writes temporary `C:\os2taskN.cmd`, `.log`, and `.rdy` files, using slots 1 through 9. It reads `C:\CONFIG.SYS` to restore `SET` statements before running the command. Review this disk activity and the OS/2 paths in `OS2CMD.S` before use. When all nine task slots are occupied, the original code removes existing task files.

## Files

- `OS2CMD.S`: SAL source, with an added `Main()` introduction and INI setting.
- `os2cmd.ini`: startup message setting.
- `OS2CMD.MAC`: original 1996 compiled macro; recompile the modified source to get the new `Main()` behavior.
- `HSTART05.ZIP`: original bundled OS/2 helper archive.
- `FILE_ID.DIZ`: original package description.

## Configuration

Keep `os2cmd.ini` in TSE's current working directory:

```ini
[Options]
silent=false
```

`silent=false` displays the introductory `Warn()` box when you run the compiled macro directly. Set `silent=true` to suppress it. The key must be written without spaces around `=`; capitalization is ignored. The key bindings run the original command procedure directly, so this setting affects the `Main()` introduction only. If the INI file is missing, the default is `false`.

## Installation and use on OS/2

1. Extract `HSTART05.ZIP` and put `hstart.exe` in a directory on the OS/2 command search path, as described by its own documentation.
2. Place `OS2CMD.S` and `os2cmd.ini` where you will use them. Start TSE with that directory as its current working directory if you want the INI setting read.
3. Compile the modified source with the SAL compiler appropriate for your OS/2 TSE installation. Load the newly compiled macro; the supplied `OS2CMD.MAC` predates these changes.
4. Run the macro directly to see the introduction. Press `Ctrl+1` and enter a foreground OS/2 command, or press `Ctrl+2` and enter a background OS/2 command.
5. If a background command finishes by itself, its captured output opens in TSE. For a command that keeps running, switch to its OS/2 session and back manually. In the hstart screen, press any key to stop waiting for captured output. Foreground tasks do not automatically return to TSE.

## Compatibility and cautions

This is historical OS/2 code. It requires `C:\CONFIG.SYS` and `hstart.exe`; its fixed `C:` paths and OS/2 session behavior are unsuitable for Win32 TSE. The original `.MAC` may also be incompatible with newer SAL versions. The new source has not been compiled or executed under OS/2 here.
