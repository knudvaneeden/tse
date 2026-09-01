# ccRepl — Case-Copying Replace Macro for TSE

**README version:** 1.0.0.0.0  
**Created:** 1 September 2026, 20:20:50 (UTC+02:00)  
**Original macro date:** 30 June 1999  
**Original author:** Carlo Hogeveen  
**Language:** TSE SAL  
**Original compatibility:** TSE Pro 2.5 and TSE Pro/32 2.8

## Description

`CCREPL.S` is a TSE SAL macro that performs a case-copying search-and-replace operation. It works similarly to TSE's normal Replace command, but copies the letter case of the found text to the replacement text.

For example, when searching for `road` and replacing it with `path`, the macro produces results such as:

| Found text | Replacement |
| --- | --- |
| `road` | `path` |
| `Road` | `Path` |
| `ROAD` | `PATH` |
| `rOaD` | `pAtH` |

The macro can also replace strings whose lengths differ. If the replacement is longer than the found text, the case of the last character in the found text determines the case of the remaining replacement characters.

## Files in the Original Archive

- `CCREPL.S` — TSE SAL source code for the macro.
- `FILE_ID.DIZ` — short description of the original package.

## Installation

1. Extract `ccrepl.zip`.
2. Copy `CCREPL.S` to your TSE macro directory, normally the directory named `MAC` beneath the TSE installation directory.
3. Start TSE.
4. Open `CCREPL.S` in TSE.
5. Compile the source with TSE's **Macro Compile** command.
6. Confirm that compilation completes without errors. TSE should create the compiled macro required by your TSE version.

You may optionally add `ccrepl` to a TSE PotPourri menu or assign it to a key.

## How to Run

1. Open the file in which replacements must be made.
2. Execute the compiled macro named `ccrepl` using TSE's **Execute Macro** command.
3. At **Search for:**, enter the text to find.
4. At **Replace with:**, enter the replacement text.
5. At **Search & replace options [abcgilnw^$#]:**, enter the required standard TSE replace options.
6. If the `n` option was not selected, answer each confirmation prompt:

   - `Y` — replace this occurrence.
   - `N` — skip this occurrence.
   - `O` — replace only this occurrence and stop.
   - `R` — replace this and all remaining occurrences without prompting.
   - `Q` or `Escape` — quit the replacement operation.

7. When finished, TSE displays the number of changes made.

## Example

Suppose the current file contains:

```text
road Road ROAD rOaD
```

Run `ccrepl` and enter:

```text
Search for: road
Replace with: path
Options: ginw
```

The resulting text is:

```text
path Path PATH pAtH
```

## Search and Replace Options

The macro accepts the ordinary TSE search-and-replace options displayed by its prompt:

```text
abcgilnw^$#
```

It also recognizes a numeric replacement limit when supplied as part of the option text. Consult the help for your installed TSE version for the precise meaning of its standard search options.

### Important Restrictions

- Regular-expression options `V` and `X` are deliberately rejected.
- The search string must not be empty.
- The macro operates on the current TSE buffer.
- This is legacy SAL source from 1999; compatibility with newer TSE releases depends on their support for the SAL functions used by the macro.

## How Case Copying Works

For every replacement character, the macro checks the character in the corresponding position of the found text:

- An uppercase source letter makes the replacement letter uppercase.
- A lowercase source letter makes the replacement letter lowercase.
- A non-letter does not force a case change.
- When the replacement is longer, the final source character supplies the case pattern for all additional replacement characters.

## Troubleshooting

### The macro cannot be executed

- Make sure `CCREPL.S` was compiled successfully.
- Make sure the compiled macro is in a directory searched by TSE.
- Execute it using the macro name `ccrepl`.

### Options V and X are not allowed

This is expected. `ccrepl` does not support regular-expression replacements. Use a normal text search instead.

### No replacements are made

- Check the search text and selected options.
- Check whether case-sensitive or whole-word options are preventing a match.
- Confirm that the correct file and buffer are active.

### Replacement case is unexpected

The case is copied character by character from the matched text. For a longer replacement, the final character of the matched text determines the case of the additional replacement characters.

## Version History

| Version | Date and time | Changes |
| --- | --- | --- |
| 1.0.0.0.0 | 1 September 2026, 20:20:50 (UTC+02:00) | Initial Markdown documentation created from `CCREPL.S` and `FILE_ID.DIZ`. |

Future documentation revisions can continue as `1.0.0.0.1`, `1.0.0.0.2`, `1.0.0.0.3`, and so on.

## Credits

The original `ccRepl` macro was written by Carlo Hogeveen in 1999. This README documents the behavior found in the supplied archive.
