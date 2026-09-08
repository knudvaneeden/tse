# GREPZIP

**Version:** 1.0.0.0.7  
**Date:** 2026-09-08  
**Authoring model:** OpenAI Codex

GREPZIP is a portable TSE Pro SAL macro for recursively searching file contents with a **TSE SAL regular expression**. It accepts a directory, one file, or a file specification and also searches files stored in ZIP archives. ZIP archives stored inside other ZIP archives are expanded and searched recursively.

## Package contents

- `grepzip.s` - TSE SAL source.
- `grepzip_helper.ps1` - portable Windows ZIP/file enumerator.
- `build.bat` - SAL build command.
- `grepzip_readme.md` - this documentation.

No Borland C++ DLL is required in version 1.0.0.0.7. ZIP support uses Windows PowerShell and the built-in .NET ZIP classes. This avoids a separate decompression DLL while leaving all text matching to TSE's own search engine.

## Requirements

- TSE Pro 4.50 for Windows.
- The `sc32` SAL compiler.
- Windows PowerShell 5.1 or another Windows PowerShell version providing `System.IO.Compression`.

## Build

1. Extract the complete package into one directory.
2. Open a command prompt in that directory.
3. Ensure `sc32.exe` is available through `PATH`, or edit `build.bat` to specify its full path.
4. Run `build.bat`.
5. Confirm that `GREPZIP.MAC` was created.

## Install

Keep these three files together in a directory from which TSE loads macros:

- `GREPZIP.MAC`
- `grepzip.s`
- `grepzip_helper.ps1`

The macro obtains its own location with `CurrMacroFilename()`, so it does not depend on TSE's current working directory and does not use `LoadDir()`.

## Run

Run `GREPZIP` as a macro, or press **Ctrl+Alt+Shift+G**. Press **Ctrl+Alt+Shift+R** to open TSE's built-in **Regular Expression Operators** help topic.

1. Enter the search string.
2. Enter TSE search options, for example `i` or `ix`.
3. Enter a directory, file, or file specification.
4. Wait while GREPZIP enumerates files, expands ZIPs, and asks TSE to search each file.
5. Review the results buffer.

Examples of source specifications:

```text
C:\SOURCE
C:\SOURCE\*.S
C:\SOURCE\README.MD
C:\ARCHIVES\*.ZIP
```

The file specification is applied recursively below its parent directory. A directory searches all files below it. A literal filename searches only that file.

## Regular expressions

The search string is passed directly to TSE's `lFind()`. The separate options prompt controls matching. GREPZIP searches each temporary file buffer separately and does not add TSE's global-buffer option.

- `i` - ignore case.
- `x` - interpret the search string as a TSE regular expression.
- `ix` - ignore case and use TSE regular expressions.
- Leave `x` out for a literal text search, such as `Dos`.

Use TSE regular-expression syntax when `x` is present, not PowerShell or Perl syntax. GREPZIP does not translate the expression.

### TSE regular-expression operators

The following operators are accepted directly by TSE when option `x` is used:

- `\\` - TSE regular-expression escape character. Use it before an operator when that character must be matched literally.
- `.` - any single character.
- `^` - anchor the following sub-pattern to the beginning of the line.
- `$` - anchor the preceding sub-pattern to the end of the line.
- `|` - OR; match the preceding or following sub-pattern.
- `?` - zero or one occurrence of the preceding sub-pattern.
- `[abc]` - match one character from the class.
- `[A-Za-z]` - match one character from the indicated ASCII ranges.
- `[~abc]` - match one character not present in the class; `~` must immediately follow `[`. 
- `*` - minimum-closure zero or more occurrences of the preceding sub-pattern.
- `+` - minimum-closure one or more occurrences of the preceding sub-pattern.
- `@` - maximum-closure (greedy) zero or more occurrences of the preceding sub-pattern.
- `#` - maximum-closure (greedy) one or more occurrences of the preceding sub-pattern.
- `{pattern}` - tag/group a sub-pattern; tags may be nested.

Examples:

```text
Do.*
Dos?Command
Dos+Command
file\\.zip
Do@
Do#
[A-Za-z]#
[~0-9]@
{Begin}|{End}File
^Dos$
```

In `file\\.zip`, the backslash escapes the dot, so the dot is matched literally.

Character classes remain case-sensitive even when option `i` is selected. Include both cases explicitly, for example `[A-Za-z]`. OR alternatives are tried from left to right, put a longer alternative before a shorter one when one contains the other.

Examples:

```text
TODO
proc[ \t]+Main
Version[ \t]*:[ \t]*1\.0
```

Whether matching is case-sensitive follows the active TSE search behavior and expression/options supported by the installed TSE version.

## Results

Each match is shown as:

```text
filename(line,column): matching line
```

ZIP members use `::` to show archive nesting, for example:

```text
C:\DATA\outer.zip::docs/inner.zip::source/test.s(42,7): proc Main()
```

## ZIP behavior

- Ordinary ZIP files are searched.
- Nested ZIP files are searched to a maximum depth of 32.
- ZIP directory entries are ignored.
- Encrypted, damaged, or unsupported ZIP archives are skipped.
- Extracted temporary members use unique names below `%TEMP%`.
- The manifest contains system paths only temporarily; search output retains the archive/member path.
- After TSE finishes searching, the helper removes the temporary extraction tree and manifest.

## Current limits

- TSE SAL strings and displayed result lines are limited to 255 characters; very long paths or lines can be truncated.
- TSE SAL integers are signed 32-bit.
- Binary files may not be meaningful to TSE's text search.
- Password-protected ZIP files are not searched.

## Version history

### 1.0.0.0.7 - 2026-09-08

- Adds the complete pasted TSE search-operator set to the search prompt and documentation.
- Documents `[]` character classes and ranges such as `[A-Za-z]`.
- Documents complement classes such as `[~0-9]`.
- Documents `{}` tags/groups and nested tags.
- Documents the `|` OR operator and its left-to-right precedence.
- Documents `^` and `$` line anchors.
- Distinguishes minimum closure (`*`, `+`) from maximum/greedy closure (`@`, `#`).
- Adds Ctrl+Alt+Shift+R to open TSE's built-in Regular Expression Operators help.

### 1.0.0.0.6 - 2026-09-08

- Traverses the manifest by stored line number instead of relying on the current buffer after a source file is abandoned.
- Explicitly restores the manifest buffer before reading every entry.
- Displays the number of files examined in the results and final warning.
- Adds TSE `@` greedy zero-or-more and `#` greedy one-or-more operators to the prompt and documentation.

### 1.0.0.0.5 - 2026-09-08

- Stops adding the `g` global-buffer option to each TSE search.
- Loads the manifest and source files with TSE `EditBuffer()`.
- Uses `lFind()` for the first match and `lRepeatFind()` for subsequent matches.
- Searches each source in its own current temporary buffer.
- Documents TSE's `\\` escape character and `.`, `*`, `+`, and `?` operators.
- Corrects literal and regular-expression searches such as `Dos` with options `ix`.

### 1.0.0.0.4 - 2026-09-08

- Removes every double-quote character from the entered source specification.
- Handles specifications containing only a leading quote or only a trailing quote.
- Converts forward slashes in the source specification to Windows backslashes.
- Fixes zero-file enumeration when the results header showed a leading quote.

### 1.0.0.0.3 - 2026-09-08

- Prevents PowerShell from prompting for a missing `Manifest` parameter.
- Uses `%TEMP%\\grepzip_manifest.txt` as the default manifest name.
- Shortens the command to stay within TSE's 255-character string limit.
- Starts PowerShell non-interactively with a hidden window.
- Uses the same hidden, non-interactive invocation during cleanup.

### 1.0.0.0.2 - 2026-09-08

- Changed the prompt order to search string, search options, then source specification.
- Added a separate TSE search-options prompt with default `ix`.
- Passes the selected `i` and `x` options to TSE `lFind()`.
- Removes surrounding quotes from a source path.
- Removes a non-root trailing slash so a quoted PowerShell argument remains valid.
- Corrected the empty-result problem demonstrated by searching for `Dos`.

### 1.0.0.0.1 - 2026-09-08

- Renamed the program and package from RGZIP to GREPZIP.
- Corrected `SplitPath()` to use the numeric `_DRIVE_|_PATH_` flag expression required by TSE SAL.
- Fixed compiler error 2336 at the former line 75.

### 1.0.0.0.0 - 2026-09-08

- Initial release.
- Recursive directory and file-specification enumeration.
- TSE SAL regular-expression content matching.
- ZIP and nested-ZIP searching.
- Results include line and column numbers plus virtual nested archive paths.
- Direct key binding: Ctrl+Alt+Shift+G.
- Automatic cleanup of extracted ZIP members after the TSE search.
