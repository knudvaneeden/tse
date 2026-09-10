# GETWORD3

## Description

GETWORD3 is a TSE SAL macro that completes a partially typed word by finding an earlier matching word in the current text. It is useful when a long or difficult word already occurs in the file and you do not want to type it again in full.

For example, if `supercalafragilisticexpedalioucious` already appears earlier in the file, type `superc` and run the macro. GETWORD3 searches backward for a word beginning with `superc` and offers the complete word for insertion.

The original source identifies Mel Hulse and Richard Hendricks as its authors and is dated June 19, 1993, version 3.

## How it works

GETWORD3:

1. Selects the partial word immediately before or at the cursor.
2. Temporarily removes that partial word.
3. Searches backward through the current file for a matching complete word.
4. Displays the found word in an `Ask()` prompt.
5. Inserts the suggested word when the prompt is accepted.
6. Restores the original partial word if **Esc** is pressed or no match is found.

The search recognizes words preceded by a space, tab, single quote, double quote, opening parenthesis, opening brace, opening bracket, vertical bar, or the beginning of a line. The search is performed backward and ignores character case.

## Requirements

- The SemWare Editor (TSE) with SAL macro support.
- The TSE SAL compiler suitable for the installed TSE version, such as `sc32.exe` for 32-bit TSE.
- The supplied source file `GETWORD3.S`.

## Installation

1. Extract `GETWORD3.S` from `getword3.zip`.
2. Copy `GETWORD3.S` to a convenient TSE macro source directory.
3. Open a command prompt in that directory.
4. Compile the source:

   ```text
   sc32 GETWORD3.S
   ```

5. Confirm that the compiler creates `GETWORD3.MAC`.
6. Copy `GETWORD3.MAC` to the directory from which TSE loads macros, if necessary.

## Steps to run

1. Open a text file in TSE.
2. Make sure the complete word you want to reuse occurs earlier in the current file.
3. Begin typing that word. For example, type `superc`.
4. Leave the cursor immediately after the partial word.
5. Run the compiled macro from TSE's **Macro Execute** command and enter:

   ```text
   GETWORD3
   ```

6. Review the suggested complete word in the prompt.
7. Press **Enter** to accept the suggestion, or press **Esc** to keep the original partial word.

The macro can also be assigned to a key through the normal TSE key-mapping facilities for quicker use.

## Messages and prompts

- `Is This It:` — shows the matching word. Accept it with **Enter**, or cancel with **Esc**.
- `No Matching Word...` — no earlier matching word was found; the original partial word is restored.

## Notes and limitations

- GETWORD3 searches only the current file.
- It searches backward from the current cursor position.
- The partial and completed words are stored in 40-character string variables; very long words may therefore be limited by the original macro.
- The macro uses the original 1993 SAL syntax. Depending on the installed TSE version, minor source adjustments may be required before compilation.
- Save important work before testing older macros in a production file.

## Version history

### 1.0.0.0.0 — 2026-09-10 13:45:45 CEST

- Created the initial Markdown documentation.
- Added a description of the macro and its backward word-completion behavior.
- Added requirements, installation instructions, and step-by-step usage help.
- Documented prompts, search behavior, and limitations found in `GETWORD3.S`.

### 1.0.0.0.1 — Reserved for the next update

- The next documentation revision will use this version number.

## Document information

- File: `getword3_readme.md`
- Documentation version: `1.0.0.0.0`
- Created: 2026-09-10 13:45:45 CEST
- Prepared by: OpenAI Codex (GPT-5)
