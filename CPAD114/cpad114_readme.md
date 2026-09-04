# CodePad (cpad114)

**README version:** 1.0.0.0.0  
**Date and time:** 2026-09-04 14:55:29 CEST  
**Original macro version:** 1.1.4 (2002-06-19)  
**Author:** Michael Graham

## Description

CodePad is a formatting macro for The SemWare Editor (TSE). It aligns matching punctuation, operators, keywords, or other strings into columns by inserting spaces on related lines.

For example, CodePad can change:

```text
integer Grapes = 5439
integer Pinapples = 15
integer Raspberries = 2
integer Pips = 3
```

into:

```text
integer Grapes      = 5439
integer Pinapples   = 15
integer Raspberries = 2
integer Pips        = 3
```

The archive contains:

- `CodePad.s` — the TSE SAL source code.
- `findprof.si` — include file used to locate the TSE profile file.
- `setcache.si` — include file used to detect refreshed settings.
- `CodePad.txt` — the original documentation.
- `FILE_ID.DIZ` — a short package description.

The original package identifies support for TSE Pro 2.x, 3.x, and 4.x. Compatibility with newer TSE releases should be tested locally.

## Main functions

### `Pad(string)`

Aligns text around one or more specified strings.

Examples:

```sal
Pad('=')
Pad(',')
Pad(', ;')
Pad('= //')
```

Multiple search strings are separated by spaces and processed in separate passes. Calling `Pad('')` opens a prompt in which the strings can be entered interactively.

When a block is marked, `Pad()` processes the lines in that block. The macro removes the block marking after processing it.

### `AutoPad()`

Automatically examines the current group of related, nonblank lines with the same indentation and attempts to align them using the configured automatic padding set. If a block is already marked, it processes that block.

Automatic detection is convenient, but its result depends on the text and may occasionally be unexpected. Save the file first or be ready to undo the change.

## Installation

1. Extract `cpad114.zip`.
2. Copy `CodePad.s`, `findprof.si`, and `setcache.si` to the same TSE macro source directory.
3. If those `.si` files already exist there, compare their versions before replacing them.
4. Open a command prompt in that directory.
5. Compile the macro:

```bat
sc32 CodePad.s
```

6. Confirm that compilation completes without errors.
7. Load or run the compiled `CodePad` macro in TSE.

For TSE 2.5 for DOS, the separate Profile package is also required, as stated in the original documentation.

## How to run

### Interactive padding

1. Open the file to format in TSE.
2. Mark the lines that should be aligned, or place the cursor among adjacent related lines.
3. Run:

```text
CodePad
```

4. At the prompt, enter the string around which to align the lines, such as `=`, `=>`, `)`, or `= //`.
5. Press Enter. CodePad inserts spaces to place matching strings in the same column.

### Automatic padding

Place the cursor in a group of related lines, or mark a block, and run:

```text
CodePad -a
```

The `-a` option is the switch implemented by the supplied `CodePad.s` source. The old `CodePad.txt` installation example mentions `-f`, but that switch is not handled by this version's `Main()` procedure.

## Optional key bindings

You can enable or add direct bindings in `CodePad.s`, for example:

```sal
<Ctrl g><d> AutoPad()
<Ctrl g><s> Pad('')
```

If functions are called directly from key bindings, add CodePad to TSE's autoload list so the functions are available.

Alternatively, key definitions in a UI macro can run CodePad through `ExecMacro()`:

```sal
<Ctrl g><d> ExecMacro('CodePad -a')
<Ctrl g><s> ExecMacro('CodePad')
```

Recompile the edited source or UI macro after changing key assignments.

## Configuration

CodePad reads settings from the `[CodePad]` section of `TSE.INI`. The supplied source uses these names and defaults:

```ini
[CodePad]
auto_pad_set== => ) if # ,
default_pad_set1==
default_pad_set2==>
default_pad_set3=)
default_pad_set4=) = =>
default_pad_set5=
```

- `auto_pad_set` controls the strings tried by `AutoPad()`.
- `default_pad_set1` through `default_pad_set5` populate the interactive prompt history.

The old documentation calls the automatic setting `full_pad_set`; the supplied version 1.1.4 source actually reads `auto_pad_set`, so `auto_pad_set` is the correct name for this archive.

If the SReload macro and SetCache support are installed, edit `TSE.INI` and run SReload to make CodePad reload its settings without restarting TSE.

## Notes and limitations

- CodePad inserts spaces; it does not perform complete language-aware source formatting.
- A search string must be present on the relevant lines for useful alignment.
- Search strings supplied together are separated by spaces, so a literal search string containing a space cannot be expressed through that list syntax.
- Review the result after automatic formatting, especially with complex source code.
- The source and original documentation use legacy TSE SAL include syntax and may require adaptation for a particular modern compiler configuration.

## Version history

- **1.0.0.0.0 — 2026-09-04 14:55:29 CEST**
  - Created this Markdown README from the contents of `cpad114.zip`.
  - Added installation, usage, key-binding, configuration, and troubleshooting guidance.
  - Documented the source-code setting name `auto_pad_set` and the implemented automatic-mode switch `-a`.

Future README revisions can increment the last component, for example `1.0.0.0.1`, `1.0.0.0.2`, and so on.

## License and disclaimer

The original source states that CodePad is free software distributed under the Perl Artistic License. It also states that the software is used at the user's own risk. Consult the notices in `CodePad.s` and `CodePad.txt` for the original copyright and license information.
