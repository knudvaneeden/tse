# FINDWS for TSE Pro

## Document information

- README version: 1.0.0.0.0
- Date: 2026-09-09
- Time: 13:38:03 UTC
- Macro file: `FindWS.s`
- Original macro version: 6
- Original author: Carlo Hogeveen

## Description

FINDWS is a TSE Pro SAL macro that finds a sequence of words separated by whitespace.

Enter the required words with one ordinary space between them. FINDWS then matches the words even when the source text separates them with any combination of:

- Spaces
- Horizontal tabs
- End-of-line characters

For example, the search text `great britain` can match `great` and `britain` when they appear on the same line or on consecutive lines with whitespace between them.

The search:

- Starts at the current cursor position.
- Is case-insensitive.
- Treats each entered word as a TSE regular expression.
- Marks the complete matching text, from the first character of the first word through the last character of the final word.
- Moves the cursor to the beginning of the match.
- Displays a `not found` message and sounds the alarm when no match is found.

Words in the search expression cannot contain spaces because spaces separate the individual search words.

## Requirements

- The SemWare Editor Professional (TSE Pro)
- The TSE SAL compiler, normally `sc32.exe`
- The source file `FindWS.s`

## Installation

1. Extract `findws.zip` to a directory of your choice.
2. Open a command prompt in the directory containing `FindWS.s`.
3. Compile the macro:

   ```text
   sc32 FindWS.s
   ```

4. Confirm that the compiler creates the executable TSE macro file, normally `FindWS.mac`.
5. Place the compiled macro where TSE Pro can find and execute it, or specify its path when using TSE's **Macro Execute** command.

## How to run FINDWS interactively

1. Open the file that you want to search in TSE Pro.
2. Move the cursor to the position where the search should begin.
3. Select **Macro Execute** from the TSE menu.
4. Run `FindWS` without parameters.
5. At the prompt, enter the words separated by single spaces, for example:

   ```text
   great britain
   ```

6. Press **Enter**.
7. If a match is found, FINDWS marks the complete matched sequence and places the cursor at its beginning.

## Running FINDWS with a command-line parameter

The search expression can be supplied directly when the macro is executed:

```text
FindWS great britain
```

This avoids the interactive prompt and searches for `great` followed by whitespace and then `britain`.

## Repeating the previous search

Run FINDWS with the special `_again_` parameter to repeat the previous FINDWS search:

```text
FindWS _again_
```

The previous search is retained while the macro remains loaded in the current TSE session.

## Calling FINDWS from another SAL macro

FINDWS can also be called from another TSE SAL macro:

```sal
BegFile()
ExecMacro("findws")
ExecMacro("findws great britain")
ExecMacro("findws _again_")
```

- `ExecMacro("findws")` opens the interactive search prompt.
- `ExecMacro("findws great britain")` performs the supplied search immediately.
- `ExecMacro("findws _again_")` repeats the previous FINDWS search.

FINDWS may also be assigned to a key by calling `ExecMacro()` from a TSE key definition.

## Search behavior and examples

If you enter:

```text
one two three
```

FINDWS can match text laid out like this:

```text
one two three
```

or like this:

```text
one
two	three
```

The words must occur in the specified order, with only whitespace between consecutive words.

Because each word is searched as a TSE regular expression, regular-expression characters have their TSE meanings. Escape them according to the TSE regular-expression rules when they must be matched literally.

## Troubleshooting

### The macro reports `not found`

- Confirm that the cursor is before the desired occurrence; searching begins at the current cursor position.
- Confirm that the words occur in the requested order.
- Confirm that only whitespace occurs between consecutive words.
- Remember that spaces in the entered expression separate search words.
- Check whether regular-expression characters in a word require escaping.

### `_again_` finds nothing

Run a normal FINDWS search first. `_again_` requires a previous non-empty FINDWS search in the current TSE session.

### The macro cannot be executed

- Confirm that `FindWS.s` compiled successfully.
- Confirm that the generated `FindWS.mac` is in a location accessible to TSE Pro.
- Confirm that the macro name or path supplied to **Macro Execute** is correct.

## Original macro history

- Version 2, May 1998: Added `_again_` searching.
- Version 3, May 1998: Bug-fix release.
- Versions 4 and 5, May 1998: Variants that treated all non-letter characters as whitespace.
- Version 6, May 2011: Based on version 3 and adds marking of the found text.

## README version history

- 1.0.0.0.0 - 2026-09-09 13:38:03 UTC - Initial Markdown documentation with description, help, installation, execution steps, examples, troubleshooting, and original macro history.

Future README updates should increment the final component sequentially: `1.0.0.0.1`, `1.0.0.0.2`, `1.0.0.0.3`, and so on.

## License

No license information is included in the supplied `findws.zip` archive. Consult the original author or distribution source before redistributing or modifying the macro.
