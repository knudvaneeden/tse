# FORTM

**Version:** 1.0.0.0.0  
**Date:** 2026-09-09  
**Time:** 22:58:21 UTC  
**Original author:** Paul Bennett

## Description

FORTM is a collection of TSE SAL macros for cleaning up, checking, and reformatting fixed-format FORTRAN 77 source code. The original macros were written for The SemWare Editor Professional v2.50 and for FORTRAN 77 as used on Unisys 1100/2200 systems.

The collection can:

- indent `IF`, `ELSE`, `ELSEIF`, `ENDIF`, and optionally labeled `DO` structures;
- convert FORTRAN code to uppercase while preserving quoted text;
- convert comment text to lowercase;
- remove blank comment lines;
- left-justify statement labels;
- renumber labels;
- identify apparently unused labels, subroutines, and functions;
- move Unisys-style `@` inline comments to separate comment lines; and
- assign sequential values to a selected variable.

These macros modify source text directly. Always work on a backup copy and compile and test the FORTRAN program after making changes.

## Requirements

- The SemWare Editor (TSE) with SAL macro support.
- The SAL compiler appropriate for your TSE installation, such as `sc32.exe` for 32-bit TSE.
- Fixed-format FORTRAN source, normally using columns 1 through 72.
- Spaces instead of horizontal tab characters while the macros are processing the file.

Some macros assume that FORTRAN statements are uppercase, comments begin with `C`, `c`, or `*` in column 1, labels occupy columns 1 through 5, the continuation indicator is in column 6, and code begins in column 7.

## Included files

### `ASGNUM.S`

Finds assignments to a selected variable and replaces the value following `=` with sequential numbers. It asks for the search text, starting value, and increment. A marked line block is used when present; otherwise the macro can process the whole file after confirmation. Comment lines are skipped.

### `BLINES.S`

Deletes blank lines and blank FORTRAN comment lines from a marked line block. Lines containing only `C`, `c`, or `*`, including comment lines whose only additional text is in columns 73 through 80, can be removed.

### `COMMENTS.S`

Converts columns 2 through 72 of comment lines in a marked block to lowercase. The comment marker in column 1 is preserved.

### `INDENT.S`

Indents structured `IF`, `ELSE`, `ELSEIF`, and `ENDIF` code in a marked block. It can also indent labeled `DO` loops, with support for up to ten nested pending loop labels. The macro asks for the indentation width, whether `DO` loops should be indented, and the initial code column.

Use `UPPERC.S`, `COMMENTS.S`, `LJLABELS.S`, and `NIN.S` first when the source needs normalization. Review lines that extend beyond column 72 after indentation.

### `INUSE.S`

Scans the current file for subroutine and function definitions and warns when their names do not appear to be referenced elsewhere. This is a text-based check, so review every result before deleting code.

### `LJLABELS.S`

Left-justifies numeric FORTRAN labels in columns 1 through 5 of a marked line block.

### `NIN.S`

Converts Unisys-style inline comments beginning with `@` into separate `C` comment lines. It requires a marked line block and asks whether the new comment lines should be placed above or below their associated code. Each comment can be converted, skipped, or followed by automatic conversion of all remaining matches.

### `NOTLABEL.S`

Checks labels in a marked block and reports the first label that does not appear to be referenced in the code area. Review the result manually because the check is based on textual matching.

### `RELABEL.S`

Renumbers all labels in a marked block using a requested starting number and increment. Optional warning checks try to detect occurrences that might be ordinary numeric values rather than label references.

Review `READ`, `WRITE`, and `FORMAT` statements carefully. If old and new label ranges overlap, first renumber to a temporary non-overlapping range and then run the macro again with the final range.

### `UPPERC.S`

Converts FORTRAN code to uppercase while leaving text inside single quotes unchanged. Comment lines are skipped, although a lowercase `c` comment marker is changed to uppercase `C`. A marked line block is used when present; otherwise the macro can process the whole file after confirmation.

### Other files

- `README.!$!` contains the original documentation.
- `FILE_ID.DIZ` contains the original archive description.

## Installation

1. Extract `fortm.zip` to a working directory.
2. Keep the original archive as a backup.
3. Open a command prompt in the directory containing the `.S` files.
4. Compile each macro with the SAL compiler. For example:

   ```text
   sc32 indent.s
   sc32 upperc.s
   ```

5. Repeat the command for every macro you intend to use.
6. Copy the compiled macro files to a directory from which TSE can load them, or leave them in a known directory and run them by their full path.

The exact compiled filename and loading procedure can vary with the TSE version and configuration.

## How to run a macro

1. Make a backup of the FORTRAN source file.
2. Open the source file in TSE.
3. Expand horizontal tabs to spaces.
4. For a block-oriented macro, mark the required lines as a line block.
5. Execute the compiled macro through TSE's macro execution command.
6. Answer any prompts displayed by the macro.
7. Review all changes and warnings.
8. Save the file only after verifying the result.
9. Recompile and test the FORTRAN program.
10. When practical, compare the generated executable with one built from the unchanged source.

## Suggested cleanup sequence

For old fixed-format FORTRAN code, the following order is useful:

1. Work on a copy and convert tabs to spaces.
2. Run `NIN` if the source contains `@` inline comments.
3. Run `UPPERC` to normalize code to uppercase.
4. Run `COMMENTS` to make comment text lowercase.
5. Run `LJLABELS` to normalize label placement.
6. Run `BLINES` if blank comment lines should be removed.
7. Run `INDENT` to format control structures.
8. Run `NOTLABEL` and `INUSE` to help locate potentially unused code.
9. Run `RELABEL` only after making a backup and reviewing its cautions.
10. Compile, test, and compare the resulting program.

## Important limitations

- The macros were designed for older fixed-format FORTRAN 77 conventions and may not understand free-form or modern Fortran syntax.
- They do not cover every valid FORTRAN construct.
- Most checks are textual rather than full language parsing, so false matches are possible.
- `INDENT.S` supports a maximum of ten nested tracked labeled `DO` loops.
- Formatting can push code beyond column 72.
- Label renumbering can affect numeric text that resembles a label.
- `INUSE.S` and `NOTLABEL.S` should be treated as review aids, not proof that code is unused.
- The source macros are historical and may require small compatibility changes for newer SAL compilers.

## Safety recommendations

- Never run these macros on the only copy of a source file.
- Process a small marked block first when learning a macro.
- Inspect the editor's undo history before saving.
- Check fixed-format column boundaries after every formatting operation.
- Compile and test the FORTRAN source after each major transformation.

## Version history

- **1.0.0.0.0 — 2026-09-09 22:58:21 UTC**
  - Created the initial Markdown description, help, installation instructions, usage steps, macro reference, limitations, and safety guidance for the FORTM collection.

Future documentation revisions should increment the final component sequentially, for example `1.0.0.0.1`, `1.0.0.0.2`, and so on.
