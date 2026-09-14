# LINEPRO - Multi-Function Line Processor

**README filename:** `linepro_readme.md`  
**Session name:** `Create LINEPRO MarkDown Readme`  
**README version:** `1.0.0.0.0`  
**Date:** 2026-09-14  
**Time:** 20:00 CEST  
**Created with:** OpenAI Codex (GPT-5)

---

## Description

LINEPRO is a multi-function line-processing macro for The SemWare Editor Professional (TSE Pro).

The macro was written by Jean Heroux and provides 13 text-processing functions through a menu. It can modify all lines in the current file or the lines in a marked block, depending on the selected operation and the state of the editor.

LINEPRO can perform operations such as:

- Removing blank lines.
- Removing contiguous duplicate lines.
- Removing lines containing a specified string.
- Keeping only lines containing a specified string.
- Processing lists of search strings.
- Double-spacing lines.
- Inserting text into lines.
- Appending text to lines.
- Flushing or aligning text.
- Squeezing unnecessary spaces.
- Numbering lines.

The original LINEPRO package was released for:

- TSE Pro 2.5 for DOS.
- TSE Pro/32 2.8 for Microsoft Windows.

The source uses a maximum line length of 255 characters.

---

## Package contents

The supplied package contains at least the following files:

- `linepro.s` - LINEPRO TSE SAL source code.
- `file_id.diz` - Short package description.
- `linepro.zip` - Original LINEPRO package.

After compilation, the following file is created:

- `linepro.mac` - Compiled TSE macro.

---

## Requirements

To compile and use LINEPRO, you need:

- The SemWare Editor Professional.
- The TSE SAL compiler appropriate for your TSE edition.
- `linepro.s`.
- A writable directory in which the compiler can create `linepro.mac`.

For a modern 32-bit TSE installation, use `sc32.exe`.

For an older 16-bit DOS version of TSE, use the corresponding `sc.exe` compiler.

---

## Important precautions

LINEPRO changes the contents of the current file or marked block.

Before running it:

1. Save the current file.
2. Create a backup of important files.
3. Test the macro on a copy of the file first.
4. Check whether a block is marked.
5. Confirm that the current file is the file you intend to process.
6. Review the result before saving the modified file.

If the result is not correct, use TSE's Undo command immediately or close the file without saving it.

---

## Compiling LINEPRO

### Microsoft Windows and TSE Pro/32

Open a command prompt in the directory containing `linepro.s`.

Compile it with:

    sc32 linepro.s

A successful compilation should create:

    linepro.mac

If `sc32.exe` is not in the current directory or `PATH`, specify its complete path:

    C:\path\to\tse\sc32.exe linepro.s

Replace the example path with the actual location of your TSE SAL compiler.

### Older DOS version

For an older 16-bit TSE Pro installation, compile the source with:

    sc linepro.s

Use the compiler supplied with that TSE version.

---

## Installing the compiled macro

You can use LINEPRO as an explicitly executed macro or add it to TSE's macro configuration.

### Method 1 - Run it directly

1. Copy `linepro.mac` to a directory from which TSE can load macros.
2. Start TSE.
3. Open the text file that you want to process.
4. Select TSE's macro execution command.
5. Enter:

       linepro

6. Press **Enter**.

### Method 2 - Load it during the TSE session

1. Start TSE.
2. Use TSE's **Load Macro** command.
3. Select `linepro.mac`.
4. Execute `linepro` when you want to open its processing menu.

### Method 3 - Assign a key

LINEPRO may also be assigned to a key in your TSE user-interface source.

The precise key assignment depends on the `.ui` file used by your TSE installation. Assign an unused key to execute the `linepro` macro, and then recompile the user-interface source.

Do not replace an existing key assignment unless you are certain that it is no longer required.

---

## How to run LINEPRO

1. Start TSE.
2. Open the file that you want to process.
3. Save the file and preferably make a backup.
4. If you want to process only part of the file, mark the required block.
5. Run the macro:

       linepro

6. Select the required operation from the LINEPRO menu.
7. Supply any requested search string, insertion text, numbering information, or formatting value.
8. Confirm the operation when requested.
9. Examine the changed text.
10. Save the file only when the result is correct.

The exact prompts depend on the selected operation.

---

## Selecting the processing area

LINEPRO operations may work on either:

- The entire current file.
- A marked block in the current file.

Before choosing an operation, verify whether a block is active. A forgotten block can cause only part of the file to be processed when you intended to process the whole file.

Likewise, running an operation without a block may process more text than intended.

---

## Functions

LINEPRO provides 13 menu-selected line-processing functions. The menu displayed by the running macro is the authoritative list for the supplied version.

### Cut blank lines

Removes blank lines from the selected text.

This is useful for compacting files containing unnecessary empty lines.

### Cut contiguous duplicate lines

Removes adjacent repeated lines while retaining one copy.

Only contiguous duplicate lines are handled by this operation. Identical lines located in different parts of the file are not necessarily considered duplicates.

### Cut lines containing a string

Removes lines that contain the specified text.

Use this function when unwanted records or lines can be identified by a word, phrase, code, or other character sequence.

### Keep lines containing a string

Retains matching lines and removes nonmatching lines.

This can be used to extract selected records from logs, reports, lists, or other line-oriented text files.

### String-list processing

Some string-oriented operations can use a list of strings. This allows several search values to be processed during one operation.

Carefully check the required list syntax shown by LINEPRO before starting the operation.

### Double-space lines

Inserts blank lines between existing lines.

This operation can make densely formatted text easier to read or prepare it for printing and annotation.

### Insert a string

Inserts specified text into the processed lines.

Depending on the selected option, LINEPRO may request the text and its intended position.

### Append a string

Adds specified text to the processed lines.

This is useful for adding delimiters, suffixes, comments, commands, or other fixed text to a group of lines.

### Flush text

Moves or aligns text according to the selected flush operation.

This can be used to normalize the horizontal placement of line contents.

### Squeeze text

Removes or reduces unnecessary spacing in the processed lines.

Review the result carefully when spacing has structural meaning, such as in tables, source code, or fixed-column data.

### Number lines

Adds line numbers to the processed text.

LINEPRO may request numbering information such as the starting value or increment. Follow the displayed prompts and verify that the added numbers fit within the supported line length.

---

## Examples

### Remove blank lines

1. Open the file.
2. Mark a block if only part of the file should be processed.
3. Run `linepro`.
4. Select the blank-line removal function.
5. Review the resulting text.
6. Save the file if the result is correct.

### Remove adjacent duplicate lines

Given:

    Alpha
    Alpha
    Beta
    Beta
    Beta
    Gamma

The duplicate-line function should produce a result similar to:

    Alpha
    Beta
    Gamma

This function is intended for contiguous duplicates.

### Keep selected lines

To extract all lines containing a particular word:

1. Run `linepro`.
2. Select the function that keeps matching lines.
3. Enter the required search string.
4. Confirm the operation.
5. Review the extracted lines.

For example, keeping lines containing `ERROR` can be useful when processing a log file.

### Add a suffix to every line

1. Run `linepro`.
2. Select the append-string function.
3. Enter the suffix.
4. Apply it to the required block or file.
5. Review the result before saving.

### Number a block

1. Mark the lines that should be numbered.
2. Run `linepro`.
3. Select the numbering function.
4. Enter the requested numbering values.
5. Confirm the operation.
6. Check the resulting line numbers and alignment.

---

## Maximum line length

LINEPRO supports lines up to 255 characters.

An inserted prefix, appended suffix, or added line number increases the length of a line. If the original line is already close to 255 characters, the resulting line may exceed the supported limit.

Before processing long lines:

1. Check their existing lengths.
2. Allow space for text that LINEPRO will add.
3. Test the operation on a copy.
4. Verify that no text was truncated.

---

## Cancelling an operation

When an input or selection window is displayed, press **Escape** to cancel if that prompt supports cancellation.

After cancelling:

- Check whether the file was changed.
- Use Undo if necessary.
- Do not save the file until you have verified its contents.

Because this is an older macro, cancellation behaviour can vary between menu items.

---

## Troubleshooting

### `linepro.mac` is not created

Check that:

- `linepro.s` exists in the current directory.
- You are using the correct SAL compiler.
- The source file is readable.
- The destination directory is writable.
- All reported compiler errors have been corrected.

For 32-bit TSE, use:

    sc32 linepro.s

### TSE cannot find `linepro.mac`

Check that:

- `linepro.mac` was created successfully.
- The macro is stored in a directory searched by TSE.
- You entered the macro name as `linepro`.
- The macro was loaded when manual loading is required.
- The filename was not accidentally changed to `linepro.mac.mac`.

### The macro does not appear to do anything

Check that:

- The correct file is active.
- The selected operation applies to the current text.
- A block is marked if the function expects a block.
- The search string actually occurs in the selected text.
- The operation was not cancelled.
- The compiled `linepro.mac` corresponds to the supplied `linepro.s`.

### More text was processed than expected

The operation may have been applied to the entire file instead of a block.

Use Undo immediately, mark the required block, and run the operation again.

### Only part of the file was processed

A block may still have been marked.

Cancel or remove the block marking before running LINEPRO if the entire file must be processed.

### Search-based processing gives unexpected results

Check:

- The exact spelling of the search string.
- Uppercase and lowercase differences.
- Leading or trailing spaces.
- Whether a string list was used.
- Whether the operation was **cut matching lines** or **keep matching lines**.

Test the operation on a small sample before applying it to an important file.

### Long lines are truncated or altered

The macro's documented maximum line length is 255 characters.

Shorten the original lines or reduce the amount of inserted or appended text.

### The macro behaves differently in a recent TSE release

LINEPRO was originally released for TSE Pro 2.5 and TSE Pro/32 2.8. Newer TSE versions may have differences in compiler rules, menu behaviour, block handling, or built-in commands.

Compile the supplied source with the SAL compiler belonging to the TSE version being used, and test the macro on a disposable file.

---

## Compatibility

The original package identifies compatibility with:

- TSE Pro 2.5.
- TSE Pro/32 2.8.

It may also compile and run with newer 32-bit versions of TSE, but such versions should be tested separately.

The macro was designed around a maximum line length of 255 characters. It should not be assumed to support Unicode text, UTF-8-specific processing, or lines longer than the original TSE limit without source-code changes.

---

## Uninstalling LINEPRO

To remove LINEPRO:

1. Remove any LINEPRO key assignment from the TSE user-interface source.
2. Remove it from any macro AutoLoad list if it was added there.
3. Recompile the modified user-interface source when applicable.
4. Exit TSE.
5. Delete or archive `linepro.mac`.
6. Keep `linepro.s` if you may want to compile it again later.

---

## Original package information

- **Package:** `linepro.zip`
- **Program:** LINEPRO
- **Description:** Multi-function line processor
- **Author:** Jean Heroux
- **Original package date:** 1999-11-09
- **SemWare posting date:** 1999-11-17
- **Original platforms:** TSE Pro 2.5 and TSE Pro/32 2.8
- **Number of functions:** 13
- **Maximum line length:** 255 characters
- **Replaces:** `LINEPR.ZIP` dated 1997-03-21

---

## Version history

### Version 1.0.0.0.0 - 2026-09-14 20:00 CEST

- Created `linepro_readme.md`.
- Added a description of the LINEPRO multi-function line processor.
- Documented the supplied package files.
- Added compilation instructions for `sc32.exe` and older `sc.exe` installations.
- Added installation and execution instructions.
- Described the available line-processing categories.
- Added examples, precautions, troubleshooting, compatibility information, and uninstallation steps.
- Documented the original author, package dates, supported TSE versions, and 255-character maximum line length.

### Future versions

Use the following sequence for later README revisions:

- `1.0.0.0.1`
- `1.0.0.0.2`
- `1.0.0.0.3`
- `1.0.0.0.4`
- Continue by increasing the final component for each revision.

---

## Disclaimer

LINEPRO can remove or extensively rewrite lines in the current file. Always save and back up important work before running it.

The supplied source is an older TSE SAL macro. Compatibility with modern TSE releases should be confirmed through testing before it is used on production files.
