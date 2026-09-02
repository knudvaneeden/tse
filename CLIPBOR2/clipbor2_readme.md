# ClipBord 2 for The SemWare Editor (TSE)

**README version:** 1.0.0.0.0  
**README date and time:** 2026-09-02 16:04:04 CEST (UTC+02:00)  
**Original macro author:** Carlo Hogeveen  
**Original macro date:** 5 April 1999  
**Original ClipBord version:** 2

## Description

ClipBord is a TSE SAL macro that saves and restores clipboard contents by using a last-in, first-out (LIFO) clipboard stack.

This is useful when another macro temporarily needs to change the TSE clipboard. The calling macro can push the current clipboard before doing its work and pop it afterward, restoring the previous clipboard contents.

The concept is similar to TSE's `PushPosition`/`PopPosition` and `PushBlock`/`PopBlock` commands.

The archive contains:

- `CLIPBORD.S` - TSE SAL source code.
- `FILE_ID.DIZ` - original short package description.

## Features

- Pushes the current TSE clipboard onto a stack.
- Restores the most recently pushed clipboard.
- Supports nested push/pop operations.
- Preserves line, column, inclusive, and non-inclusive block types.
- Supports an interactive menu when started without a parameter.
- Warns if a pop is attempted when the stack is empty.
- Remains loaded in memory for repeated use.

## Requirements

- The SemWare Editor Professional (TSE) with SAL macro support.
- The SAL compiler appropriate for the installed TSE version, such as `SC32.EXE` for TSE Pro/32.
- `global.si` from `Global.zip`.
- `initpar.si` from `MacPar3.zip`.

The two include files must be installed where the SAL compiler can find them. The original package description identifies compatibility with TSE Pro 2.5 and TSE Pro/32 2.8. Compatibility with newer TSE versions depends on the availability and compatibility of the required include files.

## Installation

1. Extract `clipbor2.zip`.
2. Install the required Global.zip and MacPar3.zip support packages.
3. Verify that `global.si` and `initpar.si` are available to the SAL compiler.
4. Copy `CLIPBORD.S` to your TSE macro source directory, if desired.
5. Open a command prompt in the directory containing `CLIPBORD.S`.
6. Compile the macro:

   ```cmd
   sc32 CLIPBORD.S
   ```

7. Confirm that compilation creates the executable TSE macro, normally `CLIPBORD.MAC`.
8. Place the compiled macro in a directory from which TSE can load macros.

If your TSE installation uses a different SAL compiler command, use the compiler supplied with that installation.

## How to run it interactively

Run the macro without a parameter:

```text
clipbord
```

ClipBord displays a menu with these choices:

- **Push clipboard onto the stack** - saves the current clipboard.
- **Pop clipboard from the stack** - restores the most recently saved clipboard.

## How to use it from another SAL macro

Push the current clipboard before code that may change it:

```sal
ExecMacro("clipbord push")
```

Perform the clipboard-related work, and then restore the saved clipboard:

```sal
ExecMacro("clipbord pop")
```

A typical pattern is:

```sal
ExecMacro("clipbord push")

// Code that temporarily uses or changes the clipboard goes here.

ExecMacro("clipbord pop")
```

Push and pop calls must be balanced. Each `pop` restores the clipboard saved by the most recent unmatched `push`.

## Example of nested use

Given this sequence:

```text
push clipboard A
push clipboard B
pop
pop
```

The first pop restores clipboard B. The second pop restores clipboard A.

## Parameters

| Parameter | Action |
| --- | --- |
| `push` | Saves the current clipboard on the stack. |
| `pop` | Restores and removes the top clipboard from the stack. |
| No parameter | Displays the interactive push/pop menu. |
| Any other value | Displays an illegal-parameter warning. |

Parameters are converted to lowercase, so their input is not case-sensitive.

## Notes and limitations

- The clipboard stack exists only while the macro remains loaded in the current TSE session.
- The macro intentionally remains resident for speed and to retain its stack state.
- An empty clipboard can also be pushed and restored.
- Popping an empty stack displays `ClipBord: there are no more clipboards to pop` unless TSE's `MsgLevel` is `_NONE_`.
- The original documentation states that available memory and TSE's built-in limits determine the maximum stack depth, with an effective upper limit below 65,536 pushed clipboards.
- If a macro exits before executing its matching `pop`, the clipboard stack remains unbalanced.
- ClipBord operates on TSE's internal clipboard buffer; it is not documented as a direct Windows system-clipboard utility.

## Troubleshooting

### The compiler cannot find `global.si`

Install the contents of Global.zip and make sure `global.si` is in the compiler's include search path.

### The compiler cannot find `initpar.si`

Install the contents of MacPar3.zip and make sure `initpar.si` is in the compiler's include search path.

### TSE reports that the macro cannot be found

Confirm that `CLIPBORD.MAC` was created successfully and is located in a directory searched by TSE for macros.

### A pop operation reports that no clipboards remain

There was no matching earlier push, or the saved stack was lost when the macro or TSE session was unloaded. Check that every `ExecMacro("clipbord pop")` has a corresponding earlier `ExecMacro("clipbord push")`.

### The wrong clipboard is restored

ClipBord uses LIFO order. Check for additional nested push operations and ensure that all push/pop calls are balanced.

## Version history

| README version | Date and time | Changes |
| --- | --- | --- |
| 1.0.0.0.0 | 2026-09-02 16:04:04 CEST | Initial Markdown documentation based on `CLIPBORD.S` and `FILE_ID.DIZ` from `clipbor2.zip`. |

Future documentation updates can increment the final component, for example `1.0.0.0.1`, `1.0.0.0.2`, and so on.

## Original package history

- ClipBord version 2 uses Global.zip and the updated MacPar3.zip to avoid historical TSE problems.
- According to `FILE_ID.DIZ`, version 2 replaces the earlier Clipbord.zip package.

## License

No explicit license is included in the supplied archive. The original author retains applicable rights. Review the source and contact the author if permission beyond personal or archival use is required.
