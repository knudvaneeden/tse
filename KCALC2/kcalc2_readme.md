# KCALC2

**README version:** 1.0.0.0.0  
**Last updated:** 12 September 2026, 20:25 CEST  
**Session:** Create KCALC2 MarkDown Readme

## Description

KCALC2 is a calculator macro written in the SemWare Application Language (SAL) for The SemWare Editor Professional (TSE Pro).

The macro provides an interactive calculator inside TSE. It allows calculations to be performed without leaving the editor.

## Requirements

- The SemWare Editor Professional
- The TSE SAL compiler `sc32.exe`
- The KCALC2 source files supplied in `kcalc2(3).zip`
- A 32-bit TSE environment when using the supplied SAL source

Keep all files from the archive together while compiling and testing the macro.

## Installation

1. Extract `kcalc2(3).zip` into a working directory.
2. Open a Windows Command Prompt in that directory.
3. Compile the main SAL source file:

   ```text
   sc32 kcalc2.s
   ```

4. If compilation succeeds, the compiler creates:

   ```text
   kcalc2.mac
   ```

5. Keep `kcalc2.mac` in a directory from which TSE can load macros, or copy it to your normal TSE macro directory.

If the archive contains additional `.s`, `.si`, `.inc`, or `.mac` files, keep them in the same directory unless the source documentation specifies otherwise.

## How to run KCALC2

### Run the source from TSE

1. Start TSE Pro.
2. Open `kcalc2.s`.
3. Run the current SAL source using the appropriate compile-and-run command configured in TSE.

### Run the compiled macro

1. Start TSE Pro.
2. Open TSE's **Execute Macro** command.
3. Enter:

   ```text
   kcalc2
   ```

4. Press **Enter**.

KCALC2 should display its calculator interface.

## Using the calculator

1. Start the `kcalc2` macro.
2. Enter numbers and select the required arithmetic operation.
3. Use the keys or commands shown in the calculator window.
4. Continue entering values and operations as required.
5. Use **Backspace**, **Delete**, or the calculator's clear command to correct an entry, where supported.
6. Press **Esc** to close the calculator and return to the editor.

The precise available operations and keyboard commands depend on the supplied version of KCALC2. Follow the labels and instructions displayed in its calculator window.

## Troubleshooting

### The macro does not run

Confirm that `kcalc2.mac` was created successfully and that TSE can find it.

Try executing the macro by its name without the extension:

```text
kcalc2
```

### The compiler reports a missing include file

Make sure every file from `kcalc2(3).zip` was extracted and remains in the same working directory.

Compile from that directory:

```text
cd path\to\kcalc2
sc32 kcalc2.s
```

### A different source filename is used

Check the extracted archive for the main `.s` file and compile that filename instead:

```text
sc32 filename.s
```

### The displayed characters do not look correct

KCALC2 is an older TSE SAL macro and may rely on DOS or OEM characters. Use a suitable monospaced console font, such as **Terminal**, if the calculator border or symbols are displayed incorrectly.

### The source contains unreadable characters

TSE SAL source files normally use an ASCII-compatible encoding. Do not automatically convert the source to UTF-8 because that may alter extended characters used by the interface.

### Changes to the source do not appear

Recompile the source and confirm that the new `.mac` file replaces the previous version. If necessary, close and restart TSE before testing again.

## Safety and notes

- Keep a backup of the original archive.
- Compile and test modified files in a separate working directory.
- Do not overwrite the original source until the modified version has been tested.
- Calculator results should be checked independently when they are used for important financial, technical, or scientific work.

## Version history

### Version 1.0.0.0.0 - 12 September 2026, 20:25 CEST

- Created the first Markdown README for KCALC2.
- Added a description of the macro.
- Added requirements and installation instructions.
- Added compilation and execution steps.
- Added general operating guidance.
- Added troubleshooting and safety information.

Future README revisions should increment the final component of the version number:

```text
1.0.0.0.1
1.0.0.0.2
1.0.0.0.3
```
