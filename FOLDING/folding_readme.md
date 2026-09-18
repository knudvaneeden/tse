# FOLDING for TSE Pro

## Version information

- Version: `1.0.0.0.3`
- Date and time: `2026-09-18 13:16:41 UTC`
- Created by: OpenAI GPT-5 Codex
- Target: The SemWare Editor Professional 4.50
- Source encoding: ASCII

## Description

FOLDING adds simulated line folding to the TSE SAL editor.

TSE SAL does not provide a native command that hides selected lines inside an active edit buffer. FOLDING therefore moves a marked line block into a hidden buffer, saves the removed text in a sidecar file, and replaces it with one placeholder line.

For example:

```text
// [FOLDING:1:27 lines]
```

Unfolding the placeholder moves the original lines back into the source buffer exactly where the placeholder was located.

## Main features

- Folds a marked line block into one placeholder line.
- Restores the fold at the cursor.
- Restores every fold in the current file.
- Supports folds in multiple loaded files.
- Supports nested folding.
- Assigns a unique number to each active fold.
- Stores folded text in hidden TSE buffers and disk-backed sidecar files.
- Preserves folding information after saving, closing, and reopening TSE.
- Validates the fold number and line count before restoring sidecar data.
- Provides separate commands for saving folded and fully unfolded files.
- Reads configuration from `folding.ini`.
- Provides safe-save commands that unfold everything before saving.
- Does not require a DLL or external executable.

## Important safety information

FOLDING simulates folding by temporarily removing lines from the visible source buffer. The folded text is stored both in a hidden buffer and in a sidecar file.

Consequently:

1. Use `Alt+Shift+F12` to save a file while preserving its folded state.
2. Use `Shift+F12` to unfold everything and save a conventional source file.
3. Do not edit or delete folding placeholder lines.
4. Keep each generated `.folding.N.dat` sidecar beside its source file.
5. Do not rename or move a folded source without also managing its sidecars.
6. Test persistent folding on backed-up or disposable files first.

Every sidecar contains a format signature, fold identifier, and expected line count. FOLDING refuses restoration if these values do not match the source placeholder.

## Package contents

```text
folding.s
folding.ini
folding_readme.md
```

## Installation

1. Extract `folding1.0.0.0.3.zip` into a working directory.
2. Keep `folding.ini` in the same directory as the compiled `folding.mac` file.
3. Open a command prompt in that directory.
4. Compile the source:

```bat
sc32 folding.s
```

5. Confirm that the compiler creates `folding.mac` without errors.
6. Load or execute `folding.mac` from TSE.

For example, use TSE's macro loading command or add the macro to the normal startup configuration.

## Default keys

| Key | Operation |
|---|---|
| `F11` | Fold the currently marked line block |
| `Shift+F11` | Unfold the placeholder at the cursor |
| `Ctrl+F11` | Unfold every fold in the current file |
| `Shift+F12` | Unfold all and safely save the current file |
| `Ctrl+Shift+F12` | Unfold all and run Save As |
| `Alt+Shift+F12` | Save the current file with its folds preserved |

These assignments can be changed in the key-definition section at the end of `folding.s`, followed by recompilation.

## How to fold a block

1. Open a file in TSE.
2. Mark text spanning at least two lines. A line, character, stream, or column block may be used.
3. Press `F11`.
4. Confirm the operation when asked.
5. The marked lines are replaced by one numbered placeholder.

At the same time, FOLDING creates a sidecar file beside the source. For example, fold 3 in `ddd.s` is stored as:

```text
ddd.s.folding.3.dat
```

FOLDING converts character, stream, and column blocks into a complete line block from the first selected line through the last selected line. The complete lines are folded so they can later be restored without changing their layout.

## How to unfold one fold

1. Put the cursor anywhere on the folding placeholder line.
2. Press `Shift+F11`.
3. The placeholder is removed and the stored lines are restored.

If the matching hidden buffer no longer exists, FOLDING automatically loads and validates the corresponding sidecar file. If the sidecar is missing or invalid, the placeholder remains untouched and a warning is displayed.

## How to unfold all folds

1. Activate the file containing folds.
2. Press `Ctrl+F11`.
3. Confirm the operation.
4. Every available fold in the current file is restored.

This operation applies only to the current file. Repeat it in other loaded files if they also contain folds.

## Nested folds

Nested folding is supported through independent hidden buffers.

To create a nested fold:

1. Fold an inner line block.
2. Mark a larger line block that includes the inner placeholder.
3. Fold the larger block.

Unfold the outer fold first. The inner placeholder will reappear and can then be unfolded separately. `Unfold All` restores both levels.

## Safe saving

### Save with folds preserved

Press `Alt+Shift+F12`. FOLDING verifies that each placeholder has sidecar data and then saves the source file with its placeholders. Close TSE normally. When the file is reopened later, its placeholders remain visible and can be unfolded from their sidecars.

### Save as a normal unfolded source

Press `Shift+F12`. FOLDING restores all folds in the current file and then calls `SaveFile()`.

Press `Ctrl+Shift+F12` to restore all folds and call `SaveAs()`.

After this type of safe save, the file remains fully unfolded.

## Configuration file

`folding.ini` uses this section:

```ini
[folding]
marker_prefix=// [FOLDING:
sidecar_middle=.folding.
confirm_fold=yes
confirm_unfold_all=yes
unfold_before_save=yes
```

### `marker_prefix`

Defines the visible start of each placeholder. The default works naturally in TSE SAL, C, C++, and other languages that accept `//` comments.

Do not change `marker_prefix` while closed folds exist. Existing placeholders would no longer be recognized.

### `sidecar_middle`

Defines the text placed between the source filename and fold number when constructing a sidecar filename. The default creates names such as `ddd.s.folding.3.dat`.

Do not change this setting while saved folded files exist. Their existing sidecars would no longer be found.

### `confirm_fold`

- `yes`: ask before folding a marked block.
- `no`: fold immediately.

### `confirm_unfold_all`

- `yes`: ask before the interactive Unfold All command.
- `no`: unfold immediately.

### `unfold_before_save`

- `yes`: safe-save commands restore all folds before saving.
- `no`: safe-save commands do not restore folds. This setting is not recommended.

Boolean settings accept `yes/no`, `true/false`, `1/0`, or `on/off`.

## Limitations of version 1.0.0.0.3

- Folding is simulated; the source buffer is temporarily modified.
- Each fold currently uses a separate sidecar file.
- Ordinary TSE Save, Save As, menu, exit, and quit commands are not intercepted. Use the supplied folding save commands.
- Undo operations performed around folding can invalidate a placeholder or its stored text.
- Editing a placeholder can prevent its fold from being found.
- Renaming a folded source prevents automatic sidecar discovery under its old name.
- The macro does not automatically detect SAL procedures, braces, indentation, or comment markers.

These restrictions avoid replacing the user's complete save/quit interface and make the initial implementation easier to test safely.

## Recommended test procedure

1. Make a backup copy of a small test file.
2. Load `folding.mac`.
3. Mark several complete lines.
4. Press `F11` and verify the placeholder.
5. Press `Shift+F11` and compare the restored file with the original.
6. Create two separate folds and use `Ctrl+F11`.
7. Create an inner fold followed by an outer fold and test nested restoration.
8. Create a fold and press `Shift+F12`; verify that all text is restored before the file is saved.
9. Compile and test using TSE SAL Compiler V4.50.26 or the compiler version normally used with the editor.

## Troubleshooting

### The macro says that a marked block is required

No completed block exists in the active file. Complete a selection in the current file and try again. Any block type is accepted; FOLDING expands it to complete lines.

### The cursor is not on a folding placeholder

Move the cursor to the line beginning with the configured `marker_prefix` and try again.

### Stored text is unavailable

The matching `.folding.N.dat` sidecar is absent or the folded source was renamed or moved without its sidecars. Restore the sidecar beside the source and try again.

### Sidecar validation failed

The sidecar signature, fold identifier, or stored line count does not match the placeholder. FOLDING refuses to insert the data. Restore matching versions of both the source and its sidecar from backup.

### An ordinary Save command was used accidentally

Version 1.0.0.0.3 writes every sidecar at folding time. If all sidecars exist, use `Alt+Shift+F12` to save the folded state or `Shift+F12` to restore everything and save normally.

## Version history

### 1.0.0.0.3 - 2026-09-18 13:16:41 UTC

- Added persistent disk-backed storage using one sidecar file per fold.
- Added automatic sidecar loading after closing and reopening TSE.
- Added signature, fold-number, and line-count validation.
- Added `Alt+Shift+F12` to save the source with folds preserved.
- Retained `Shift+F12` for unfolding all folds before saving.

### 1.0.0.0.2 - 2026-09-18 13:04:51 UTC

- Accepts any marked block type in the current file.
- Automatically expands character, stream, and column selections to complete lines.
- Fixes the misleading line-block warning encountered with a visible character selection.

### 1.0.0.0.1 - 2026-09-18 12:57:42 UTC

- Replaced string-valued `#define` declarations with global string variables.
- Fixes compiler error 2336, `numeric expression expected`, reported on line 17 with SAL Compiler V4.50.rc23.

### 1.0.0.0.0 - 2026-09-18 12:36:58 UTC

- Initial implementation.

## Design background

The implementation was inspired by earlier TSE folding experiments by Dirk Wissmann, Marc Spruijt, Rob Howse, and the author of Pretty Good Folding. Version 1.0.0.0.3 combines their hidden-buffer technique with unique fold identifiers, validated disk persistence, and separate folded/unfolded save operations for current TSE 4.50 testing.
