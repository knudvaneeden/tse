# LINES

**Session:** Create LINES MarkDown Readme  
**README version:** 1.0.0.0.1  
**Last updated:** 2026-09-14 21:20:24 CEST (+0200)  
**Original macro date:** 2001-03-30  
**Original author:** Carlo Hogeveen (`carlo.hogeveen@xs4all.nl`)

## Description

`LINES.S` is a TSE SAL macro for The SemWare Editor (TSE). It extracts selected lines from a disk file without first loading the entire file into editor memory.

The macro can extract:

- The first **N** lines.
- The last **N** lines.
- A range from line **N** through line **M**, inclusive.

This is particularly useful for inspecting very large files when available memory is limited or loading the complete file would take too long. When only the last lines are requested, the macro keeps only the required number of lines in memory while reading the file.

## Package contents

- `LINES.S` — TSE SAL source code.
- `FILE_ID.DIZ` — Original short package description.

## Requirements

- The SemWare Editor Professional or TSE Pro/32.
- The TSE SAL compiler appropriate for the installed editor version.
- `GLOBAL.ZIP`, installed as required by the original macro package.
- `MACPAR3.ZIP`, installed as required by the original macro package.
- The `initpar.si` include file must be available to the SAL compiler. It is supplied by the parameter-handling dependency used by this macro.

The original package identifies compatibility with TSE Pro 2.5 and TSE Pro/32. Compatibility with newer TSE releases depends on the availability and compatibility of the required include files.

## Installation

1. Extract `LINES.S` from `lines(1).zip`.
2. Install the contents required from `GLOBAL.ZIP` and `MACPAR3.ZIP`.
3. Confirm that the compiler can find `initpar.si`.
4. Copy `LINES.S` to your TSE macro source or working directory.
5. Open a command prompt in that directory.
6. Compile the macro:

   ```text
   sc32 lines.s
   ```

7. Confirm that the compiler creates `LINES.MAC` without errors.
8. Place `LINES.MAC` where TSE can load or execute it, if it was compiled elsewhere.

For a 16-bit TSE installation, use the matching SAL compiler and editor executable instead of the 32-bit commands shown above.

## How to run interactively

### From within TSE

1. Start TSE normally.
2. Execute the `LINES` macro using TSE's macro execution command, commonly **Escape**, **Macro**, **Execute**.
3. Enter one of the following line specifications:

   - `N` — extract the first N lines.
   - `-N` — extract the last N lines.
   - `N-M` — extract lines N through M, inclusive.

4. Select the file from which the lines must be extracted.
5. The selected lines are placed in a newly created editor buffer.

Equivalent macro calls include:

```text
ExecMacro("Lines")
ExecMacro("Lines N Filename")
```

Replace `N` and `Filename` with the required line specification and file name.

## How to run from the command line

Start TSE and supply the macro parameters on the command line:

```text
e32.exe -eLines
```

This starts the macro and lets it ask for the line specification and file.

To supply all parameters directly, use one of these forms:

```text
e32.exe -eLines:N:Filename
e32.exe -eLines:-N:Filename
e32.exe -eLines:N-M:Filename
```

Meanings:

- `N` loads the first N lines.
- `-N` loads the last N lines.
- `N-M` loads lines N through M.
- `Filename` is the file to read.

Examples from the original source:

```text
e32.exe -eLines:5:\autoexec.bat
e32.exe -eLines:10:"c:\program files\desktop.ini"
```

The first example extracts the first five lines of `\autoexec.bat`. The second extracts the first ten lines of `c:\program files\desktop.ini`; quotation marks protect the path containing a space.

## Operation and controls

- The macro reads the selected file directly from disk.
- A progress message is displayed after each 1,000 lines read.
- Press **Escape** while the file is being read to interrupt processing.
- After processing, the cursor is positioned at the beginning of the resulting buffer.
- The resulting buffer is marked unchanged.
- If no lines were extracted, the empty result buffer is abandoned.

## Input examples

| Input | Result |
| --- | --- |
| `25` | Extracts the first 25 lines. |
| `-25` | Extracts the last 25 lines. |
| `100-150` | Extracts lines 100 through 150, inclusive. |

## Error messages

### `Error: illegal parameter format.`

The line specification is invalid, describes a non-positive range, has its limits reversed, or the result buffer could not be created.

Use one of the supported forms: `N`, `-N`, or `N-M`, with positive line numbers.

### `Error reading file: ...`

The requested file could not be opened. Check that the path and file name are correct and that the file is accessible.

### Compiler cannot find `initpar.si`

Install the required `MACPAR3.ZIP` support files and ensure that `initpar.si` is located in a directory searched by the SAL compiler.

## Notes and limitations

- The macro reads ordinary disk files and recognizes CRLF, CR, and LF line endings.
- The source uses the original macro parameter support supplied through `initpar.si`.
- The file-selection prompt uses `*.*` when no filename was supplied as a macro parameter.
- For more parameter-passing forms, consult the `PAR.DOC` documentation supplied with the original parameter-handling package.
- Back up important work before testing older macros in a newer TSE installation.

## Version history

### 1.0.0.0.1 — 2026-09-14 21:20:24 CEST (+0200)

- Expanded the README with installation requirements, interactive and command-line instructions, examples, controls, error guidance, and compatibility notes.
- Documented the original package contents and dependencies.

### 1.0.0.0.0 — 2026-09-14 21:20:24 CEST (+0200)

- Created the initial Markdown README for the original `LINES.S` package.
- Documented the macro's purpose and its three supported extraction modes.

