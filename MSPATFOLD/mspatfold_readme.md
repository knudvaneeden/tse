# MSPATFOLD

Version: 1.0.0.0.1  
Date: 2026-09-22  
Time: 22:57 UTC

## Description

MSPATFOLD is a folding macro for The SemWare Editor (TSE), originally written by Marc Spruijt. It can temporarily hide and restore sections of a text or source file. It supports multiple folds, nested folds, fold names of up to 64 characters, and identical fold names in different files.

The package retains the original source filename `FOLD.S` and includes `FOLD_ME.1ST`, a foldable demonstration file.

## Requirements

- The SemWare Editor and its SAL compiler.
- A TSE version capable of compiling the supplied SAL source.
- ASCII-compatible files. The package does not require UTF-8.

Older compiled `.MAC` files should not be reused with a newer incompatible TSE release. Compile `FOLD.S` with the SAL compiler belonging to the TSE version in which the macro will run.

## Fold marker format

A starting marker consists of four comment or remark characters, followed by `#[`, a fold name, and a colon. An ending marker uses `#]`.

Example for a SAL source file:

```text
//  #[ Example section :
Text belonging to the fold
//  #] Example section :
```

When the fold is closed, `#[` on the starting marker is changed temporarily to `##`. The hidden text is retained in a system buffer until the fold is reopened.

## Installation and compilation

1. Extract all files from `mspatfold1.0.0.0.1.zip` into one directory.
2. Keep `mspatfold.ini` in the directory from which the macro is loaded or started so the relative INI filename can be found.
3. Open a command prompt in that directory.
4. Compile the macro with the SAL compiler:

   ```text
   sc32 FOLD.S
   ```

5. Verify that `FOLD.MAC` was created without compiler errors.
6. Load `FOLD.MAC` in TSE through the Macro menu or your normal macro-loading method.

When the macro starts, it displays a short help message unless `silent=true` is configured.

## How to run it

1. Open the supplied `FOLD_ME.1ST` file or another file containing valid fold markers.
2. Put the cursor on a starting fold-marker line.
3. Press `F11` to close that fold.
4. Press `Shift+F11` on the resulting closed fold line to open it again.

## Commands and keys

| Key | Command | Purpose |
|---|---|---|
| `F11` | `CloseFold()` | Close the fold at the cursor. |
| `Shift+F11` | `OpenFold()` | Open the closed fold at the cursor. |
| `Alt+F11` | `CloseAllFolds()` | Close all open folds in the current file. |
| `Ctrl+F11` | `OpenAllFolds(0)` | Open all closed folds in the current file. |
| `Ctrl+Shift+F11` | `MakeFoldLines()` | Create fold-marker lines around the name on the current line. |
| `Shift+F12` | `FoldSaveFile(1)` | Save after offering to open closed folds. |
| `Alt+F12` | `FoldExit()` | Exit using fold-aware save handling. |
| `Ctrl+F12` | `FoldSaveAndQuitFile()` | Save and close the current file. |
| `Ctrl+Shift+F12` | `FoldSaveAllAndExit()` | Save all files and exit. |
| `Ctrl+Alt+F12` | `FoldSaveAs()` | Perform a fold-aware Save As. |
| `Alt+Shift+F12` | `FoldSaveBlock()` | Save the current block with fold handling. |

The macro also replaces these key assignments:

| Key | Command |
|---|---|
| `Ctrl+K`, `Q` | `FoldQuitFile()` |
| `Ctrl+K`, `S` | `FoldSaveFile(1)` |
| `Ctrl+K`, `X` | `FoldSaveAndQuitFile()` |
| `Alt+X` | `FoldExit()` |
| `Alt+W` | `FoldSaveBlock()` |

## Creating fold markers

1. Type a fold name by itself on a new line.
2. Place the cursor at the beginning of that line.
3. Press `Ctrl+Shift+F11`.
4. MSPATFOLD converts the line into matching start and end markers appropriate for several recognized filename extensions, including `.S`, `.UI`, `.C`, `.CPP`, `.PAS`, `.BAS`, `.BAT`, and `.INI`.
5. Insert or move the text to be folded between the two marker lines.

## Configuration

The file `mspatfold.ini` contains:

```ini
[mspatfold]
silent=false
```

- `silent=false` displays the informative `Warn()` box when the macro starts.
- `silent=true` suppresses that startup `Warn()` box.

## Important notes

- Do not edit a closed fold line. Changing it can prevent the hidden fold from being restored.
- Saving through the fold-aware commands offers to reopen closed folds first. This prevents hidden text from being omitted from the saved file.
- `OpenAllFolds` moves the cursor to the beginning of the file.
- `FoldSaveBlock` requires a block in the current file.
- A marked block can be disturbed when a closed fold at its beginning is reopened; the original macro contains a special workaround only for Save Block.
- The folding data is held in memory. Reopen folds before unloading the macro, abandoning the file, or ending TSE unexpectedly.

## Package contents

- `FOLD.S` - TSE SAL source, updated with version 1.0.0.0.1 and the configurable startup message.
- `FOLD_ME.1ST` - original foldable example and test file.
- `mspatfold.ini` - startup-message configuration.
- `mspatfold_readme.md` - this documentation.

## Version history

### 1.0.0.0.1 - 2026-09-23

- Corrected the TSE SAL `GetProfileStr()` call to assign its returned value to `GSSilent`.
- Fixes compiler error 2336, `')' expected`, on the former five-argument call.

### 1.0.0.0.0 - 2026-09-22

- Created the MSPATFOLD package documentation.
- Added `mspatfold.ini` with `silent=false` as the default.
- Added `Main()` with an informative startup `Warn()` message.
- Preserved the original folding operations, example file, and key assignments.
