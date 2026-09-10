# HIREXP

## Session

**Create HIREXP MarkDown Readme**

## README version

**1.0.0.0.0**

Future revisions should increment the final component, for example:
`1.0.0.0.1`, `1.0.0.0.2`, `1.0.0.0.3`, and so on.

## Date and time

**2026-09-10 21:57:28 UTC**  
**2026-09-10 23:57:28 CEST (Netherlands local time)**

## Description

HIREXP is a syntax-highlighting macro written by Carlo Hogeveen for the
32-bit edition of The SemWare Editor Professional (TSE Pro). The original
package is dated 29 May 1998 and targets TSE Pro/32 version 2.8.

The macro adds regular-expression-based colors to text displayed in the
current editing window. Rules can depend on:

- The current file extension.
- One or more TSE regular expressions.
- Existing screen colors that must not be recolored, such as comment colors.
- Several expressions evaluated in sequence on the same line.

HIREXP reads its highlighting rules from `HIREXP.DAT`. The supplied data file
contains examples for C/C++, COBOL, and Fortran files.

TSE's built-in syntax highlighting should be preferred whenever it can perform
the required highlighting because it is considerably faster. HIREXP is useful
for rules that the built-in 32-bit syntax highlighter cannot express.

## Package contents

| File | Purpose |
| --- | --- |
| `HIREXP.S` | TSE SAL source code for the macro. |
| `HIREXP.DAT` | Highlighting rules and detailed rule-format instructions. |
| `FILE_ID.DIZ` | Short description of the original package. |

## Requirements

- A 32-bit version of TSE Pro with its SAL compiler.
- Access to TSE's `MAC` directory.
- The supplied `HIREXP.DAT` file.

The macro is historical software. Test it with your installed TSE version and
keep backup copies of the original source and data files before changing them.

## Installation and compilation

1. Extract `hirexp.zip` into a temporary directory.
2. Copy `HIREXP.S` and `HIREXP.DAT` to TSE's `MAC` directory.
3. Open a command prompt in that directory, or use your normal TSE SAL build
   setup.
4. Compile the source:

   ```text
   sc32 hirexp.s
   ```

5. Confirm that the compiler creates `HIREXP.MAC` without errors.
6. Keep `HIREXP.DAT` in TSE's `MAC` directory. The original source explicitly
   loads `MAC\HIREXP.DAT` relative to the TSE installation directory.
7. Add `HIREXP` to TSE's Macro Autoload List so it is loaded when TSE starts.
   Alternatively, load `HIREXP.MAC` manually for testing.
8. Restart TSE, or load the newly compiled macro through TSE's macro-loading
   command.

## How to run HIREXP

HIREXP is designed to run as an autoloaded macro; it does not require a normal
interactive command each time highlighting is needed.

1. Start TSE with `HIREXP` present in the Macro Autoload List.
2. Open a file whose extension is listed in `HIREXP.DAT`, such as a `.c`,
   `.c++`, `.cbl`, `.cob`, or `.ftn` file from the supplied examples.
3. Pause briefly after typing or moving through the file. The macro performs
   its work from TSE's idle hook and recolors matching text in the visible
   window.
4. Scroll through the file to apply the rules to newly displayed screen lines.

Running the compiled `HIREXP` macro manually invokes one highlighting pass, but
autoloading it is the intended method because the idle hook then remains
active.

## Configuring `HIREXP.DAT`

Rules are grouped beneath an extension header:

```text
[.extension1 .extension2]
color_not-colors<heart>regular-expression<heart>options
```

The real format uses the heart character (character code 3) as its field
delimiter. Consult the comments at the beginning of the supplied `HIREXP.DAT`
and edit the file in a way that preserves this character.

### Extension header

An extension header lists one or more file extensions between brackets:

```text
[.c .c++]
```

Use `. ` (a period followed by a space) to define rules for files without an
extension.

### Rule fields

A rule line contains the following fields, separated by the heart delimiter:

1. **Highlight color** — mandatory hexadecimal TSE color value.
2. **Colors not to replace** — optional hexadecimal values. This is commonly
   used to preserve text already colored as a comment.
3. **Regular expression** — the first expression is mandatory.
4. **Search options** — optional; the effective default is an
   ignore-case regular-expression line search.
5. **Additional expression/options pairs** — optional. All expressions in the
   rule must succeed; the text found by the final expression is recolored.

Useful option behavior from the original documentation:

- `>` on the second or a later expression starts that search after the text
  found by the preceding expression.
- Omitting `g` allows HIREXP to try additional occurrences on the same line.
- Using `b` or `g` makes that rule non-repeatable for the current line.
- A trailing heart delimiter is optional, but delimiters for omitted fields
  remain necessary when later fields are present.

Lines before the first extension header, and lines that do not contain at
least two heart delimiters, are treated as comments.

## Performance setting

Near the beginning of `HIREXP.S` is:

```text
#define PRIORITY 1
```

`PRIORITY 1` gives the quickest highlighting but may reduce keyboard
responsiveness and use more processor time. Raising the value shifts the
balance toward keyboard responsiveness and lower processor use. Recompile
`HIREXP.S` after changing this definition.

## Help and troubleshooting

### No highlighting appears

- Verify that `HIREXP.MAC` compiled successfully and is loaded.
- Verify that `HIREXP.DAT` is in TSE's `MAC` directory.
- Check that the current file extension appears in an extension header.
- Preserve the heart delimiters in each rule line.
- Confirm that the hexadecimal color and regular expression are valid for TSE.
- Allow TSE to become idle briefly; active typing delays highlighting.

### Some text is not recolored

The color under the matching text may be listed in the rule's “colors not to
replace” field. HIREXP also deliberately avoids replacing the cursor,
highlighted-text, block, and cursor-in-block display attributes.

### TSE feels slow

- Prefer TSE's built-in syntax highlighting where possible.
- Increase the `PRIORITY` value and recompile the macro.
- Reduce the number or complexity of regular expressions.
- Avoid overly broad expressions that produce many matches per visible line.

### Rules changed but the display did not

The macro copies `HIREXP.DAT` into an internal temporary buffer when it is
loaded. After editing the data file, unload and reload the macro or restart TSE
so the changed rules are read again.

## Original author

Carlo Hogeveen  
Original source date: 28 May 1998  
Original macro version: 1

## Version history

| Version | Date and time | Changes |
| --- | --- | --- |
| 1.0.0.0.0 | 2026-09-10 21:57:28 UTC | Initial Markdown description, installation instructions, usage help, configuration summary, and troubleshooting guide based on the supplied HIREXP package. |

