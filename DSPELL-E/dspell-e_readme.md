# DSpell-E — Alternative Spelling Checker for TSE

**README version:** 1.0.0.0.7  
**Updated:** 2026-09-05 18:50:57 UTC  
**Original release:** 1996-11-05  
**Original authors:** Dave Monksfield; updated by Chris Antos  
**Target editors:** The SemWare Editor Professional (TSE Pro) 2.5 for DOS and TSE Pro/32 2.6 for Windows

## Description

DSpell-E is an alternative interactive spelling checker for older versions of The SemWare Editor Professional. This archive contains the original implementation, including ready-to-run compiled macros, SAL source code, configuration support, help files, and a copy of the GetHelp package.

DSpell can check an entire file, the remainder of a file, a marked block, or the word under the cursor. Its AutoSpell feature can also check words while they are typed. A misspelled word can be indicated by a beep and a visual flash.

Important features include:

- Interactive spelling correction with suggested replacements.
- Whole-file, rest-of-file, marked-block, and current-word modes.
- AutoSpell checking after **Space**, **Enter**, and optionally **Tab**.
- An `S` indicator on the TSE status line while AutoSpell is active.
- **Ctrl+Shift+A** to temporarily override the current AutoSpell setting.
- Support for `SEMWARE.LEX`, `USER.LEX`, `PERSONAL.LEX`, `FLAG.LEX`, and additional custom dictionaries.
- Commands for changing, ignoring, or adding misspelled words.
- Saved preferences, such as AutoSpell, beep, flash, ignored filename extensions, and display colors.
- Compatibility with both TSE Pro 2.5 for DOS and TSE Pro/32 2.6.

## Files in the original archive

| File | Purpose |
|---|---|
| `DSPELL.MAC` | Compiled main DSpell macro; this is the normal macro to run. |
| `DSPELL2.MAC` | Compiled supporting macro used automatically by DSpell. |
| `DSPELL.S` | SAL source code for the main DSpell macro. |
| `DSPELL2.S` | SAL source code for the supporting macro. |
| `DSPELL.SI` | Include file required when compiling the DSpell source. |
| `DSPELL.TXT` | Original documentation and revision history. |
| `DSPELL.HLP` | Original external DSpell help-topic file; retained for reference. |
| `INI.S` | Source for the shared INI macro used by TSE Pro 2.5 DOS. |
| `INI.SI` | INI declarations included by the DOS build. |
| `INI.TXT` | Documentation for the INI support macro. |
| `GETHELP.ZIP` | Original GetHelp package; retained for historical reference. |
| `file_id.diz` | Short archive description. |

## Requirements

- TSE Pro 2.5 for DOS or TSE Pro/32 2.6 for Windows.
- TSE's main spelling dictionary, `SEMWARE.LEX`.
- `SEMWARE.LEX` must be discoverable through TSE's search path, normally in the `SPELL` directory below a directory listed in `TSEPATH`.
- Write access to TSE's configuration location if settings are to be saved.

The package is historical software written for the listed 1990s TSE versions. Later TSE releases might require source changes or recompilation and are not guaranteed to be compatible.

## Installation using the supplied compiled macros

1. Make a backup of any existing DSpell files.
2. Extract `dspell-e.zip` to a temporary directory.
3. Copy `DSPELL.MAC` and `DSPELL2.MAC` to a directory in TSE's macro search path.
4. For TSE Pro 2.5 DOS, also make `INI.MAC` available. If it is not already installed, compile `INI.S` or use an appropriate compiled INI macro.
5. Confirm that `SEMWARE.LEX` is available in TSE's spelling dictionary path.
6. Start or restart TSE so that it uses the newly installed macro files.

The compiled `DSPELL.MAC` and `DSPELL2.MAC` files are the easiest way to run the original implementation; recompilation is not required for normal use.

### Portable companion-macro loading

Beginning with portable package version `1.0.0.0.1`, `DSPELL.S` constructs the path to `DSPELL2.MAC` from `CurrMacroFilename()`. Therefore `DSPELL2.MAC` only needs to be kept in the same directory as `DSPELL.MAC`; the package no longer depends on TSE's current working directory to locate the companion macro.

Compile `DSPELL2.S` before `DSPELL.S`. When the compiler runs `DSPELL.MAC` during its final error-checking phase, the patched macro now loads the adjacent `DSPELL2.MAC` by its complete path. This fixes the warning:

```text
Path not found: dspell2.mac
```

### Large whole-file confirmation

Beginning with portable package version `1.0.0.0.3`, DSpell asks for confirmation before checking an entire file larger than `102400` bytes (100 KiB):

```text
This file is larger than 100 KB. Spellchecking may take a long time. Continue?
```

Only the explicit **Yes** result starts the whole-file spellcheck. Selecting **No** or pressing **Escape** cancels it immediately. The question also appears when **File** is selected from DSpell's spelling-mode menu. It does not appear for Word, Rest-of-file, or Block checks.

The size is calculated portably from `CurrLineLen()` for every buffer line, including two bytes per line separator. The calculation stops as soon as the total exceeds 100 KiB. This avoids the unsupported `FileSize()` call.

### Suggestion-history compatibility

Portable package version `1.0.0.0.6` no longer calls `GetFreeHistory()`. Some TSE sessions can have all 127 user-history slots occupied, in which case every request for another temporary history returns zero regardless of its name.

```text
_REPLACE_HISTORY_
```

Suggestions are now added to TSE's built-in replacement history, which is appropriate for the correction prompt and remains available even when no user-history slots are free. The code no longer calls `DelHistory()` for this built-in list. This removes the **Unable to get new history list** warning while retaining **Up Arrow** access to suggested spellings.

### Built-in help

Beginning with portable package version `1.0.0.0.7`, DSpell help is implemented directly in `DSPELL.S`. Pressing **F1** opens an internal list-based viewer containing:

- Main spellchecking controls.
- Replacement-prompt instructions.
- AutoSpell information.
- Command-line modes.
- Dictionary descriptions.
- Word-list editing controls.
- Custom-dictionary management controls.

`GETHELP.MAC` and `DSPELL.HLP` are no longer runtime requirements. The original `GETHELP.ZIP` and `DSPELL.HLP` remain in the archive only as historical reference material.

## Optional: compile from the original SAL source

Keep the related source and include files together, or place the include files in the compiler's include path.

1. Compile `DSPELL2.S` to produce `DSPELL2.MAC`.
2. Compile `DSPELL.S` to produce `DSPELL.MAC`.
3. When targeting TSE Pro 2.5 DOS, compile `INI.S` to produce `INI.MAC` and make it available in TSE's macro path.
4. Install the resulting `.MAC` files as described above.

Example commands, if the matching SAL compiler is available on the command line:

```text
sc dspell2.s
sc dspell.s
sc ini.s
```

Compiler names and options vary by TSE edition. Use the SAL compiler supplied for the exact editor version being targeted. `DSPELL.S` conditionally uses native profile commands in the Win32 build and `INI.SI`/`INI.MAC` in the DOS build.

### Optional blind-user support

`DSPELL.SI` contains an optional `BLIND` definition. Enabling it before compiling adds audible progress feedback and positions prompts in the upper-left corner. Recompile all DSpell source files after changing this option.

## Bind DSpell to a key

The original documentation recommends binding DSpell to a key in the TSE `.UI` file or adding it to a menu such as Potpourri. For example:

```text
<F7> ExecMacro("dspell")
```

Choose a key that does not conflict with an existing binding in your configuration, rebuild the UI if required by your TSE version, and restart or reload the UI.

## How to run DSpell

Open the document to check and execute the macro:

```text
ExecMacro("dspell")
```

With no parameter, DSpell checks the marked block when the cursor is inside a block; otherwise it checks the whole file. This default behavior is implemented in `proc Spell` in `DSPELL.S`.

### Command-line parameters

| Parameter | Action |
|---|---|
| `-o` | Open the Options menu. |
| `-m` | Open the spelling-mode menu. |
| `-f` | Check the whole file. |
| `-r` | Check from the cursor to the end of the file. |
| `-b` | Check the marked block; reports an error if no block exists. |
| `-w` | Check the word under the cursor. |
| none | Check the current block when applicable; otherwise check the whole file. |

Examples:

```text
ExecMacro("dspell -o")
ExecMacro("dspell -m")
ExecMacro("dspell -f")
ExecMacro("dspell -r")
ExecMacro("dspell -b")
ExecMacro("dspell -w")
```

## Interactive controls

During an interactive spell-check, the original implementation uses these principal controls:

| Key | Action |
|---|---|
| `A` | Add the word to `USER.LEX`. |
| `C` or `Enter` | Change all occurrences. |
| `Shift+C` or `Ctrl+Enter` | Change only the current occurrence. |
| `I` or `Delete` | Ignore the word. |
| `O` | Open DSpell options. |
| `F7` or `Tab` | Edit the document or resume the spelling session. |
| `Escape` | Finish or cancel the current operation. |
| `F1` | Display DSpell's built-in help. |

The word list appears in a separate hidden buffer/window. You can also move between the document and word-list windows with the mouse or TSE's previous/next-window commands.

## AutoSpell

AutoSpell checks a word after it is completed with **Space** or **Enter**. Checking after **Tab** can be enabled or disabled in the Options menu. When a word is not recognized, DSpell can beep, flash the word, or do both.

- Open the Options menu by running `ExecMacro("dspell -o")`, or press `O` while using DSpell.
- Toggle AutoSpell, sound, flashing, Tab checking, and other preferences there.
- Press **Ctrl+Shift+A** to temporarily force AutoSpell on or off.
- Look for the `S` status-line indicator when AutoSpell is active.

The original documentation warns that Tab checking can conflict with `TEMPLATE.MAC`. If template expansion causes incorrect checks, disable **Tab Key Checking** in DSpell's Options menu.

## Dictionaries

DSpell can use the following word lists:

- `SEMWARE.LEX` — required main TSE dictionary.
- `USER.LEX` — words added by the user.
- `PERSONAL.LEX` — personal dictionary supported for lookup.
- `FLAG.LEX` — words that must always be reported as misspelled; this overrides normal and user dictionaries.
- Custom dictionaries — additional word lists configured through the Options menu.

Custom dictionaries can slow checking when they contain many entries. Use the Options menu to add, enable, disable, edit, or remove them.

## Settings

On TSE Pro 2.5 DOS, DSpell uses the included INI support and stores settings in `TSEPRO.INI` in the main TSE directory. TSE Pro/32 2.6 uses its native profile support and `TSE.INI` conventions.

Saved settings include AutoSpell, beep and flash behavior, Tab checking, verification of replacement words, ignored file extensions, word-list colors, and custom dictionaries.

## Troubleshooting

### `Unable to find SEMWARE.LEX`

Verify that `SEMWARE.LEX` exists and that its directory is reachable through `TSEPATH`. The source searches for the file in the `SPELL` subdirectory of the TSE path.

### DSpell or DSpell2 cannot be loaded

Place both `DSPELL.MAC` and `DSPELL2.MAC` in a directory in TSE's macro search path. Their base filenames must remain `DSPELL` and `DSPELL2`.

### Help does not open

Recompile `DSPELL.S` from portable package version `1.0.0.0.7` or later. Help is embedded in `DSPELL.MAC`; no external GetHelp installation is required.

### Settings are not saved in the DOS edition

Ensure that `INI.MAC` is installed and loadable, and that TSE can write to `TSEPRO.INI` in its main directory.

### AutoSpell reacts badly to template expansion

Open DSpell Options and turn off **Tab Key Checking**.

### AutoSpell does not check a source-code file

This is normally intentional. The default ignored-extension list includes common programming extensions such as `.s`, `.si`, `.c`, `.cpp`, `.h`, `.hpp`, `.idl`, `.rc`, `.mak`, `.inc`, `.pas`, `.asm`, and `.ui`. Change the list in the Options menu if desired.

### A newer TSE compiler reports source errors

This is original mid-1990s SAL source. Compile it with the compiler corresponding to TSE Pro 2.5 or TSE Pro/32 2.6, or adapt obsolete syntax and APIs for the newer editor. Keep an unchanged backup of the original source before making compatibility changes.

## Safety and backup advice

- Test the macro on copies of documents before relying on it.
- Back up dictionaries and TSE configuration files before editing them.
- Keep the original archive unchanged so the historical implementation can always be restored.
- Review changes carefully when using **Change all**.

## Version history for this README

| Version | Date and time | Change |
|---|---|---|
| 1.0.0.0.7 | 2026-09-05 18:50:57 UTC | Embedded DSpell-specific F1 help in `DSPELL.S` and removed the GetHelp runtime dependency. |
| 1.0.0.0.6 | 2026-09-05 18:45:04 UTC | Removed `GetFreeHistory()` dependency and used `_REPLACE_HISTORY_` for spelling suggestions. |
| 1.0.0.0.5 | 2026-09-05 18:34:18 UTC | Updated the temporary suggestion-history name to `DSPELL2:suggestions` for current TSE compatibility. |
| 1.0.0.0.4 | 2026-09-05 18:25:22 UTC | Fixed `YesNo()` handling: only result `1` continues; No and Escape now cancel the whole-file check. |
| 1.0.0.0.3 | 2026-09-05 15:04:38 UTC | Replaced unsupported `FileSize()` with a `CurrLineLen()` calculation and added Yes/No confirmation for large whole-file checks. |
| 1.0.0.0.2 | 2026-09-05 14:56:56 UTC | Added a warning before spellchecking normal files larger than 100 KiB. |
| 1.0.0.0.1 | 2026-09-05 14:40:34 UTC | Made `DSPELL2.MAC` loading independent of the current working directory. |
| 1.0.0.0.0 | 2026-09-05 14:26:35 UTC | Initial README for the original DSpell-E implementation. |

Future README updates should increment the final component:

```text
1.0.0.0.0
1.0.0.0.1
1.0.0.0.2
1.0.0.0.3
```

## Original implementation notice

This README describes the supplied original `DSPELL-E` implementation plus the portable companion-macro path fix and large-file warning. No other historical behavior has intentionally been changed, and the macro has not been claimed as fully modernized for current TSE releases.
