# CblComnt for TSE Pro

**README version:** 1.0.0.0.0  
**Date and time:** 2026-09-01 17:56:05 UTC  
**Original macro version:** 1.1  
**Original author:** Carlo Hogeveen  
**Compatibility stated by the author:** TSE Pro 2.8 and later

## Description

`CblComnt.s` is a TSE SAL macro that improves the display of fixed-format COBOL source files in The SemWare Editor (TSE Pro).

Fixed-format COBOL reserves particular columns for special purposes:

- Columns 1 through 6 normally contain sequence numbers and do not form part of the executable statement.
- Column 7 is the indicator area. In COBOL versions through COBOL-85, `*` and `/` in this column can identify comment lines.
- Columns 73 and later are normally ignored by the compiler and may contain identification text or comments.

The macro can color the left and right margins so these non-code areas are visually distinct. It can also color complete COBOL comment lines when required by an older TSE version.

The ZIP archive contains:

| File | Purpose |
| --- | --- |
| `CblComnt.s` | TSE SAL source code for the macro. |
| `COBOL.TXT` | Optional COBOL syntax-highlighting mapping for older TSE installations. |
| `COBOL.DOC` | Original instructions for importing `COBOL.TXT`. |
| `FILE_ID.DIZ` | Short original package description. |

## Default behavior

The supplied source has the following defaults:

```text
COLOR_COBOL_COMMENTS     FALSE
COLOR_COBOL_LEFT_MARGIN  TRUE
COLOR_COBOL_RIGHT_MARGIN TRUE
```

Therefore, it colors columns 1 through 6 and columns 73 through the end of each visible line. Direct comment-line coloring by the macro is disabled because TSE Pro 3.0 and later can normally handle column-7 COBOL comments through syntax highlighting.

The macro recognizes files with the extensions `.cbl` and `.cob`.

## Installation

1. Extract `cblcomnt.zip` to a temporary directory.
2. Copy `CblComnt.s` to the TSE macro source directory, usually the `mac` directory below the TSE installation directory.
3. If you use TSE Pro 2.8 and need the macro itself to color column-7 comment lines, edit `CblComnt.s` and change:

   ```text
   #define COLOR_COBOL_COMMENTS FALSE
   ```

   to:

   ```text
   #define COLOR_COBOL_COMMENTS TRUE
   ```

4. Compile the macro from TSE, or run the appropriate SAL compiler for your TSE installation. A typical command for a current 32-bit TSE installation is:

   ```bat
   sc32 CblComnt.s
   ```

5. Confirm that compilation creates `CblComnt.mac`.
6. Add `CblComnt` to TSE's macro `AutoLoadList`. The macro must remain loaded because it performs its highlighting from TSE's idle hook.
7. Restart TSE, or load the compiled macro manually for the current TSE session.

## How to run it

The macro has no interactive command or dialog. After it has been compiled and loaded, it works automatically:

1. Open a fixed-format COBOL file whose extension is `.cbl` or `.cob`.
2. View or move through the source normally.
3. The macro colors the visible fixed-format margin columns automatically.

If the macro was added to `AutoLoadList`, no further action is required whenever TSE starts.

## Installing the optional COBOL syntax highlighting

Use this section only if the TSE installation does not already contain a suitable `COBOL.SYN` file.

1. Start TSE and open a `.cbl` file.
2. Open the main menu with `Esc`.
3. Select **Options/Other**.
4. Select **Full Configuration**.
5. Select **Display/Color Options**.
6. Select **Configure Syntax Hilite Mapping Sets**.
7. Select the current mapping set, or create a new one.
8. Choose the option to overlay settings from a mapping text file.
9. Enter the full path to the extracted `COBOL.TXT` file.
10. Configure the associated extensions, normally `.cbl` and `.cob`, and adjust colors if desired.
11. Exit the configuration menus with `Esc` and allow TSE to save the syntax-highlighting settings, normally as `COBOL.SYN` in TSE's `synhi` directory.

After the mapping has been imported successfully, the extracted `COBOL.TXT` copy is no longer required for normal operation.

## Configuration

Configuration values are near the start of `CblComnt.s`.

### Highlighting priority

```text
#define PRIORITY 1
```

`1` gives the fastest response. A higher value reduces how often the highlighting code runs; the original source suggests `18` for approximately a one-second delay. A slower setting may reduce processing activity or help coordinate this macro with another highlighting macro.

### File extensions

The default extension string is:

```text
.cbl.cob
```

Edit `comment_extensions` in the source if other COBOL filename extensions must be recognized, then recompile and reload the macro.

### Colors

The macro takes its three default colors from TSE's `ToEOL1Attr` setting. Change the relevant color expressions in `hilite_cobol_comments()` if different colors are required, then recompile the macro.

## Troubleshooting

### Nothing changes when a COBOL file is opened

- Confirm that `CblComnt.mac` was created successfully.
- Confirm that `CblComnt` is present in `AutoLoadList`, or load it manually.
- Confirm that the filename ends in `.cbl` or `.cob`.
- Restart TSE after recompiling so an older loaded copy of the macro is not still active.

### Columns 1 through 6 or columns 73 onward are not colored

Confirm that these definitions remain set to `TRUE`:

```text
#define COLOR_COBOL_LEFT_MARGIN TRUE
#define COLOR_COBOL_RIGHT_MARGIN TRUE
```

Recompile and reload the macro after changing either definition.

### Column-7 comments are not colored

For TSE Pro 3.0 and later, configure COBOL syntax highlighting to recognize `*` and `/` in column 7. For TSE Pro 2.8, set `COLOR_COBOL_COMMENTS` to `TRUE`, compile the source again, and reload or restart TSE.

### Syntax colors are missing completely

Check whether a COBOL syntax-highlighting mapping is already installed. If it is absent, import the supplied `COBOL.TXT` by following the optional syntax-highlighting instructions above.

## Notes and limitations

- This macro is designed for fixed-format COBOL. Free-format COBOL does not use the same fixed column layout.
- Highlighting is display-only; the macro does not change the contents of the COBOL source file.
- Cursor, selected-block, and existing highlight attributes are preserved where possible.
- The source can be adapted for fixed-format Fortran by changing the comment position, comment characters, extensions, and margin settings. The original author notes that an asterisk in column 1 is commonly used for older Fortran comments.

## Version history

| README version | Date and time (UTC) | Changes |
| --- | --- | --- |
| 1.0.0.0.0 | 2026-09-01 17:56:05 UTC | Initial Markdown documentation created from `cblcomnt.zip`; added description, installation, running instructions, configuration help, troubleshooting, and archive contents. |

Future revisions should increment the final component sequentially, for example `1.0.0.0.1`, `1.0.0.0.2`, and so on.
