# OPENTYPE

Version: 1.0.0.0.0  
Date and time: 26 September 2026, 12:42 CEST (Europe/Amsterdam)  
Original macro: OpenType 1.3 by Carlo Hogeveen (4 September 2005)  
Session: Create OPENTYPE Readme

## Description

OpenType customizes the file type list in TSE's Windows **File Open** dialog using extensions from files previously opened in TSE. The list can follow recent use or frequency. It can set a fixed initial file type and optionally group extensions associated with the same Windows program. The `*` entry keeps all file types available.

It works when TSE's **Use the Windows Common File Dialogs** (`UseCommonDialogs`) option is ON. It does not change the character-mode File Open dialog. The original source states compatibility with TSE 4.4 and later on Windows.

## Files

- `OpenType.s`: SAL source with a startup information message and INI control.
- `opentype.ini`: optional startup message setting.
- `File_Id.diz`: description supplied with the original macro.

## Install and run

1. Extract the ZIP. Keep `opentype.ini` in TSE's **current working directory** when running the macro. You can copy `OpenType.s` to a directory from which you compile SAL macros.
2. Compile `OpenType.s` with the SAL compiler for your TSE installation, for example `sc32 OpenType.s` on Windows. This creates `OpenType.mac`.
3. In TSE, execute `OpenType.mac` once to open its configuration. With the default `silent=false`, an introductory `Warn()` box appears first; dismiss it to continue to configuration.
4. If prompted, enable **Use the Windows Common File Dialogs**. Choose whether to leave the file type list alone, order it by recent use, or order it by frequency. If using the enhanced list, select an initial file type and whether to group associated types.
5. The configuration adds OpenType to TSE's autoload macros when the list choice is made. Open files normally to build the history used for the type list. Re-execute the macro whenever you want to change its settings.

## Startup message setting

In `opentype.ini`, set:

```ini
[OpenType]
silent=false
```

`silent=false` (the default, including when the INI file is absent) displays the introductory `Warn()` box on direct execution. `silent=true` skips that box and proceeds to configuration. Use the exact lowercase spelling shown, with no spaces around `=`. The setting controls only this new introductory message; existing warnings and configuration prompts still appear when applicable.

The macro's original list, grouping, and initial type choices continue to use its existing TSE profile settings.
