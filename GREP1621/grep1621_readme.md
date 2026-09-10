# GREP1621

## Description

GREP1621 is the 16-bit DOS edition of Christopher Antos's GREP macro version 2.1 for The SemWare Editor Professional (TSE Pro) 2.5. It searches one or more files for text and displays matching filenames, line numbers, and matching lines in a navigable results list.

The package is freeware and was originally dated February 23, 1997. The `GREP16_21` edition is intended for DOS TSE 2.5. It is not the separate `GREP32_21` package intended for TSE 2.6 for Win32.

## Main features

- Search multiple files for a text string.
- Search with ordinary text or TSE regular expressions.
- Ignore letter case or match whole words.
- Recursively search subdirectories.
- Exclude selected filenames, wildcard patterns, or directories.
- Display matching lines in a GREP results list.
- Optionally list only filenames containing matches.
- Show surrounding context lines in a context window.
- Refresh a previous search with `<F5>`.
- Jump directly from a result to the matching line in its source file.
- Search loaded files, the current directory, the current file, or a marked block.
- Find function declarations in several programming languages.
- Run interactively inside TSE or from a DOS command prompt with `G.BAT`.

GREP1621 does not search for an expression that spans more than one line.

## Package contents

| File | Purpose |
|---|---|
| `BUILD.BAT` | Rebuilds all required macros for the installed TSE SAL version |
| `GREP.S` | GREP macro source code |
| `GREP.MAC` | Compiled GREP macro; generated locally from `GREP.S` for the target SAL version |
| `GREP.HLP` | Online help used from within GREP |
| `GREP.TXT` | Original release notes and installation information |
| `G.BAT` | DOS/4DOS command-line launcher |
| `GREPDLG.SI`, `GREPDLG.DLG`, `GREPDLG.D` | GREP dialog definitions and support files |
| `DIALOG.S`, `DIALOGP.S`, `DIALOG.SI` | Recompilable Dialog 2.22 runtime and paint module |
| `SCPAINT.SI`, `SCWINCLP.SI` | Dialog runtime include files |
| `GETHELP.SI`, `GETHELP.K32`, `GUIINC.INC` | Recompilable GETHELP 4.0 source and Win32 includes |
| `GETHELP.DAT`, `GETHELP.HLP`, `HELP30.HLP` | GETHELP configuration and help files |
| `HELPHELP.S` | Recompilable helper for context-sensitive help in TSE menus |

## Requirements

The original GREP16_21 release requires TSE Pro 2.5 for DOS. Portable package `1.0.0.0.1` instead targets TSE Pro/32 with the SAL 4.50 compiler and includes source for every macro that must be rebuilt.

Use the files supplied in the portable archive together. Installing unrelated versions of the Dialog or GETHELP files may cause incompatibilities.

## Portable adaptation

Portable package version `1.0.0.0.2` contains the sources needed to rebuild GREP, Dialog, DialogP, GETHELP, and HELPHELP. It resolves runtime support files relative to the directory containing the corresponding loaded macro. It does not depend on TSE's current working directory, editor installation directory, `MAC` directory, or `TSEPath` to locate the bundled support files.

Keep these files together in one directory:

- `GREP.MAC`
- `DIALOG.MAC`
- `DIALOGP.MAC`
- `GETHELP.MAC`
- `HELPHELP.MAC`
- `GREP.HLP`
- `GETHELP.DAT`
- the remaining supplied dialog and support files

When `GREP.MAC` is loaded, it obtains its own full pathname with `CurrMacroFilename()`. It then uses that directory to load `DIALOG.MAC` and `GETHELP.MAC`. `DIALOG.MAC` similarly loads `DIALOGP.MAC` from its own directory. GETHELP searches its own directory first for `GETHELP.DAT` and help files. GREP passes the complete same-directory pathname of `GREP.HLP` to GETHELP.

## Installation

1. Make a backup of any existing GREP, Dialog, GETHELP, or INI files in the TSE `MAC` directory.
2. Extract all files from the portable ZIP into one directory of your choice.
3. Run `BUILD.BAT` in that directory to compile every required source for your installed SAL version.
4. Confirm that the compiler creates `DIALOGP.MAC`, `DIALOG.MAC`, `GETHELP.MAC`, `HELPHELP.MAC`, and `GREP.MAC` in the same directory.
5. Start TSE Pro.
6. Load that `GREP.MAC` with TSE's macro-loading command, or add its full pathname to the TSE AutoLoad list.
7. Press `<Alt G>` to verify that the GREP dialog opens.
8. Press `<F1>` in the GREP dialog to open the supplied help.

The original archives supplied precompiled macros for their original TSE SAL environments. The portable package omits those stale binaries. By design, `.MAC` files must always be recompiled when using a different TSE SAL version. Run `BUILD.BAT` with the SAL compiler belonging to the target TSE version before loading GREP.

For TSE Pro/32 and SAL 4.50, the complete manual build order is:

```text
sc32 dialogp.s
sc32 dialog.s
sc32 gethelp.si
sc32 helphelp.s
sc32 grep.s
```

Alternatively, run the supplied portable build script:

```text
build.bat
```

Do not compile the historical archive with `sc32 *.s`. Its `INI.S` is DOS-only and deliberately produces a syntax error when `WIN32` is defined. The portable package does not require `INI.S`; Win32 TSE provides the necessary profile/INI functions natively.

After compilation, keep the newly created `GREP.MAC` in the same directory as the support files. You may load it while TSE is using any other working directory; the portable path handling will still locate the colocated files.

## How to run an interactive search

1. Load the GREP macro.
2. Press `<Alt G>` to open the GREP dialog.
3. Enter the text or expression in **Search for**.
4. Enter the desired option letters.
5. Specify the files to search, such as `*.S *.SI` or `*.*`.
6. Specify files or directories to exclude when required.
7. Select the starting directory.
8. Configure the context window and number of context lines if desired.
9. Start the search.
10. Press `<Esc>` or `<Ctrl Break>` to abort a search in progress.

The macro remembers several settings through its profile/INI support.

## Search options

| Option | Meaning |
|---|---|
| `D` | Search subdirectories recursively |
| `I` | Ignore differences between uppercase and lowercase |
| `L` | List matching filenames only |
| `M` | Also search files currently loaded in TSE |
| `V` | Verbose output while searching; turning this off is faster |
| `W` | Match whole words only |
| `X` | Interpret the search text as a regular expression |
| `^` | Anchor the match to the beginning of a line |
| `$` | Anchor the match to the end of a line |

The dialog also permits zero through five context lines before and after each match. The supplied source uses dialog variation 2.

## Installed keyboard commands

| Key | Action |
|---|---|
| `<Alt G>` | Open the GREP dialog and start a new search |
| `<Alt Shift G>` | Redisplay the most recent GREP results list |
| `<Ctrl Alt G>` | Search the current directory for the word or marked block |
| `<Ctrl Shift '>` | Alternative key for searching the current directory |
| `<Ctrl '>` | Search loaded files for the word or marked block |
| `<Ctrl G>` | Find the function under the cursor, or list functions in the current file |

If there is no suitable word under the cursor, GREP prompts for a search expression.

## Working with the GREP results list

| Key | Action |
|---|---|
| `<Enter>` | Open the selected file at the matching line |
| `<Ctrl Enter>` | Open a second window at the selected match |
| `<Up>` / `<Down>` | Move to the previous or next result line |
| `<Shift PgUp>` / `<Shift PgDn>` | Move to the previous or next file section |
| `<Del>` | Remove the selected match; on a filename, remove all matches for that file |
| `<F5>` | Repeat the entire search and refresh the results |
| `<F1>` | Open help for the results list |
| `<Alt E>` | Edit the GREP results list as a normal file |
| `<Esc>` | Close the results list |

The optional context window shows lines around the selected match. For recognized programming-language source files, GREP attempts to show the containing function name. This detection is helpful but is not guaranteed to be completely accurate.

## Running from a DOS prompt

Place `G.BAT` in a directory listed in the DOS `PATH`. TSE's executable must also be available as expected by the batch file.

Basic syntax:

```text
G [-deilpwx] needle files
```

Example:

```text
G hello *.txt
```

This searches all `.txt` files in the current directory for `hello`.

Command-line switches:

| Switch | Meaning |
|---|---|
| `-d` | Search subdirectories |
| `-eFilespec` | Exclude matching files; separate multiple patterns with commas or semicolons |
| `-i` | Ignore case |
| `-l` | List matching filenames only |
| `-pDirectory` | Begin searching in the specified directory |
| `-w` | Match whole words |
| `-x` | Use regular expressions |

Example with exclusions:

```text
G -d -i -e*.bak,*.tmp hello *.*
```

This searches downward from the current directory, ignores case, and omits `.bak` and `.tmp` files.

Enter `G`, `G ?`, `G -?`, or `G /?` without a search to display command-line help.

## Filename and search limitations

- File specifications may be separated by spaces, commas, or semicolons.
- DOS wildcards can be used for files and exclusions.
- The 16-bit package is intended for DOS-style filenames and paths.
- The original release notes state that long-filename support belongs to the TSE 2.6 version; even there, names containing spaces cannot be used in the search or exclusion specifications.
- Search expressions cannot span line boundaries.
- Very large searches may be constrained by DOS conventional memory.

## Troubleshooting

### `<Alt G>` does nothing

Confirm that `GREP.MAC` is loaded or appears in the TSE AutoLoad list. Also check for another loaded macro that defines the same key.

### The dialog or help does not open

Verify that `DIALOG.MAC`, `DIALOGP.MAC`, `GETHELP.MAC`, `HELPHELP.MAC`, `GETHELP.DAT`, and `GREP.HLP` were built or copied into the same directory as `GREP.MAC`.

### `INI.S` reports error 2333 at line 31

This error is intentional when compiling under Win32 TSE. `INI.S` contains a compile-time guard stating that it must not be compiled for Win32 because Win32 TSE supplies the same profile/INI functionality itself.

Compile only the main source:

```text
sc32 grep.s
```

The successful creation of `GREP.MAC` confirms that the main GREP source compiled correctly. Do not use `sc32 *.s`, because that command also selects the DOS-only `INI.S` file.

### Expected files are not searched

Check the starting directory, file specification, exclusion patterns, and the `D` option. Remove exclusions temporarily to determine whether one of them is filtering the files.

### Search results are too numerous

Use a narrower file specification, enable whole-word matching, add exclusion patterns, or use regular expressions. The `L` option can be used when only the names of matching files are needed.

### The macro runs out of memory

Close unnecessary files and unload unneeded macros or TSR programs. This release was specifically trimmed to fit the memory limitations of DOS TSE 2.5.

### Running on a modern TSE version

The original archive is historical 16-bit software. Portable package `1.0.0.0.2` adapts its source and dependencies for recompilation with TSE SAL 4.50 on Win32. Compilation of all five required macros was confirmed successfully with SAL Compiler V4.50.rc23 (2024-05-27, build 12390). Runtime testing remains necessary.

## Version history

### 1.0.0.0.5 — 2026-09-10 17:37:23 UTC

- Documented the successful SAL 4.50 compilation of all five required macros.
- Updated the portable package to `1.0.0.0.2`.
- Removed `exit /b` and the batch subroutine from `BUILD.BAT` because the user's command environment displayed `exit` help messages.
- Retained error checking with direct `if errorlevel 1 goto failed` commands.

### 1.0.0.0.4 — 2026-09-10 17:31:56 UTC

- Documented portable package version `1.0.0.0.1`.
- Added the complete recompilable Dialog 2.22 runtime and GETHELP 4.0 dependency chain.
- Documented the build order for `DIALOGP.MAC`, `DIALOG.MAC`, `GETHELP.MAC`, `HELPHELP.MAC`, and `GREP.MAC`.
- Documented same-directory loading inside GREP, Dialog, and GETHELP.

### 1.0.0.0.3 — 2026-09-10 16:59:51 UTC

- Documented portable package version `1.0.0.0.0`.
- Documented automatic support-file discovery relative to `GREP.MAC` using `CurrMacroFilename()`.
- Clarified that the newly compiled `GREP.MAC` and all runtime support files must remain together in one directory.

### 1.0.0.0.2 — 2026-09-10 16:52:20 UTC

- Reworded the TSE SAL recompilation rule from “by definition” to the clearer phrase “by design.”
- Documented that `INI.S` is intentionally blocked from compiling under Win32 TSE.
- Added the correct SAL 4.50 command, `sc32 grep.s`, and warned against using `sc32 *.s` for this mixed DOS/Win32 source package.

### 1.0.0.0.1 — 2026-09-10 16:49:50 UTC

- Added the TSE SAL rule that `.MAC` files must always be recompiled when using a different TSE SAL version.
- Replaced the earlier statement that recompiling `GREP.S` was normally unnecessary.

### 1.0.0.0.0 — 2026-09-10 16:46:02 UTC

- Created the first Markdown description and help document for GREP1621.
- Documented installation, interactive use, shortcuts, search options, result-list controls, DOS command-line use, limitations, and troubleshooting.
- Based the instructions on the files and original documentation contained in `grep1621.zip`.

Future revisions should increment the final component sequentially: `1.0.0.0.6`, `1.0.0.0.7`, and so on.

## Document information

- Document: `grep1621_readme.md`
- Document version: `1.0.0.0.5`
- Created: 2026-09-10 16:46:02 UTC
- Last updated: 2026-09-10 17:37:23 UTC
- Source package: `grep1621.zip`
- Program documented: GREP 2.1 for TSE Pro 2.5 (DOS/16-bit)
- Original program author: Christopher Antos
- Documentation generated by: OpenAI Codex (GPT-5)
