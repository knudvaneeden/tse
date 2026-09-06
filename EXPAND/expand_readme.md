# EXPAND — TSE Abbreviation and Word Expansion Macro

**README version:** 1.0.0.0.0  
**Package:** `expand.zip`  
**Original macro:** `EXPAND.S`, Version 1, by David Marcus  
**Original macro date:** 1993-08-19  
**README date:** 2026-09-06  
**README time:** 23:19:06 UTC

## Description

`EXPAND.S` is a legacy SAL macro for The SemWare Editor (TSE). It expands a just-typed abbreviation by proposing matching words from:

1. an external abbreviation file; and
2. words already present in the current document.

The macro first searches the external abbreviation list. If no suggestion is accepted, it searches backward through the current document and then forward. Previously rejected words are tracked during the current expansion operation so that the same suggestion is not offered repeatedly.

The supplied activation key is the backtick key: `` ` ``.

## Package contents

| File | Purpose |
| --- | --- |
| `EXPAND.S` | TSE SAL source code for the expansion macro |
| `FILE_ID.DIZ` | Short original package description |

## Main features

- Expands abbreviations from an external word list.
- Searches the current document for words beginning with the abbreviation.
- Searches backward first and forward afterward.
- Lets the user reject a proposal and continue to the next match.
- Avoids offering the same rejected word more than once during an expansion.
- Maps the capitalization of the abbreviation onto the proposed expansion.
- Can preserve the expansion's original capitalization by appending `-` to the abbreviation.
- Can add accepted document words to the external abbreviation list.
- Can manually add an abbreviation and its expansion when invoked at the beginning of a line.

## Requirements

- The SemWare Editor (TSE) with a SAL compiler compatible with this legacy source.
- Permission to read and write the configured abbreviation-list file.
- A writable directory for the compiled macro file.

Because this source dates from 1993, modern TSE SAL versions may report deprecated syntax or compatibility errors. If that happens, the source must be adapted before it can be compiled successfully.

## Configuration required before compiling

Open `EXPAND.S` and review these settings.

### Activation key

The macro currently defines:

```sal
startup_key = <`>
```

Change `startup_key` in the `CONSTANT` section if the backtick key conflicts with another assignment. Do not change only the final key definition.

### Abbreviation-list path

The active setup code assigns a hard-coded legacy path to `abbrev_file`:

```sal
abbrev_file = 'q:\abbrevs.wrd,'
```

Replace this with a valid path on your system before compiling. Also verify whether the trailing comma is intentional; on most systems it should probably be removed, for example:

```sal
abbrev_file = 'C:\TSE\abbrevs.wrd'
```

The earlier global declaration contains a different path (`q:\expand.wrd`), but the value assigned by `Get_Ready()` is the one used when the macro runs.

## External abbreviation-file format

Store one abbreviation and its expansion on each line, separated by at least one space:

```text
addr address
cfg configuration
key keystrokes
repl replace
```

If the configured file cannot be found, the original documentation says the external-list search is skipped. The macro can still search for matching words in the current document, although behavior can depend on the TSE version used.

## How to compile

1. Extract `expand.zip` into a working directory.
2. Edit `EXPAND.S` and configure the activation key and abbreviation-file path.
3. Open a command prompt in that directory.
4. Compile the source with the TSE SAL compiler. For a current 32-bit TSE setup, the command is normally:

   ```bat
   sc32 EXPAND.S
   ```

5. Confirm that compilation completes without errors.
6. Place or load the resulting compiled macro in the location expected by your TSE installation.

The exact compiled filename and loading method can vary with the TSE/SAL version and local configuration.

## How to run

### Expand a typed abbreviation

1. Open a document in TSE.
2. Type an abbreviation immediately before the cursor, such as `key`.
3. Press the configured Expand key (backtick by default).
4. The proposed expansion is displayed in place and highlighted.
5. Choose what to do:

   - Press `N`, `n`, or the Expand key again to reject the proposal and show another one.
   - Press `Escape` to cancel and restore the original abbreviation.
   - Press any other key to accept the proposal. That key is returned to TSE and processed as the next editing keystroke.

Example: typing `key`, pressing the Expand key, accepting `keystrokes`, and then typing `s` produces the accepted word followed by that keystroke.

### Preserve the expansion's stored capitalization

Append a hyphen to the abbreviation before invoking the macro:

```text
repl-
```

The hyphen disables capitalization mapping. If the matching word is stored as `Replace`, the macro offers `Replace` regardless of the abbreviation's capitalization.

### Add an abbreviation manually

1. Move the cursor to column 1 at the beginning of a line.
2. Press the Expand key.
3. Enter the abbreviation when prompted.
4. Enter its full expansion when prompted.
5. The macro appends the pair to the configured abbreviation file and saves it.

## Capitalization behavior

Without a trailing hyphen, the macro maps capitalization from the abbreviation onto the expansion.

| Typed abbreviation | Example offered expansion |
| --- | --- |
| `repl` | `replace` |
| `REPL` | `REPLACE` |
| `RePl` | `RePlace` |
| `repl-` | Stored capitalization, such as `Replace` |

## Automatic abbreviation learning

When a word found in the current document is accepted, the macro may append the abbreviation and accepted word to the external list. In the supplied source, this condition is coded as `Length(abbrev) <= 3`, although the original explanatory comment says “3 or more characters.” Treat the source code as authoritative unless you deliberately correct this legacy inconsistency.

## Important warnings

- Configure the external abbreviation-file path before use.
- The source is not portable as supplied because it uses a hard-coded `Q:` drive path.
- Back up the abbreviation file before testing automatic additions.
- The original author warns that editing the abbreviation file and then using Expand again in the same TSE session can cause those edits to be lost.
- Pressing an acceptance key also sends that key back to TSE. Choose the key you actually want processed next.
- This README documents the supplied source; it does not claim that the unmodified 1993 macro compiles on every modern TSE release.

## Troubleshooting

### The external abbreviation list is not used

- Verify the path assigned to `abbrev_file` inside `Get_Ready()`.
- Remove the supplied trailing comma unless your setup specifically requires it.
- Confirm that the file exists and is readable.
- Check that every entry begins with an abbreviation followed by spaces and its expansion.

### No suggestion appears

- Make sure the cursor is immediately after the abbreviation.
- Confirm that the abbreviation exists in the external list or that a matching word exists elsewhere in the current document.
- Try a longer abbreviation to reduce ambiguous matches.

### The wrong macro runs when backtick is pressed

Change `startup_key` in the `CONSTANT` section, recompile the macro, and reload it in TSE.

### Compilation fails

The macro uses early-1990s SAL syntax and functions. Check the compiler's line and column diagnostics and adapt obsolete constructs to the SAL version installed with your copy of TSE.

## Version history

| Version | Date and time (UTC) | Changes |
| --- | --- | --- |
| 1.0.0.0.0 | 2026-09-06 23:19:06 | Initial README created from `EXPAND.S` and `FILE_ID.DIZ`; added description, configuration, compilation, operating instructions, warnings, and troubleshooting. |

Future documentation revisions should increment the final component, for example:

- `1.0.0.0.1` — first README update
- `1.0.0.0.2` — second README update
- `1.0.0.0.3` — third README update

## Original license notice

The source grants non-commercial redistribution permission provided that the original author is credited and changes by others are attributed. It separately grants SemWare commercial-distribution permission under those attribution conditions. Other rights are reserved by the original author. Consult the complete notice at the end of `EXPAND.S` before redistributing modified or commercial packages.
