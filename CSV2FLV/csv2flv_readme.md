# Csv2flv

**README version:** 1.0.0.0.0  
**Created:** 2026-09-04 17:06:53 CEST (UTC+02:00)  
**Macro version:** 1.1  
**Macro author:** Carlo Hogeveen  
**Compatibility:** The SemWare Editor Professional (TSE Pro) 2.5e and later

## Description

`Csv2flv` is a TSE SAL macro that converts a character-separated values file into a fixed-length-values file. Although the source refers to CSV, the input separator is configurable and may be a comma, semicolon, or another single character.

The macro examines every field in the current file, determines the maximum required width, and writes an aligned copy to a new `.flv` buffer. It can:

- detect comma- or semicolon-separated input;
- let you correct the detected input separator;
- recognize quoted alphanumeric values;
- let you select the quoting character;
- distinguish numeric and alphanumeric fields;
- align numeric fields on their decimal character;
- pad numeric values with leading or trailing zeroes;
- left-align alphanumeric fields and pad them with spaces;
- optionally insert a separator between the fixed-width output fields;
- handle either a point or comma as a numeric decimal character.

The original CSV buffer is not changed or removed. A successful conversion creates a new, unsaved buffer with the original base filename and the `.flv` extension.

## Package contents

- `Csv2flv.s` — TSE SAL source code.
- `File_id.diz` — short package description.

## Requirements

- The SemWare Editor Professional 2.5e or later.
- The TSE SAL compiler appropriate for your TSE installation, such as `sc32.exe` for 32-bit TSE.
- A text file containing one record per line and consistently arranged fields.

## Installation and compilation

1. Extract `csv2flv.zip`.
2. Copy `Csv2flv.s` to your TSE macro source directory, normally the `mac` directory below the TSE installation directory.
3. Open a command prompt in that directory.
4. Compile the source:

   ```bat
   sc32 Csv2flv.s
   ```

5. Confirm that the compiler completes without errors and creates the compiled TSE macro.

If `sc32` is not on `PATH`, invoke it with its full path or compile the source through your existing TSE macro-development setup.

## How to run

1. Start TSE.
2. Open the CSV or other separated-values input file.
3. Make that file the current buffer.
4. Execute the macro by entering its macro name in TSE:

   ```text
   Csv2flv
   ```

5. Review the proposed old field separator and correct it if necessary. This must be one character.
6. Enter the optional separator for the generated FLV data. Leave the answer empty to create adjacent fixed-width fields.
7. Review the proposed quoting character and correct it if necessary.
8. For fields detected as numeric, choose whether each field—or all numeric fields—should be treated as numeric or alphanumeric.
9. If the decimal character cannot be determined, choose the appropriate point/comma option or treat that field as alphanumeric.
10. Wait until TSE reports `Done`.
11. Inspect the new `.flv` buffer carefully, especially its first records and field boundaries.
12. Save the new buffer manually when satisfied with the result.

## Numeric-field behavior

A field is initially considered numeric only when all of its values match the macro's supported numeric notation. Numeric values may have:

- digits;
- one leading or trailing `+` or `-` sign;
- a comma or point decimal character;
- consistently used comma or point grouping characters.

If the notation is ambiguous, the macro asks which decimal character to use. Numeric output is zero-padded to a consistent width and aligned by its decimal portion. Alphanumeric output is left-aligned and space-padded.

## Input expectations and limitations

- Each record should contain the same logical set of fields.
- Field types should be consistent down each column.
- Unquoted values should not contain leading or trailing spaces.
- Values containing spaces or quote characters should be quoted consistently.
- A quote inside a quoted value should be represented by two quote characters.
- The macro does not cover every CSV dialect or malformed-input case.
- TSE's maximum line length applies. Conversion stops if a line reaches `MAXLINELEN`.
- The macro chooses between comma and semicolon by sampling their occurrence in the first part of the file; always verify the proposed separator.
- If a numeric value contains only one possible grouping character, automatic decimal detection may be impossible. Select the opposite character when that is the actual decimal character.

## Important whitespace note

Fixed-length output depends on trailing spaces. After a successful conversion, the macro leaves TSE's `RemoveTrailingWhite` setting turned off and reports that files will be saved with trailing whitespace. This prevents the padding in the FLV buffer from being removed, but it also affects subsequently saved files in the same TSE session. Restore your preferred editor setting after saving the FLV file if necessary.

## Troubleshooting

### The wrong separator was detected

Replace the proposed character in the **old field separator** prompt with the actual one-character separator used by the input file.

### A numeric identifier is reformatted

Choose **Treat this field as alphanumeric**. This is appropriate for account numbers, postal codes, product codes, and other digit-only values whose leading zeroes or exact textual form must be preserved.

### The decimal character is undeterminable

Select the point or comma used as the decimal character in that field. You may apply the choice to one field or all ambiguous numeric fields.

### The output columns do not match an external specification

The macro sizes fields from the input data. Use TSE column-block operations afterward to insert, remove, or resize columns required by the external specification.

### Conversion is aborted

The new FLV buffer is abandoned and the original CSV buffer remains available. Correct the input or prompt choices and run `Csv2flv` again.

## Safety recommendations

- Keep a backup of important input data.
- Verify record counts, field boundaries, numeric signs, decimal positions, and padding before using the output.
- Test the conversion on representative data before processing production files.
- Save the generated `.flv` file under a new name if a file with that name already exists.

## Version history

| README version | Date and time | Changes |
|---|---|---|
| 1.0.0.0.0 | 2026-09-04 17:06:53 CEST | Initial Markdown description, installation, compilation, usage, limitations, troubleshooting, and safety notes. |

For future README revisions, increment the final component sequentially: `1.0.0.0.1`, `1.0.0.0.2`, `1.0.0.0.3`, and so on.

## Original macro history

| Macro version | Changes |
|---|---|
| 1.0 | Initial release. |
| 1.1 | Added an optional separator for the generated FLV file. |

## Disclaimer

Use this macro at your own risk. Always inspect the generated fixed-length data before relying on it or passing it to another system.
