# NAMCLDOC

Version: 1.0.0.0.0  
Created: 2026-09-23 19:38:40 UTC  
Documentation for the TSE Named Clipboard System (NameClip), version 4.7 by David Marcus.

## Contents

- `NAMECLIP.DOC`: original 1993 NameClip documentation, including menus, key assignments, settings, and installation notes.
- `FILE_ID.DIZ`: original archive description.
- `namcldoc.ini`: requested configuration template. No program in this package reads it.
- `namcldoc_readme.md`: this guide.

## What it does

NameClip adds named clipboards to The SemWare Editor. Its documented features include copy, cut, and paste with named clipboards; append and overwrite operations; clipboard viewing, editing, renaming, deletion, searching, saving, and loading. The documentation describes optional automatic naming, picklists, and clipboard backups.

This archive contains **documentation only**. `NAMECLIP.S`, the SAL macro described by `NAMECLIP.DOC`, was not included in the supplied `namcldoc.zip`. A copy of `NAMECLIP.S` is required to compile or run NameClip. `namcldoc.ini` is a template and has no effect until SAL source code is modified to read it.

## Install and run when NAMECLIP.S is available

1. Obtain `NAMECLIP.S` separately and place it where the TSE configuration/interface sources can include it.
2. Review `NAMECLIP.DOC` for the original installation procedure and compatibility with your TSE version. It instructs you to put `#include ['nameclip.s']` before your menus in your TSE configuration source and to remove conflicting key definitions and any existing `ClipBoardMenu` definition.
3. Ensure the main menu includes `"&Clipboard", clipboardmenu()`; adjust the documented key assignments if they clash with yours.
4. The original documentation says to remove `main()` from `NAMECLIP.S` for inclusion in the user interface and to rebind the editor using the compiler's `-b` switch. Back up your configuration before rebinding.
5. Once installed, use **F11** for the main clipboard menu, **Ctrl+F11** for other functions, **Shift+F11** for settings, or **Alt+F11** for global actions. The original documentation also assigns numeric keypad Grey +, -, and * keys to copy, cut, and paste variants; see `NAMECLIP.DOC` for the complete mapping.

For a standalone macro build, the original documentation says its `main()` is useful when compiling and running `NAMECLIP.S` externally, but that source and its implementation are unavailable here. No startup `Warn()` can be added or verified without the `.s` file. Supply `NAMECLIP.S` to implement the requested informative startup message and read `silent` from the INI file.

## Configuration template

`namcldoc.ini` contains `silent=false`. The intended behavior after source integration is: `false` displays the informative startup `Warn()` box; `true` suppresses it. This setting currently does not control NameClip because this archive has no SAL source. The original NameClip settings are documented in `NAMECLIP.DOC` and are separate from this INI template.

## Attribution

The original NameClip documentation credits David Marcus (1993), version 4.7, and describes conditions for noncommercial distribution: preserve author credit and attribute changes. This README and INI template were added for package version 1.0.0.0.0; the original files are preserved unchanged.
