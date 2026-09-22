# MFFND50 Multi-File Find/Replace

Version: 1.0.0.0.1  
Date: 2026-09-22  
Time: 11:35 UTC

## Description

MFFND50 is a classic multi-file find-and-replace package for The SemWare Editor (TSE). It searches the files currently loaded in the editor and supports normal searches, replacements, regular expressions, incremental searching, current-word searches, function searches, hit navigation, and several line-oriented operations.

The package is based on MFFind 5.0 by E. Ray Asbury, Jr. The supplied source was originally intended for TSE 2.00. `ENGLISH.ZIP` and `GERMAN.ZIP` contain the six original precompiled macro modules for their respective languages.

## Package contents

- `MFFIND.S` - main TSE SAL source, now including `Main()` and the configurable startup message.
- `MFFIND.INI` - original MFFind configuration file used by the program.
- `mffnd50.ini` - startup-message configuration added in this package.
- `mffnd50_readme.md` - this documentation.
- `ENGLISH.ZIP` - English precompiled `MFFIND.MAC` through `MFFIND6.MAC` files.
- `GERMAN.ZIP` - German precompiled `MFFIND.MAC` through `MFFIND6.MAC` files.

## Startup-message configuration

Edit `mffnd50.ini` and set:

```ini
[Startup]
silent=false
```

- `silent=false` shows an informative `Warn()` box when `MFFIND.S` is run. This is the default.
- `silent=true` suppresses that startup `Warn()` box.

Keep `mffnd50.ini` in the directory from which TSE can find the macro and its configuration files.

## Installation

1. Extract `mffnd501.0.0.0.1.zip` to a working directory.
2. Choose either `ENGLISH.ZIP` or `GERMAN.ZIP`.
3. Extract the selected language ZIP so that `MFFIND.MAC`, `MFFIND2.MAC`, `MFFIND3.MAC`, `MFFIND4.MAC`, `MFFIND5.MAC`, and `MFFIND6.MAC` are together.
4. Put those `.MAC` files, `MFFIND.INI`, and `mffnd50.ini` in a directory searched by TSE for macros.
5. To use the modified source version, compile `MFFIND.S` with the TSE SAL compiler and place the resulting `MFFIND.MAC` beside `MFFIND2.MAC` through `MFFIND6.MAC`.
6. Back up existing files before replacing an older MFFind installation.

## Compiling the modified source

From a command prompt in the extracted directory, run the compiler appropriate for your TSE installation. For TSE 4.50 this is commonly:

```text
sc32 MFFIND.S
```

The other five modules are distributed only as compiled `.MAC` files, so retain `MFFIND2.MAC` through `MFFIND6.MAC` from the chosen language archive.

## How to run

1. Start TSE.
2. Load the files that you want to search or modify.
3. Load or execute `MFFIND.MAC`.
4. When `silent=false`, acknowledge the startup information box.
5. The MFFind menu opens. Choose the required search, replace, line, hit-list, configuration, or help command.

The original default menu sequence is `<Alt v>` followed by one of these keys:

- `f` - find a string.
- `w` - find the current word.
- `c` - find functions.
- `l` - find lines.
- `r` - replace.
- `d` - delete lines.
- `i` - incremental search.
- `n` - next hit.
- `p` - previous hit.
- `a` - show the hit list again.
- `u` - configure MFFind.
- `h` - show help.
- `v` - open the main MFFind menu.

`<AltShift 1>` selects the previous hit and `<AltShift 2>` selects the next hit.

## Important notes

- MFFind works on files loaded in the TSE file ring. Save and back up important files before using replace or delete operations.
- `MFFIND.INI` is the original functional configuration. Do not replace it with `mffnd50.ini`; both files serve different purposes.
- All six MFFind macro modules must be available. The main macro reports which companion module could not be loaded if one is missing.
- The package is historical software. Compile and test the modified source with your installed TSE SAL compiler before relying on it for production edits.

## Version history

### 1.0.0.0.1 - 2026-09-22 11:35 UTC

- Added the missing `FORWARD MENU mnMFFind()` declaration.
- Fixed compiler error 2335, `Undefined symbol 'mnMFFind' encountered`, caused by `Main()` calling the menu before its definition.

### 1.0.0.0.0 - 2026-09-22 11:25 UTC

- Added this Markdown description, help, installation, and run guide.
- Added `mffnd50.ini` with `silent=false` as the default.
- Added `Main()` to `MFFIND.S`.
- Added a configurable informative startup `Warn()` box.
- Preserved the original English and German compiled macro archives.
