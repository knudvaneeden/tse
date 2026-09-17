# SEARCHCOMPILE

**Version:** 1.0.0.0.5  
**Date:** 2026-09-18  
**Time:** 00:29:39 CEST  
**LLM:** OpenAI GPT-5 Codex  
**Session:** Create SEARCHCOMPILE Readme

## Description

`SEARCHCOMPILE` is a TSE SAL macro that searches compiler definitions stored in a SemWare/TSE `compile.dat` file.

The normal TSE compile macro uses `compile.dat` to associate filename extensions with compiler commands and error-parsing rules. `SEARCHCOMPILE` lets you search those definitions without changing `compile.dat`.

The package contains:

- `searchcompile.s` — TSE SAL source code.
- `searchcompile.ini` — initial values offered by the input dialogs.
- `searchcompile_readme.md` — this documentation.

The supplied `compile.s` and `compile.dat` reference files are intentionally not included in the package.

## Search inputs

When run, the macro asks for the following information in this order:

1. Full path to `compile.dat`.
2. Search string, for example `Borland`.
3. Search options, for example `i` or `ix`.
4. File extension, initially `.c`; leave this blank to search every extension.
5. Compiler option field, selected from a menu.

Every `Ask()` dialog uses `_EDIT_HISTORY_`, so previous entries can be recalled through TSE's edit history.

## Search options

- `i` — ignore letter case.
- `x` — treat the search string as a TSE regular expression.
- `ix` or `xi` — regular-expression search while ignoring letter case.

Other valid TSE `lFind()` search options can also be entered. An invalid expression or unsupported option is handled by TSE's normal search behavior.

For a literal search, normally use an empty option or `i`. For a regular-expression search, include `x`. Characters that are operators in a TSE regular expression must be escaped when they are intended literally.

## Searchable fields

The field-selection menu offers:

- Compiler Extension
- Compiler Description
- Compiler Command
- Compiler Output
- Compiler Rules
- Error
- Error Options
- Filename
- Filename Options
- Filename Tag
- Line
- Line Options
- Line Tag
- Column
- Column Options
- Column Tag
- Message
- Message Options
- Message Tag

`Compiler Rules` searches all error-parsing expressions, their options and tags, plus the optional user-rule macro, as one combined field. The individual rule choices search only their exact stored fields.

`Compiler Output` searches the readable name of the stored output mode, such as `Tee Output, Run Hidden and Don't Prompt After Shell`.

## Configuration

Keep `searchcompile.ini` in the same directory as `searchcompile.s` or the compiled `searchcompile.mac` file.

The initial file is:

```ini
[SearchCompile]
compile_dat=
search_string=Borland
search_options=ix
file_extension=.c
```

When `compile_dat=` is empty, the proposed path is automatically:

```text
LoadDir() + "compile.dat"
```

This normally selects the `compile.dat` file in TSE's load directory. If a full path is entered after `compile_dat=`, that configured path takes priority. A blank `file_extension=` means all compiler extensions.

The macro only reads this INI file. Entries typed in the dialogs are retained by TSE's edit history, but they are not written back to the INI file.

## Compile the macro

1. Extract the ZIP file into a directory.
2. Keep `searchcompile.s` and `searchcompile.ini` together.
3. Open a command prompt in that directory.
4. Compile the source with the TSE SAL compiler:

```text
sc32 searchcompile.s
```

This creates `searchcompile.mac` when compilation succeeds.

## Load and run in TSE

The macro can be run directly:

```text
ExecMacro("searchcompile")
```

It can also be loaded from TSE's macro menu or assigned to a key in the usual way.

After starting it:

1. Confirm or change the proposed path to `compile.dat`.
2. Enter the text or regular expression to find.
3. Enter the required search options.
4. Enter an extension or leave it blank for all extensions.
5. Select the field to search.
6. Review the `*SEARCHCOMPILE RESULTS*` buffer.

Each match shows:

- the source record's line number in `compile.dat`;
- the compiler extension;
- the compiler description;
- the selected field name and its matching value.

## Examples

### Find Borland compiler descriptions for C

```text
compile.dat:     f:\bbc\taal\compile.dat
Search string:   Borland
Search options:  i
File extension:  .c
Field:           Compiler Description
```

### Find Java commands using a regular expression

```text
Search string:   ^javac
Search options:  ix
File extension:  .java
Field:           Compiler Command
```

### Search all extensions for a numbered error tag

```text
Search string:   7
Search options:  i
File extension:
Field:           Message Tag
```

## Notes

- `compile.dat` is opened read-only in a temporary buffer; the macro does not modify it.
- The file must begin with `Semware compile macro data file`.
- Compiler records are recognized by the control-character format used by TSE's compile macro.
- The result buffer is not saved automatically.
- The macro is designed for TSE SAL and ASCII source compatibility.

## Version history

### 1.0.0.0.5 — 2026-09-18 00:29:39 CEST

- Changed the default file extension from `.java` to `.c`.
- Updated both the INI proposal and the source fallback value.

### 1.0.0.0.4 — 2026-09-18 00:21:57 CEST

- Fixed SAL Compiler Error 2224 for the local compiler-record strings.
- Explicitly initialized all local record-field strings to empty strings.
- Removed the related Warning 1101 messages about possible use before initialization.

### 1.0.0.0.3 — 2026-09-18 00:20:12 CEST

- Fixed SAL Compiler Error 2333 in the field-selection menu.
- Replaced direct menu-item assignments with a shared `command` handler using `MenuOption()`.

### 1.0.0.0.2 — 2026-09-18 00:16:55 CEST

- Made the initial `compile_dat=` INI setting empty.
- Added `LoadDir() + "compile.dat"` as the default path when the INI setting is empty.
- A non-empty `compile_dat=` setting continues to take priority.

### 1.0.0.0.1 — 2026-09-18 00:12:16 CEST

- Fixed SAL Compiler Error 2336 at the original line 14.
- Replaced string-valued `#define` directives with SAL string variables.
- Retained numeric `#define` directives only, as required by the SAL preprocessor.

### 1.0.0.0.0 — 2026-09-17 21:53:12 UTC

- Initial release.
- Added INI-based initial proposals.
- Added literal and TSE regular-expression searching.
- Added optional filtering by compiler file extension.
- Added a menu containing all requested compiler option fields.
- Added a result buffer with record line, extension, description, field, and matching value.
- Added `_EDIT_HISTORY_` to every `Ask()` call.
