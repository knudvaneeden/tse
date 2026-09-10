# GREP3230 for The SemWare Editor (TSE)

**README version:** 1.0.0.0.1  
**Updated:** 2026-09-10 20:02:38 CEST  
**Package version:** GREP v3.0  
**Original package date:** 2002-05-15  
**Original author:** Christopher Antos

## Description

GREP3230 is a powerful search macro for The SemWare Editor Professional (TSE Pro/32). It searches one or more files for text and displays the matching files and lines in a navigable results list.

The macro can search in the background, allowing editing to continue during a long search. A context window can show surrounding lines for the selected match, and recent searches can be revisited with Back and Forward commands.

According to the supplied documentation, GREP v3.0 was designed for TSE versions 2.6, 2.8, 3.0, and 4.0, including the console and GUI editions of TSE 4.0. Compatibility with newer TSE releases should be tested in the user's environment.

## Main features

- Searches multiple files for a text string.
- Supports ordinary text and TSE regular-expression searches.
- Can search subdirectories recursively.
- Can search loaded files or files stored on disk.
- Can restrict matches to whole words or ignore character case.
- Supports file and directory exclusion masks.
- Can list only filenames containing matches.
- Performs searches in the background.
- Shows matching lines in a results list.
- Provides a scrollable context window around the selected match.
- Remembers the ten most recent search-result lists.
- Can refresh a search after files have changed.
- Can load every file containing a match.
- Can locate function declarations in several programming languages.
- Can save and later reload an edited results list.

## Package contents

The portable source archive contains:

- `build.bat` — ordered build procedure for all five required macros.
- `grep.s`, `grep.hlp`, `grep.txt`, and `file_id.diz` — GREP source, help, and original documentation.
- `grepdlg.si`, `grepdlg.d`, and `grepdlg.dlg` — GREP dialog definitions.
- `dialog.s`, `dialogp.s`, `dialog.si`, `scpaint.si`, and `scwinclp.si` — selected Dialog v2.22 runtime sources.
- `GETHELP.SI`, `GETHELP.K32`, `GETHELP.DAT`, `GETHELP.HLP`, `HELPHELP.S`, and `COMPAT.SI` — selected GETHELP v4.0 sources and support data.
- `guiinc.inc` — shared console/GUI compatibility include file.
- `grep3230_readme.md` — this documentation.

The five `.mac` files are generated locally by `build.bat`, ensuring that they match the user's installed SAL compiler and TSE version.

## Portable package dependencies

The portable edition was assembled from GREP3230 and the following dependency archives:

- `dlg222.zip` — **required and included selectively**. GREP uses the Dialog v2.22 runtime. The portable package includes `dialog.s`, `dialogp.s`, `dialog.si`, `scpaint.si`, and `scwinclp.si`.
- `gethlp40.zip` — **required and included selectively**. GREP calls GETHELP to display topics from `grep.hlp`. The portable package includes the GETHELP source, compiled-data include, configuration data, its own help file, and HELPHELP source.
- `dlg222p.zip` — **not required and not included**. This is the Dialog programmer/example package; its documentation, demonstrations, tests, and generated dialog-data examples are not dependencies of GREP3230.

No files from `dlg222p.zip` are present in the final portable archive.

## Installation

1. Close TSE before replacing any macros that may already be loaded.
2. Extract `grep3230_portable_1.0.0.0.0.zip` to a directory of your choice.
3. Ensure `sc32.exe` is available through `PATH`.
4. Run `build.bat` in the extracted directory.
5. Confirm that the build created `dialogp.mac`, `dialog.mac`, `GETHELP.mac`, `HELPHELP.mac`, and `grep.mac`.
6. Keep the portable directory on TSE's macro search path, or copy the generated `.mac` files together with `grep.hlp`, `GETHELP.DAT`, and `GETHELP.HLP` to the TSE macro directory.
7. Start TSE.
8. Load `grep.mac` through TSE's macro-loading facility, or add `grep` to the TSE AutoLoad list.
9. Press **Alt+G** to open the GREP dialog.

## Compiling the source

The portable package includes `build.bat`, which compiles all required macros with the SAL compiler belonging to the installed TSE version. Keep all extracted files together and make sure `sc32.exe` is available through `PATH`.

Example:

```text
build.bat
```

The batch file changes to its own directory, so it can be started from any working directory. It stops immediately if a compilation fails.

Compilation occurs in this order:

1. `dialogp.s` creates `dialogp.mac`.
2. `dialog.s` creates `dialog.mac`.
3. `GETHELP.SI` creates `GETHELP.mac`.
4. `HELPHELP.S` creates `HELPHELP.mac`.
5. `grep.s` creates `grep.mac`.

After a successful compilation, keep all five generated `.mac` files available through TSE's macro search path. Restart TSE or purge and reload previously loaded copies before testing the new build.

## Running an interactive search

1. Press **Alt+G**.
2. Enter the text or expression in **Search for**.
3. Enter one or more file masks in **Files to search**, for example `*.s *.c *.h`.
4. If required, enter masks or directory names in **Files to exclude**.
5. Select the starting directory.
6. Enable the required search options, such as subdirectories, ignore case, whole words, regular expressions, filenames only, or verbose output.
7. Start the search.
8. Select a result and press **Enter** to open the corresponding file at the matching line.

Press **F1** in the GREP dialog or results list for the supplied context-sensitive help.

## Default keyboard shortcuts

| Shortcut | Action |
|---|---|
| **Alt+G** | Open the GREP dialog. |
| **Alt+Shift+G** | Redisplay the most recent GREP results. |
| **Ctrl+Alt+G** | Search the current file's directory for the word or marked block under the cursor. |
| **Ctrl+Shift+'** | Alternative shortcut for the current-directory search. |
| **Ctrl+'** | Search loaded files for the word or marked block under the cursor. |
| **Ctrl+G** | Find a function declaration, or list functions when no word is selected. |

## Working with the GREP results list

| Key | Action |
|---|---|
| **Enter** | Open the selected match. |
| **Ctrl+Enter** | Open another window and go to the selected match. |
| **Esc** | Close the results list while allowing a background search to continue. |
| **Ctrl+C** | Stop the search currently in progress. |
| **Up / Down** | Move through the results. |
| **Ctrl+Up / Ctrl+Down** | Scroll the context window vertically. |
| **Ctrl+Left / Ctrl+Right** | Scroll the context window horizontally. |
| **Shift+PgUp / Shift+PgDn** | Move to the previous or next file in the list. |
| **Del** | Remove the selected match, or all matches for the selected filename, from the list. |
| **Alt+E** | Edit the results list as a normal file so it can be saved. |
| **Alt+L** | Load all files that contain matches. |
| **F5** | Repeat the search and refresh the results. |
| **Alt+Left / Alt+Right** | Move backward or forward through recent result lists. |
| **F1** | Display help. |

## Search options

The following options are supported when GREP is invoked by a command line or another macro:

| Option | Meaning |
|---|---|
| `-^` | Anchor the search at the beginning of a line. |
| `-$` | Anchor the search at the end of a line. |
| `-b` | Search only the marked block in the current file. |
| `-c` | Search only the current file. |
| `-d` | Search subdirectories recursively. |
| `-eWild` | Exclude matching files or directories; multiple masks can be separated by commas or semicolons. |
| `-i` | Ignore differences between uppercase and lowercase characters. |
| `-l` | List only filenames containing matches. |
| `-m` | Search loaded files. |
| `-pPath` | Begin the disk search in the specified directory. |
| `-rFile` | Reload a previously saved GREP results file. |
| `-v` | Use verbose mode and show matches as they are found. |
| `-w` | Match whole words only. |
| `-x` | Interpret the search text as a TSE regular expression. |
| `-Bnumber` | Use the specified buffer ID as a list containing one filename per line. |

When GREP is called from another macro, its documented defaults are `-vm`.

## Examples

Open the dialog:

```text
grep
```

Search text files for `hello`:

```text
grep hello *.txt
```

Search case-insensitively through subdirectories:

```text
grep -di hello *.*
```

Search for a phrase containing spaces:

```text
grep "hello world" *.txt *.doc
```

Exclude executable and temporary files:

```text
grep -e*.exe;*.tmp hello *.*
```

Start in a specified directory:

```text
grep -pc:\src hello *.s *.c *.h
```

Search the current file only:

```text
grep -c hello
```

Reload a saved results list:

```text
grep -rsavedresults.txt
```

## Calling GREP from another SAL macro

Use `ExecMacro()` to invoke GREP programmatically. Examples:

```text
ExecMacro("grep -w")
ExecMacro("grep -c hello")
ExecMacro('grep "hello world" *.txt *.doc')
ExecMacro("grep -pc:\src hello *.s")
```

The source also exposes `GrepGetVersion()`. It returns the macro version through `MacroCmdLine`; GREP v3.0 reports hexadecimal version value `0300`.

## Configuration in `grep.s`

The source contains compile-time settings near the beginning of the file:

- `AUTO_HILITE` enables TSE find-list highlighting.
- `CONTEXT_WINDOW` enables the match context window.
- `CWBORDER` draws a border around the context window.
- `VARIATION` selects the interface: `0` for prompts, `1` for menus, or `2` for the dialog interface supplied in this package.
- `BACKGROUNDSEARCH` selects whether searches always run in the background.

Recompile `grep.s` after changing these definitions.

## Limitations and notes

- A single search expression cannot span multiple lines.
- Proximity searches, such as finding one word near another, are not supported.
- The supplied documentation warns that long filenames containing spaces are not supported in the **Files to search** or **Files to exclude** fields of the original release.
- Exclusion masks accept normal DOS wildcards, but malformed forms such as `*foo*.*` may behave unexpectedly.
- The original documentation refers to an optional `G.BAT` DOS-prompt launcher, but that batch file is not present in the supplied archive. GREP can still be run inside TSE or from another SAL macro.
- `-Bnumber` transfers ownership of the specified file-list buffer to GREP; GREP may modify and free that buffer.
- Restart TSE after replacing a loaded compiled macro if the old version remains active.

## Version history of this README

### 1.0.0.0.1 — 2026-09-10 20:02:38 CEST

- Converted the distribution into a self-contained portable source package.
- Added the ordered `build.bat` compilation procedure.
- Included only the files required from Dialog v2.22 and GETHELP v4.0.
- Documented why `dlg222.zip` and `gethlp40.zip` are necessary.
- Documented why `dlg222p.zip` was skipped.

### 1.0.0.0.0 — 2026-09-10 19:54:47 CEST

- Created the initial Markdown description and help for the GREP3230 package.
- Documented installation, compilation, interactive use, shortcuts, results-list controls, search options, examples, SAL invocation, configuration, and known limitations.
- Verified the documented features and package contents against the supplied archive, source file, text documentation, and help file.
