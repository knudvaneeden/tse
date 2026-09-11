# JOINFILS

README version: 1.0.0.0.1  
JOINFILS source version: 1.0.0.0.2  
Created: 2026-09-11 22:29:35 UTC  
Last updated: 2026-09-11 23:38:27 UTC  
LLM: OpenAI GPT-5

## Description

JOINFILS is a TSE SAL macro by Carlo Hogeveen that joins two ASCII text files using a key stored at fixed column positions in each file.

The key may occupy different columns in the two files. JOINFILS sorts both files by their selected key columns and creates a new record containing:

```text
record from file 1:record from file 2
```

The colon (`:`) is the separator between the two source records. When a key exists in only one file, the corresponding part of the joined record is left blank.

JOINFILS is designed for a one-to-many relationship: one record in file 1 may match multiple records in file 2. For multiple matching records in file 2, the first matching file 1 record is repeated. A many-to-one or many-to-many relationship is not handled as a full database-style join.

## Files in the package

- `JOINFILS.S` — source code for the JOINFILS macro.
- `SORT.S` — source code for the sorting macro required by JOINFILS.
- `FILE_ID.DIZ` — brief description from the original package.

## Requirements

- The SemWare Editor (TSE) with the SAL compiler.
- Two ASCII text files whose keys occupy fixed column positions.
- A compiled `SORT.MAC` that TSE can find when JOINFILS runs.

The original package was written for TSE Pro 2.5 and TSE Pro/32 2.8. Compatibility with newer TSE releases depends on whether the older SAL source still compiles and runs without modification.

## Compile the macros

1. Extract `joinfils.zip` into a working directory.
2. Open a command prompt in that directory.
3. Compile both SAL source files:

   ```text
   sc32 SORT.S
   sc32 JOINFILS.S
   ```

4. Confirm that `SORT.MAC` and `JOINFILS.MAC` were created.
5. Place both `.MAC` files in the same macro directory, or in another location where TSE can find and execute them.

## Prepare the input files

Before running JOINFILS:

1. Identify the key field shared by both files.
2. Determine the first and last column of that key in each file. Columns are numbered starting at 1.
3. Ensure that the key is stored at fixed column positions throughout each file.
4. Keep backup copies of the input files. The macro sorts and modifies the opened input buffers while processing them, then abandons those buffers without saving.

Example:

- File 1 key in columns 1 through 5.
- File 2 key in columns 8 through 12.

Both selected key ranges must represent the same key and should have the same effective width and formatting.

## Run JOINFILS

### From TSE

1. Start TSE.
2. Execute the `JOINFILS` macro using TSE's macro execution command.
3. At **File 1 to join**, enter the full path and filename of the first input file.
4. Enter the starting and ending key columns for file 1.
5. At **File 2 to join**, enter the full path and filename of the second input file.
6. Enter the starting and ending key columns for file 2.
7. Review the displayed selections.
8. Answer **Yes** to **Proceed with these choices?**

### Cancel at a file prompt

Press **Escape** at either **File 1 to join** or **File 2 to join** to cancel JOINFILS. Version 1.0.0.0.2 displays:

```text
JOINFILS cancelled. TSE will remain open.
```

After you acknowledge the warning, the macro stops and returns control to TSE. It does not call `AbandonEditor()` on this cancellation path. If the second file prompt is cancelled, JOINFILS also closes the first input buffer that it opened for the operation.

The original command-line form documented by the author is:

```text
E -EJOINFILS
```

Use the executable name and macro command syntax appropriate for your installed TSE version.

## Result

JOINFILS opens the result in a new read-only-style buffer named:

```text
c:\*read\only*\joined.fil
```

The result initially exists only in the editor. Inspect it and use **Save As** to save it under a normal filename and path.

Each output line contains the fixed-width record from file 1, a colon, and the fixed-width record from file 2. Records are ordered by the selected keys because the macro sorts both input buffers before joining them.

## Important notes

- JOINFILS works with ASCII text, not UTF-8 data.
- The macro uses exact, case-sensitive key comparisons.
- Leading spaces, trailing spaces, capitalization, and key width can affect matching.
- Keys must remain in fixed columns on every line.
- The two source buffers are closed without saving after a successful join.
- Pressing **Escape** at either file-selection prompt displays a cancellation warning, stops JOINFILS, and leaves TSE open.
- An invalid or unreadable filename still displays an error and follows the original `AbandonEditor()` error path.
- Cancelling a column prompt or answering **No** to the final confirmation still follows the original macro's `AbandonEditor()` behavior.
- `SORT.MAC` must be available because JOINFILS calls it with `ExecMacro("sort")`.
- The output separator is always a colon.

## Troubleshooting

### TSE reports that SORT cannot be found

Compile `SORT.S` and put `SORT.MAC` where TSE can locate macros. Keep it available when running `JOINFILS.MAC`.

### Records that should match remain separate

Check that the selected column ranges contain precisely the same key text. Pay particular attention to spaces, letter case, and different key widths.

### The joined output appears padded

JOINFILS preserves fixed-width records based on the longest line in each input file. Padding is therefore expected.

### Multiple records produce unexpected combinations

The intended relationship is one file 1 record to one or more file 2 records. The macro is not a general many-to-many join utility.

### No output file appears on disk

The macro creates an editor buffer, not a saved disk file. Use **Save As** after inspecting the result.

## Version history

- 1.0.0.0.1 — 2026-09-11 23:38:27 UTC — Updated for JOINFILS 1.0.0.0.2: documented safe cancellation at either file prompt without closing TSE.
- 1.0.0.0.0 — 2026-09-11 22:29:35 UTC — Initial Markdown description, help, compilation instructions, operating steps, limitations, and troubleshooting guidance.
