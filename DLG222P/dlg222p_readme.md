# DLG222P — Dialog.S Programmer Package

**README version:** 1.0.0.0.0  
**Created:** 2026-09-05 13:06:12 UTC  
**Package:** `dlg222p.zip`  
**Original Dialog.S release:** Version 2.22

## Description

DLG222P is the programmer package for **Dialog.S**, a TSE SAL run-time library for creating and running CUA-style dialog boxes in The SemWare Editor (TSE). It contains the programmer documentation, dialog-resource tools, example macros, textual dialog resources, compiled dialog-resource include files, and support source.

The package is intended for advanced SAL programmers. Its programming model is message-oriented: a macro launches a dialog and supplies public callback procedures that receive events and exchange data with the Dialog.S run-time library.

> **Important:** This programmer package is not standalone. The archive's `file_id.diz` states that the user package **`DLG222.ZIP` is required**. That package supplies the Dialog.S run-time and related include files/macros, such as `dialog.s`, `dialog.si`, `msgbox.si`, and other dependencies referenced by these sources.

## Main contents

| File or group | Purpose |
| --- | --- |
| `program.doc` | Detailed programmer's guide and API reference |
| `dc.s` | Command-line dialog-resource compiler |
| `dd.s` | Utility for displaying and testing a compiled dialog resource |
| `de.s` | Interactive visual dialog-resource editor |
| `dbgtrace.s` | Debugging/trace support macro |
| `scruns.si` | Shared helper for loading and executing dialog macros |
| `hello.s` | Minimal message-box example |
| `testmb1.s` | Message-box example |
| `testib1.s` | Input-box example |
| `testdlg1.s`–`testdlg4.s` | Complete dialog-programming examples |
| `testdlg*.d` | Editable text dialog-resource definitions |
| `testdlg*.dlg` | Compiled dialog resources included by the examples |
| `testdlg*.si` | Symbolic control identifiers used by the examples |
| `dlg*.d` | Additional dialog-resource examples/templates |

## Requirements

- The SemWare Editor (TSE) with its SAL compiler.
- The separate Dialog.S user package, `DLG222.ZIP`.
- All Dialog.S run-time macros and required `.si` include files installed where TSE and the SAL compiler can locate them.
- A working backup before modifying these historical source files.

The files date from the TSE 2.x/3.x era. Newer SAL compilers may report compatibility errors or warnings. Preserve the original archive and adapt a copy if changes are necessary.

## Installation

1. Extract `DLG222.ZIP`, the required user package, into a working directory used for TSE macros.
2. Extract `dlg222p.zip` into the same directory, or into another directory included in the SAL compiler's include/macro search path.
3. Verify that referenced dependencies are present. In particular, sources refer to files such as `dialog.si`, `msgbox.si`, `scver.si`, and `sctoken.si`, and they execute macros such as `dialog`, `MsgBox`, and `InpBox`.
4. Keep related `.s`, `.si`, `.d`, and `.dlg` files together unless your TSE configuration provides suitable search paths.
5. Open `program.doc` in TSE for the full programming guide and API documentation.

## Compile the supplied SAL tools and examples

Open a command prompt in the directory containing the extracted files and run the SAL compiler for the source you want to use. For example:

```bat
sc32 dc.s
sc32 dd.s
sc32 de.s
sc32 hello.s
sc32 testmb1.s
sc32 testib1.s
sc32 testdlg1.s
sc32 testdlg2.s
sc32 testdlg3.s
sc32 testdlg4.s
```

You may alternatively compile the macros from inside TSE if that is how your installation is configured. Compilation must be able to find every referenced `.si` and `.dlg` include file.

## Quick start

1. Start TSE.
2. Ensure the Dialog.S run-time macros and the example macro you want to test are compiled and available to TSE.
3. Run a small example first:

```text
hello
```

4. Then try the supplied dialog examples:

```text
testdlg1
testdlg2
testdlg3
testdlg4
```

5. Use `F1` in the dialog editor for its built-in help.

Depending on your TSE setup, macros may be launched through the **Macro** menu, an assigned key, or the macro command prompt.

## Working with dialog resources

Dialog resources use two forms:

- `.d` — editable ASCII resource definition.
- `.dlg` — compiled resource represented as a SAL `datadef`, ready to be included by a macro.

### Compile a resource with DC

Open a `.d` file in TSE and run:

```text
dc
```

DC saves and compiles the current `.d` file, checks it for errors, and creates the corresponding `.dlg` file. If the current file is not a `.d` file, DC asks for an input filename.

Command format:

```text
DC [-b] [-k] [-r] [filename]
```

| Option | Meaning |
| --- | --- |
| `-b` | Batch mode; do not ask to test the dialog |
| `-k` | Keep and return the binary resource; implies `-b` |
| `-r` | Relaxed checking of control positions and sizes |
| `filename` | Resource source file to compile |

### Display a resource with DD

To display and test a compiled resource:

```text
DD [filename]
```

If no filename is supplied, DD prompts for one. When the current file has a `.d` extension, DD attempts to load the corresponding `.dlg` file. DD is useful for checking appearance, hotkeys, and tab order.

### Edit a resource with DE

To create or edit a dialog visually:

```text
DE [filename]
```

Useful editor keys include:

| Key | Action |
| --- | --- |
| `F1` | Display help |
| `F10` | Open the main menu |
| `Alt+F10` | Open the object menu |
| `Tab` / `Shift+Tab` | Select the next/previous control |
| Arrow keys | Move the selected control |
| `Ctrl`+Arrow keys | Resize the selected control |
| `Enter` | Edit the selected control's properties |
| `Ctrl+Enter` | Edit dialog properties |
| `Ctrl+Delete` | Delete the selected control |

DE creates a `.d0` backup of the input resource. Its editor does not provide undo. When building a new resource, add controls first, then define tab order and group boundaries, and add comments last. Run DC afterward without relaxed mode to perform full boundary checks.

## Using a dialog in a SAL macro

A dialog macro generally performs these actions:

1. Include its identifier file and the Dialog.S definitions.
2. Include the compiled `.dlg` resource.
3. Create a temporary buffer and insert the resource data.
4. Execute `dialog` with a unique callback prefix.
5. Handle events in public callback procedures.
6. Read the result from `Query(MacroCmdLine)`.
7. abandon the temporary buffer.

Study `testdlg1.s` through `testdlg4.s` alongside `program.doc`; they demonstrate initialization and retrieval of control data, callbacks, buttons, custom controls, lists, combo boxes, and other Dialog.S features.

## Troubleshooting

### Include file not found

Place the required `.si` or `.dlg` file in the source directory or configure the SAL compiler's include path. Remember that several dependencies belong to the required `DLG222.ZIP` user package rather than this programmer archive.

### Macro cannot be loaded

Compile the corresponding `.s` source and ensure the resulting macro is stored in a directory searched by TSE.

### Dialog does not open

Confirm that the Dialog.S run-time macro is installed and loadable. The buffer containing the inserted dialog resource must be the current buffer when `dialog` is executed.

### Resource compilation fails

Run DC interactively. It displays an error and marks the faulty portion of the `.d` source. Check control identifiers, coordinates, dimensions, grouping, quoting, and required include statements.

### DE changes or removes comments/group statements

This is a documented limitation of its tab-order editor. Define tab order before adding final comments and elaborate grouping, or use the source editor for later changes.

### New SAL compiler reports errors

This is historical code and may rely on older syntax, APIs, or supporting include files. First verify that the complete original dependency set is present. If adaptation is necessary, work on a copy and change one incompatibility at a time.

## Documentation

`program.doc` is the authoritative guide supplied with the package. It covers the programming model, helper libraries, resource compiler and editor, resource syntax, control types, public library functions, callback messages, custom controls, errors, and complete examples.

## Version history

| README version | Date and time (UTC) | Changes |
| --- | --- | --- |
| 1.0.0.0.0 | 2026-09-05 13:06:12 UTC | Initial Markdown description, installation help, run instructions, tool reference, and troubleshooting notes |

Future documentation revisions should increment the final component sequentially:

```text
1.0.0.0.0
1.0.0.0.1
1.0.0.0.2
1.0.0.0.3
```

## Original copyright notice

The source files identify the original author as **DiK** and contain copyright notices covering 1995–2000 (with archive files updated later). Retain the original notices and consult the distributed files for applicable terms.
