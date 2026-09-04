# Cword — Crossword Word Finder for TSE Pro/32

**README version:** 1.0.0.0.0  
**Created:** 2026-09-04 21:59:05 CEST (2026-09-04 19:59:05 UTC)  
**Original program:** Cword v1.0  
**Original program date:** 2001-05-29  
**Author:** Warren Porter  
**Original target:** The SemWare Editor Professional (TSE Pro/32) v2.8

## Description

`cword.s` is a TSE SAL macro for finding dictionary words when some letters are known and other letters are unknown. Unknown letters are represented by asterisks (`*`).

For example, entering:

```text
c**
```

causes Cword to try every three-letter combination beginning with `c`. Each generated combination is checked with TSE's spelling system, and valid words are placed in a temporary results buffer.

The source code credits spell-checking techniques from SemWare's `SpellChk` macro and Peter Birch's `anagram.s` macro. Its progress window is also based on work by Peter Birch.

## Archive contents

| File | Description |
| --- | --- |
| `cword.s` | TSE SAL source code for the Cword macro. |
| `file_id.diz` | Original short package description. |

## Requirements

- A compatible 32-bit version of TSE Professional.
- The TSE SAL compiler (`sc32.exe`) if the source must be compiled.
- TSE's `spell.dll` spelling library.
- The SemWare dictionary file `semware.lex`.
- A configured TSE search path that allows the macro to find the dictionary, normally in the `SPELL` subdirectory.

The source searches for `semware.lex` with TSE's configured `TSEPATH` and the `SPELL\` subdirectory when the macro is loaded.

## Installation

1. Extract `cword.zip` to a working directory.
2. Copy `cword.s` to your preferred TSE macro source directory.
3. Open a command prompt in that directory.
4. Compile the macro:

   ```bat
   sc32 cword.s
   ```

5. Confirm that compilation creates the corresponding compiled TSE macro file.
6. Make sure `spell.dll` is available to TSE.
7. Make sure `semware.lex` exists in a directory searched by TSE, normally the `SPELL` directory below an entry in `TSEPATH`.

## How to run Cword

1. Start TSE Professional.
2. Load or execute the compiled `cword` macro using your usual TSE macro command or macro menu.
3. At the prompt, enter the known letters and use `*` for every unknown letter.
4. Press **Enter** to begin the search.
5. Review the valid words displayed in the temporary results buffer.
6. Enter another pattern when prompted, or press **Esc** to quit.

Example patterns:

```text
c**
*at
b**k
*o*d
```

Input is converted to lowercase automatically. Do not include spaces.

## Stopping a search

While the progress window is displayed, press any key to stop the current search. Words already found remain available in the results buffer.

## Performance warning

The number of generated combinations is `26` raised to the number of asterisks:

| Wildcards | Combinations checked |
| ---: | ---: |
| 1 | 26 |
| 2 | 676 |
| 3 | 17,576 |
| 4 | 456,976 |
| 5 | 11,881,376 |

Search time therefore increases very quickly. Use as few wildcards as possible. The original program supports no more than five asterisks and a maximum pattern length of 20 characters.

## Messages and troubleshooting

### `No asterisks, I don't have anything to do`

The entered pattern contains no `*` wildcard. Enter at least one unknown position.

### `I can't handle more than five asterisks`

Reduce the pattern to five or fewer wildcard positions.

### `Can't load word list: semware.lex`

Check that `semware.lex` is installed and that its directory is included in TSE's search path. The macro expects to find it through `TSEPATH`, normally under `SPELL\`.

### `Can't create work buffer`

TSE could not create the temporary buffer used for results. Close unnecessary files or buffers, check available memory, and try again.

### `No words found for ...`

The dictionary contains no valid word matching the supplied pattern, or the search was stopped before a match was found.

### Compilation or DLL errors

This is an older macro written for TSE Pro/32 v2.8. A newer TSE release may report compatibility issues. Verify that you are using the 32-bit SAL compiler and that the spelling DLL exports the functions referenced by `cword.s`.

## How the macro works

1. The macro reads the entered word pattern.
2. It records the positions of all `*` characters.
3. It generates every lowercase `a` through `z` substitution for those positions.
4. It sends each candidate to `SpellCheckWord()` in `spell.dll`.
5. It adds recognized words to a temporary buffer.
6. It displays the resulting list and prompts for another pattern.

## Version numbering

Documentation revisions use this five-part sequence:

```text
1.0.0.0.0
1.0.0.0.1
1.0.0.0.2
1.0.0.0.3
...
```

Increase the final component for each subsequent documentation update. Larger components may be increased when a broader revision warrants it.

## Version history

| Version | Date and time | Changes |
| --- | --- | --- |
| 1.0.0.0.0 | 2026-09-04 21:59:05 CEST | Initial Markdown README created from `cword.zip`, `cword.s`, and `file_id.diz`. |

## Original program history

| Version | Date | Changes |
| --- | --- | --- |
| 1.0 | 2001-05-29 | Initial version by Warren Porter. |

## License

No explicit license was included in the supplied archive. The original author retains applicable rights. Review the source header and obtain permission where necessary before redistribution or modification.
