# DocMode for The SemWare Editor (TSE)

**README version:** 1.0.0.0.0  
**Date:** 2026-09-05  
**Time:** 13:24:11 UTC  
**Package:** `docmode.zip`

## Description

DocMode is a document-editing macro package for The SemWare Editor (TSE). It makes plain-text editing more compatible with the generic text format used by word processors.

The macro distinguishes soft, wrapped line endings from hard paragraph endings by inserting a visible carriage-return marker. Paragraph wrapping stops at these markers. A document can also be converted between:

- **Generic format:** each paragraph is stored as one long line.
- **DocMode format:** text is wrapped to TSE's current margins and hard paragraph endings are marked.

DocMode does not turn TSE into a full word processor and does not preserve proprietary word-processor formatting or print-layout information.

## Package contents

| File | Purpose |
| --- | --- |
| `DOCMODE.S` | Main DocMode SAL source code |
| `DOCMODE.MAC` | Precompiled TSE macro, ready to load |
| `DAUTOWRP.S` | AutoWrap implementation included by `DOCMODE.S` |
| `AUTOWRAP.S` | Alternative/general AutoWrap source and documentation |
| `FILE_ID.DIZ` | Short package description |

## Main features

- Wraps generic-text paragraphs to the current TSE margins.
- Marks hard paragraph endings with a special CR marker.
- Stops paragraph wrapping and AutoWrap at marked endings.
- Converts a complete DocMode file back to generic format before saving.
- Converts one paragraph at a time when special formatting must be retained.
- Searches for invalid text placed after a CR marker.
- Enables DocMode automatically for files with the `.ASC` extension.
- Provides a manual DocMode on/off toggle.
- Shows `D` on the status line while DocMode is active.
- Includes enhanced AutoWrap behavior and shows `W` on the status line when AutoWrap is active.

## Requirements

- The SemWare Editor (TSE) for DOS or a compatible TSE installation capable of loading the supplied macro.
- The TSE SAL compiler if you want to rebuild `DOCMODE.MAC` from the source files.
- All included source files should remain together while compiling.

## Installation using the supplied macro

1. Extract `docmode.zip` to a folder.
2. Copy `DOCMODE.MAC` to your TSE macro directory, or leave it in another directory from which TSE can load macros.
3. Start TSE.
4. Load or execute the `DOCMODE` macro using the normal macro-loading command for your TSE installation.
5. Open an `.ASC` file, or press `Ctrl+K`, then `D`, to enable DocMode manually.
6. Look for `D` at column 18 of the status line to confirm that DocMode is active.

## Compiling from source

Keep `DOCMODE.S` and `DAUTOWRP.S` in the same directory because `DOCMODE.S` contains this include directive:

```text
#include["dautowrp.s"]
```

From a command prompt in that directory, run:

```bat
sc32 DOCMODE.S
```

The compiler should create or update `DOCMODE.MAC`. Load the resulting macro in TSE.

If your compiler executable is not on `PATH`, invoke it with its complete path.

## How to use DocMode

### Convert a generic file to DocMode format

1. Open the generic plain-text file.
2. Set TSE's left and right margins as required.
3. Press `Ctrl+K`, then `A`.
4. DocMode wraps the text to the current margins and adds a CR marker at each hard paragraph ending.

### Edit a document

- Press `Enter` to create a normal new line and add a hard-ending CR marker when DocMode is active.
- Press `Alt+B` to wrap the current paragraph without wrapping beyond its CR marker.
- Do not place text after a CR marker on the same line.
- Press `Ctrl+K`, then `C`, to locate any marker followed by other characters.

### Save in generic format

When an applicable file is saved, DocMode asks whether it should be saved in generic format.

- Choose **Yes** to join each paragraph into one long line, remove its CR marker, and save the result.
- Choose **No** to leave the document in its current DocMode layout.
- Use `Ctrl+K`, then `F`, to convert the entire file manually before saving.

Before conversion, check for CR-marker errors. Full-file generic conversion changes the current buffer, so save a backup first when the file contains tables or deliberately formatted text.

### Preserve a specially formatted section

Press `Ctrl+K`, then `G`, to genericize only the current paragraph. This can help when a small table or another intentionally formatted section should not be processed with the rest of the file. Wide tables may still be unsuitable for generic word-processor interchange.

## Key bindings

| Key | Action |
| --- | --- |
| `Shift+F1` | Open the DocMode menu and detailed help |
| `Shift+F2` | Cycle WordWrap/AutoWrap modes |
| `Alt+B` | Wrap the current paragraph using DocMode rules |
| `Alt+E` | Edit a file and optionally reformat it for DocMode |
| `Enter` | Insert a CR marker in DocMode, then perform the normal Enter action |
| `Ctrl+K`, `A` | Convert generic text to DocMode format |
| `Ctrl+K`, `F` | Convert the whole file from DocMode to generic format |
| `Ctrl+K`, `G` | Convert only the current paragraph to generic format |
| `Ctrl+K`, `I` | Insert a CR marker without performing the Enter action |
| `Ctrl+K`, `C` | Locate a CR marker that incorrectly has following characters |
| `Ctrl+K`, `D` | Toggle DocMode on or off |

Some bindings intentionally replace TSE's normal commands. If your installation assigns those commands to different keys, update both the key definitions near the end of `DOCMODE.S` and the labels in the `dDocModeHelp` menu.

## Configuration

### Change the automatic file extension

DocMode is enabled automatically for `.ASC` files. To use another extension, edit this declaration in `DOCMODE.S`:

```text
string dmode_ext[4] = ".asc"
```

Adjust the string size if the new extension is longer, then recompile the macro.

### Disable automatic activation

Comment out the following hook in `WhenLoaded()`, then recompile:

```text
Hook(_ON_CHANGING_FILES_,dSetDocMode)
```

DocMode can still be switched manually with `Ctrl+K`, then `D`.

### Build without the included AutoWrap module

Follow the comments in `DOCMODE.S` and `DAUTOWRP.S`. At minimum, remove or comment the `DAUTOWRP.S` include, its related global variables, and the four AutoWrap-related lines identified in `WhenLoaded()`.

## Troubleshooting

### The compiler cannot find `dautowrp.s`

Make sure `DOCMODE.S` and `DAUTOWRP.S` are in the same directory and compile from that directory. The main source includes `dautowrp.s` by filename.

### DocMode does not activate automatically

Check that the current filename has the `.ASC` extension, that the macro is loaded, and that the `_ON_CHANGING_FILES_` hook has not been removed. Use `Ctrl+K`, then `D`, to activate it manually.

### Paragraphs wrap incorrectly

Set the intended margins before running file setup. Check that CR markers occur only at real hard paragraph endings and that no text follows a marker.

### A table or formatted block was changed

Generic conversion is designed primarily for prose paragraphs. Restore the original file from a backup, then convert suitable paragraphs individually with `Ctrl+K`, then `G`.

### Key commands conflict with existing assignments

Edit the key definitions at the end of `DOCMODE.S`, update the help-menu text to match, and recompile.

## Important notes

- Work on a backup until you are familiar with the conversion behavior.
- The special CR marker is part of DocMode's editing representation.
- Generic format is intended for sharing editable prose, not final print-formatted documents.
- Once a document has been formatted for printing in a word processor, further layout-sensitive editing should normally be done in that word processor.
- This is a historical package: details may depend on the TSE version and user-interface configuration in which it is installed.

## Version history

| Version | Date and time (UTC) | Changes |
| --- | --- | --- |
| 1.0.0.0.0 | 2026-09-05 13:24:11 | Initial README created from the contents and documentation supplied in `docmode.zip`. |

Future README revisions can increment the final component, for example: `1.0.0.0.1`, `1.0.0.0.2`, and so on.

## License and authorship

The archive does not include a separate license file. Consult the source headers and original distribution information before redistributing or modifying the package.
