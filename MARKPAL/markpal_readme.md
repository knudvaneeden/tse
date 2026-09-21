# MARKPAL

**Version:** 1.0.0.0.1  
**Date and time:** 2026-09-21 17:37:31 CEST  
**Original author:** Jean Heroux

## Description

MARKPAL is a TSE SAL macro for managing TSE bookmarks as a ring. It can place the next available lowercase bookmark automatically, move to the next or previous bookmark, and show all existing lowercase bookmarks in a selection list together with the text of their target lines.

MARKPAL uses bookmark letters `a` through `z`. Navigation wraps around at the beginning and end of that range.

## Included files

- `MARKPAL.S` - TSE SAL source code.
- `markpal.ini` - configuration information for this package.
- `markpal_readme.md` - description, help, installation, and usage instructions.

## Requirements

- The SemWare Editor (TSE) with its SAL compiler.
- A TSE version that supports the SAL commands used by the source.

## Default keys

| Key | Action |
|---|---|
| `<F9>` | Go to the next existing lowercase bookmark. |
| `<Shift F9>` | Go to the previous existing lowercase bookmark. |
| `<Ctrl F9>` | Place the first available lowercase bookmark. |
| `<Alt F9>` | Display the bookmark list and go to the selected bookmark. |
| `<Ctrl 0>` | Run TSE's standard `PlaceMark()` command. |
| `<Alt 0>` | Run TSE's standard `GotoMark()` command. |

The key assignments are located at the end of `MARKPAL.S` and can be changed before compilation.

## Installation and compilation

1. Extract all files from `markpal1.0.0.0.1.zip` into a directory.
2. Copy `MARKPAL.S` to the directory from which you compile or maintain TSE macros.
3. If desired, edit the key definitions at the end of `MARKPAL.S`.
4. Compile the source with the TSE SAL compiler, for example:

   ```text
   sc32 MARKPAL.S
   ```

5. Confirm that the compiler creates `MARKPAL.MAC` without errors.
6. Load `MARKPAL.MAC` in TSE, or add it to TSE's AutoLoad list if it should be available in every editing session.

## How to run it

### Run MARKPAL directly

Run the compiled `MARKPAL.MAC` from TSE's macro execution facility. The new `Main()` procedure displays the version, LLM name, confirmation that MARKPAL is loaded, and a summary of the available keys.

### Place an automatic bookmark

1. Put the cursor at the desired position.
2. Press `<Ctrl F9>`.
3. MARKPAL searches from `a` through `z`, places the first unused bookmark, and reports its letter on the message line.

If all 26 lowercase bookmark letters are already in use, MARKPAL displays `Too many marks`.

### Move through bookmarks

- Press `<F9>` to move to the next bookmark.
- Press `<Shift F9>` to move to the previous bookmark.

The search wraps between `a` and `z`. If no lowercase bookmarks exist, MARKPAL displays `No marks`.

### Select a bookmark from the list

1. Press `<Alt F9>`.
2. MARKPAL displays every existing lowercase bookmark and the text of the corresponding line.
3. Move to the required entry.
4. Press `<Enter>` to go to it, or cancel the list to remain at the original position.

For a useful index, place bookmarks on lines containing recognizable headings, labels, or other descriptive text.

### Use TSE's standard bookmark prompts

- Press `<Ctrl 0>` to invoke `PlaceMark()` and specify a mark using TSE's normal interface.
- Press `<Alt 0>` to invoke `GotoMark()` and specify a mark using TSE's normal interface.

## Configuration file

`markpal.ini` is included for package consistency and future configuration. Version 1.0.0.0.1 does not read settings from the INI file; its active key assignments remain in `MARKPAL.S` and must be changed before compiling.

## Notes

- MARKPAL manages and lists lowercase bookmarks `a` through `z` only.
- Bookmark information is maintained by TSE. The original source mentions the separate FILEPAL macro as a possible way to save bookmarks to disk; FILEPAL is not included in this package.
- The bookmark list uses up to 72 characters of text from each bookmarked line.
- The original source contains a French no-bookmarks message, `Pas de marque`, in the list function.

## Version history

### 1.0.0.0.1 - 2026-09-21

- Added `Main()` so running the macro displays its version and key summary.
- Added the LLM name to the displayed information.

### 1.0.0.0.0 - 2026-09-21

- Added this Markdown documentation.
- Added `markpal.ini`.
- Packaged the original `MARKPAL.S` source with the documentation and INI file.
