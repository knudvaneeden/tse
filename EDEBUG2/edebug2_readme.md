# Edebug2 — Extended TSE Macro Debugger

**README version:** 1.0.0.0.0  
**Package:** `edebug2.zip`  
**Original macro:** `EDEBUG.S`, version 2  
**Original author:** Carlo Hogeveen  
**Original macro date:** 14 October 1998  
**README date and time:** 2026-09-05 21:44:58 UTC

## Description

Edebug is an extended debugging helper for The SemWare Editor (TSE). It was created as a workaround for TSE versions 2.5 through 2.5e, whose normal debugger could not correctly debug SAL macros that use `#include` files.

Edebug works as a wrapper around TSE's regular `debug` macro. Before starting the debugger, it:

1. Opens the requested SAL source macro.
2. Creates a temporary source file in TSE's `mac` directory.
3. Replaces each `#include` directive with the contents of the referenced include file.
4. Adds comments that identify the beginning and end of the main macro and each included file.
5. Starts the standard TSE debugger with the expanded temporary source file.
6. Removes its temporary `.s` and `.mac` files after the debugging session.

The inserted comments make it possible to identify which original source or include file is represented while stepping through the expanded code.

Edebug also works with macros that do not use include files.

## Files in the archive

- `EDEBUG.S` — Edebug SAL source code.
- `FILE_ID.DIZ` — short package description.

## Requirements

- The SemWare Editor (TSE).
- A TSE installation that can compile and run SAL macros.
- TSE's standard `debug` macro.
- Write access to TSE's `mac` directory, because Edebug creates temporary files there.

The macro was specifically written for TSE 2.5 through 2.5e. Later TSE versions may already handle included files correctly in the standard debugger, although Edebug may still be useful for older macro projects.

## Installation

1. Extract `edebug2.zip`.
2. Copy `EDEBUG.S` to TSE's `mac` directory.
3. Compile the source with the SAL compiler. For example:

   ```text
   sc32 EDEBUG.S
   ```

4. Confirm that compilation creates the corresponding compiled macro, normally `EDEBUG.MAC`.
5. Start or restart TSE if necessary so the compiled macro can be found.

Optional: edit the TSE `.ui` file that you use and replace calls such as:

```text
ExecMacro("debug ...")
```

with:

```text
ExecMacro("edebug ...")
```

Back up the `.ui` file before changing it, then recompile it if required by your TSE setup.

## How to run Edebug

### Debug the current source file

Open a SAL source file in TSE, choose **Macro Execute**, and run:

```text
edebug
```

When no macro name is supplied, Edebug debugs the current file.

### Debug a named macro

From TSE's **Macro Execute** command, run:

```text
edebug my_macro
```

You may supply the `.s` extension or omit it, depending on how the source file is located by TSE.

### Pass parameters to the macro being debugged

Place the target macro's parameters after its name:

```text
edebug my_macro parameter1 parameter2
```

Edebug passes the remaining command line to the standard debugger and therefore to the target macro's debugging session.

### Run Edebug from another SAL macro

Use `ExecMacro()`:

```text
ExecMacro("edebug my_macro parameter1 parameter2")
```

## Include-file handling

Edebug recognizes `#include` directives in the source and expands them into the temporary debug file.

- An include name written in square brackets is resolved relative to the current source file's drive and directory.
- A quoted include name is used as the filename supplied by the directive.
- Nested include directives are processed while Edebug scans the expanded temporary source.
- Comments such as `// Begin ...` and `// End ...` mark the boundaries of inserted source.

All include files must exist and be accessible. If an include file cannot be opened, the debugging session is not started.

## Temporary files

Edebug creates a temporary source file named approximately as follows in TSE's `mac` directory:

```text
edebug01.s
edebug02.s
...
edebug99.s
```

The expanded source is compiled or used by TSE's standard debugger. At the end, Edebug attempts to remove matching temporary `.s` and `.mac` files.

Do not use `edebug00` through `edebug99` as permanent filenames in TSE's `mac` directory, because Edebug treats names in this range as temporary files and may erase them.

## Typical workflow

1. Open the main `.s` macro source in TSE.
2. Save any changes to the main source and its include files.
3. Execute `edebug`, or execute `edebug macro_name`.
4. Use the regular TSE debugger controls to step through the expanded source.
5. Read the inserted `Begin` and `End` comments to determine which original file contains the code being examined.
6. End the debugging session normally and return to the original source.

## Troubleshooting

### Edebug cannot create a temporary file

- Confirm that TSE's `mac` directory exists.
- Confirm that the directory is writable.
- Check whether files named `edebug01.s` through `edebug99.s` already exist or are locked.
- Remove only obsolete Edebug temporary files after first confirming that they are not your own files.

### An include file cannot be found

- Verify the spelling and path in the `#include` directive.
- For a square-bracket include, confirm that the include file is located relative to the main source file.
- For a quoted include, confirm that TSE can resolve the supplied filename from its current environment.
- Save untitled source buffers before starting Edebug so relative paths can be resolved.

### The wrong source file is debugged

- Open the intended `.s` file and run `edebug` without parameters, or provide its explicit filename.
- Close or rename duplicate buffers that have the same short filename.
- Use a full path when necessary.

### The standard debugger does not start

- Confirm that TSE's normal `debug` macro is installed and operational.
- First test the standard debugger with a simple macro that has no include files.
- Recompile `EDEBUG.S` with the SAL compiler used by your TSE installation.

### Temporary files remain after debugging

This can happen if TSE or the macro is terminated unexpectedly. After closing TSE, inspect its `mac` directory and remove only confirmed Edebug temporary files.

## Limitations and cautions

- This is historical software written for TSE 2.5 through 2.5e.
- The macro depends on TSE's installation directory and `mac` subdirectory.
- Source shown during debugging is an expanded temporary copy, not the original file.
- Line numbers in the temporary file may differ from line numbers in the original source because include contents and comments are inserted.
- Edebug deletes files matching its temporary filename pattern. Keep personal files outside the `edebug00`–`edebug99` `.s` and `.mac` name range.
- Test the macro on copies of important source files before adopting it in a production workflow.

## Version history

### README 1.0.0.0.0 — 2026-09-05 21:44:58 UTC

- Created the first Markdown documentation for the `edebug2.zip` package.
- Added a description, requirements, installation instructions, usage examples, include-file behavior, troubleshooting, limitations, and safety notes.

### Future versions

Use the following sequence for later README revisions:

- `1.0.0.0.1`
- `1.0.0.0.2`
- `1.0.0.0.3`
- Continue by increasing the final number for each revision.

## Original macro version history

- **Version 1 — 29 September 1998:** initial Edebug release.
- **Version 2 — 14 October 1998:** corrected a bug that could select the wrong current file at the start of a debugging session.

