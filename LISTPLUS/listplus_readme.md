# LISTPLUS

## Session name

`Create LISTPLUS MarkDown Readme`

## README version

`1.0.0.0.0`

## Date and time

2026-09-14 21:59 CEST (UTC+02:00)

## Description

LISTPLUS is an enhanced version of the standard LIST macro for The SemWare Editor (TSE). It searches the current file and displays a pick list containing the matching lines. After selecting a result, LISTPLUS returns to the original file and moves the cursor to the selected line.

In addition to a normal single-string search, LISTPLUS can search for two strings on the same line, search for two strings within a specified number of lines, and use the vertical bar (`|`) as a logical OR operator.

The macro was written by Jean Heroux and was originally supplied for TSE Pro v2.5 and TSE Pro/32 v2.8.

## Package contents

| File | Description |
| --- | --- |
| `LISTPLUS.S` | TSE SAL source code for the LISTPLUS macro. |
| `LISTPLUS.TXT` | Original short description. |
| `file_id.diz` | Original package identification and compatibility information. |

## Main features

- Searches the currently active file.
- Displays every matching line in a selectable pick list.
- Shows the original line number before each result.
- Jumps directly to the selected line.
- Remembers earlier search entries through TSE history lists.
- Searches for one string.
- Searches for two strings on the same line.
- Searches for two strings within a specified line distance.
- Supports a logical OR expression with `|`.
- Supports a literal vertical bar with `||`.
- Supports `cursor` and `repeat` command-line modes.
- Opens an editable result buffer when the first pick-list entry is selected.

## Requirements

- The SemWare Editor Professional.
- The SAL compiler appropriate for the installed TSE version.
- The supplied `LISTPLUS.S` source file.

The original package identifies compatibility with TSE Pro v2.5 and TSE Pro/32 v2.8. Compatibility with newer TSE releases should be verified by compiling and testing the source with the intended SAL compiler.

## Installation and compilation

1. Extract `listplus.zip` to a working directory.
2. Open a command prompt in that directory.
3. Compile the SAL source with the TSE SAL compiler:

   ```text
   sc32 LISTPLUS.S
   ```

4. A successful compilation creates `LISTPLUS.MAC`.
5. Copy `LISTPLUS.MAC` to a directory from which TSE can load macros, or leave it in the working directory and supply its full path when loading it.

For a 16-bit TSE installation, use the compiler supplied with that installation instead of `sc32`.

## How to run LISTPLUS

### Run from inside TSE

1. Open the text file that you want to search.
2. Execute the macro by entering:

   ```text
   Macro LISTPLUS
   ```

3. Enter the requested search string.
4. Select a matching line from the displayed list.
5. Press `Enter` to return to the source file at that line.
6. Press `Escape` to close the result list without jumping to another line.

Depending on the TSE configuration, the macro may also be run by its `.MAC` filename or assigned to a key.

### Run when starting TSE

The macro can also be passed to TSE on its command line. The exact editor executable and macro-loading syntax depend on the installed TSE version and configuration.

## Search modes

### 1. Search for one string

Enter a normal search string at the first prompt:

```text
error
```

LISTPLUS displays all lines containing `error`.

### 2. Search for either of two strings

Place one vertical bar between the alternatives:

```text
error|warning
```

LISTPLUS displays lines containing either `error` or `warning`.

Only one OR separator is processed in each search string. Both alternatives must contain text.

### 3. Search for a literal vertical bar

Use two vertical bars when the vertical bar itself must be found:

```text
||
```

For example, `left||right` searches for the literal text `left|right`.

### 4. Search for two strings on the same line

Append a semicolon to the first search string:

```text
error;
```

LISTPLUS then asks for a second string. Enter it without a trailing semicolon:

```text
file
```

The result list contains lines on which both `error` and `file` occur. Only the line containing the first string is displayed in the pick list.

### 5. Search for two strings within a line distance

Append a semicolon to both search strings.

First prompt:

```text
error;
```

Second prompt:

```text
file;
```

LISTPLUS then asks:

```text
Distance in lines?
```

Enter the permitted distance, for example:

```text
5
```

LISTPLUS finds occurrences of the first string when the second string occurs within the selected surrounding line range. The pick list displays the lines containing the first string.

### 6. Use OR in a two-string search

Either search string may contain `|`. For example:

```text
error|warning;
```

followed by:

```text
open|close
```

This searches for a line matching either first-string alternative and requires either second-string alternative according to the selected same-line or distance mode.

## Command-line modes

LISTPLUS examines the text supplied through `MacroCmdLine`.

### `cursor`

Run the macro with:

```text
LISTPLUS cursor
```

The first prompt is preloaded with:

- The marked text when the cursor is inside a column or inclusive block; or
- The word at the cursor when no suitable block is active.

The macro still displays its normal search prompt, allowing the proposed text to be accepted or edited.

### `repeat`

Run the macro with:

```text
LISTPLUS repeat
```

LISTPLUS repeats the preceding search specification without asking for the strings again. If no earlier search exists in the current macro session, LISTPLUS displays the normal prompt.

## Working with the result list

The list title shows the active search definition. Each result begins with its line number in the original file.

- Move through the list with the normal TSE list-navigation keys.
- Press `Enter` on a matching line to jump to that line in the original file.
- Press `Escape` to cancel the list.
- Select the first entry, `>> Select this line to edit FindList <<`, to leave the generated `findlist` buffer open for editing.

When a matching result is chosen, LISTPLUS attempts to position that line near the vertical center of the editing window.

## Search behavior and limitations

- Searches are case-insensitive.
- LISTPLUS searches only the current buffer.
- The result list contains the complete matching source lines with their line numbers.
- An empty current file causes the macro to return without displaying results.
- A search with no matches displays a `Not found` message.
- The semicolon at the end of a search string controls whether LISTPLUS asks for another value; it is not included in the actual search text.
- `|` is interpreted as logical OR unless doubled as `||`.
- The source defines the distance input as a short string and converts it with `Val()`; enter a valid whole-number line distance.
- The macro uses a buffer named `findlist`. It cannot run a new search while the current buffer itself is that buffer.

## Examples

| Goal | First entry | Second entry | Distance |
| --- | --- | --- | --- |
| Find `TODO` | `TODO` | Not requested | Not requested |
| Find `TODO` or `FIXME` | `TODO|FIXME` | Not requested | Not requested |
| Find a literal `|` | `||` | Not requested | Not requested |
| Find `name` and `address` on the same line | `name;` | `address` | Not requested |
| Find `start` near `finish` | `start;` | `finish;` | For example, `10` |

## Optional key assignment

LISTPLUS does not define a key assignment in the supplied source. A key can be assigned through TSE configuration or by calling the macro from another SAL macro.

When assigning a key, load or execute `LISTPLUS.MAC` using the method required by the local TSE setup.

## Troubleshooting

### `LISTPLUS.MAC` is not created

- Confirm that the SAL compiler is available.
- Compile from the directory containing `LISTPLUS.S`, or supply the full source path.
- Read the compiler's line and column information and correct any incompatibility with the installed TSE version.

### TSE cannot find the macro

- Confirm that `LISTPLUS.MAC` exists.
- Put it in a macro directory known to TSE, or use its full path.
- Check that the correct 16-bit or 32-bit SAL compiler was used for the target editor.

### No matching lines are displayed

- Confirm that the intended file is the active TSE buffer.
- Check the spelling of every search string.
- For a two-string search, verify whether the second string should be on the same line or within a distance.
- Use `||` when searching for a literal vertical bar.

### The wrong search mode starts

- Do not append `;` for a one-string search.
- Append `;` only to the first string for a same-line two-string search.
- Append `;` to both strings to request a line distance.

## Author

Jean Heroux  
Original contact address: `heroux.jean@videotron.ca`

## Version history

### 1.0.0.0.0 — 2026-09-14 21:59 CEST (UTC+02:00)

- Created `listplus_readme.md`.
- Documented the package contents and original compatibility information.
- Added compilation, installation, and execution instructions.
- Documented single-string, two-string, distance, OR, literal-bar, `cursor`, and `repeat` modes.
- Added examples, result-list behavior, limitations, and troubleshooting guidance.

Future README updates should increment the final version component sequentially:

```text
1.0.0.0.0
1.0.0.0.1
1.0.0.0.2
1.0.0.0.3
...
```
