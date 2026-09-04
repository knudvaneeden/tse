# COUNT — TSE Occurrence Counter

**README version:** 1.0.0.0.1  
**Date:** 2026-09-04  
**Time:** 02:44:45 CEST  
**Original macro date:** 1995-06-04 13:34  

## Description

`COUNT` is a macro for The SemWare Editor (TSE) that counts occurrences of a word or search string in the current file.

When started, the macro obtains the word at or immediately before the cursor and uses it as the default search text. You can accept that word or replace it with another string. The macro then asks for TSE find options, searches from the beginning of the current file, and displays the number of occurrences found.

The supplied archive contains:

- `COUNT.S` — editable SAL source code.
- `COUNT.MAC` — precompiled TSE macro.

## Default key

Press:

```text
Alt+V
```

The source defines this key assignment as:

```text
<Alt V> mCount()
```

You can change the key assignment near the end of `COUNT.S` and recompile the source if `Alt+V` is already assigned to another command.

## Installation

1. Extract `count.zip`.
2. Copy `COUNT.MAC` to a directory from which you normally load TSE macros.
3. Start TSE.
4. Load `COUNT.MAC` by using TSE's macro-loading command or your normal macro autoload configuration.
5. Open the file in which you want to count occurrences.

The supplied `COUNT.MAC` can be used directly. You only need to compile `COUNT.S` when you modify the source.

## How to run

1. Open a file in TSE.
2. Put the cursor on the word you want to count. You may also enter a different search string later.
3. Press `Alt+V`.
4. At **String to count occurrences of:**, accept the proposed word or type another search string.
5. At **Options [GLIWX] (Global Local Ignore-case Words reg-eXp):**, enter the required TSE find options or accept the displayed options.
6. The macro searches the current file and displays a message similar to:

```text
Found 12 occurrence(s)
```

Canceling either prompt stops the operation without performing the count.

## Find options

The prompt lists these TSE search-option letters:

| Option | Meaning |
| --- | --- |
| `G` | Global search |
| `L` | Local search |
| `I` | Ignore letter case |
| `W` | Match whole words |
| `X` | Interpret the search text as a regular expression |

Use only the options needed for the search. The precise behavior of option combinations follows the search rules of your installed TSE version.

## Examples

### Count a word regardless of case

1. Put the cursor on `example`.
2. Press `Alt+V`.
3. Accept `example` as the search string.
4. Enter `IW` to ignore case and match whole words.

This counts `example`, `Example`, and `EXAMPLE` as whole words.

### Count a literal text fragment

1. Press `Alt+V`.
2. Replace the proposed word with the required text fragment.
3. Leave out `W` when matches may occur inside longer text.
4. Accept the prompt to display the total.

## Search range

The original source contains this statement before the search:

```text
BegFile()
```

Therefore, the standard macro counts from the beginning of the current file. To count only from the current cursor position to the end of the file, comment out or remove `BegFile()` in `COUNT.S`, then compile and load the modified macro.

## Compiling the source

If you change `COUNT.S`, compile it with the SAL compiler appropriate for your TSE installation. For example, with the TSE Pro/32 command-line compiler available on `PATH`:

```bat
sc32 COUNT.S
```

After compilation:

1. Confirm that a new `COUNT.MAC` was created successfully.
2. Replace the previously loaded macro with the newly compiled file.
3. Reload the macro in TSE. Restart TSE first if your installation keeps the old compiled macro in memory.

## Notes and limitations

- The standard version counts matches in the current file only.
- The macro preserves the cursor position and the existing block state.
- The word at the cursor is only a suggested search value; it can be edited at the prompt.
- Search behavior depends on the selected TSE find options.
- The original source uses older SAL syntax and was supplied together with a compiled macro from 1995. Compatibility with newer TSE releases may require small source changes before recompilation.

## Troubleshooting

### `Alt+V` does not start the macro

- Verify that `COUNT.MAC` is loaded.
- Check whether another macro or command has reassigned `Alt+V`.
- Change the key definition in `COUNT.S`, compile it, and reload the resulting macro.

### The count is different from what you expected

- Use `W` when only complete words should match.
- Use `I` when uppercase and lowercase forms should be treated as equal.
- Remove `X` unless the entered text is intended to be a regular expression.
- Confirm that the search starts at the beginning of the file in the standard version.

### Changes to `COUNT.S` are not visible

- Compile the source again.
- Make sure TSE loads the newly generated `COUNT.MAC` rather than an older copy elsewhere.
- Reload the macro or restart TSE if the previous macro remains in memory.

## Version history

| Version | Date | Time | Description |
| --- | --- | --- | --- |
| 1.0.0.0.0 | 1995-06-04 | 13:34 | Original `COUNT.S` and `COUNT.MAC` files in the supplied archive. |
| 1.0.0.0.1 | 2026-09-04 | 02:44:45 CEST | Added Markdown description, installation instructions, usage help, examples, compilation guidance, and troubleshooting information. |

