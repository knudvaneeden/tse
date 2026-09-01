# CHDIR for TSE

**README version:** 1.0.0.0.0  
**Created:** 2026-09-02 00:02:10 CEST (2026-09-01 22:02:10 UTC)  
**Original program date:** 1994-07-25  
**Original author:** Walter Metcalf

## Description

`chdir.txt` is a macro for The SemWare Editor (TSE) that lets you change the editor's current drive and directory interactively.

When the macro is run, it displays a **New directory:** prompt. After you enter a path, the macro changes to that location and calls `EditFile()` so that TSE displays its file-selection list for the new directory.

The macro accepts:

- A complete path, such as `C:\WORK\SOURCE`
- A path on the current drive, such as `WORK\SOURCE`
- A root-relative path, such as `\WORK`
- A drive specification, such as `D:`
- A single backslash (`\`) for the root directory

## Files in the archive

| File | Purpose |
| --- | --- |
| `chdir.txt` | TSE macro source code |
| `readme` | Original installation and usage notes |

## Requirements

- The SemWare Editor (TSE) version compatible with this historical macro
- Access to TSE's `ui\wp.bin` binary interface file
- TSE's SAL macro compiler

> [!IMPORTANT]
> This is a historical TSE macro from 1994. It declares an internal `_CD` procedure from `wp.bin`. Compatibility with newer TSE releases is not guaranteed.

## Installation

1. Extract `chdir.zip` to a working directory.
2. Open `chdir.txt` in TSE.
3. Find this line near the beginning of the source:

   ```text
   binary '??:\tse\ui\wp.bin'
   ```

4. Replace `??` with the drive letter containing your TSE installation. For example, if TSE is installed on drive `G:`, use:

   ```text
   binary 'G:\tse\ui\wp.bin'
   ```

5. If your TSE directory is not `\tse`, change the entire path so it points to the actual `ui\wp.bin` file.
6. Save the edited source.
7. Compile the macro with your TSE SAL compiler. Depending on the TSE installation, this is commonly done by loading the source in TSE and invoking the macro compiler, or by using the supplied command-line compiler.
8. Install or load the resulting compiled macro in TSE according to your normal macro setup.

## Important source-order requirement

The following declarations must occur **before every other macro or procedure definition** in any combined SAL source file:

```text
binary '??:\tse\ui\wp.bin'
    integer proc _CD(string dir) : 0
end

integer proc ChgDir(string dir)
    return (_CD(dir))
end
```

If you copy this code into a startup macro or another source file, place that block near the beginning of the file and before all other procedure and macro definitions.

## How to run

1. Start TSE.
2. Execute the compiled `mChDir` macro using TSE's normal macro execution command or your assigned key binding.
3. At the **New directory:** prompt, enter the desired drive or directory.
4. Press **Enter**.
5. TSE changes to that location and opens the file-selection list.

Press **Escape** at the prompt to cancel without changing the directory.

## Examples

### Change to a directory on the current drive

```text
WORK\SOURCE
```

### Change drive and directory

```text
D:\PROJECTS
```

### Change only the current drive

```text
G:
```

### Change to the root directory

```text
\
```

## How it works

The macro:

1. Uses `Ask()` to request a destination path.
2. Detects a drive prefix such as `D:`.
3. Calls `LogDrive()` when a different drive was supplied.
4. Handles a leading backslash as a root-relative path.
5. Calls the `_CD` routine imported from `wp.bin` to change directory.
6. Calls `EditFile()` to display the files in the new location.

## Limitations

- `path` and `directory` are limited to 40 characters by the original source.
- The drive identifier is expected to be a single character followed by a colon.
- The macro does not report an explicit error when a directory change fails.
- It depends on the internal `wp.bin` interface and therefore may not work unchanged in every TSE release.
- The `wp.bin` path must be configured before compilation.

## Troubleshooting

### The macro does not compile

- Verify that the `binary` path points to an existing `wp.bin` file.
- Confirm that the `_CD` and `ChgDir` declarations appear before every other macro or procedure.
- Check that the source is being compiled with a compatible TSE SAL compiler.

### The drive changes but the directory does not

- Enter an absolute path such as `D:\PROJECTS`.
- Confirm that the directory exists.
- Remember that the original source allows only 40 characters for the path.

### No files appear

- Verify that the selected directory exists and contains files.
- Try changing to a known directory using a complete drive and path.
- Confirm that `EditFile()` works normally in your TSE installation.

## Version history

| Version | Date and time | Changes |
| --- | --- | --- |
| 1.0.0.0.0 | 2026-09-02 00:02:10 CEST | Initial expanded Markdown documentation based on `chdir.txt` and the original `readme` file. |

Future documentation revisions can increment the final component: `1.0.0.0.1`, `1.0.0.0.2`, and so on.

## Credits

The original macro and accompanying notes identify **Walter Metcalf** as the author.
