# MAKECSV1

## Package information

- Package version: 1.0.0.0.1
- Package created: 2026-09-21 08:12:46 UTC
- Original macro: MAKECSV.S version 1.1
- Original author: M. W. Hulse
- Original date: 1994-10-16
- Intended editor: The SemWare Editor (TSE)
- Macro language: TSE SAL

## Description

MAKECSV1 converts a text file containing fixed-width records into a comma-separated-value file. In a fixed-width file, every field begins at a known column and occupies a fixed number of characters. The macro removes leading and trailing spaces from each selected field, separates the fields with commas, and optionally encloses character fields in double quotation marks.

The fields to export are described in a separate definition file named `DEFINEcc.RCD`, where `cc` is a two-character suffix chosen by the user. The resulting CSV file is named `RESULTcc.CSV`.

The macro can:

- Include a header line.
- Export all fields or only selected fields.
- Place fields in a different order from the source file.
- Treat character and numeric fields differently.
- Replace existing double quotation marks in the source data with single quotation marks after confirmation.

## Files in this package

- `MAKECSV.S` — original TSE SAL source code.
- `MAKECSV.DOC` — original documentation.
- `FILE_ID.DIZ` — original short package description.
- `makecsv1_readme.md` — this description and usage guide.
- `makecsv1.ini` — configuration placeholder for possible future versions.

## Requirements

- The SemWare Editor (TSE) with a SAL compiler compatible with the source.
- A fixed-width text file loaded in the editor.
- A matching `DEFINEcc.RCD` field-definition file in TSE's current working directory.

The original source identifies TSE 2.0 as its target. Later TSE versions may compile it, but the macro is supplied as historical source and should be tested on a copy of the input data.

## Definition-file format

Create one line for every field that should appear in the output. Do not place blank lines between definitions. Each line has this format:

```text
[Field Name],Beginning Column,Field Length,Character Field,
```

The final comma is required by the format used by the original macro.

### Fields

1. `Field Name` is the optional CSV header text. The original macro stores at most 16 characters for a field name. Supply names for every field or omit them for every field.
2. `Beginning Column` is the one-based starting column of the field in the fixed-width input record.
3. `Field Length` is the number of character positions occupied by the field.
4. `Character Field` is `Y` for text or `N` for numeric data. Text fields are enclosed in double quotation marks; numeric fields are not.

The order of the definition lines determines the order of the fields in the CSV output. Definitions do not have to follow the source-file order, and unwanted source fields can be omitted.

### Definition-file example

For suffix `01`, create `DEFINE01.RCD`:

```text
Last Name,1,16,Y,
First Name,17,16,Y,
Age,33,3,N,
```

If no header is wanted, leave the first value empty on every line:

```text
,1,16,Y,
,17,16,Y,
,33,3,N,
```

## Example

An input record could contain fixed-width fields like these:

```text
Blow            Joseph           23
Malone          Maggie           21
```

With the preceding `DEFINE01.RCD`, the macro creates `RESULT01.CSV` containing data in this general form:

```csv
"Last Name","First Name","Age",
"Blow","Joseph",23,
"Malone","Maggie",21,
```

The original macro appends a comma after every field, including the last field on a line. Most spreadsheet programs can import this, but applications requiring strict CSV may interpret the final comma as an additional empty field.

## Compile and install

1. Extract every file from `makecsv11.0.0.0.1.zip` into a working directory.
2. Compile `MAKECSV.S` with the TSE SAL compiler, for example:

   ```text
   sc32 MAKECSV.S
   ```

3. Confirm that the compiler creates `MAKECSV.MAC`.
4. Place or load the compiled macro according to the macro-loading method used by your TSE installation.

The source includes a `Main()` entry point that calls `MakeCSV()`. It also assigns the macro to `<Alt i>` when it is loaded.

## Steps to run

1. Back up the source data file. Although the macro is intended not to change it, choosing quote conversion does edit double quotation marks in the loaded source buffer before processing.
2. Create the required `DEFINEcc.RCD` file in TSE's current working directory. Replace `cc` with exactly two characters, such as `01`.
3. Open the fixed-width source data file in TSE and make it the current buffer.
4. Load `MAKECSV.MAC` if it is not already loaded.
5. Run `MAKECSV.MAC` directly, which invokes `Main()`, or press `<Alt i>` to start the macro through its assigned hotkey.
6. If the source contains double quotation marks, choose whether they should be converted to single quotation marks. Answering anything other than `Y` causes the macro to stop.
7. At `Enter 2 character DEFINEcc suffix:`, enter only the two-character suffix. For `DEFINE01.RCD`, enter `01`.
8. Wait while the message line reports each processed input line.
9. The macro saves the result as `RESULTcc.CSV`; for suffix `01`, this is `RESULT01.CSV`.
10. Inspect the CSV file in a text editor or spreadsheet before using it as production data.

## Important behavior and limitations

- The suffix input is limited to two characters.
- `DEFINEcc.RCD` and `RESULTcc.CSV` are opened by relative filename, so TSE's current working directory matters.
- The result file is not explicitly cleared before output. Avoid reusing an existing `RESULTcc.CSV` unless its contents have been removed or the file has been renamed.
- Do not use blank lines in the definition file.
- Source fields must fit within the 255-character string limit used by the macro.
- Field names are limited to 16 characters by the original source.
- Leading and trailing spaces in exported fields are removed.
- Character-field recognition is case-sensitive in the source: use uppercase `Y`.
- Embedded double quotation marks are not escaped according to modern CSV rules. The macro instead offers to replace all double quotation marks in the source with single quotation marks.
- Every emitted field has a following comma, including the final field.
- The macro closes the result, definition, and data buffers after saving the result. Save unrelated changes before running it.

## `makecsv1.ini`

The included `makecsv1.ini` records suggested settings for possible future modernization. The original `MAKECSV.S` does not read an INI file, so changing these values currently has no effect. Runtime input is still supplied through the macro prompts and `DEFINEcc.RCD`.

## Troubleshooting

### The definition file cannot be opened

Check that its name is exactly `DEFINEcc.RCD`, that `cc` matches the two characters entered at the prompt, and that the file is in TSE's current working directory.

### Columns are shifted or values are cut off

Recheck the one-based beginning column and field length in every definition. Tabs in the input can make visual columns differ from character positions; fixed-width input should preferably use spaces.

### No header is wanted

Leave the field-name portion empty on every definition line. Do not mix named and unnamed fields.

### The output contains an extra empty column

This is caused by the trailing comma written after the last field. Remove the final comma from each result line with a separate editor operation if the target application requires strict CSV.

### The source data changed

If quote conversion was accepted, the macro replaced double quotation marks with single quotation marks in the loaded source buffer. Restore the original from a backup if necessary.

## Version history

### 1.0.0.0.1 — 2026-09-21 08:12:46 UTC

- Added `Main()` to `MAKECSV.S`.
- `Main()` calls the existing `MakeCSV()` conversion procedure.
- Retained the existing `<Alt i>` hotkey assignment.

### 1.0.0.0.0 — 2026-09-21 07:58:46 UTC

- Packaged the original MAKECSV version 1.1 source and documentation.
- Added this Markdown description, help, examples, and run instructions.
- Added `makecsv1.ini` as a documented placeholder for future configuration support.
