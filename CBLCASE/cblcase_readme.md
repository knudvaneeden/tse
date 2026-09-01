# CblCase

Version: **1.0.0.0.0**

## Description

`CBLCASE.S` is a TSE Pro/16 and TSE Pro/32 SAL macro that changes the letter case of COBOL source code while preserving comments and quoted text.

The macro supports three conversion modes:

- `lower` - converts program text to lowercase.
- `upper` - converts program text to uppercase.
- `capitalize` - converts the first letter of each word to uppercase and the remaining letters to lowercase.

Configuration is stored separately for each filename extension. Although the macro was written for COBOL 74/85 source files, it may also be useful for fixed-format Fortran or other source formats with a comment indicator in a known column.

## Important behavior

- Text inside single or double quotes is left unchanged.
- Entire comment lines are left unchanged when the configured comment-indicator column contains a character.
- Quoted strings are assumed to begin and end on the same line.
- Opening and closing quotes must use the same quote character.
- When the comment-indicator column is `7`, the macro assumes traditional COBOL format. Columns 1 through 7 and columns 73 onward are then left unchanged.
- A comment-indicator column of `0` disables fixed-column comment detection.
- The conversion changes the current file. Save a backup or use version control before processing important source code.

## Included files

- `CBLCASE.S` - TSE SAL source code.
- `FILE_ID.DIZ` - brief description of the original package.

## Requirements

- The SemWare Editor Professional (TSE Pro), 16-bit or 32-bit.
- A TSE SAL compiler compatible with this older macro source.

## Installation

1. Extract `cblcase.zip`.
2. Copy `CBLCASE.S` to TSE's `MAC` directory.
3. Open a TSE command prompt or use TSE's macro compiler.
4. Compile the source file. A typical command is:

   ```text
   sc32 cblcase.s
   ```

   For a 16-bit TSE installation, use the corresponding 16-bit SAL compiler.

5. Confirm that the compiled macro is available to TSE.

## First-time configuration

1. Open a source file whose extension you want to configure, for example a file ending in `.cbl`.
2. Execute the `CblCase` macro from TSE.
3. At the extension prompt, enter an extension beginning with a period, for example:

   ```text
   .cbl
   ```

4. Enter the column whose presence indicates a comment line. For traditional COBOL, enter:

   ```text
   7
   ```

5. Enter one of the following actions:

   ```text
   lower
   upper
   capitalize
   ```

6. The macro saves the setting in `cblcase.cfg` in TSE's `MAC` directory and applies the selected conversion to the current file.

## Running the macro manually

1. Open the source file in TSE.
2. Make sure its filename extension has been configured.
3. Execute the `CblCase` macro.
4. Review the converted source.
5. Save the file when the result is correct.

Executing the macro manually opens the configuration prompts, allowing the current extension's settings to be added or changed before conversion.

## Automatic conversion when opening files

To process configured files when they are first opened:

1. Add `CblCase` to TSE's Macro AutoLoad List.
2. Restart TSE.
3. Open a file with a configured extension.

The resident macro reads `cblcase.cfg` and performs the configured conversion during TSE's first-edit event.

Because this can modify a file immediately after it is opened, test the feature on copies of files before using it routinely.

## Changing a configuration

Run the macro again, enter the existing extension, and supply a new comment column or conversion action. The matching entry in `cblcase.cfg` is updated.

## Removing a configuration

1. Execute the macro.
2. Enter the extension to remove.
3. Enter its comment-indicator column when prompted.
4. At the action prompt, enter:

   ```text
   deconfigure
   ```

The entry for that extension is removed from `cblcase.cfg`.

## Configuration-file format

Each entry in `cblcase.cfg` contains an extension, a comment-indicator column, and an action:

```text
.cbl 7 capitalize
.cob 7 upper
.f 1 lower
```

Using the macro's prompts is recommended instead of editing this file manually.

## Example

Given this COBOL source:

```text
       IDENTIFICATION DIVISION.
      *This comment remains unchanged.
       DISPLAY "Mixed Case Text".
```

With `.cbl`, column `7`, and action `lower`, program text is converted to lowercase while the comment and quoted text remain unchanged.

## Troubleshooting

### Nothing is converted

- Confirm that the current file's extension matches the configured extension.
- Check that the configured action is `lower`, `upper`, or `capitalize`.
- For COBOL files, verify that the comment-indicator column is `7`.
- A line is intentionally skipped when the configured comment column contains a non-space character.

### The configuration cannot be saved

- Confirm that TSE's `MAC` directory exists and is writable.
- Check that TSE can create or overwrite `cblcase.cfg` there.

### Quoted text is converted unexpectedly

- Make sure the quoted string opens and closes on the same line.
- Make sure the same quote character is used at both ends.

### Source outside columns 8 through 72 is unchanged

This is intentional when the configured comment-indicator column is `7`; the macro then applies traditional COBOL column rules.

## Version history

### 1.0.0.0.0

- Initial Markdown documentation for the original `CBLCASE.S` package.
- Added installation, configuration, execution, AutoLoad, removal, examples, limitations, and troubleshooting information.

Future documentation revisions can continue as `1.0.0.0.1`, `1.0.0.0.2`, and so on.

## Original author

Carlo Hogeveen (`carlo.hogeveen@xs4all.nl`)

Original macro date: September 30, 2000.
