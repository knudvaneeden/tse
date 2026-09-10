# GCMACRO

## Description

GCMACRO is a collection of SemWare Editor (SE) macro-language source files written by G. Grafton Cole in May 1993. The package adds enhanced block editing, scrolling and window-alignment commands, a menu-driven sorting command, macro-loading support, and integration with the external ShareSpell spelling checker.

The archive contains source code rather than one single ready-to-run macro. Compile or incorporate only the components that you need, then assign their procedures to suitable keys in the editor.

## Package contents

| File | Purpose |
| --- | --- |
| `README` | Original package notes and file list. |
| `BLOCK.S` | Enhanced block copy, delete, move, marking, and printing procedures. |
| `SCROLL.S` | Scroll/roll toggles, synchronized two-window scrolling, and line alignment. |
| `MACROS` | Short source routines for interactive sorting and locating/executing another macro. |
| `SS.S` | Runs ShareSpell on the current file and then reloads the checked file. |
| `SS1WORD.S` | Uses ShareSpell to check or replace a single word. |

## Main features

### Block functions (`BLOCK.S`)

- `BlockOverwriteToggle()` turns block overwrite mode on or off.
- `BlockFillToggle()` turns block fill mode on or off.
- `mCopyBlock()` performs either a normal copy or an overwrite copy.
- `mDelBlock()` deletes a block or fills its area with spaces.
- `mMoveBlock()` moves a block while respecting the fill and overwrite modes.
- `mMarkColumnMove()` performs a fill-and-overwrite column move and then resets both modes.
- `mKN()` and `mKB()` provide modified column and character marking operations.
- `mKP()` prints the marked block, or the entire file if no block is marked.

### Scroll functions (`SCROLL.S`)

- `ScrollLock()` toggles synchronized scrolling for two open windows.
- `ScrollMode()` switches between scrolling and rolling.
- `mRollUp()` and `mRollDown()` move one window, or both windows when scroll lock is enabled.
- `ScrollAlign()` searches the next window for the current line and centers matching lines for comparison.

### Short macros (`MACROS`)

- `mSort()` displays a choice of ascending, descending, case-sensitive, and case-insensitive sorting modes.
- `mExecMacro()` attempts to locate and execute another macro by checking the `SEMAC` environment variable, the editor load directory, and finally the system path.

### ShareSpell support (`SS.S` and `SS1WORD.S`)

- `SS.S` saves the current file when needed, calls `SS.EXE`, reloads the file, and restores the cursor, window, and marked-block state.
- `SS1WORD.S` copies the current word into a temporary file, runs the `SS` macro, and inserts the resulting word back into the document.

## Requirements

- SemWare Editor or a compatible TSE installation with a suitable SAL compiler.
- ShareSpell and `SS.EXE` are required only for `SS.S` and `SS1WORD.S`.
- The `SS` environment variable may be used to specify the directory containing `SS.EXE`.
- The `SEMAC` environment variable may be used to specify the directory containing the compiled `SS` macro.

## Installation

1. Extract `gcmacro.zip` into a working directory.
2. Keep an untouched backup of the original 1993 source files.
3. Choose the `.S` file containing the functions you want to use.
4. Open the source in SemWare Editor or TSE.
5. If necessary, update legacy SAL statements for the installed editor/compiler version.
6. Compile a stand-alone source file with the SAL compiler. For example:

   ```text
   sc32 BLOCK.S
   sc32 SCROLL.S
   sc32 SS.S
   sc32 SS1WORD.S
   ```

7. Load the resulting macro, or copy selected procedures into your main editor macro source and compile that source.
8. Assign the desired procedures to unused keys in your key-definition section.

The `MACROS` file is a source fragment without a `.S` extension. It is intended to be incorporated into a larger macro source or renamed and completed as required by the target SAL environment.

## How to run

### Running block or scroll functions

1. Compile or incorporate `BLOCK.S` and/or `SCROLL.S`.
2. Add key definitions that call the required procedures.
3. Compile and load the containing macro.
4. Open a file and invoke the assigned key.
5. For `ScrollLock()` and `ScrollAlign()`, open two editor windows before running the command.

No default key assignments are included in the supplied files. Choose keys that do not conflict with existing editor commands.

### Running the full-file ShareSpell macro

1. Install ShareSpell and make `SS.EXE` available through the `SS` environment variable or another location expected by the source.
2. Compile `SS.S`.
3. Open the file to be checked.
4. Execute the compiled `SS` macro.
5. The macro saves the file if it has changed, starts ShareSpell, reloads the file, and restores the editing position.

### Running the single-word ShareSpell macro

1. Compile both `SS.S` and `SS1WORD.S`.
2. Ensure the compiled `SS` macro can be found through `SEMAC`, the editor's macro directory, or the system path.
3. Put the cursor on the word to check and execute `SS1WORD`.
4. If the cursor is not on a word, enter a word when prompted.
5. Review the spelling result and, when prompted, choose whether to insert it.

## Help and usage notes

- Block overwrite is primarily intended for column blocks.
- When moving a character block in overwrite mode, reliable overwrite behavior requires the block to contain complete lines beginning and ending in column 1.
- Synchronized scrolling operates on the current window and the next window.
- `ScrollAlign()` uses the current line as its search text and is most useful when comparing two versions of a file.
- The spelling macros modify files through an external DOS-era program. Test them on copies of files before using them on important data.
- `SS1WORD.S` creates temporary files named `J'K'` and `J'K'.bak`, then attempts to delete them.
- The sources use legacy functions such as `LoadDir()` and older SAL syntax. Modern TSE SAL releases may report compile errors or warnings until the code is adapted.
- Paths and filenames containing spaces are not explicitly quoted by the original ShareSpell command line and may require a source change.
- The original package provides no automated test suite.

## Troubleshooting

### The compiler reports an unknown function or invalid syntax

The source dates from 1993 and targets an older SemWare Editor macro language. Consult the documentation for the installed SAL compiler and replace obsolete functions or syntax where necessary.

### ShareSpell cannot be started

Verify that `SS.EXE` is installed and that the `SS` environment variable points to its directory. Also check the command constructed in `SS.S` for filename quoting and path compatibility.

### `SS1WORD` cannot find the `SS` macro

Set `SEMAC` to the directory containing the compiled `SS` macro, or place that macro in a directory searched by the editor.

### Synchronized scrolling does nothing

Open at least two windows. `ScrollLock()`, `mRollUp()`, `mRollDown()`, and `ScrollAlign()` depend on a next window being available.

### Colors are incorrect

`SCROLL.S` contains hard-coded legacy color attributes. Adjust `DEFcursor_att` and the `Color(...)` values to match the current editor color scheme.

## Version history

### 1.0.0.0.1 - 2026-09-10 09:41:57 UTC

- Expanded the documentation with component descriptions, installation instructions, run procedures, requirements, usage notes, and troubleshooting help.
- Documented the package's legacy status and ShareSpell dependency.

### 1.0.0.0.0 - 2026-09-10 09:41:57 UTC

- Created the initial Markdown README for the original GCMACRO archive.

## Original author and history

The supplied sources identify G. Grafton Cole as the author of the block, scroll, and supporting macro routines. The package's original files are dated May 1993. `SS.S` also credits an earlier submission by Don Dougherty and a rewrite by KAC before G. Grafton Cole's environment-variable addition.

## License

No explicit software license is included in the supplied archive. Retain the original author notices and confirm permission before redistributing modified source code.
