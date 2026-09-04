# CLIPCMP2 — Clipper compile-error navigator for TSE

**README version:** 1.0.0.0.0  
**Created:** 2026-09-02 16:49:39 UTC  
**Source archive:** `clipcmp2.zip`  
**Included source:** `CLIPCOMP.S`

## Description

CLIPCMP2 is a legacy TSE SAL macro that starts the external Clipper compiler from The SemWare Editor (TSE), redirects the compiler output to `ERROR.LOG`, opens that log, and navigates from a reported diagnostic back to the corresponding location in the source file.

The macro searches the compiler output for these diagnostic types:

- `Fatal`
- `Error`
- `Warning`

When a recognized diagnostic contains a line number and a quoted problem string, the macro returns to the original source window, goes to the reported line, and searches that line for the quoted text.

## Included file

| File | Purpose |
| --- | --- |
| `CLIPCOMP.S` | TSE SAL source code for compiling a Clipper source file and navigating its diagnostics. |

## Requirements

- The SemWare Editor (TSE) with a compatible SAL compiler.
- A Clipper compiler whose command is available as `Clipper` from a DOS command prompt.
- Permission to create or overwrite `ERROR.LOG` in TSE's current working directory.
- Compiler diagnostics in the format expected by this macro, including a line number in parentheses and, for accurate text positioning, a quoted problem string.

This is old source code dated 1993. Modern TSE or Clipper environments may require small compatibility changes.

## Installation

1. Extract `clipcmp2.zip` to a convenient directory.
2. Locate `CLIPCOMP.S` in the extracted files.
3. Compile it with the TSE SAL compiler. For example:

   ```text
   sc32 CLIPCOMP.S
   ```

4. Confirm that compilation creates the corresponding executable TSE macro, normally `CLIPCOMP.MAC`.
5. Put the compiled macro where TSE can load it, or run it by specifying its full path.

## How to run it

1. Open in TSE the source file that you want to compile.
2. Run the compiled `CLIPCOMP` macro.
3. At the `File to compile:` prompt, enter the Clipper source filename, including its extension when required. For example:

   ```text
   MYPROGRAM.PRG
   ```

4. The macro executes this command:

   ```text
   Clipper MYPROGRAM.PRG > ERROR.LOG
   ```

5. When the compiler finishes, the macro opens `ERROR.LOG` and searches for the first `Fatal`, `Error`, or `Warning` entry.
6. If the diagnostic format is recognized, the macro returns to the original source window and places the cursor at the reported source text.
7. Press `Alt+N` to find the next error or warning.

## Keyboard command

| Key | Action |
| --- | --- |
| `Alt+N` | Search `ERROR.LOG` for the next fatal error, error, or warning and jump back to its source location. |

The `Alt+N` definition is active after the macro has been loaded. If that key is already assigned by another macro or TSE configuration, change the final key definition in `CLIPCOMP.S` and recompile it.

## Normal messages

- `No more Errors/Warnings!` means that no later recognized diagnostic was found in `ERROR.LOG`.
- `Don't know how to handle:` means that a diagnostic was found, but its layout did not contain the line-number structure expected by the macro.

## Important behavior and limitations

- `ERROR.LOG` is overwritten each time the macro runs because command output is redirected with `>`.
- The log is created in TSE's current working directory, not necessarily in the directory containing `CLIPCOMP.S` or the file being compiled.
- The macro invokes `Clipper` by command name only. The compiler executable must therefore be on `PATH`, or the source must be adapted to use an appropriate command or full path.
- The entered filename is passed directly to the DOS command. Filenames or paths containing spaces may not work because the original macro does not add quotation marks.
- The source file should already be open in the TSE window from which the macro is started. The macro remembers that window and returns to it for diagnostic navigation.
- Navigation depends on the exact format of the Clipper compiler's messages. Output produced by other compilers or different Clipper releases may not be recognized.
- If no compiler-output window is available after the DOS command, `ERROR.LOG` may not be opened by this original implementation.
- Global state is used to remember the source window, log window, and reported row. Run the compile command before relying on `Alt+N`.

## Troubleshooting

### `Clipper` is not recognized

Make sure the directory containing the Clipper compiler is included in the DOS or Windows `PATH`. Test this from a command prompt:

```text
Clipper
```

### `ERROR.LOG` cannot be found

Check TSE's current working directory and confirm that it is writable. The macro uses the relative filename `ERROR.LOG`.

### The macro finds a message but does not jump correctly

Open `ERROR.LOG` and compare its diagnostic layout with what the macro expects:

- a line number enclosed in parentheses, such as `(25)`;
- a quoted problem string near the end of the diagnostic line.

If the compiler uses another layout, the searches in `nextError()` must be adapted.

### `Alt+N` does nothing or performs another command

First run `CLIPCOMP` so that its state and log window are initialized. If another macro has claimed `Alt+N`, assign a different key at the bottom of `CLIPCOMP.S` and recompile it.

## Version history

| Version | Date and time | Changes |
| --- | --- | --- |
| 1.0.0.0.0 | 2026-09-02 16:49:39 UTC | Initial Markdown documentation based on the supplied `clipcmp2.zip` archive and `CLIPCOMP.S` source. |

Future documentation revisions can continue as `1.0.0.0.1`, `1.0.0.0.2`, and so on.
