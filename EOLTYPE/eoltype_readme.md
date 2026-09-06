# EOLTYPE — Automatic Line-Ending Selection for TSE

**README version:** 1.0.0.0.0  
**Date:** 2026-09-06  
**Time:** 22:58:16 UTC  
**Original macro author:** Carlo Hogeveen  
**Original macro date:** 1999-07-05

## Description

`EOLTYPE.S` is a macro for The SemWare Editor (TSE Pro and TSE Pro/32). It automatically selects the end-of-line format used when a file is saved:

- Files whose names begin with a configured Unix filename prefix are saved with **LF** line endings.
- All other files are saved with **CR/LF** line endings.
- When a file is loaded, its existing end-of-line format is retained.

This is useful when the same TSE installation edits both Unix/Linux files and Windows or DOS files. For example, files on Unix-oriented drives or paths such as `X:\`, `J:\`, or `U:\` can automatically be saved with LF endings.

## Package contents

- `EOLTYPE.S` — TSE SAL source code for the macro.
- `FILE_ID.DIZ` — original short package description.

The macro creates and maintains an additional configuration file named `eoltype.dat` in the macro's load directory.

## Requirements

- The SemWare Editor Professional (TSE Pro or TSE Pro/32).
- A compatible TSE SAL compiler.
- Permission to write `eoltype.dat` in the directory from which the macro is loaded.

## Installation

1. Extract `eoltype.zip`.
2. Copy `EOLTYPE.S` to TSE's `mac` directory.
3. Open a command prompt in that directory.
4. Compile the macro:

   ```text
   sc32 EOLTYPE.S
   ```

5. Add `EolType` to TSE's **Macro AutoLoad List** so that it is loaded whenever TSE starts.
6. Run the macro once and enter the filename prefixes that identify Unix/Linux files.

Depending on the TSE edition and compiler setup, the compiler command or generated macro filename may differ. Use the normal macro compilation procedure for your TSE installation if `sc32` is not available.

## Configuration

Run the macro interactively from TSE. At the prompt, enter one or more Unix filename prefixes separated by spaces.

Example:

```text
X:\ J:\ U:\
```

A prefix may be a drive or a more specific path. Matching is case-insensitive and starts at the beginning of the current filename.

Example configuration:

```text
X:\Linux\ W:\WSL\Projects\
```

With that configuration:

- `X:\Linux\script.sh` is saved with LF.
- `W:\WSL\Projects\demo.txt` is saved with LF.
- `C:\Documents\notes.txt` is saved with CR/LF.

The configured prefixes are stored in `eoltype.dat` when the macro is purged or the editor is closed. They are loaded again the next time the macro starts.

## How to run and use it

1. Start TSE.
2. Make sure `EolType` has been loaded, preferably through the Macro AutoLoad List.
3. Open a file normally.
4. Edit and save the file.
5. The macro selects the saved line-ending type automatically:
   - LF for a filename matching one of the configured prefixes.
   - CR/LF for every other filename.

No command is needed for each save. Run `EolType` again only when you want to review or change the prefix list.

## How it works

- On file load, the macro sets `EOLType` to `0`, meaning that TSE uses the type detected in the loaded file.
- Before file save, the macro initially selects `EOLType` `3` (CR/LF).
- It compares the beginning of the current filename with every configured prefix.
- A matching prefix changes `EOLType` to `2` (LF).
- When TSE exits or the macro is unloaded, the prefix list is written to `eoltype.dat`.

## Important notes

- Prefixes must be separated by spaces. Paths containing spaces therefore cannot be represented reliably by this original macro format.
- A broad prefix affects every matching file. Configure prefixes carefully.
- Files that do not match a configured prefix are saved as CR/LF, even if they were originally loaded with LF.
- The macro uses `LoadDir()` to locate `eoltype.dat`. Keep the macro's load directory writable.
- Back up important files before first using automatic line-ending conversion across a large project.

## Troubleshooting

### Unix files are saved as CR/LF

- Run `EolType` and verify that the correct drive or path prefix is present.
- Separate multiple prefixes with a single space.
- Make sure the configured prefix matches the beginning of TSE's full current filename.
- Confirm that the macro is loaded before saving.

### Windows files are unexpectedly saved as LF

- Check whether a configured prefix is too broad.
- Replace a drive-only prefix with a more specific directory prefix if necessary.

### Settings are not retained

- Verify that TSE can create and update `eoltype.dat` in the macro load directory.
- Close TSE normally so the editor-abandon hook can save the configuration.

### The macro does not run automatically

- Confirm that the compiled macro is available to TSE.
- Check that `EolType` is listed in TSE's Macro AutoLoad List.
- Restart TSE after changing the AutoLoad configuration.

## Version history

| Version | Date | Description |
|---|---|---|
| 1.0.0.0.0 | 2026-09-06 | Initial Markdown documentation created from `EOLTYPE.S` and `FILE_ID.DIZ`. |

Future documentation revisions should increment the final component, for example: `1.0.0.0.1`, `1.0.0.0.2`, and so on.

## License and attribution

The supplied source identifies Carlo Hogeveen as the original author. No separate license file is included in the archive. Consult the original author or distribution source before redistributing or modifying the macro.
