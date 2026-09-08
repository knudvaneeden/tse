# FILT100 — TSE Command-Line Filter Interface

**README version:** 1.0.0.0.0  
**Package/source version:** 1.00 (1995-10-19)  
**README date:** 2026-09-08  
**README time:** 19:19:00 CEST (17:19:00 UTC)

## Description

FILT100 contains a user-interface file and two example SAL macros that turn a copy of The SemWare Editor Professional (TSE Pro) into a non-interactive, macro-driven DOS command-line filter.

The resulting `FILTER.EXE` reads text from standard input, runs a selected TSE SAL macro on that text, and writes the resulting buffer to standard output. It can therefore be used with input/output redirection or as part of a DOS command pipeline.

## Package contents

| File | Description |
| --- | --- |
| `FILTER.DOC` | Original documentation, installation instructions, examples, limitations, copyright, and disclaimer. |
| `FILTER.UI` | TSE user-interface source used to build the dedicated filter executable. |
| `NULL.S` | Example filter macro that makes no changes, effectively copying standard input to standard output. |
| `FIND.S` | Example filter macro that retains lines containing a specified text or regular-expression match. |

## Requirements

- A compatible DOS-era installation of TSE Pro.
- The TSE SAL compiler (`SC.EXE`).
- A working copy of the TSE executable, normally `E.EXE`.
- A DOS command prompt or a compatible environment that supports standard input/output redirection and pipes.

> This package dates from 1995 and uses DOS interrupts in `FILTER.UI`. It is intended for a compatible DOS/TSE environment and might not work unchanged with modern Windows or current TSE releases.

## Installation and build steps

1. Extract `filt100.zip` into a working directory.

2. Make a separate copy of the TSE executable so that the normal editor executable remains unchanged:

   ```dos
   copy e.exe filter.exe
   ```

3. Burn `FILTER.UI` into the copied executable. If `FILTER.UI` is in the current directory, run:

   ```dos
   sc -bfilter filter.ui
   ```

   If the file is elsewhere, supply its path:

   ```dos
   sc -bfilter somepath\filter.ui
   ```

4. Compile the supplied example macros:

   ```dos
   sc null.s
   sc find.s
   ```

5. Keep the compiled macros where `FILTER.EXE` can load them, or make sure their directory is included in the applicable TSE macro search path.

## General syntax

Run the filter with redirected files:

```dos
filter filter_macro [macro_arguments] < input.txt > output.txt
```

Use it in a pipeline:

```dos
program1 | filter filter_macro [macro_arguments] | program2
```

The first argument identifies the filter macro. Any remaining arguments are passed to that macro and can be read in SAL with `Query(MacroCmdLine)`.

Input/output redirection characters are processed by the operating system and are not included in the macro command line.

## Examples

### Copy input with `NULL.S`

The `NULL` macro leaves the input buffer unchanged:

```dos
filter null < input.txt > output.txt
```

This effectively copies `input.txt` to `output.txt` through TSE.

### Find literal text with `FIND.S`

Retain only lines containing `error`:

```dos
filter find error < input.txt > matches.txt
```

The search performed by the supplied macro is case-sensitive unless the behavior of the TSE search flags in your version differs.

### Find text with a regular expression

Use the `-x` option to interpret the search expression as a TSE regular expression:

```dos
filter find -x "regular_expression" < input.txt > matches.txt
```

Quote expressions containing spaces or command-shell metacharacters as required by your DOS environment.

### Use `FIND.S` in a pipeline

```dos
type input.txt | filter find warning | more
```

## Writing your own filter macro

A filter macro operates on the buffer loaded from standard input. A minimal filter has this form:

```sal
proc main()
    // Modify the current buffer here.
end
```

Compile the macro with the SAL compiler, then pass its macro name as the first argument to `FILTER.EXE`. Keep filters non-interactive: input should normally come from standard input and output should remain in the current buffer for `FILTER.EXE` to write to standard output.

## Help and troubleshooting

### `Filter macro not specified`

No macro name was supplied. Run `FILTER.EXE` with a filter macro such as `null` or `find`.

### The macro does not load

- Confirm that the macro was compiled successfully.
- Confirm that the compiled macro is in a location accessible to TSE.
- Check that the macro name on the command line is correct.

### `Cannot allocate buffer`

TSE could not create its internal input buffer. Close other applications or buffers and verify that sufficient conventional memory is available.

### `Error reading stdin into buffer`

Verify that input is redirected or piped into the filter and that the source command or file can be read.

### `Error writing buffer to stdout`

Verify that the destination is writable and that the following program in a pipeline is accepting input.

### Console behavior

The original implementation documents several limitations:

- Typing filter input interactively at the console is unreliable because input may close after the first Return.
- When output goes directly to the console, TSE clears the screen and displays `Finished...` before exiting.
- TSE file-status messages can move the cursor while redirected input and output are processed.
- Filters should avoid prompts and other interactive actions.

Press `Alt+X` for the emergency exit defined by `FILTER.UI`.

## Version history

| Version | Date | Changes |
| --- | --- | --- |
| 1.0.0.0.0 | 2026-09-08 | Initial Markdown README created from `FILTER.DOC`, `FILTER.UI`, `NULL.S`, and `FIND.S`. |

Future documentation revisions should increment the final component, for example:

- `1.0.0.0.1` — first README update
- `1.0.0.0.2` — second README update
- `1.0.0.0.3` — third README update

## Original copyright and disclaimer

The original `FILTER.DOC` states that the program was donated to the public domain and may be used or altered at the user's own risk. Refer to `FILTER.DOC` in the archive for the complete original notice.

