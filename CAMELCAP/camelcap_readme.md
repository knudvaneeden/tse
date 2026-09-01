# CamelCaps for TSE

**README version:** 1.0.0.0.0  
**Original author:** Reed Truitt  
**Original release date:** February 21, 2004  
**Required editor:** The SemWare Editor (TSE) Pro 2.5e or later

## Description

CamelCaps provides replacement word-navigation procedures for TSE:

- `m_WordLeft()` moves the cursor to the previous word or CamelCaps boundary.
- `m_WordRight()` moves the cursor to the next word or CamelCaps boundary.

Unlike TSE's normal word-left and word-right commands, these procedures recognize changes inside an identifier. This makes it easier to move through source-code names written in camelCase, PascalCase, or combinations of letters and digits.

For example, cursor movement can stop at the internal parts of names such as:

```text
camelCaseName
ParseHTTP2Response
item25Value
```

The module treats `0-9`, `A-Z`, and `a-z` as word characters while it operates. It restores the previous TSE `WordSet` afterward.

CamelCaps also avoids treating the end of a line as a word. When no word exists in the requested direction, it displays a message and sounds the alarm.

## Files

| File | Purpose |
| --- | --- |
| `CamelCaps.inc` | TSE SAL include file containing `m_WordLeft()` and `m_WordRight()` |
| `File_Id.diz` | Short description of the original package |

## Important: this is an include file

`CamelCaps.inc` is not intended to be compiled or run by itself. It must be included in a TSE user-interface (`.ui`) source file, assigned to keys, and then incorporated into TSE by rebuilding/burning in that user interface.

## Installation

1. Extract `camelcap.zip` to a working directory.
2. Copy `CamelCaps.inc` to the directory containing your TSE user-interface source files, or use an appropriate path in the include statement.
3. Open the `.ui` source file that you use to build your customized TSE interface.
4. Add the following include directive in the source area where include files are loaded:

   ```sal
   #include "CamelCaps.inc"
   ```

5. Change the key assignments for word-left and word-right so that they call:

   ```sal
   m_WordLeft()
   m_WordRight()
   ```

   The original package recommends assigning these to **Ctrl+Left Arrow** and **Ctrl+Right Arrow**, respectively.

6. Recompile and burn in the modified `.ui` file using the normal procedure for your TSE installation.
7. Restart TSE if your interface changes are not loaded automatically.

The exact key-definition syntax and burn-in command can vary with the TSE version and the customized `.ui` file being used. Preserve a backup of the working `.ui` source before modifying it.

## How to use

After installation:

1. Open a text or source-code file in TSE.
2. Place the cursor in or near an identifier such as `customerAccount2Name`.
3. Press **Ctrl+Right Arrow** to move forward through its internal boundaries.
4. Press **Ctrl+Left Arrow** to move backward through those boundaries.

The procedures recognize boundaries including:

- a lowercase or non-uppercase character followed by an uppercase character;
- a non-alphabetic character followed by a lowercase character;
- a non-digit character followed by a digit;
- the beginning of another normal word after punctuation or whitespace.

## Example

With this identifier:

```text
customerAccount2Name
```

word navigation can stop at logical components such as:

```text
customer | Account | 2 | Name
```

The exact starting position and direction determine the first boundary reached.

## Troubleshooting

### The include file does not compile by itself

This is expected. `CamelCaps.inc` supplies procedures for inclusion in a `.ui` source file; it is not a complete standalone TSE macro.

### The keys still perform normal word movement

Confirm that:

- `CamelCaps.inc` is included in the `.ui` source;
- the chosen keys call `m_WordLeft()` and `m_WordRight()`;
- the modified interface compiled successfully;
- the new interface was burned in or otherwise loaded by TSE;
- TSE was restarted if required.

### A procedure-name conflict occurs

Search the `.ui` source and its other includes for existing procedures named `m_WordLeft`, `m_WordRight`, `isAlpha`, `isUpper`, `isLower`, or `isDigit`. Rename or remove the conflicting definition as appropriate.

### Navigation does not recognize underscores as part of a word

The module temporarily uses the word set `0-9A-Za-z`. Therefore, an underscore is treated as a separator rather than as an internal word character. This is the behavior of the original source.

### A message says there is no word to the left or right

The cursor has reached a point where no further word exists in that direction. This is normal behavior.

## Compatibility notes

- The original package states compatibility with TSE Pro 2.5e and later.
- Under non-WIN32 builds, the include supplies its own `isAlpha`, `isUpper`, `isLower`, and `isDigit` helper procedures.
- Under WIN32, it expects the corresponding character-test functionality to be supplied by TSE or the surrounding interface environment.
- The source predates current TSE releases, so compilation or key-definition details may require adjustment for a heavily customized interface.

## Version numbering

This README uses a five-part version number:

```text
1.0.0.0.0
```

For later README revisions, increment the final component:

```text
1.0.0.0.1
1.0.0.0.2
1.0.0.0.3
```

## Version history

| Version | Changes |
| --- | --- |
| 1.0.0.0.0 | Initial README with description, installation, operation, examples, troubleshooting, compatibility notes, and versioning guidance. |

## License

No explicit license is included in the supplied archive. The original author retains the applicable rights. Review the original files and obtain permission before redistributing or materially modifying the source when required.
