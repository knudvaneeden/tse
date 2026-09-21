# MARKWORD

Version: 1.0.0.0.1  
Date and time: 2026-09-21 20:39:33 CEST

## Description

MARKWORD is a TSE SAL source module that provides two enhanced word-marking procedures. Repeating the assigned key extends the marked block one word at a time. Pressing a different key ends the operation and passes that key back to TSE, so normal editing can continue.

The package contains these procedures:

- `mMarkWord()` marks forwards. Its first invocation marks the current word. Repeating the same assigned key extends the selection through successive non-white groups, allowing punctuation and brackets to be included.
- `mLMarkWord()` marks backwards. Repeating the assigned key extends the selection backwards one word at a time.

The original source was written by Arnold M.J. Hennig and was designed to be included in a TSE user-interface source file (`.ui`) and assigned to keys.

## Requirements

- The SemWare Editor (TSE) with its SAL compiler.
- A writable copy of your TSE user-interface source file.
- A backup of the existing `.ui` file before modifying it.

## Files

- `MARKWORD.S` — TSE SAL procedures with an informative `Main()` entry point.
- `FILE_ID.DIZ` — original short package description.
- `markword.ini` — initialization file reserved for package settings.
- `markword_readme.md` — this documentation.

## Installation

1. Extract `markword1.0.0.0.0.zip` to a working directory.
2. Back up the `.ui` source file that you normally compile for TSE.
3. Include `MARKWORD.S` in that `.ui` source, or copy both procedures into it.
4. Assign `mMarkWord()` and `mLMarkWord()` to two unused keys in the key-definition section of the `.ui` file.
5. Compile the modified `.ui` source with the SAL compiler appropriate for your TSE installation.
6. Load or activate the resulting user-interface macro in TSE according to your normal TSE setup.

Example key assignments must be adapted to the syntax and free keys in your own `.ui` file. The package intentionally does not impose default keys.

## How to run

### Mark forwards

1. Place the cursor on or near the first word to mark.
2. Press the key assigned to `mMarkWord()`.
3. Press the same key repeatedly to extend the marked block forwards.
4. Press any different key to finish; MARKWORD passes that key back to TSE.

If the cursor is before the first word on a line, the procedure marks from the beginning of the line through the first non-white group.

### Mark backwards

1. Place the cursor on or after the word from which marking should start.
2. Press the key assigned to `mLMarkWord()`.
3. Press the same key repeatedly to extend the marked block backwards.
4. Press any different key to finish; MARKWORD passes that key back to TSE.

## Configuration

`MARKWORD.S` does not read an initialization file. Therefore `markword.ini` contains only explanatory comments and reserved settings. Key assignments remain in the user's `.ui` source file.

## Notes

- Running the compiled macro directly invokes `Main()` and displays an informative message explaining the two procedures.
- The marking operations still require `mMarkWord()` and `mLMarkWord()` to be assigned to keys in a TSE user-interface source file.
- Select unused key combinations to avoid conflicts with existing TSE commands or macros.
- Recompile the `.ui` source after changing key assignments.

## Version history

- 1.0.0.0.1 — Added `Main()` with an informative message for users who run the macro directly.
- 1.0.0.0.0 — Added Markdown documentation and the initial `markword.ini`; packaged the original files without changing their behavior.
