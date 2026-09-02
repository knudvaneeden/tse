# CLIPMAC — Clipper Editing Macros for TSE

**README version:** 1.0.0.0.0  
**Date and time:** 2026-09-02 17:00:49 UTC  
**Original source file:** `CLIPPER.S`  
**Original source date:** 1994-04-06

## Description

CLIPMAC is a collection of editing helpers for The SemWare Editor (TSE), written in the SAL macro language. It speeds up writing source code in the Clipper programming language by inserting templates for frequently used language constructs.

After the macro is compiled and run, it enables a set of function-key shortcuts. Some commands ask for details such as a condition, loop counter, or function name and then insert the corresponding Clipper code into the current file.

The supplied ZIP archive contains:

- `CLIPPER.S` — the TSE SAL source code.

## Features

- Creates an `if`/`elseif`/`else`/`endif` structure interactively.
- Inserts an `Iif()` expression template.
- Creates `do case`/`case`/`endcase` structures.
- Creates `do while`/`enddo` loops.
- Creates `for`/`next` loops from entered values.
- Generates function and static-function skeletons.
- Inserts `begin sequence`/`end sequence` blocks.
- Inserts an `#include` statement.
- Inserts the Clipper inline-assignment operator (`:=`).
- Provides commands for compiling/running and spell checking through external DOS commands.

## Requirements

- The SemWare Editor (TSE) with its SAL compiler.
- A source file in which the generated Clipper code can be inserted.
- Optional external tools if the compile/run or spell-check shortcuts are used.

The source is plain ASCII and therefore suitable for TSE's traditional text-file handling.

## Installation

1. Extract `clipmac.zip` to a working directory.
2. Locate the extracted `CLIPPER.S` file.
3. Compile it with the TSE SAL compiler. For example:

   ```text
   sc32 CLIPPER.S
   ```

4. Confirm that compilation creates the executable TSE macro file, normally `CLIPPER.MAC`.
5. Put the compiled macro where TSE can find it, or run it by specifying its full path.

If your TSE installation uses a different SAL compiler command or macro extension, use the corresponding command for that installation.

## How to run

1. Start TSE.
2. Open or create a Clipper source file.
3. Run the compiled `CLIPPER` macro from TSE's macro execution command.
4. The macro enables its key definitions for the current editing environment.
5. Press one of the keys listed below to insert the desired construct.

Running the macro does not immediately insert text. Its `Main()` procedure activates the keyboard definitions; a configured shortcut performs the actual editing command.

## Keyboard shortcuts

| Key | Command | Action |
| --- | --- | --- |
| `F2` | `IfEndif()` | Asks for a condition and the desired numbers of `elseif` and `else` clauses, then inserts the structure. |
| `F3` | `I_if()` | Inserts `if(,,)` and positions the cursor inside it. |
| `F4` | `DoCase()` | Asks for the number of `case` clauses and inserts a `do case` structure. |
| `F5` | `DoWhile()` | Asks for a condition and inserts a `do while` loop. |
| `F7` | `Function()` | Asks for a function name and return value, then creates a function skeleton. |
| `F8` | `StaticFunction()` | Creates the function skeleton and changes it to a static function. |
| `F10` | `CompileRun()` | Saves the current file and runs the external DOS command `m`. |
| `F11` | `Spell()` | Saves the file and calls the configured external spelling command. |
| `Alt+F1` | `BeginEnd()` | Inserts `begin sequence` and `end sequence`. |
| `Alt+F2` | `Include()` | Inserts `#include ""` and positions the cursor between the quotation marks. |
| `Alt+F3` | `ForNext()` | Asks for a loop counter, start value, and end value, then inserts a `for`/`next` loop. |
| `Alt+;` | `Inline()` | Inserts the Clipper inline-assignment operator `:=`. |

## Examples

### Create an IF structure

1. Position the cursor where the code should be inserted.
2. Press `F2`.
3. Enter the condition when prompted.
4. Enter the number of `elseif` clauses.
5. Answer `Y` if an `else` clause is required, or `N` if it is not.

The macro inserts the requested structure and positions the cursor for further editing.

### Create a FOR/NEXT loop

1. Press `Alt+F3`.
2. Enter the loop-counter name, for example `nItem`.
3. Enter its starting value, for example `1`.
4. Enter its ending value, for example `10`.

The inserted header will resemble:

```clipper
for nItem = 1 to 10
   
next
```

## External command configuration

Two shortcuts depend on commands outside TSE and may need to be adapted before use.

### F10 — compile and run

`CompileRun()` saves the current file and executes:

```text
m
```

This assumes that an `m` command, program, or batch file exists and is available through the DOS environment. Change the argument of `Dos()` in `CompileRun()` if your build command has another name.

### F11 — spell checker

`Spell()` saves the current file and executes a command based on:

```text
c:\spell\go <current-filename>
```

This is a machine-specific absolute path from the original setup. Install a compatible spelling command at that location or edit the path in `Spell()` and recompile the macro. The shortcut will fail if that command is unavailable.

## Notes and limitations

- The generated templates follow the coding style built into the original 1994 source and may need manual adjustment for a particular project.
- The macro inserts code at the current cursor position and can overwrite or disrupt nearby text if it is run at an unsuitable location.
- Existing `F2`–`F11`, `Alt+F1`–`Alt+F3`, or `Alt+;` assignments can be replaced or conflict while this key definition is enabled.
- `F10` and `F11` are environment-dependent, as described above.
- The function skeleton contains `saveenv()` and `restenv()` text intended for the original Clipper development environment.
- Make a backup of important source files before testing editor macros.

## Troubleshooting

### A key does nothing

- Make sure `CLIPPER.S` compiled without errors.
- Run the compiled `CLIPPER` macro before pressing its shortcuts.
- Check whether another loaded macro has assigned the same key.
- Verify that the compiled macro is in a location accessible to TSE.

### F10 reports that `m` cannot be found

Configure an `m` command in the DOS search path, or edit `CompileRun()` to call the correct build command and recompile `CLIPPER.S`.

### F11 reports a path or file error

The original macro expects `c:\spell\go`. Edit `Spell()` to use the actual spell-checker command on your computer, then recompile the macro.

### Inserted indentation is unexpected

The macro uses TSE's current tab and margin settings. Adjust those editor settings or reformat the inserted code afterward.

## Version history

| README version | Date and time (UTC) | Changes |
| --- | --- | --- |
| 1.0.0.0.0 | 2026-09-02 17:00:49 | Initial README based on the supplied `CLIPPER.S` source. |

Future revisions can continue as `1.0.0.0.1`, `1.0.0.0.2`, and so on.

