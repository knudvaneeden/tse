# DSPELL — Alternative Spelling Checker for TSE

**README version:** 1.0.0.0.3  
**Package version:** `dspell_portable_1.0.0.0.2`  
**Package source revision:** DSPELL 0.12.0.5  
**Date:** 2026-09-05  
**Time:** 23:09:04 CEST (21:09:04 UTC)  
**Original author:** Dave Monksfield  
**License:** GNU General Public License, version 2 or later

## Description

DSPELL is an alternative spelling-checker interface for The SemWare Editor (TSE). This portable update uses the 32-bit TSE `spell.dll` spelling engine and the `semware.lex` dictionary.

Instead of stopping at every possible spelling error, DSPELL first scans the selected text or the whole current file. It then opens a scrollable list containing the unrecognized words. Moving through this list highlights the corresponding word in the document, making it easier to ignore names, technical terms, and other correctly spelled words that are not in the dictionary.

DSPELL can:

- Check only the current marked block, when a block is selected.
- Check the entire current file when no block is selected.
- Display every distinct unrecognized word in a separate word-list window.
- Highlight occurrences of the selected word in the document.
- Move between the first, next, and previous occurrences.
- Replace all occurrences of a word within the checked scope.
- Present spelling suggestions through the input history list.
- Remove accepted words from the temporary word list.
- Display progress while scanning a document.

## Package contents

| File | Purpose |
| --- | --- |
| `dspell.s` | TSE SAL source code for the DSPELL macro |
| `spell.dll` | Current 32-bit TSE spelling-engine DLL |
| `readme` | Original documentation supplied with DSPELL |
| `copying` | GNU General Public License version 2 |
| `dspell_readme.md` | Updated installation, usage, help, and troubleshooting documentation |

The compiled `dspell.mac` and `semware.lex` dictionary are not included in this ZIP package.

## Requirements

- The SemWare Editor (TSE) with a compatible SAL compiler.
- The supplied 32-bit `spell.dll` spelling engine.
- The `semware.lex` dictionary in a location that the macro can find through TSE's configured path.

The supplied source searches for `semware.lex` beneath TSE's path in the `SPELL` directory. If it cannot open the dictionary, it reports:

```text
ERROR: cannot locate dictionary
```

## Installation and compilation

1. Extract `dspell_portable_1.0.0.0.2.zip` to a working directory.
2. Keep `spell.dll` with the macro files or in a directory where Windows and TSE can locate it.
3. Open `dspell.s` in TSE.
4. Compile the macro by pressing **Ctrl+F9**, or select **Macro > Compile** from TSE's menu.
5. Alternatively, compile it from a command prompt with the appropriate TSE SAL compiler, for example:

   ```bat
   sc32 dspell.s
   ```

6. Confirm that compilation produces `dspell.mac`.
7. Load `dspell.mac` in TSE. If DSPELL should load whenever TSE starts, add it through **Macro > Autoload List**.

## How to run DSPELL

1. Open the document to check.
2. To check only part of it, mark a block in the current file. Leave no block selected to check the whole file.
3. Press **F8**.
4. Wait while DSPELL scans the chosen scope. Progress is shown on TSE's message line.
5. If unrecognized words are found, use the word-list window to review and correct them.
6. Press **Escape** in the word-list window to finish and return to the document.

If no unrecognized words are found, DSPELL displays:

```text
No unrecognized words found
```

## Word-list help

| Key | Action |
| --- | --- |
| **Up Arrow** / **Down Arrow** | Select the previous or next word |
| **Page Up** / **Page Down** | Move through the list one page at a time |
| **Home** | Select the first word |
| **End** | Select the last word |
| **N** or **Right Arrow** | Highlight the next occurrence in the document |
| **P** or **Left Arrow** | Highlight the previous occurrence |
| **1** or **F** | Return to and highlight the first occurrence |
| **C** | Correct the selected word |
| **D** or **Delete** | Remove the selected word from the temporary list without changing the document |
| **Enter** or **Tab** | Switch from the word list to the document for direct editing |
| **Tab** or **F8** while editing | Return from the document to the word list |
| **Escape** | Close the word-list window and end DSPELL |

## Correcting a word

1. Select the unrecognized word in the word-list window.
2. Press **C**.
3. Edit the spelling directly, or press **Up Arrow** in the input field to access suggestions stored in its history.
4. Press **Enter** to accept the replacement.

DSPELL applies the change to **all occurrences** of that word in the checked scope. When a marked block was checked, replacement is limited to that block; otherwise it applies throughout the current file.

## Important usage notes

- The list contains distinct unrecognized words, not every individual occurrence.
- Removing a word with **D** or **Delete** only tidies the temporary list. It does not add the word to a dictionary.
- The original program intentionally does not provide custom-dictionary management.
- Scanning a large document may take considerable time because DSPELL checks the selected scope before displaying its word list. Marking a smaller block can reduce the checking time.
- The default invocation key is **F8**. It can be changed in `dspell.s`, after which the source must be recompiled.

## Troubleshooting

### The dictionary cannot be located

Verify that TSE's spelling components are installed and that `semware.lex` is present in the expected `SPELL` directory beneath the configured TSE path.

### The macro does not start when F8 is pressed

Make sure `dspell.mac` was compiled successfully and is loaded. Add it to TSE's Autoload List if it should always be active. Also check whether another macro has assigned **F8**.

### Checking takes a long time

Cancel if appropriate, mark a smaller block, and run DSPELL again. Whole-file checking can be slow on large files.

### A valid word appears in the list

This is expected for names, jargon, abbreviations, and other terms missing from `semware.lex`. Press **D** or **Delete** to remove it from the current temporary list.

### A correction changes more text than expected

The **C** command replaces all matching occurrences within the checked scope. Mark only the intended part of the document before starting DSPELL if replacement must be limited.

## Customization

The invocation key and word-list commands are defined in `dspell.s`. Edit their key assignments, compile the source again, and reload the resulting `dspell.mac` to activate the changes.

## Version history

| Version | Date | Changes |
| --- | --- | --- |
| 1.0.0.0.0 | 2026-09-05 | Initial Markdown documentation based on `dspell.zip`, DSPELL source revision 0.12.0.1, and the original package README. |
| 1.0.0.0.1 | 2026-09-05 | Updated for portable package 1.0.0.0.0, `spell.dll`, DSPELL source 0.12.0.3, and the `_REPLACE_HISTORY_` compatibility fix. |
| 1.0.0.0.2 | 2026-09-05 | Updated for portable package 1.0.0.0.1 and DSPELL source 0.12.0.4; the word list now uses `CreateTempBuffer()` to avoid fixed-buffer name collisions. |
| 1.0.0.0.3 | 2026-09-05 | Updated for portable package 1.0.0.0.2 and DSPELL source 0.12.0.5; the right-hand window is now explicitly switched to the temporary word-list buffer, preventing an empty or incorrect display and spurious `not found.` messages. |

For later documentation updates, increment the final component consecutively:

- `1.0.0.0.1`
- `1.0.0.0.2`
- `1.0.0.0.3`

## License and warranty

DSPELL is distributed under the GNU General Public License, version 2 or, at your option, any later version. It is supplied without warranty. Refer to the included `copying` file for the complete license terms.
