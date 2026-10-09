# EditEDI

**Version:** 1.0.0.0.0  
**Date:** 2026-09-06  
**Time:** 22:13:16 UTC  
**Original program date:** 2003-11-07  
**Original author:** Chris Shuffett  
**Target:** The SemWare Editor (TSE) Pro/32, SAL macro

## Description

`EditEDI.s` is a TSE SAL macro for making an X12 EDI file easier to read and edit.

An X12 EDI file commonly stores many segments on one long line. EditEDI obtains the segment delimiter from character position 106 of the file and places every segment on a separate editor line. This produces a readable layout while retaining the delimiter at the end of each segment.

The macro also attempts to preserve the original cursor position. If a block belonging to another file is marked, the block is saved before processing and restored afterward.

## Package contents

- `EditEDI.s` - TSE SAL source code.
- `file_id.diz` - original short package description.

## Requirements

- The SemWare Editor Professional/32.
- A TSE version capable of compiling and running SAL macros.
- An X12 EDI file whose segment delimiter occurs at the standard position used by the macro: character 106.

## Important precautions

- Make a backup copy of the original EDI file before editing it.
- Open the EDI file in **binary mode**, as specified by the original author.
- Run the macro only on a valid X12 EDI file. The character at position 106 is treated as the segment delimiter.
- Review the edited file before sending it to an EDI trading partner or importing it into another system.

## Compile the macro

1. Extract `editedi.zip` to a directory of your choice.
2. Open a command prompt in that directory.
3. Compile the source with the TSE SAL compiler:

   ```text
   sc32 EditEDI.s
   ```

4. Confirm that compilation completes without errors. Depending on the TSE setup, the compiler creates the corresponding compiled macro file.
5. Place the compiled macro where TSE can load it, or use TSE's normal macro loading method.

## How to run EditEDI

1. Back up the EDI file.
2. Start TSE Pro/32.
3. Open the X12 EDI file in binary mode.
4. Position the cursor anywhere in the file.
5. Run the `EditEDI` macro using TSE's **Execute Macro** command or an assigned key.
6. Wait while the macro scans the file and places each EDI segment on a separate line.
7. Make the required changes.
8. Save the file.

## What the macro does

1. Records the current cursor line and column.
2. Preserves a marked block if that block belongs to another open file.
3. Reads one character at file position 106 and uses it as the EDI segment delimiter.
4. Searches for every occurrence of that delimiter.
5. Splits the file after each delimiter so that each EDI segment occupies a separate line.
6. Adjusts the stored cursor location while lines are being added.
7. Restores the cursor and any previously preserved external block.

## Example

Before running EditEDI, an EDI file can resemble this:

```text
ISA*...~GS*...~ST*...~SE*...~GE*...~IEA*...~
```

If `~` is the delimiter at position 106, the result resembles:

```text
ISA*...~
GS*...~
ST*...~
SE*...~
GE*...~
IEA*...~
```

## Help and troubleshooting

### The file is not split correctly

Check that the input is a valid X12 EDI interchange and that its segment delimiter is at character position 106. A truncated file, an added byte-order mark, or other characters before the `ISA` header can cause the wrong delimiter to be detected.

### Compilation fails

- Confirm that `sc32` is available in the command prompt search path.
- Confirm that the source was not altered or converted to an incompatible character encoding.
- Compile with a TSE SAL compiler compatible with the source syntax.

### The output contains unexpected blank or joined lines

Restore the backup and verify that the original file uses the expected X12 delimiter consistently. Existing line breaks or malformed segments may affect the result.

### Can the macro convert the edited file back to one long line?

This source is primarily an editing aid that splits segments onto separate lines. It does not provide a separate, documented command for rebuilding the original single-line representation. Test the saved result with the receiving EDI application and retain the original backup.

## Version numbering

This README uses a five-part version number. Increase the final component for each revision:

- `1.0.0.0.0` - initial README release.
- `1.0.0.0.1` - next revision.
- `1.0.0.0.2` - following revision.

## Version history

### 1.0.0.0.0 - 2026-09-06 22:13:16 UTC

- Added a detailed description of EditEDI.
- Documented the package contents and requirements.
- Added compilation and execution instructions.
- Added safety notes, troubleshooting information, and version numbering guidance.

## Disclaimer

Use this macro at your own risk. Always keep an unmodified backup of production EDI data and validate edited interchanges before transmission or automated processing.
