# FILT — External Line Filter for TSE

**README version:** 1.0.0.0.0  
**Date:** 2026-09-08  
**Time:** 17:01:59 UTC  
**Original macro date:** 1995-11-24  
**Original author:** Bill Stewart

## Description

`FILT.S` is a TSE (The SemWare Editor) SAL macro that sends one or more selected lines to an external command-line filter program. The output produced by that program is inserted back into the current file and replaces the original lines.

The macro provides behavior similar to the external-filter feature found in UNIX editors such as `vi`. It is useful for sorting text, formatting paragraphs, changing character case, or applying any other command that reads text from standard input and writes the result to standard output.

The original `filt.zip` package contains:

- `FILT.S` — TSE SAL source code.
- `FILE_ID.DIZ` — short package description.

## How FILT Works

1. You mark a block in the current file.
2. FILT expands the selection to complete lines. Any block type is accepted, but every line touched by the block is processed in full.
3. The selected lines are written to a temporary `.TMP` file in the current directory.
4. The chosen external command receives that file through standard input.
5. The command's standard output is written to a second temporary file.
6. FILT deletes the original selected lines and inserts the filtered output.
7. The resulting lines remain marked as a line block.
8. FILT reports how many lines were sent and how many lines came back, for example: `7 line(s) out, 8 line(s) back`.
9. The temporary files are removed.

## Requirements

- TSE with support for compiling and running SAL macros.
- An external filter command that can read from standard input and write to standard output.
- Write access to the current directory, because FILT creates its temporary files there.
- The external command must be installed and discoverable through the operating system's command search path, unless its complete path is supplied.

## Installation and Compilation

1. Extract `filt.zip` to a directory of your choice.
2. Locate `FILT.S`.
3. Compile the source with the TSE SAL compiler. For example:

   ```bat
   sc32 FILT.S
   ```

4. Ensure the compiled macro is in a location from which TSE can load it, such as your configured TSE macro directory.
5. Optionally assign the macro to a key in your TSE configuration. The original macro does not define a key itself.

Compiler names and installation procedures can vary between TSE versions. Use the compiler supplied for your edition of TSE.

## How to Run It

### Interactive use

1. Open the file to process in TSE.
2. Mark a block that touches the lines you want to filter.
3. Run the compiled `FILT` macro.
4. At the `Filter lines through:` prompt, enter the external filter command and press **Enter**.
5. Review the replaced text and the line-count message.

Commands entered at the prompt are retained in a history list while the macro is loaded, making them easier to reuse.

### Supplying the filter as a macro argument

FILT can also receive the filter command through its macro command line. When an argument is supplied, the interactive prompt is skipped.

Conceptually:

```text
FILT <filter-command>
```

The exact way to pass macro arguments depends on how the macro is launched in your TSE setup.

## Examples

### Sort selected lines

Mark the desired lines, run FILT, and enter:

```text
sort
```

### Use a command with options

If an installed filter supports command-line options, include them in the command. For example:

```text
sort /R
```

Only use commands and options supported by your operating system and installed utilities.

## Help and Important Notes

- **A marked block is required.** If nothing is marked, FILT displays `No block marked` and makes no change.
- **FILT always processes entire lines.** Even a character or column block is expanded to cover every complete line it touches.
- **Check the command before running it.** The original macro deletes the selected lines even when the external program does not exist, cannot be found, or produces no output.
- **Recovering the original text:** immediately use TSE's undelete command if the result is wrong or the original lines disappear.
- **Review destructive filters carefully.** A command that writes nothing to standard output will replace the selected lines with nothing.
- **Temporary files use the current directory.** FILT may fail if that directory is read-only or otherwise unavailable.
- **Shell redirection is automatic.** FILT internally builds a command equivalent to `filter < input.tmp > output.tmp`; normally you should enter only the filter command and its options.
- **The result stays marked.** This provides a visual indication of the lines returned by the external program.
- **There is no default keyboard shortcut.** Launch the macro by your normal TSE macro mechanism or configure your own key assignment.

## Troubleshooting

### `No block marked`

Mark at least one line or a block touching one or more lines, and run FILT again.

### The selected text disappears

The filter command may not exist, may not be on the command search path, or may have produced no standard output. Use TSE's undelete command immediately, verify the command separately, and then retry.

### The command is not found

Add the program's directory to the operating system search path or enter its full path. Quote paths containing spaces if required by your command interpreter.

### Temporary-file or access error

Change to a writable current directory and retry. FILT creates two `.TMP` files in that directory while it is running.

### Unexpected number of lines

The external program controls the returned output. It may add, remove, combine, or split lines. The final message shows the number of lines sent and returned.

## Version Numbering

README revisions use a five-part version number:

```text
1.0.0.0.0
1.0.0.0.1
1.0.0.0.2
...
```

For each subsequent README revision, increment the final component unless a larger release change requires incrementing an earlier component.

## Version History

### 1.0.0.0.0 — 2026-09-08 17:01:59 UTC

- Created the initial Markdown README.
- Documented the package contents and original macro metadata.
- Added installation, compilation, usage, examples, help, safety notes, troubleshooting, and version-number guidance.

## Disclaimer

This README documents the behavior visible in the supplied original source package. Test external commands on non-critical text first and keep a backup of important files.
