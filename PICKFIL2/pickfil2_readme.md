# PICKFIL2

Version: 1.0.0.0.0  
Date and time: 2026-09-26 18:11:56 CEST

## Description

PICKFIL2 is a TSE Pro SAL file picker by Carlo Hogeveen, based largely on an example by Sammy Mitchell. It displays directory and file names without the date, time, size, and attribute columns of TSE's standard file picker. Typing text in its list jumps to the first directory or file **containing** that text. The original source states compatibility with TSE Pro 3.0 and newer.

## Install and run

1. Extract `PickFil2.s`, `pickfil2.ini`, and this README to the same working directory. Keep `File_Id.diz` if desired.
2. Compile the source with TSE's SAL compiler: `sc32 PickFil2.s` (for Win32 TSE). This produces `PickFil2.mac`.
3. From TSE, run `ExecMacro("PickFil2")`, or assign a key in your `.ui` file, for example `<Ctrl o> ExecMacro("PickFil2")`. Ensure TSE can locate the compiled macro.
4. Select a directory to enter it, or select a file and press **Enter** to open it. Press **Alt+F10** to select another drive; press **Esc** to quit.

The original source includes a command line example with `-ePickFile`; use `ExecMacro("PickFil2")` or the key binding above to invoke this macro by its actual name.

## Configuration

`pickfil2.ini` contains `[Settings] silent=false`. When `silent=false`, `Main()` displays a startup `Warn()` box with brief controls. Set `silent=true` to hide this box. Put the INI file in TSE's current working directory when invoking the macro. If the setting is missing, it defaults to `false`. This setting affects the startup help box only.

## Notes

PICKFIL2 has fewer options than TSE's built-in PickFile, EditFile, and EditThisFile commands. The source has been updated for the requested startup message and INI setting; compilation and runtime behavior require checking in TSE.
