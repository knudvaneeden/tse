# FILT2 — External Line Filter for TSE

**README version:** 1.0.0.0.0  
**Source macro version:** 2  
**Date:** 2026-09-08  
**Time:** 17:48:34 UTC

## Description

FILT2 is a TSE SAL macro by Bill Stewart that sends one or more marked lines from the current file to an external filter program. The output produced by that program is inserted back into the file, replacing the original lines.

This provides filtering similar to the `!` command in UNIX editors such as `vi`. For example, a formatting utility can receive a marked paragraph, reformat it, and return the result directly to TSE.

The archive contains:

- `FILT.S` — the TSE SAL source code.
- `FILE_ID.DIZ` — a brief package description.

## How it works

1. FILT verifies that a block is marked in the current file.
2. It expands the selection to a line block covering every line touched by the marked block.
3. It saves those lines to a temporary file.
4. It runs the selected external filter, redirecting the temporary input file to the program and its output to a second temporary file.
5. It deletes the original marked lines and inserts the filtered output.
6. It leaves the returned lines marked as a line block and reports how many lines were sent and returned.

Temporary files are placed in the directory specified by `TEMP`, then `TMP`, or finally the current directory if neither environment variable is defined.

## Requirements

- The SemWare Editor (TSE) with SAL macro support.
- The TSE SAL compiler appropriate for your TSE installation, such as `sc32.exe`.
- An external console program that can read standard input and write standard output.
- The filter program must either be available through `PATH` or be specified with a suitable path.

## Installation

1. Extract `filt2.zip` to a directory of your choice.
2. Open a command prompt in the directory containing `FILT.S`.
3. Compile the macro:

   ```text
   sc32 FILT.S
   ```

4. Confirm that compilation creates the loadable TSE macro file, normally `FILT.MAC`.
5. Place the compiled macro where TSE can load it, or supply its path when loading or executing it.

## How to run it

1. Open a text file in TSE.
2. Mark a block containing the lines to process. A character, column, or line block may be used; FILT always processes the complete lines touched by that block.
3. Run the compiled `FILT` macro.
4. When prompted with `Filter lines through:`, enter the external filter command and press **Enter**.
5. FILT replaces the selected lines with the command's output and displays a result such as:

   ```text
   7 line(s) out, 8 line(s) back
   ```

The filter command can also be passed as the macro command-line argument. If an argument is supplied, FILT uses it without displaying the prompt. Commands entered at the prompt are retained in a history list for reuse.

## Example uses

The exact commands available depend on the utilities installed on your computer. Typical filters include:

- A formatter that wraps or reformats text.
- A sort utility that reorders lines.
- A custom script that transforms text received through standard input.

For example, if a compatible `sort` command is available, mark several lines and enter:

```text
sort
```

## Help and safety notes

- FILT changes complete lines, even when the original selection covers only part of those lines.
- Save important work before running an unfamiliar external command.
- If the filter command cannot be found or produces no usable output, the selected lines may be deleted. Use TSE's **Undelete** command immediately to restore them.
- If insertion of the filtered temporary file fails, FILT displays a warning and attempts to restore the deleted lines with `Undelete`.
- If no block is marked in the current file, FILT displays `No block in current file`.
- If a temporary file cannot be created, verify that `TEMP` or `TMP` points to a writable directory and that sufficient disk space is available.
- No key is assigned by the source. You may assign the compiled macro to a key through your normal TSE configuration.

## Version history

### 1.0.0.0.0 — 2026-09-08 17:48:34 UTC

- Initial Markdown documentation for the supplied FILT2 archive.
- Added description, requirements, installation, usage, examples, help, and safety notes.
- Documents source macro version 2.

Future documentation revisions should increment the final component, for example:

- `1.0.0.0.1`
- `1.0.0.0.2`
- `1.0.0.0.3`

## Original source history

- **Version 2 — 2001-02-23:** Places temporary files in the `TEMP` directory, adds more error checking, and increases temporary filename variables to 255 characters.
- **Version 1 — 1995-11-24:** Initial version.

## Credits

FILT was written by Bill Stewart. This README documents the supplied source and does not change the macro itself.
