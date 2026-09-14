# KEYASSIG — Keyboard Assignment Help for TSE

**README version:** 1.0.0.0.30  
**Updated:** 2026-09-14 01:25:10 UTC  
**Session:** Create KEYASSIG MarkDown Readme

## Description

KEYASSIG is a package of two TSE SAL macros that inspect the keyboard assignments defined in the TSE user-interface file:

- `KEYASSGN.S` displays the command assigned to a key that you press.
- `KEYFIND.S` searches the keyboard definitions for keys, commands, comments, or other text.

The updated `KEYASSGN.S` asks for the `.UI` source file whenever it is loaded. It also searches the `.S` source files found on disk for all macros that are currently loaded in TSE. The current working directory has first priority.

For debugging, every source file actually added to the search is recorded by full pathname in `keyassgn_search_paths.txt`. The entries occur in the exact order in which their contents are searched.

Before collecting the macro sources, KEYASSGN makes TSE rebuild its live Purge Macro list. Version `1.0.0.0.12` introduced the user-supplied working pattern directly: `NewFile()`, a plain `list_startup()` procedure, `Hook(_LIST_STARTUP_, list_startup)`, queued `Escape`, `PurgeMacro()`, and `UnHook(list_startup)`. The captured list is processed only after `PurgeMacro()` returns.

Testing confirmed that the captured fixed-width records contain a leading space, the visible macro name, padding, and an internal flag. The current parser reads the bounded record, trims its leading space, and extracts only its first space-delimited field.

Version `1.0.0.0.30` supports 32-bit TSE on Windows, TSE Linux under WSL, and TSE on native Linux. It uses `WhichOS()` for runtime platform decisions and widens the output popup to the available screen width.

The package was originally written by Dieter Koessl and donated to the public domain. The included source history identifies `KEYASSGN.S` and `KEYFIND.S` as version 3.01 dated 1997-04-18.

## Package Contents

| File | Purpose |
|---|---|
| `KEYASSGN.S` | Shows the command and description assigned to a pressed key |
| `KEYFIND.S` | Searches and lists matching key assignments |
| `KEYTABLE.SI` | Legacy key-code table retained from the original package; version 29 uses `KeyName()` |
| `READ.ME` | Original documentation |
| `FILE_ID.DIZ` | Short package description |

## Requirements

- The SemWare Editor (TSE) with its SAL compiler.
- Access to the UI source file containing the active key definitions.
- `KEYASSGN` searches TSEPath's `ui` locations for `tse.ui` as its initial suggestion, but lets you enter any `.UI` source filename.
- The `.S` source of a loaded macro can be in the current directory, beside its `.MAC` file, or somewhere on TSE's normal macro search path.

Compile `KEYASSGN.S` with the SAL compiler supplied with the target 32-bit TSE installation. Use the Windows compiler for Windows TSE and the Linux compiler for TSE Linux. Compile separately on each target rather than copying a Windows `.MAC` to Linux.

## Installation

1. Extract `keyassig.zip` into a working directory.
2. Compile the macros:

   ```text
   sc32 KEYASSGN.S
   sc32 KEYFIND.S
   ```

3. Copy the resulting `KEYASSGN.MAC` and `KEYFIND.MAC` files to a directory from which TSE can load macros.
4. You may keep the `.S` source files in the current working directory. This location is searched first. Otherwise, keep each source beside its corresponding loaded `.MAC` file or on TSE's macro search path.

### Linux and WSL Paths

Use Linux pathnames when running TSE Linux:

- WSL example: `/mnt/c/temp`
- Native Linux example: `/home/knud/tse/macros`

Do not enter Windows syntax such as `C:\TEMP` into TSE Linux. For multiple additional directories, use the path-list syntax accepted by the Linux TSE `SearchPath()` implementation and configuration.

On Linux, loaded macro names are normally reported in uppercase while source files commonly use lowercase. Version 29 lowercases the derived macro basename before looking for its `.s` and `.mac` files. Therefore, lowercase filenames such as `template.s` are recommended on case-sensitive Linux filesystems.

## How to Run KEYASSGN

1. Start TSE.
2. Execute the macro `KEYASSGN` using TSE's macro execution command.
3. Enter the full filename of the `.UI` source file used by your TSE configuration. The previous entries are available through TSE's edit history.
4. Press `Enter`. Pressing `Escape` cancels without opening the key-assignment window.
5. At the next prompt, press the key or key combination you want to inspect.
6. `KEYASSGN` searches sources in this priority order:

   1. The `.S` sources corresponding to macros currently loaded in TSE.
   2. The selected `.UI` source as the fallback.

   For each loaded macro, its `.S` source is located in this order:

   1. The current working directory.
   2. Any additional macro directories entered by the user.
   3. Directories on TSE's normal search path.
   4. The directory containing a resolved `.MAC` file.
   5. Conventional `mac` subdirectories below TSEPath entries.

7. The popup displays:

   - the recognized key name;
   - the assigned TSE command;
   - the comment or description found in the UI definition, when present.
   - `File:` followed by the full pathname of the source file containing the resolved key assignment.

8. For a two-key assignment, press the first key and then the second key when prompted.
9. Press `Escape` to close the popup and unload the macro. TSE then goes directly to the `keyassgn_search_paths.txt` buffer, positioned at its first line.

## Debug Search-Path File

Each run creates or overwrites this file in TSE's current working directory—the directory reported by the TSE `CurrDir()` command:

```text
keyassgn_search_paths.txt
```

Its contents are ordered exactly like the combined search data:

1. The full path of the first loaded macro `.S` source found and searched.
2. The remaining located macro sources, in the order in which they are searched.
3. The full path of the selected `.UI` source file, searched last as the fallback.

Only files whose contents were actually loaded into the search buffer are listed. A loaded macro whose `.S` source cannot be found is skipped and therefore does not appear in the debug file.

The loaded-macro list is refreshed on every KEYASSGN run. It is not copied from a potentially stale internal list buffer.

When you press `Escape` to leave the KEYASSGN popup, the macro preserves this buffer and makes it the current TSE buffer. You can therefore inspect the ordered paths immediately without locating the file manually. The buffer represents the saved `keyassgn_search_paths.txt` file and can be closed normally when no longer needed.

If no definition is found, the macro reports `not assigned`. If the matching line does not have a valid key-definition format, it reports `invalid keydefinition`.

### Symbolic Key Constants

`KEYASSGN` recognizes key assignments that use a named constant. For example:

```sal
constant TEMPLATE_MENU = <CtrlAltShift F8>

<TEMPLATE_MENU> TemplateMenu()
```

When `<CtrlAltShift F8>` is pressed, the macro first extracts `TEMPLATE_MENU` from the active constant declaration. It then finds `<TEMPLATE_MENU>` and reports `TemplateMenu()` as the assigned command. A commented-out constant declaration is ignored because an active declaration must begin with `constant`, apart from optional whitespace.

The popup also reports the full pathname of the source containing `<TEMPLATE_MENU> TemplateMenu()`. For the supplied example this should be:

```text
F:\BBC\TAAL\template.s
```

## How to Run KEYFIND

1. Start TSE.
2. Execute the macro `KEYFIND`.
3. Enter one or more search strings. Separate multiple strings with commas.
4. Enter `all` to list the entire key-assignment file.
5. Press `Enter` to display the matching assignments.
6. In the results list, use:

   - `Alt-K` to sort by key;
   - `Alt-C` to sort by command;
   - `Enter` to search within the displayed list;
   - `Escape` to close the list.

The search is case-insensitive and uses the TSE regular-expression search supported by the macro.

## Optional Help Menu Entries

The original documentation suggests adding the following entries to the `HelpMenu()` definition in the UI source:

```sal
"&Find Key...",             ExecMacro("keyfind")
"&Display Assignments...",  ExecMacro("keyassgn")
```

After changing the UI source, reinstall or recompile the UI according to the procedure for your TSE installation.

## Troubleshooting

### Cannot load UI file

Check the filename entered at the new UI-file prompt. Enter an existing `.UI` source file, including its full drive and directory when necessary.

### Cannot find UI file

`KEYFIND` could not open the configured UI source. Correct the path declarations and recompile the macro.

### Cannot allocate a work buffer

TSE could not create a temporary buffer. Close unnecessary files or applications and try again.

### Results do not match the active keys

Make sure the macros read the same UI source from which the currently installed TSE interface was built. If you changed the UI file, reinstall the UI and restart TSE if necessary.

### A key is reported as not assigned

The key may genuinely be unassigned. A definition in another macro can only be found when that macro is currently loaded and its same-name `.S` source can be found in the current directory, beside the `.MAC` file, or through TSE's macro search path.

## Version History

### 1.0.0.0.30 — 2026-09-14 11:52:45 UTC

- Widens the key-assignment output popup from fixed columns 5–76 to columns 2 through `Query(ScreenCols) - 1`.
- Gains six text columns on an 80-column display and automatically uses additional width on wider TSE displays.
- Keeps a one-column margin so the popup remains visibly bounded.
- Retains the Windows, WSL Linux, and native Linux support introduced in version 29.

### 1.0.0.0.29 — 2026-09-14 01:25:10 UTC

- Adds support for 32-bit TSE on Windows, TSE Linux under WSL, and native Linux.
- Uses `WhichOS() == _LINUX_` for runtime platform distinctions.
- Finds the default `tse.ui` through TSEPath's `ui` locations instead of constructing a Windows backslash path from `LoadDir()`.
- Uses lowercase derived `.s` and `.mac` basenames on Linux for case-sensitive filesystems.
- Uses `KeyName()` for both supported 32-bit platforms and removes the legacy DOS-style key-table runtime branch.
- Provides a Linux-specific additional-directory prompt.
- Documents WSL `/mnt/c/...` and native Linux `/home/...` pathname forms.
- Preserves the confirmed Windows version 28 search and popup behavior.

### 1.0.0.0.28 — 2026-09-14 01:13:10 UTC

- Breakpoint 5 was confirmed successful: all 35 resolvable loaded-macro sources were inserted in order.
- Restores the normal operational flow after the completed diagnostic stages.
- Searches the loaded macro `.S` sources first.
- Appends and searches the selected `.UI` source last as the fallback.
- Restores the interactive key-assignment popup and defining-file display.
- Retains the additional macro-directory prompt for unusual locations such as `C:\TEMP`.
- Retains `keyassgn_parsed_macros.txt`, `keyassgn_load_trace.txt`, and `keyassgn_search_paths.txt` for debugging.
- Pressing `Escape` from the popup opens the ordered search-path buffer.

### 1.0.0.0.27 — 2026-09-14 00:54:10 UTC

- The hexadecimal view revealed that each captured fixed-width record begins with byte `20`, a leading space.
- Version 26 therefore requested token 1 from a string whose first token was empty.
- Changes extraction to `GetToken(Trim(lineText), " ", 1)`.
- The initial `Trim()` removes the leading space; `GetToken()` then returns the macro name before the padded remainder.
- Retains the parsed-name file, load trace, search-path file, and breakpoint 5.

### 1.0.0.0.26 — 2026-09-14 00:50:10 UTC

- Version 25 again produced only the trace header, proving its character-at-a-time parser returned no names.
- Restores the reliable whole-line `GetText(1, lineLength)` operation.
- Extracts only the first fixed-record field with `GetToken(lineText, " ", 1)`.
- Excludes the internal padding and trailing list flag without using `CurrChar(position)` or `GetText(column, 1)`.
- Saves the normalized names to `keyassgn_parsed_macros.txt` before any path resolution or source loading.
- Retains `keyassgn_load_trace.txt`, `keyassgn_search_paths.txt`, and breakpoint 5.

After testing, the three diagnostic files independently show the parsed names, per-stage loading progress, and successfully searched paths.

### 1.0.0.0.25 — 2026-09-14 00:45:10 UTC

- Version 24 completed without crashing in both tested TSE versions but displayed an empty combined buffer.
- Its trace contained only the header and its search-path file was empty, proving the loading loop never processed its first entry.
- Changes the all-source loading loop to iterate over the already verified normalized `parsed_macros_id` buffer.
- The original fixed-width captured buffer is now used only once, during normalization.
- Retains breakpoint 5 and the persistent trace for verification.

### 1.0.0.0.24 — 2026-09-14 00:40:10 UTC

- The version 23 trace isolated the crash before resolving the first macro, `KEYASSGN`.
- Revealed that each visually short list line contains the macro name, internal space padding, and a trailing flag near column 255.
- `Trim(GetText(1, CurrLineLen()))` removed only outside whitespace and retained the internal padding and flag.
- Replaces whole-line extraction with `GetText(column, 1)` for each character.
- Stops at the first whitespace, control character, non-ASCII character, or the 255-character limit.
- Prevents malformed padded list records from being passed to `SplitPath()` and `SearchPath()`.
- Retains the persistent per-stage load trace and breakpoint 5.

### 1.0.0.0.23 — 2026-09-14 00:36:10 UTC

- Breakpoint 5 crashed silently while iterating through all loaded macros.
- Adds the persistent diagnostic file `keyassgn_load_trace.txt` in TSE's current working directory.
- Saves the trace immediately after every individual stage so useful evidence remains after a TSE crash.
- Records `BEGIN`, macro name, `RESOLVED`, full source path, `INSERTING`, and `LOADED` or `LOAD FAILED`.
- Records `SOURCE NOT FOUND` when a macro name cannot be resolved.
- The last trace entries identify the macro and operation active at the crash.

After reproducing the crash, open `keyassgn_load_trace.txt` and inspect or provide its final approximately ten lines.

### 1.0.0.0.22 — 2026-09-14 00:32:10 UTC

- Breakpoint 4 was confirmed successful: `C:\TEMP\ddd.s` was loaded and displayed.
- Adds breakpoint 5 to resolve and load the `.S` sources for all captured macros.
- Removes unnecessary `PushBlock()` and `PopBlock()` calls around `InsertFile()`.
- Preserves and displays the combined macro-source buffer after unloading KEYASSGN.
- Writes the successfully loaded source paths to `keyassgn_search_paths.txt` in search order.
- Does not load or search the selected `.UI` source and does not open the key-assignment popup.
- The status line reports `Breakpoint 5: all resolved macro sources loaded; no UI`.

### 1.0.0.0.21 — 2026-09-14 00:27:10 UTC

- Breakpoint 3 was confirmed successful: `DDD` resolved to `C:\TEMP\ddd.s`.
- Adds breakpoint 4 to test loading one resolved source file independently.
- Loads only the selected macro's `.S` file into a new buffer with `InsertFile()`.
- Unloads KEYASSGN and displays the loaded source buffer at its first line.
- Does not load any other macro source and does not load or search the `.UI` file.
- The status line reports `Breakpoint 4: one resolved macro source loaded`.

### 1.0.0.0.20 — 2026-09-14 00:23:10 UTC

- Breakpoint 3 reached pathname resolution normally but reported `[SOURCE NOT FOUND]` for `DDD`.
- Corrected the resolver so it no longer assumes every TSEPath source is inside a `mac` subdirectory.
- Uses `SearchPath(name, ".")` for the explicit current-working-directory check.
- Asks for optional additional macro directories separated by semicolons.
- Searches those additional directories after the current directory and before TSEPath.
- This permits a name-only live-list entry such as `DDD` to resolve a macro loaded from `C:\TEMP`.
- Searches the configured TSEPath directories directly before trying their `mac` subdirectories.
- Searches beside a located `.MAC` file in both direct and `mac`-subdirectory cases.
- Retains breakpoint 3 and still does not load or search source contents.

### 1.0.0.0.19 — 2026-09-14 00:17:10 UTC

- Breakpoint 2 was confirmed successful: the parsed list contains `DDD`.
- Adds breakpoint 3 to test pathname resolution independently.
- Asks for one loaded macro name, defaulting to `DDD`.
- Resolves only that macro using the current-directory, adjacent-`.MAC`, and TSE-path search order.
- Displays the macro name and resolved full `.S` pathname in a separate buffer.
- Does not call `InsertFile()` and does not search the `.UI` source.
- The status line reports `Breakpoint 3: one macro path resolved; no source loaded`.

### 1.0.0.0.18 — 2026-09-14 00:14:20 UTC

- Corrected the parser after breakpoint 2 produced an empty buffer.
- Replaced character-by-character `CurrChar(position)` processing with `GetText(1, lineLength)`.
- Limits `lineLength` to SAL's 255-character string capacity and trims surrounding whitespace.
- Retains breakpoint 2 and still performs no pathname lookup or source loading.
- If successful, the displayed buffer will contain the parsed names, including `DDD`.

### 1.0.0.0.17 — 2026-09-14 00:11:30 UTC

- Diagnostic build containing breakpoint 2.
- Captures TSE's live macro list using the confirmed working hook procedure.
- Reads the leading printable name from every captured line into a separate buffer.
- Unloads KEYASSGN and displays that parsed-name buffer at its first line.
- Does not call `SplitPath()`, `SearchPath()`, or `InsertFile()`.
- Does not load macro `.S` files or search the selected `.UI` source.
- The status line reports `Breakpoint 2: parsed macro names; no path lookup performed`.

If this buffer still contains `DDD`, capture and name parsing are both correct. The next diagnostic version can then test pathname resolution independently.

### 1.0.0.0.16 — 2026-09-14 00:06:45 UTC

- Diagnostic build that stops immediately after TSE's live macro list has been copied.
- Unhooks `_LIST_STARTUP_` and unloads KEYASSGN before showing the captured buffer.
- Preserves the captured buffer unchanged and positions it at its first line.
- Does not parse macro names, resolve source paths, load `.S` files, or search the selected `.UI` file.
- The status line reports `Breakpoint 1: captured loaded-macro list; no parsing performed`.
- This breakpoint isolates the capture stage from every later operation.

### 1.0.0.0.15 — 2026-09-14 00:00:51 UTC

- Updated the parser using the successful standalone capture result.
- Reads each displayed macro name directly from column 1.
- Builds the name one printable ASCII character at a time.
- Stops before whitespace, control bytes, non-ASCII bytes, or the 255-character SAL limit.
- Removed all column-12, column-13, and raw-record decoding assumptions.
- Removed the separate unsafe-name scan because unsafe characters never enter the returned name.

### 1.0.0.0.14 — 2026-09-13 23:52:04 UTC

- Fixed the TSE access violation introduced by treating an internal list record as a filename.
- Added bounds-checked extraction of raw loaded-macro records.
- Reads the macro-name length from byte 12 and the name from column 13 only when the record is valid.
- Supports plain-text captured list entries as a fallback.
- Rejects extracted names containing control characters before calling `SplitPath()`, `SearchPath()`, or `ExpandPath()`.
- Does not destructively rewrite the captured list buffer.

### 1.0.0.0.13 — 2026-09-13 23:45:59 UTC

- Fixed the correctly captured macro list being destroyed during post-processing.
- Removed `RemoveMacroListColumns()` from the `list_startup()` capture route.
- The visible Purge Macro list already contains plain macro names and is now processed directly.
- The old column decoder applied only to raw internal buffer 4 and was incompatible with this capture method.
- Fixes the debug output containing only the UI pathname despite the macro list visibly flashing on screen.

### 1.0.0.0.12 — 2026-09-13 23:38:47 UTC

- Replaced the previous loaded-macro capture implementation with the supplied working source pattern.
- Uses `loaded_macros_id = NewFile()` rather than a temporary buffer.
- Uses a plain `proc list_startup()` with the exact `PushLocation`, `PushBlock`, `MarkLine`, `GotoBufferId`, `CopyBlock`, `PopBlock`, and `PopLocation` sequence.
- Installs the hook, queues `Escape`, calls `PurgeMacro()`, and removes the hook directly from `Main()`.
- Formats and searches the captured list only after the live Purge Macro window has closed.

### 1.0.0.0.11 — 2026-09-13 23:30:29 UTC

- Fixed live macro-list capture still returning no macro sources.
- Saved the original user buffer ID at the beginning of `WhenLoaded()`.
- Restored that normal editing buffer before `Main()` begins.
- Prevents `PurgeMacro()` from being invoked while KEYASSGN's temporary/system buffer is current.
- Preserved the corrected block-copy sequence from version `1.0.0.0.10`.

### 1.0.0.0.10 — 2026-09-13 23:26:11 UTC

- Fixed the refreshed loaded-macro list being copied as empty.
- Removed `EmptyBuffer()` from between `MarkLine()` and `CopyBlock()` in the list-startup callback.
- The callback now follows the proven TSE macro-list capture sequence exactly.
- Fixes the debug buffer containing only the UI pathname while omitting loaded macros such as `DDD.MAC`.

### 1.0.0.0.9 — 2026-09-13 23:22:30 UTC

- Fixed KEYASSGN failing to complete macro loading after the live-list change.
- Moved the Purge Macro list refresh and capture from `WhenLoaded()` to `Main()`.
- KEYASSGN now finishes loading before it invokes TSE's live macro-list interface.
- Preserved the refreshed list, loaded-macro-first search order, UI fallback, debug buffer, and source-file display.

### 1.0.0.0.8 — 2026-09-13 23:17:51 UTC

- Fixed newly loaded macros sometimes being absent from the search.
- TSE's live Purge Macro list is now rebuilt on every KEYASSGN run.
- The refreshed list is captured during the list-startup event.
- A queued `Escape` closes the temporary list without purging any macro.
- Newly loaded macros such as `DDD.MAC` can now be included immediately when their `.S` source is found.

### 1.0.0.0.7 — 2026-09-13 22:56:50 UTC

- Reversed the top-level key-definition search priority.
- Loaded macro `.S` sources are now searched first.
- The selected `.UI` source is searched last as the fallback.
- Updated `keyassgn_search_paths.txt` to show the same revised order.
- A loaded macro definition now takes priority when the same key is also defined in the UI source.

### 1.0.0.0.6 — 2026-09-13 21:59:47 UTC

- Added source-boundary markers to the combined internal search buffer.
- Added a `File:` field to the key-assignment popup.
- The field shows the full pathname of the file containing the resolved key-definition line.
- Symbolic assignments report the source containing `<CONSTANT_NAME> command`, not merely the constant declaration.

### 1.0.0.0.5 — 2026-09-13 21:55:41 UTC

- Added resolution of symbolic key constants such as `constant TEMPLATE_MENU = <CtrlAltShift F8>`.
- The symbolic `<TEMPLATE_MENU>` assignment is followed to its actual command, such as `TemplateMenu()`.
- Commented-out constant declarations are excluded.
- Direct key searches are anchored at the start of key-definition lines, avoiding unrelated occurrences in comments or code.
- Corrected `TranslateKey()` so it restores the buffer that was active before escaping the search expression.

### 1.0.0.0.4 — 2026-09-13 21:49:13 UTC

- Preserved the debug-path buffer when KEYASSGN is closed with `Escape`.
- Made the debug buffer current after the popup closes.
- Positioned the cursor at the beginning of the debug buffer.
- Clarified that the disk file is stored in TSE's current working directory.

### 1.0.0.0.3 — 2026-09-13 21:44:22 UTC

- Added `keyassgn_search_paths.txt` for debugging.
- The debug file is written to the current working directory.
- Every entry is a full source-file path.
- Paths are listed in the exact order in which the UI and macro sources are searched.
- The debug file is overwritten on each run so that it represents the current search.

### 1.0.0.0.2 — 2026-09-13 21:37:59 UTC

- Changed loaded-macro source discovery to search the current working directory first.
- The directory of the resolved `.MAC` file is searched next.
- Other TSE macro search-path directories are searched afterward.
- Updated the installation, operation, and troubleshooting documentation.

### 1.0.0.0.1 — 2026-09-13 21:30:50 UTC

- Changed `KEYASSGN.S` to ask for the `.UI` source-file location.
- Added edit-history support to the filename prompt.
- Added searching of on-disk `.S` sources for all currently loaded TSE macros.
- Sources beside their resolved `.MAC` files are preferred; TSE's normal macro search path is used as a fallback.
- Missing macro source files are skipped safely.
- Updated the installation, operation, and troubleshooting instructions.

### 1.0.0.0.0 — 2026-09-13 19:47:23 UTC

- Created the Markdown description and help file.
- Documented package contents, requirements, compilation, installation, and operation.
- Documented both `KEYASSGN` and `KEYFIND`.
- Added UI configuration, optional Help menu entries, keyboard controls, and troubleshooting information.

Future documentation revisions can continue as `1.0.0.0.30`, `1.0.0.0.31`, and so on.

## Copyright and Disclaimer

According to the original `READ.ME`, the program was donated to the public domain and may be used or altered at the user's own risk.
