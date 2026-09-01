# CJCONFIG — Crazy Jack's TSE Configuration Notes and SAL Macros

**README version:** 1.0.0.0.0  
**Created:** 2026-09-02 00:53:48 CEST (2026-09-01 22:53:48 UTC)  
**Original package:** `cjconfig.zip`  
**Original material:** Copyright 1993 by Jack Hazlehurst; `PARAFIND.S` is released to the public domain. See the source files for their individual notices.

## Description

`cjconfig.zip` is a historical customization package for The SemWare Editor (TSE). It contains Jack Hazlehurst's detailed configuration notes and four TSE SAL source files. The examples are intended primarily as components to study, adapt, and integrate into a custom TSE user-interface or burn-in source rather than as one complete, ready-to-run application.

The package demonstrates:

- configurable and direction-sensitive bracket matching;
- Borland-style indentation-aware backspace behavior;
- full paragraph justification;
- navigation to the beginning or end of adjacent paragraphs; and
- techniques for maintaining file-specific editor settings, described in the notes.

## Package contents

| File | Purpose |
| --- | --- |
| `CJCONFIG.NTS` | The main documentation. It explains the author's TSE customizations, integration ideas, file-specific settings, and example SAL code. |
| `MMATCH.S` | A modified `mMatch(integer dir)` routine with configurable bracket pairs and forward/backward matching. It can also match identical character pairs such as quotation marks. |
| `BACKSPAC.S` | A replacement `mBackSpace()` routine that follows indentation levels on preceding lines and provides Borland-style outdenting. |
| `FULLJUST.S` | Provides `mJustifyPara()` to wrap and fully justify the current paragraph up to the configured right margin. It includes the callable test entry point `mTest()`. |
| `PARAFIND.S` | Provides `mNextPara()` and `mPrevPara()` for moving to paragraph boundaries. It includes a small callable test entry point named `test()`. |

## Requirements

- The SemWare Editor with a compatible SAL compiler.
- Basic familiarity with compiling and running TSE SAL macros.
- A backup copy of your existing TSE interface or burn-in source before replacing built-in routines or key bindings.

These sources date from 1993 and use the TSE/SAL interface available at that time. Newer TSE releases may require small compatibility changes. Test the macros on copies of files before making them part of a permanent editor configuration.

## How to install and run

### 1. Extract the archive

Extract `cjconfig.zip` to a working directory. Keep all five files together while reviewing the package.

### 2. Read the configuration notes

Open `CJCONFIG.NTS` in TSE. This is the primary guide and explains how the routines were intended to be incorporated into a customized TSE interface.

For the original formatting, display the document with tabs expanded at a width of 8.

### 3. Compile a standalone macro for testing

Open the desired `.S` source in TSE and compile it with TSE's SAL compiler using the normal macro-compilation command for your installation. Compilation should create the executable macro form used by your TSE version.

`FULLJUST.S` and `PARAFIND.S` have empty `main()` procedures because their useful routines are intended to be called by name or integrated into another interface source.

### 4. Test `FULLJUST.S`

1. Compile and load `FULLJUST.S`.
2. Open a text file containing a paragraph.
3. Set a suitable right margin.
4. Place the cursor in the paragraph.
5. Execute the public macro `mTest`.

The macro calls `mJustifyPara()`, wraps the paragraph, and distributes spaces so that applicable lines reach the right margin. The last line of a paragraph is not expanded in the same way as the preceding lines.

### 5. Test `PARAFIND.S`

1. Compile and load `PARAFIND.S`.
2. Open a document containing several paragraphs.
3. Execute the public macro `test`.

The supplied test calls `mNextPara(0)`, which moves toward the beginning of the next paragraph and reports whether the operation succeeded.

For custom use, call:

- `mNextPara(FALSE)` — next paragraph beginning;
- `mNextPara(TRUE)` — next paragraph end;
- `mPrevPara(FALSE)` — previous paragraph beginning;
- `mPrevPara(TRUE)` — previous paragraph end.

### 6. Integrate `MMATCH.S`

`MMATCH.S` is designed as a replacement or adaptation of TSE's existing match routine.

- Call `mMatch(1)` to search in the forward/right direction.
- Call `mMatch(-1)` to search in the backward/left direction.
- Use `GetAllBrackets()` to edit the paired-character table.
- Use `GetLRBrackets()` when adapting controls for the left- and right-bracket search sets.

The default paired characters are parentheses, braces, square brackets, angle brackets, and double quotation marks. Matching does not understand language syntax, so brackets or quotes inside comments and strings can produce unexpected matches.

### 7. Integrate `BACKSPAC.S`

`BACKSPAC.S` supplies `mBackSpace()` as a replacement for the standard interface routine. Add it to the appropriate custom interface source and bind the Backspace key to it using your existing TSE key-binding setup.

When auto-indent and language mode are active, pressing Backspace at the first non-white character searches upward for the next smaller indentation level and aligns the current line with it. In overwrite mode, the routine performs rubout-style behavior.

### 8. Rebuild and test the customized interface

After copying the required procedures into your own burn-in/interface sources:

1. resolve any duplicate procedure names;
2. update calls and key bindings to use the replacement routines;
3. compile the complete interface with the SAL compiler;
4. load or burn in the resulting interface according to your TSE version; and
5. test bracket matching, Backspace, paragraph movement, and justification on disposable files.

## Important integration notes

- The archive is a collection of source modules and documentation, not a single macro with one unified start command.
- `MMATCH.S` and `BACKSPAC.S` are chiefly replacement routines. They need calls or key bindings in the surrounding interface.
- The original notes recommend extracting only `mJustifyPara()` from `FULLJUST.S` when placing it in a burn-in source.
- `PARAFIND.S` can be compiled externally for testing, but its navigation routines become more useful when copied into the main interface and assigned to keys or menu entries.
- Other packages mentioned in `CJCONFIG.NTS`, including TABOLATE, BITSET, and STRSTUFF, are not included in `cjconfig.zip`.
- The extensive file-specific configuration system described in `CJCONFIG.NTS` is explanatory sample material; it is not supplied as a separate complete `.S` module in this archive.

## Troubleshooting

### The macro compiles but appears to do nothing

Confirm that you executed the correct public procedure. The empty `main()` routines in `FULLJUST.S` and `PARAFIND.S` intentionally perform no action by themselves.

### Duplicate procedure-name errors

Your current TSE interface may already define `mMatch()`, `mBackSpace()`, or related helpers. Replace or rename the existing routine instead of compiling two definitions with the same name into one interface.

### Backspace does not follow indentation

The enhanced indentation behavior depends on both AutoIndent and the interface's `language` flag being enabled. Otherwise the routine falls back to more conventional Backspace behavior.

### Matching goes in the wrong direction

Check the argument passed to `mMatch()`: use a negative value for backward matching and a non-negative value for forward matching. The original notes specifically recommend `-1` and `1`.

### Full justification gives unexpected spacing

Check the right margin, paragraph boundaries, word-wrap setting, tabs, and sentence punctuation. Test first with a simple plain-text paragraph. The routine normalizes whitespace and aims to place two spaces after `.`, `!`, and `?` where applicable.

### Compilation fails on a modern TSE release

The source targets an early TSE SAL environment. Compare identifiers and syntax with the SAL documentation supplied with your installed TSE version, then adapt obsolete names carefully.

## Version history

| README version | Date and time | Changes |
| --- | --- | --- |
| 1.0.0.0.0 | 2026-09-02 00:53:48 CEST | Initial Markdown README created from the contents and original documentation in `cjconfig.zip`. |

Future revisions can continue as `1.0.0.0.1`, `1.0.0.0.2`, `1.0.0.0.3`, and so on.
