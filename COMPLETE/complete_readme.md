# COMPLETE — Word Completion Macro for TSE Pro/32

**README version:** 1.0.0.0.0  
**Date:** 2026-09-03  
**Time:** 20:24:48 CEST (UTC+02:00)  
**Macro version:** 1.2  
**Original author:** Andrew Bovett  
**Revision:** Ross Boyd

## Description

`COMPLETE.S` is a word-completion macro for The SemWare Editor Professional (TSE Pro/32). It completes a partially typed word by searching for matching words in expansion files and loaded editor files.

Unlike a completion tool that displays a picklist, COMPLETE presents one matching word at a time. Press the completion key repeatedly to cycle through the available matches. If you pass the desired result, use the reverse-completion key before typing anything else.

The macro can also suggest the next word after a complete word. For example, after typing `just `, invoking completion may find a phrase such as `just typed` elsewhere in the searched text.

## Archive contents

| File | Description |
| --- | --- |
| `COMPLETE.S` | TSE SAL source code for the COMPLETE macro, version 1.2 |
| `file_id.diz` | Original short package description |

## Search order

COMPLETE searches for expansions in this order:

1. `complete.tse` in the current working directory, if present.
2. `complete.tse` in the TSE startup directory, if present.
3. The current loaded file, searching backward from the cursor.
4. The current loaded file, searching forward from the cursor.
5. All other loaded files.

The two `complete.tse` files are optional. They may contain words or phrases that you want COMPLETE to find even when those terms do not occur in a currently loaded document.

## Default keys

| Key | Action |
| --- | --- |
| `Ctrl+Alt+H` | Complete the word using a case-sensitive search |
| `Ctrl+H` | Complete the word while ignoring case |
| `Alt+H` | Return to the previous completion |

The key assignments are located at the end of `COMPLETE.S` and can be changed before compiling if they conflict with existing assignments.

## Installation

1. Extract `complete.zip` to a working directory.
2. Copy `COMPLETE.S` to your TSE macro source directory, or compile it directly from the extracted directory.
3. Open a command prompt in the directory containing `COMPLETE.S`.
4. Compile the source with the TSE SAL compiler:

   ```text
   sc32 COMPLETE.S
   ```

5. Confirm that the compiler completes without errors and creates the compiled macro.
6. Add the compiled COMPLETE macro to TSE's **AutoLoad List**.
7. Restart TSE so the macro is loaded and its key definitions become active.

Alternatively, load or execute the compiled macro manually using the normal macro-loading facilities of your TSE installation.

## How to use it

### Complete a partial word

1. Type the beginning of a word, for example:

   ```text
   pro
   ```

2. Leave the cursor immediately after the partial word.
3. Press `Ctrl+H` to search without regard to case, or `Ctrl+Alt+H` for a case-sensitive search.
4. Press the same completion key repeatedly to cycle through other matches.
5. If you go past the desired match, immediately press `Alt+H` to step backward through the completion history.

### Complete a two-word sequence

1. Type a complete word followed by a space.
2. Press one of the completion keys.
3. COMPLETE searches for occurrences of that word and inserts a word that followed it elsewhere.

### Use custom expansion files

1. Create a plain-text file named `complete.tse`.
2. Enter the words and phrases that should be available for completion.
3. Put the file in either:
   - the current working directory for project-specific expansions; or
   - the TSE startup directory for global expansions.
4. Reload the macro or restart TSE after creating or changing the expansion file.

## Messages and troubleshooting

### `No word to expand`

There is no partial word at the cursor and no preceding word that can be used for a two-word completion.

### `No expansion found`

No matching expansion was found in either expansion file or any searched loaded file. Load more relevant files, add the desired term to `complete.tse`, or type a longer/different abbreviation.

### `No previous expansions`

The reverse-completion history contains no earlier result.

### `Cursor must be over a previous expansion`

`Alt+H` only works while the cursor is still positioned over the most recently inserted completion. Use it before typing or moving elsewhere.

### A shortcut performs another command

The key is probably already assigned by another macro or configuration. Edit the three key definitions at the end of `COMPLETE.S`, recompile the macro, and restart TSE.

### Changes to `complete.tse` are not detected

The expansion files are loaded when the macro is loaded. Purge and reload COMPLETE, or restart TSE, so the files are read again.

## Notes and limitations

- This package is intended for TSE Pro/32 and works with both the GUI and console editors according to the original package description.
- Expansion strings are limited by the source code's `STRING_SIZE` setting of 80 characters.
- Reverse completion must be requested before the cursor is moved or additional text is typed.
- The macro temporarily removes an active block mark while completing text and restores the saved block state afterward.
- The source uses `LoadDir()` to locate the global `complete.tse` file in TSE's macro/startup location.

## Original macro change history

| Version | Date | Changes |
| --- | --- | --- |
| 1.2 | 2005-10-01 | Fixed handling of an active marked block; renamed `continue` to `proceed` to avoid a reserved-word clash; tidied `WhenLoaded()`; changed the default keys to emulate SemWare's `expand.s`; removed trailing word characters after completion. |
| 1.1 | Not specified | Various minor bug fixes. |
| 1.0 | 1996-04-20 | Initial release. |

## README version history

README versions use the sequence `1.0.0.0.0`, `1.0.0.0.1`, `1.0.0.0.2`, and so on.

| Version | Date and time | Changes |
| --- | --- | --- |
| 1.0.0.0.0 | 2026-09-03 20:24:48 CEST | Initial Markdown documentation created from `complete.zip`. |

