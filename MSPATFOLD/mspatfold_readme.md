# MSPATFOLD

Version: 1.0.0.0.9  
Date: 2026-09-25  
Time: 21:15 CEST

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

1. Extract all files from `mspatfold1.0.0.0.9.zip` into one directory.
2. Keep `mspatfold.ini` in the directory from which the macro is loaded or started so the relative INI filename can be found.
3. Open a command prompt in that directory.
4. Compile the macro with the SAL compiler:

   ```text
   sc32 FOLD.S
   ```

5. Verify that `FOLD.MAC` was created without compiler errors.
6. Load `FOLD.MAC` in TSE through the Macro menu or your normal macro-loading method.

When the macro starts, it displays a short help message unless `silent=true` is configured.

## Simple test with FOLD_ME.1ST

1. Load `FOLD.MAC` in TSE.
2. Open the supplied `FOLD_ME.1ST` file.
3. Find this line near the beginning of the file:

   ```text
   //  #[ Features :
   ```

4. Put the cursor anywhere inside the fold, normally on its `#[` starting-marker line.
5. Press `F11`. No marked block is required.

The complete Features section should disappear, leaving this single closed-fold line:

```text
//  ## Features :
```

To restore the hidden section:

1. Keep the cursor on the closed-fold line.
2. Press `Shift+F11`.

The Features section should reappear, including its ending marker:

```text
//  #] Features :
```

As an additional test, press `Alt+F11` to close all folds in the current file and press `Ctrl+F11` to open them all again. Do not edit a `##` closed-fold line because the macro uses that line to restore the hidden text.

## How to run it

1. Open the supplied `FOLD_ME.1ST` file or another file containing valid fold markers.
2. Put the cursor inside the desired fold, normally on its starting fold-marker line.
3. Press `F11` to close that fold.
4. Press `Shift+F11` on the resulting closed fold line to open it again.

## Commands and keys

| Key | Command | Purpose |
|---|---|---|
| `F11` | `CloseFold()` | Close the fold at the cursor. |
| `Shift+F11` | `OpenFold()` | Open the closed fold at the cursor. |
| `Alt+F11` | `CloseAllFolds()` | Close all open folds in the current file. |
| `Ctrl+F11` | `OpenAllFolds(0)` | Open all active closed folds in the current file. |
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
4. MSPATFOLD converts the line into matching start and end markers appropriate for the recognized filename extension. Extension matching is case-insensitive.
5. Insert or move the text to be folded between the two marker lines.

### Supported languages and extensions

| Language | Extensions | Comment form |
|---|---|---|
| ABAP | `.abap` | `*` |
| Ada | `.ada`, `.adb`, `.ads` | `--` |
| Assembly language | `.asm` | `;` |
| BASIC and Batch | `.bas`, `.bat` | `REM` |
| C and C++ | `.c`, `.cpp` | `/* ... */` |
| C# | `.cs` | `//` |
| CAML and OCaml | `.ml`, `.mli` | `(* ... *)` |
| COBOL | `.cob`, `.cbl`, `.cpy` | `*>` |
| Dart | `.dart` | `//` |
| Delphi and Pascal | `.pas` | `{ ... }` |
| Erlang | `.erl`, `.hrl` | `%` |
| Fortran | `.f`, `.for`, `.f77`, `.f90`, `.f95`, `.f03`, `.f08` | `!` |
| FoxPro | `.prg` | `*` |
| Go | `.go` | `//` |
| Haskell | `.hs`, `.lhs` | `--` |
| INI | `.ini` | `;` |
| Java | `.java` | `//` |
| Julia | `.jl` | `#` |
| Kotlin | `.kt`, `.kts` | `//` |
| Lua | `.lua` | `--` |
| Maple source | `.mpl`, `.maple` | `#` |
| MatLab | `.m` | `%` |
| Perl | `.pl`, `.pm` | `#` |
| PHP | `.php`, `.php3`, `.php4`, `.php5`, `.phtml` | `//` |
| PowerShell | `.ps1`, `.psm1`, `.psd1` | `#` |
| Prolog | `.pro`, `.prolog` | `%` |
| Python | `.py`, `.pyw` | `#` |
| R | `.r` | `#` |
| Ruby | `.rb`, `.rake` | `#` |
| Rust | `.rs` | `//` |
| SAS | `.sas` | `/* ... */` |
| Scala | `.scala`, `.sc` | `//` |
| Scratch text or pseudocode | `.scratch` | `//` |
| SQL | `.sql` | `--` |
| Swift | `.swift` | `//` |
| TSE SAL | `.s`, `.ui` | `//` |
| TypeScript | `.ts`, `.tsx` | `//` |
| VHDL | `.vhd`, `.vhdl` | `--` |
| XSLT | `.xsl`, `.xslt` | `<!-- ... -->` |

The `.s` extension remains assigned to TSE SAL, so assembly language uses `.asm`. The ambiguous `.pl` extension is assigned to Perl; Prolog uses `.pro` or `.prolog`. Scratch `.sb`, `.sb2`, and `.sb3` project files are not plain-text source files and must not be edited by MSPATFOLD; only `.scratch` text or pseudocode files are mapped.

## Removing a fold

There is no separate remove-fold command. Safely remove a fold by deleting its marker lines while leaving the enclosed text in place:

1. If the fold is closed and its marker contains `##`, mark that closed-marker line and press `Shift+F11` to open the fold first.
2. Confirm that the hidden text and the matching ending marker have reappeared.
3. Delete the `#[` starting-marker line.
4. Delete its matching `#]` ending-marker line.
5. Save the file normally. The former fold contents remain as ordinary text.

Never delete a closed `##` marker directly. Its hidden contents are still stored in a temporary TSE system buffer and could become inaccessible or be lost.

## Configuration

The file `mspatfold.ini` contains:

```ini
[mspatfold]
silent=false
```

- `silent=false` displays the informative `Warn()` box when the macro starts.
- `silent=true` suppresses that startup `Warn()` box.

## Important notes

- Folding commands no longer require a marked block. They operate in the current file as in the original macro.
- `F11` closes the fold containing the cursor, `Shift+F11` opens the closed fold at the cursor, `Alt+F11` closes all folds in the file, and `Ctrl+F11` opens all active closed folds in the file.
- **The closed or open folding state is not preserved when a file is saved and reloaded.** The fold-marker lines remain in the file, but all folds are open after the file is loaded again.
- Hidden fold contents are stored only in temporary TSE system buffers during the current editor session. They are not stored as persistent folding metadata.
- Use a fold-aware save command and answer **Yes** when asked to open closed folds before saving. All active closed folds in the current file are opened before the file is written.
- The save check verifies that a matching temporary fold buffer actually exists. An ordinary text line that merely resembles a `## foldname:` marker is not treated as an active closed fold and does not prevent saving.
- After reloading a file, press `F11` again on each desired `#[` marker, or press `Alt+F11` to close all folds again.
- Exiting TSE or abandoning a file while folds remain closed can risk losing text that exists only in temporary fold buffers.
- Do not edit a closed fold line. Changing it can prevent the hidden fold from being restored.
- Saving through the fold-aware commands offers to reopen closed folds first. This prevents hidden text from being omitted from the saved file.
- `OpenAllFolds` moves the cursor to the beginning of the file.
- `FoldSaveBlock` requires a block in the current file.
- A marked block can be disturbed when a closed fold at its beginning is reopened; the original macro contains a special workaround only for Save Block.
- The folding data is held in memory. Reopen folds before unloading the macro, abandoning the file, or ending TSE unexpectedly.

## Package contents

- `FOLD.S` - TSE SAL source, updated with version 1.0.0.0.9 and the configurable startup message.
- `FOLD_ME.1ST` - original foldable example and test file.
- `mspatfold.ini` - startup-message configuration.
- `mspatfold_readme.md` - this documentation.

## Version history

### 1.0.0.0.9 - 2026-09-25

- Removed the requirement for a marked block when using folding commands.
- Restored whole-file behavior for `Alt+F11` and `Ctrl+F11`.
- `F11`, `Shift+F11`, and fold-marker creation again work without a marked block.
- Fold-aware saving now opens all active closed folds in the current file before saving.
- Retained the active temporary-buffer verification that prevents marker-like text from being mistaken for a real closed fold.

### 1.0.0.0.8 - 2026-09-25

- Added comment-marker support for ABAP, Ada, Assembly language, C#, CAML/OCaml, COBOL, Dart, Erlang, Fortran, FoxPro, Go, Haskell, Java, Julia, Kotlin, Lua, Maple, MatLab, Perl, PHP, PowerShell, Prolog, Python, R, Ruby, Rust, SAS, Scala, Scratch text, SQL, Swift, TypeScript, VHDL, and XSLT.
- Made filename-extension matching case-insensitive.
- Documented the `.s` and `.pl` extension choices and the exclusion of binary Scratch project formats.

### 1.0.0.0.7 - 2026-09-23

- Added instructions for safely removing a fold.
- Documented that a closed fold must be opened before deleting its marker lines.
- Warned against deleting a `##` marker while its contents remain in a temporary fold buffer.

### 1.0.0.0.6 - 2026-09-23

- Fixed a false "Closed folds remain outside the marked block" save refusal.
- The macro now verifies that a closed-marker line has a corresponding active temporary fold buffer.
- Lines that only resemble closed-fold markers no longer prevent saving.
- Opening all folds ignores marker-like lines that do not represent active folds.

### 1.0.0.0.5 - 2026-09-23

- Restricted all folding commands to the marked block.
- `Alt+F11` now closes all complete folds inside the block instead of processing the whole file.
- `Ctrl+F11` now opens only closed folds inside the block.
- `Shift+F11` and fold-marker creation now also enforce the block boundary.
- Fold-aware saving refuses to save if closed folds remain outside the marked block.
- Text and fold markers outside the block are left unchanged.

### 1.0.0.0.4 - 2026-09-23

- Restricted `F11` folding to a marked block in the current file.
- The cursor must be on the fold's `#[` starting marker.
- The matching `#]` ending marker must be inside the marked line range.
- The macro refuses incomplete or out-of-block folds without changing text.

### 1.0.0.0.3 - 2026-09-23

- Documented explicitly that the closed or open folding state is not preserved when saving and reloading a file.
- Explained that hidden fold contents exist only in temporary TSE system buffers.
- Added safe saving and reloading guidance.

### 1.0.0.0.2 - 2026-09-23

- Added a simple step-by-step folding test using the supplied `FOLD_ME.1ST` file.
- Documented the expected closed-fold line and how to restore the hidden section.

### 1.0.0.0.1 - 2026-09-23

- Corrected the TSE SAL `GetProfileStr()` call to assign its returned value to `GSSilent`.
- Fixes compiler error 2336, `')' expected`, on the former five-argument call.

### 1.0.0.0.0 - 2026-09-22

- Created the MSPATFOLD package documentation.
- Added `mspatfold.ini` with `silent=false` as the default.
- Added `Main()` with an informative startup `Warn()` message.
- Preserved the original folding operations, example file, and key assignments.
