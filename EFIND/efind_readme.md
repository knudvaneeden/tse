# eFind for TSE Pro

**README version:** 1.0.0.0.0  
**eFind source version:** 2.0.2  
**Created:** 2026-09-06 22:36:17 UTC  
**Original author:** Carlo Hogeveen

## Description

eFind is a TSE SAL macro for searching through a very large number of files that are already open in The SemWare Editor Professional (TSE Pro).

TSE can keep files open without loading all of them into memory. eFind takes advantage of this behavior: it temporarily loads each file while searching it and unloads the file again immediately afterward. This makes it possible to search more open files than would normally fit in memory.

The macro can also perform an action for every match, including deleting matching lines, appending matching text to the clipboard, counting matches, and keeping or abandoning matching files.

## Package contents

- `eFind.s` — TSE SAL source code, version 2.0.2.
- `File_Id.diz` — short package description.

## Requirements

- TSE Pro 2.5e or later.
- The TSE SAL compiler appropriate for your TSE installation, such as `sc32.exe` for 32-bit TSE.
- Sufficient access to TSE's macro directory.

## Installation

1. Extract `efind.zip` to a temporary directory.
2. Copy `eFind.s` to the TSE `mac` directory, or open a command prompt in the directory containing `eFind.s`.
3. Compile the macro:

   ```bat
   sc32 eFind.s
   ```

4. Confirm that compilation creates the compiled macro, normally `eFind.mac`.
5. If you compiled it outside the TSE macro directory, copy `eFind.mac` to that directory.
6. Start or restart TSE if necessary so the compiled macro is available.

## Preparing files for a search

eFind searches files that are already open in TSE. Open the required files first. For a large group of files, use TSE's normal file-opening facilities, wildcards, and suitable open options such as `-a` and `-s` where appropriate.

Avoid commands or other macros that force all open files to load into memory while working with a file set that is larger than available memory.

## How to run eFind

Run the macro from TSE's **Execute Macro** command or enter it on the TSE macro command line.

### Interactive search

```text
efind
```

Choose **Find**, **Again**, or **Find and Do** from the menu. When prompted, enter the search text and TSE search options.

The following forms also start interactive operation:

```text
efind find
efind find&do
```

### Repeat the previous search

```text
efind again
```

### Supply a search on the command line

```text
efind find search_value search_options
```

Example:

```text
efind find TODO aiv
```

Search options use TSE's normal Find option syntax. eFind assumes the `n` option; omitting it has no effect. The `a` option is used for searching across files, and the `v` option displays a View Finds list.

If a search value contains spaces or requires special parsing, interactive mode is the safest choice.

### Low-level mode

Prefix the function with `l` to use the low-level mode, which emulates TSE's low-level `lFind` behavior and suppresses normal messages and beeps:

```text
efind l
efind lfind
efind lfind&do
efind lagain
efind lfind search_value search_options
```

## Find and Do actions

When **Find and Do** is selected, eFind can apply one of these actions to each match:

- **Delete Line** — deletes the matching line.
- **Cut Append** — cuts matching content and appends it to the clipboard.
- **Copy Append** — copies matching content and appends it to the clipboard.
- **Count** — counts the matches.
- **Keep File** — keeps files containing the search value.
- **Abandon File** — abandons files containing the search value.

Keeping or abandoning matching files can be repeated with different searches to narrow a very large set of open files step by step.

## Results and cancellation

- With the View Finds option, select an entry to go to its location.
- Press `Esc` to leave a menu, prompt, or results list.
- The macro places the number of found lines in TSE's `MacroCmdLine` value. Cancelling the View Finds list returns zero.

## Important differences from TSE Find

- Found words are not highlighted.
- File lines in a View Finds list are not colored.
- The `n` search option is always assumed.
- Replace is not implemented in this version.
- The `c` option cannot be combined with `a` or `v`.
- Searching across files with `a` is not allowed from a hidden or system buffer.

## Limitations and cautions

- In TSE versions earlier than 3.0, eFind can change file buffer IDs. This may affect other macros that expect buffer IDs to remain unchanged.
- TSE versions earlier than 3.0 can become unstable after more than 65,536 files have been loaded during one session.
- TSE Pro 3.0 through 4.4 can become unstable after more than 32,768 files have been loaded during one session.
- TSE versions through 4.4 do not safely support buffer IDs above 65,535, and `AbandonFile()` is limited in TSE Pro 3.0 through 4.4.
- eFind checks these historical limits and refuses to run when the current file count is unsafe for the detected TSE version.

## Troubleshooting

### TSE cannot find `efind`

- Confirm that `eFind.s` compiled successfully.
- Confirm that `eFind.mac` is in TSE's configured macro directory.
- Check the compiler output for errors.
- Restart TSE and try the command again.

### eFind reports too many files

The number of open or previously loaded files exceeds a safe limit for that TSE version. Close files or restart TSE with a smaller file set.

### No matches are found

- Verify that the intended files are open in TSE.
- Check the search text and TSE search options.
- Use interactive mode to avoid command-line parsing issues.
- Remember that searching for an empty string is rejected.

### Memory usage still becomes high

Another TSE command or macro may have loaded every open file. Restart TSE, reopen the required files, and avoid commands that access all file contents before running eFind.

## Version history

### 1.0.0.0.0 — 2026-09-06 22:36:17 UTC

- Initial Markdown README for the supplied eFind package.
- Documented installation, interactive and command-line use, low-level mode, actions, limitations, and troubleshooting.

Future README revisions should increment the final component sequentially:

```text
1.0.0.0.0
1.0.0.0.1
1.0.0.0.2
```

## Original software history

- eFind 1.00 — first public release, 18 August 2005.
- eFind 2.00 — version checking revised and external macro dependencies removed, 29 April 2006.
- eFind 2.01 — unimplemented Replace option removed and empty-search checks added, 4 May 2006.
- eFind 2.0.2 — excessive-open-file warning logic improved, 1 July 2007.

## License

No explicit license file is included in the supplied archive. Retain the original author information and source notices when redistributing or modifying the macro, and contact the original author if licensing clarification is required.
