# INCSEA — Improved Incremental Search for TSE

**README version:** 1.0.0.0.1  
**Date:** 11 September 2026  
**Time:** 12:48:41 UTC  
**Session:** Create INCSEA MarkDown Readme

## Description

INCSEA contains `incrsrch.s`, an improved incremental-search macro for The SemWare Editor (TSE). It was written by Tony L. Burnett and is based on TSE's original `mIncrementalSearch` routine.

The routine searches while you type and adds several controls to the original incremental search. You can change the search direction, move between matches and open files, and toggle matching options without leaving the search.

The supplied source identifies the original search routine as version 1.11, dated 26 January 1995. The current file also contains a `Main()` procedure that calls `mIncrementalSearch()`. It can therefore be compiled and run directly as a normal TSE macro; rebuilding the TSE user interface is not required.

## Features

- Searches incrementally as each character is typed.
- Finds the next or previous occurrence.
- Starts a search from the beginning or end of the current buffer.
- Toggles case-insensitive, regular-expression, whole-word, beginning-of-line, and end-of-line matching.
- Moves to the next or previous file in TSE's file ring while searching.
- Displays quick help with `F1`.
- Restores the original cursor position when the search is cancelled.
- Keeps typed characters in the search string even when no match is found.
- Adds an accepted search string to TSE's find history.

## Archive contents

| File | Purpose |
| --- | --- |
| `incrsrch.s` | Standalone SAL macro containing `Main()`, `mIncrementalSearch`, its option helper, and the quick-help definition. |

## Requirements

- The SemWare Editor (TSE).
- The TSE SAL compiler, such as `sc32.exe`, to create `incrsrch.mac`.

The added `Main()` entry point makes this a standalone loadable macro. It does not need to replace the incremental-search routine in `tse.ui`.

## Installation and compilation

1. Copy `incrsrch.s` to a working directory.
2. Open a command prompt in that directory.
3. Compile the source with the TSE SAL compiler:

   ```text
   sc32 incrsrch.s
   ```

4. Verify that compilation completes successfully and creates `incrsrch.mac`.
5. Copy `incrsrch.mac` to a directory from which TSE can load macros, or leave it in the current directory when running it by its full path.

If `sc32.exe` is not on the command path, invoke it using its full path or compile the source through your existing TSE macro-compilation setup.

## How to run it

1. Open a text file in TSE.
2. Run the compiled macro using TSE's **Macro Execute** command and select `incrsrch.mac`.
3. Alternatively, execute it from TSE's command line by entering the macro name, according to your TSE configuration.
4. The macro's `Main()` procedure immediately calls `mIncrementalSearch()`.
5. Type the text to find. TSE searches as the text is entered.
6. Use the commands below to navigate or change matching options.
7. Press `Enter` to accept the current match, or `Escape` to cancel and return to the original cursor position.

For frequent use, assign an unused key to execute `incrsrch.mac` through TSE's key-assignment facilities.

The status line displays the current search options and search text in the form `I-Search [options]: text`.

## Search keys

| Key | Action |
| --- | --- |
| `F1` | Display the quick-help screen. |
| `Backspace` | Remove the last character from the search string. |
| `Enter` | Stop searching and leave the cursor on the current match. |
| `Escape` | Cancel and return the cursor to its original position. |
| `Ctrl+L` | Find the next match. |
| `Ctrl+K` | Find the previous match. |
| `Ctrl+B` | Search from the beginning of the buffer. |
| `Ctrl+E` | Move to the end of the buffer and search backward. |
| `Ctrl+I` | Toggle case-insensitive matching. |
| `Ctrl+X` | Toggle regular-expression matching. |
| `Ctrl+W` | Toggle whole-word matching. |
| `Ctrl+N` | Go to the next file in TSE's file ring. |
| `Ctrl+P` | Go to the previous file in TSE's file ring. |
| `Ctrl+6` or `Ctrl+Shift+6` | Toggle beginning-of-line matching (`^`). |
| `Ctrl+4` or `Ctrl+Shift+4` | Toggle end-of-line matching (`$`). |

After changing files or toggling beginning/end-of-line matching, it may be necessary to press `Ctrl+B`, `Ctrl+E`, `Ctrl+L`, or `Ctrl+K` to perform the desired search.

## Search options

The initial options are taken from TSE's current `FindOptions` setting. The routine removes the global option `G` at startup because the original source notes that it interferes with next- and previous-match operation. Options toggled during the incremental search apply to the active search string.

The maximum search-string length in the supplied source is 40 characters (`S_MAX = 40`). The option-string limit is 11 characters (`OPT_MAX = 11`). These constants can be changed in the source if required and supported by the target TSE version.

## Suggested test

1. Create a small file containing repeated words with different capitalization.
2. Place the cursor in the middle of the file and start incremental search.
3. Type part of a repeated word and verify that the cursor moves to a match.
4. Press `Ctrl+L` and `Ctrl+K` to test next and previous matches.
5. Press `Ctrl+I` and verify the effect on differently capitalized text.
6. Press `F1` and verify that quick help appears.
7. Press `Escape` and confirm that the cursor returns to its starting position.
8. Run the search again and press `Enter`; confirm that the cursor remains on the selected match.

## Troubleshooting

### `incrsrch.mac` is not created

Review the compiler messages and confirm that the source is being compiled by a compatible TSE SAL compiler. Also confirm that the working directory is writable.

### TSE cannot find the macro

Copy `incrsrch.mac` to a directory searched by TSE, run it using its full path, or start TSE in the directory containing the macro.

### The search does not start

Confirm that you compiled the updated source containing `PROC Main()` and that TSE is loading the newly compiled `incrsrch.mac`, rather than an older copy with the same name.

### A key performs another command

The key may already have another meaning during the search. Change the corresponding key constant near the beginning of `incrsrch.s`, recompile the standalone macro, and run the new `incrsrch.mac`.

### Searches give unexpected results

Press `F1` to review the active controls and check the option letters displayed on the status line. Toggle regular-expression, whole-word, case, or line-boundary matching as needed.

## Original source history

| Source version | Date | Change |
| --- | --- | --- |
| 1.0 | Not stated | Initial release. |
| 1.1 | 22 December 1994, 10:54 | Added previous-file and next-file options. |
| 1.11 | 26 January 1995, 15:51 | Corrected the `Ctrl+6` and `Ctrl+4` definitions, enabled backward starts, and removed the default global (`G`) option to prevent incorrect results. |

## README version history

| Version | Date and time | Change |
| --- | --- | --- |
| 1.0.0.0.0 | 11 September 2026, 11:41:25 UTC | Initial Markdown description, installation instructions, command reference, testing procedure, and troubleshooting guide created from the supplied archive. |
| 1.0.0.0.1 | 11 September 2026, 12:48:41 UTC | Updated for the added `Main()` procedure: INCSEA can now be compiled and run directly as a standalone TSE macro without rebuilding the TSE UI. |

Future README revisions should increment the final component sequentially: `1.0.0.0.2`, `1.0.0.0.3`, and so on.

## Credits

- Original improved routine: Tony L. Burnett.
- Based on TSE's original `mIncrementalSearch` macro.
- README generated by OpenAI Codex (GPT-5).
