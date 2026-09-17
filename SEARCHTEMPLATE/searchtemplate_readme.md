# SEARCHTEMPLATE

**Session:** Create SEARCHTEMPLATE Readme  
**Program:** `searchtemplate.s`  
**Configuration:** `searchtemplate.ini`  
**Version:** 1.0.0.0.4  
**Date:** 2026-09-17  
**Time:** 22:54:54 UTC  
**LLM:** OpenAI GPT-5 Codex

## Description

`SEARCHTEMPLATE` is a TSE SAL program that searches a SemWare `template.dat` abbreviation file. It searches template header records by abbreviation and filters them by a requested file extension.

The program does not expand an abbreviation in the current editing buffer. It is a search and inspection tool: each matching abbreviation, its extension, its declared body-line count, and its body are written to a result buffer.

## Template file format

A template header and its body have this form:

```text
3   .java        abbr
first body line
second body line
third body line
```

The header fields are:

1. Columns 1 through 4 contain the integer number of body lines.
2. Columns 5 through 17 contain the optional file extension.
3. The abbreviation begins at column 18.
4. The declared number of body lines immediately follows the header.

A blank extension field means that the abbreviation applies to every file extension.

`SEARCHTEMPLATE` uses the body-line count to skip over each body. Therefore, body text is never mistaken for an abbreviation header.

## Files in the package

- `searchtemplate.s` - TSE SAL source code.
- `searchtemplate.ini` - configuration containing the default path to `template.dat`.
- `searchtemplate_readme.md` - this documentation.

The supplied reference files `template.s` and `template.dat` are intentionally not included in the package.

## Configuration

By default, the `template` value in `searchtemplate.ini` is empty:

```ini
[searchtemplate]
template=
searchstring=sh
searchfileextension=.java
searchoption=ix
```

When `template=` is empty, the program proposes this path:

```text
LoadDir() + "template.dat"
```

In practice, this means `template.dat` in TSE's current load directory. If the user enters a full path after `template=` in the INI file, that configured path takes priority over the `LoadDir()` default.

The INI file must be in the same directory as `searchtemplate.mac`. Its four values are offered as the initial values of the corresponding input fields. Each proposed value can be edited for an individual search without modifying the INI file.

The keys are:

- `template` - optional full path to the template data file; when empty, `LoadDir() + "template.dat"` is used.
- `searchstring` - proposed abbreviation search string.
- `searchfileextension` - proposed file extension.
- `searchoption` - proposed combination of search options.

## Compile

Place `searchtemplate.s` and `searchtemplate.ini` in the same directory. Compile the SAL source with the TSE SAL compiler:

```bat
sc32 searchtemplate.s
```

This creates:

```text
searchtemplate.mac
```

Keep `searchtemplate.mac` and `searchtemplate.ini` together.

## Run

Load or execute `searchtemplate.mac` using the normal TSE macro commands or assign it to a key in the TSE user interface.

The program asks for four values in this order.

All four input fields use TSE's `_EDIT_HISTORY_`, allowing earlier entries to be recalled and reused.

### 1. Full path to `template.dat`

Example:

```text
f:\bbc\taal\template.dat
```

If a path is stored in `searchtemplate.ini`, that path is offered first. Otherwise, `LoadDir() + "template.dat"` is offered.

### 2. Abbreviation search string

Example:

```text
abbr
```

Without option `x`, the input is treated as ordinary search text.

### 3. Search options

Supported options are:

- `i` - ignore letter case.
- `x` - interpret the abbreviation search string as a TSE regular expression.
- `w` - require the search string to match a complete word.
- `ix` - use a case-insensitive TSE regular-expression search.
- Options can be combined, for example `iw`, `xw`, or `ixw`.

Examples:

```text
i
```

```text
ix
```

Leave this field blank for a case-sensitive, non-regular-expression search.

Regular expressions use TSE's own regular-expression syntax, not Perl, PCRE, JavaScript, or .NET syntax. Characters that are operators in TSE regular expressions must be escaped when they are intended as literal characters.

### 4. File extension

Example:

```text
.java
```

The leading period is optional; the program adds it when necessary. Extension comparison ignores letter case. A template entry with a blank extension is included because it applies to all extensions.

## Search result

For every match, the result buffer shows:

- the abbreviation;
- the template extension or `<all>`;
- the number of body lines;
- the complete template body.

The bottom of the result buffer reports the total number of matches. A final warning reports whether the search completed, was cancelled, or failed.

## Example

Use these values:

```text
Full path:           f:\bbc\taal\template.dat
Abbreviation:        abbr
Search options:      ix
File extension:      .java
```

This searches the abbreviation names with a case-insensitive TSE regular expression and returns `.java` entries plus entries whose extension field is blank. Add `w`, for example `ixw`, when the match must be a complete word.

## Notes

- The first line of a normal SemWare template file is its identifying header. Searching starts at line 2.
- A malformed header or a body-line count below 1 stops the scan.
- The search reads the template file; it does not change it.
- Pressing **Escape** at any input field cancels the operation and leaves the original editing buffer active.
- The source and configuration files use plain ASCII text for compatibility with TSE SAL.

## Version history

### 1.0.0.0.4 - 2026-09-17 22:54:54 UTC

- Changed the initial INI value to an empty `template=` setting.
- Added `LoadDir() + "template.dat"` as the default template-file path.
- A non-empty `template=` INI value takes priority over the `LoadDir()` default.

### 1.0.0.0.3 - 2026-09-17 20:05:20 UTC

- Added `_EDIT_HISTORY_` to all four `Ask()` input fields.

### 1.0.0.0.2 - 2026-09-17 19:45:31 UTC

- Added INI proposals for the abbreviation search string, file extension, and search options.
- Added search option `w` for complete-word matching.
- Documented combined options such as `iw`, `xw`, and `ixw`.

### 1.0.0.0.1 - 2026-09-17 19:37:51 UTC

- Fixed SAL Compiler error 2336 at the former string `#define`.
- Replaced the unsupported string preprocessor definition with the global SAL string `GSVersionText`.

### 1.0.0.0.0 - 2026-09-17 19:34:32 UTC

- Initial release.
- Added template path loading from `searchtemplate.ini`.
- Added abbreviation searching with `i` and `x` options.
- Added exact extension filtering and support for global blank-extension templates.
- Added a result buffer containing matching template bodies.
