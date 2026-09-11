# INCBAK21

## Description

INCBAK21 is a TSE (The SemWare Editor) SAL source module that creates numbered backup files whenever an existing file is saved. It replaces TSE's normal single `.BAK` backup with a series of backups numbered from `0` through `999`.

For example, saving `TEST.PAS` repeatedly creates:

```text
TEST.PA0
TEST.PA1
TEST.PA2
...
TEST.PA999
```

The backup name is based on the original filename and extension. When the original file has no extension, numbered extensions such as `.0`, `.1`, and so on are used.

The archive contains:

- `INCBAK.S` — TSE SAL source code for incremental backups.

## How it works

The `mIncBak()` procedure is called by TSE's `_ON_FILE_SAVE_` hook. Before TSE writes the new contents, the procedure renames the existing disk file to the first available numbered backup name.

The global variable `DoIncBak` controls whether incremental backups are enabled. It is initially set to `TRUE`. The supplied `mToggle()` procedure can toggle this setting from a menu entry or assigned key.

If backup numbers `0` through `999` already exist, INCBAK21 sounds an alarm, displays a warning, and does not create another backup.

## Requirements

- The SemWare Editor (TSE) with SAL macro support.
- Access to the TSE user-interface source or another custom SAL source file loaded by TSE.
- TSE's standard `MakeBackups` option must be set to `Off` to prevent the normal `.BAK` mechanism from operating alongside INCBAK21.

## Installation

1. Extract `INCBAK.S` from `incbak21.zip`.
2. Place `INCBAK.S` with your TSE user-interface or custom macro source files.
3. Include the source in `TSE.UI`, or in the SAL source file where you keep custom editor hooks:

   ```sal
   #include "INCBAK.S"
   ```

4. In the appropriate `WhenLoaded()` procedure, register `mIncBak` for file-save events:

   ```sal
   Hook(_ON_FILE_SAVE_, mIncBak)
   ```

5. Set the following option in `TSE.CFG` under **System/File Options**:

   ```text
   MakeBackups = Off
   ```

6. Compile the containing TSE SAL user-interface or macro source in the normal way for your TSE installation.
7. Restart or reload the compiled interface or macro so that the hook becomes active.

## How to run it

INCBAK21 does not normally need to be started manually. After installation, use it as follows:

1. Open an existing file in TSE.
2. Edit the file.
3. Save it.
4. Check the file's directory. The former disk version should now have the first available numbered backup extension.
5. Edit and save the file again. A backup with the next number should be created.

Example for `NOTES.TXT`:

```text
First save:  NOTES.TX0
Second save: NOTES.TX1
Third save:  NOTES.TX2
```

## Enabling and disabling incremental backups

Incremental backups are enabled by default because `DoIncBak` is initialized to `TRUE`.

To toggle the feature from another SAL procedure, menu command, or key assignment, call:

```sal
mToggle(DoIncBak)
```

When `DoIncBak` is `FALSE`, the file-save hook returns without creating an incremental backup.

## Optional menu entry

The following pattern can be added to a suitable TSE options menu:

```sal
"&Inc Backups" [OnOffStr(DoIncBak) : 3],
                mToggle(DoIncBak), DontClose
```

Adapt the exact placement and punctuation to the menu definition used by your TSE version.

## Testing

Use a disposable test directory and file for the first test:

1. Create `TEST.TXT` containing recognizable text.
2. Open it in TSE, change the text, and save it.
3. Confirm that `TEST.TX0` contains the version that existed before the save.
4. Save another change and confirm that `TEST.TX1` is created.
5. Toggle `DoIncBak` off, save again, and confirm that no new numbered backup is made.
6. Toggle it on and confirm that numbering resumes with the first unused number.

## Important notes

- Test the macro with non-critical files before relying on it.
- INCBAK21 renames the existing disk file before the edited buffer is saved.
- Backup numbering stops after `999`; old backups are not automatically deleted or overwritten.
- The procedure uses an 80-character filename variable, reflecting the limits and conventions of the original 1994 source. Very long modern paths may therefore require source changes.
- The original source was written for TSE 2.x. Depending on the current TSE SAL version and your customized user interface, minor integration changes may be necessary.
- Do not enable TSE's normal backup option unless you intentionally want both backup mechanisms.

## Troubleshooting

### No numbered backup is created

- Confirm that `INCBAK.S` is included in the source that TSE actually loads.
- Confirm that `Hook(_ON_FILE_SAVE_, mIncBak)` is executed by `WhenLoaded()`.
- Confirm that `DoIncBak` is `TRUE`.
- Test with an existing named file that has already been saved to disk.

### A normal `.BAK` file is also created

Set `MakeBackups = Off` in `TSE.CFG` and reload or restart TSE.

### TSE reports that it cannot create a backup

Check that the directory is writable, that the source file is not locked, and that backup names through `999` have not all been used.

### The macro appears not to update after recompilation

Reload the compiled macro or user interface, or restart TSE, to ensure the newly compiled code and hook are active.

## Version history

### 1.0.0.0.0 — 2026-09-11 13:31:54 CEST

- Created the Markdown description, installation instructions, usage help, testing procedure, troubleshooting information, and version history for INCBAK21.
- Documented the supplied `INCBAK.S` source, originally identified internally as INCBAK version 2.1 by Tom Kellen.

Future documentation revisions should increment the final component sequentially: `1.0.0.0.1`, `1.0.0.0.2`, and so on.

## Session name

`Create INCBAK21 MarkDown Readme`

---

README version: **1.0.0.0.0**  
Created: **2026-09-11 13:31:54 CEST**  
Generated by: **OpenAI Codex (GPT-5)**
