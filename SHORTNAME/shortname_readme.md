# SHORTNAME 1.0.0.0.2

Updated: 2026-10-08 17:32 +02:00. Author: GPT-6 (OpenAI).

Shows long filenames and their existing short names side by side. Select a
row and press Enter to insert the short filename at the original text cursor.
Escape cancels. No helper program or custom DLL is required.

## Installation

1. Extract `shortname.s` and `shortname.ini` into your macro directory.
2. Compile: `sc32 shortname.s`.
3. Position the cursor in your text and execute macro `shortname`.
4. Enter the directory and mask (`*` lists all files).
5. Select a row, then Enter to insert its short filename.

The informative warning appears BEFORE both Ask prompts. The picker supports
SpeedSearch and horizontal scrolling. It lists files, including hidden/system
files, in one directory; it excludes directories. Insertion adds no quotes,
spaces or newline and uses insert mode. Successful insertion is reported on
the message line. Cancelled prompts leave the text untouched.

## Chinese and other Unicode filenames

The purpose is to obtain an ASCII short name for a file whose long name TSE
cannot handle. This version bypasses TSE's file enumeration: it calls Windows
`FindFirstFileW`/`FindNextFileW` and reads UTF-16 names directly from
`WIN32_FIND_DATAW`. It uses the actual existing alias in `cAlternateFileName`.
It does not guess an alias or substitute question marks into an inserted name.

Traditional TSE cannot reliably render Chinese characters. The long-name column
therefore shows non-ASCII UTF-16 units as `\uXXXX`, for example
`\u4E2D\u6587.txt` for a two-character Chinese filename followed by `.txt`.
Names too long for the 255-byte display string end with `...`. This display
limit does not affect the independently retrieved short alias.

Only ASCII short names are insertable. If Windows supplies no usable ASCII
alias, the row says `<no usable ASCII short name>` and cannot be selected for
insertion. Already-short ASCII names are usable without an alternate alias.
The macro does not rename files, create aliases or alter Windows settings.

The directory and mask prompts still use TSE's ANSI input. Choose a directory
with an ASCII path, or enter its ASCII short path if its directory name is
Chinese. Unicode filenames INSIDE that directory are enumerated directly.
A Unicode filesystem does not guarantee that every file has a short alias.

## Reliable basic test

The ZIP includes `TEST83.TXT`, which is already an ASCII 8.3 name.

1. Create `C:\TEMP\SHORT83` and copy `TEST83.TXT` there.
2. Run the freshly compiled macro in a scratch text buffer.
3. Directory: `C:\TEMP\SHORT83`
4. Mask: `TEST83.TXT`
5. The list should show `TEST83.TXT` in BOTH columns.
6. Press Enter: `TEST83.TXT` should be inserted into the buffer.

This test requires no generated short alias. It assumes the file is actually
copied to that directory and the directory is accessible to TSE.

## Unicode workaround test

Copy the included Chinese-named `.txt` file into the same test directory
using Windows Explorer. Run `shortname` with that directory and mask `*`.
The Chinese filename should appear as Unicode escapes in the left column.
If an ASCII short alias exists, it appears in the right column and can be
inserted into the text. Use that name (or its full path) with TSE's Open File
command to test opening the contents.

Check existing aliases in CMD with `dir /x C:\TEMP\SHORT83`.
A blank short-name column in CMD means an alias cannot be assumed. Copying
or extracting the example does not guarantee Windows will create an alias.

## INI

Current-directory `shortname.ini` is tried first, then the macro directory.
Section: `[shortname]`. Prompts do not rewrite settings.

| Key | Default | Meaning |
| --- | --- | --- |
| `directory` | empty | Initial directory; empty uses TSE's current directory. |
| `filemask` | `*` | Initial mask. |
| `insertfullpath` | `false` | Insert only the short filename; true prepends the directory returned by Windows' short-path API. |
| `silent` | `false` | Show startup and error Warn boxes; true suppresses them. |

A directory returned by the short-path API may still contain long components
if Windows has no aliases for them. Use an ASCII directory path for testing.

## Changes and verification

- 1.0.0.0.2: Unicode enumeration and real Windows alternate names for the
  Chinese-filename workaround; escaped display of non-ASCII names.
- Includes the startup warning fix and the directory expansion fix:
  TSE's `ExpandPath(directory)` appends `\*.*`; this wildcard component is
  removed before appending the user's mask.
- Empty-list errors show the searched path and Windows error number.

Requires 32-bit Windows TSE with SAL DLL and pointer functions. SAL source is
ASCII. Directory plus mask is limited to 254 bytes. Windows enumeration data
is stored in separately allocated memory, so its Unicode fields are not
restricted to a 255-byte SAL string. Allocations and search handles are released.

SAL conventions, field offsets, versions and packaging have been checked.
Compilation and interactive Windows testing have not been performed here.

Reference: [Microsoft WIN32_FIND_DATAW documentation](https://learn.microsoft.com/en-us/windows/win32/api/minwinbase/ns-minwinbase-win32_find_dataw).
