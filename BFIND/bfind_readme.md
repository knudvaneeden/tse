# bFind for The SemWare Editor (TSE)

**README version:** 1.0.0.0.0  
**bFind macro version:** 1.02  
**Author:** Carlo Hogeveen  
**Compatibility:** TSE Pro 2.5e and later

## Description

`bFind` is a Boolean/logical Find macro for The SemWare Editor (TSE). It searches the current file for lines that match a logical combination of quoted search strings.

Search strings can be combined with:

- `AND` — both conditions must match.
- `OR` — either condition may match.
- `NOT` — the condition must not match.
- Parentheses `(` and `)` — group and nest conditions.

All search strings in one expression use the same TSE search options.

## Included files

- `bFind.s` — TSE SAL source code for the macro.
- `File_id.diz` — brief package description.

## Installation

1. Extract `bfind.zip` to a temporary directory.
2. Copy `bFind.s` to TSE's macro source directory, normally the `mac` directory below the TSE installation directory.
3. Compile `bFind.s` with the SAL compiler appropriate for your TSE installation.

From a command prompt, this will usually be similar to:

```bat
sc32 bFind.s
```

Alternatively, open `bFind.s` in TSE and use TSE's macro compile command or menu option.

4. Confirm that compilation creates the compiled macro in the location from which TSE loads macros.

## How to run bFind

1. Open the text file that you want to search in TSE.
2. Run `bFind` from TSE's **Macro Execute** menu, the **Potpourri** menu, or a key assigned to:

```text
ExecMacro("bFind")
```

3. At the **Search for:** prompt, enter a logical search expression.
4. At the **Search options:** prompt, enter the required standard TSE Find options.
5. Select a matching line from the results list and press **Enter** to go to that line.

In the results list:

- **Enter** goes to the selected line in the original file.
- **Escape** cancels and closes the results list.
- **Alt+E** opens the results as an editable `*ViewFinds buffer*`.

## Search examples

Find lines that contain both `cat` and `dog`, in any order:

```text
"cat" and "dog"
```

Find lines that contain `cat`, `dog`, or both:

```text
"cat" or "dog"
```

Find lines that contain neither `cat` nor `dog`:

```text
not ("cat" or "dog")
```

Find lines that do not contain both words:

```text
not ("cat" and "dog")
```

Find lines containing `cat` together with either `dog` or `canary`:

```text
"cat" and ("dog" or "canary")
```

A more deeply nested example:

```text
(("dog" and "cat") or ("cat" and ("mouse" or "canary"))) and not "eats"
```

Find lines that do not contain a space:

```text
not " "
```

The quoting character can be any non-whitespace character. For clarity, double quotation marks are recommended in most searches.

## Expression rules

- Search strings must be quoted.
- Operators are `and`, `or`, and `not`.
- Parentheses may be nested without a fixed depth limit.
- An empty expression is not allowed.
- Without parentheses, `and` and `or` have equal precedence and are evaluated from left to right.
- Use parentheses whenever an expression mixes `and` and `or`; this makes the intended logic unambiguous.
- Each quoted value is interpreted using TSE's normal Find syntax.
- The same search options apply to every search string in the expression.

## Search-option limitations

- Options `a` and `c` cannot be entered for a logical search. The macro displays a warning if either is supplied.
- Options `g` and `v` are handled implicitly by the macro.

## Troubleshooting

### The macro does not appear in TSE

Make sure `bFind.s` was compiled successfully and that the compiled macro is in a directory from which TSE loads macros. You can still start it directly through TSE's **Macro Execute** command.

### “Logical expression syntax error” appears

Check that:

- Every search string has both opening and closing quotation characters.
- Every opening parenthesis has a matching closing parenthesis.
- Operators occur between valid expressions.
- The expression is not empty.

### No matching lines are shown

Check the search expression and the TSE search options. Start with one simple quoted search string, verify that it works, and then add the logical operators and additional strings.

### Options `a` or `c` produce a warning

This is a known limitation of bFind 1.02. Remove those options and run the search again.

## Version history

### README version 1.0.0.0.0

- Initial Markdown description, help, installation instructions, usage steps, examples, limitations, and troubleshooting information.

Future README revisions should use the sequence `1.0.0.0.1`, `1.0.0.0.2`, `1.0.0.0.3`, and so on.

The README version identifies revisions of this documentation. It does not replace the original bFind macro version number, which is 1.02.
