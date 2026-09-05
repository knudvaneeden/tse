# DTMENU — Date/Time Insertion Menu for TSE

**Version:** 1.0.0.0.0  
**Date:** 2026-09-05  
**Time:** 23:33 CEST (21:33 UTC)  
**Original author:** Todd Fiske  
**Source language:** SAL 1.0 (Pre-Release)

## Description

`DTMENU.S` is a macro for The SemWare Editor (TSE) that provides a menu for inserting the current date and time in several formats. It uses a flexible format-pattern system instead of requiring a separate procedure for every possible date/time layout.

The supplied menu includes formats for:

- Date
- Time
- Day and date
- Date and time
- Day, date, and time
- CompuServe Information Service (CIS) date
- Unix-style date/time
- A user-defined format

The source archive contains:

- `DTMENU.S` — the TSE SAL source code

## Requirements

- The SemWare Editor (TSE) with a compatible SAL compiler
- Permission to compile and load SAL macros

The source identifies itself as SAL 1.0 (Pre-Release), dated October 4, 1994. Because it is legacy source code, small compatibility changes may be required for newer TSE/SAL versions.

## Installation and Compilation

1. Extract `dtmenu.zip` to a directory of your choice.
2. Open a command prompt in the directory containing `DTMENU.S`.
3. Compile the source with the TSE SAL compiler. For a 32-bit TSE installation, for example:

   ```text
   sc32 DTMENU.S
   ```

4. Confirm that the compiler creates the compiled macro file.
5. Copy or place the compiled macro where your TSE installation can load it, if necessary.

## How to Run

1. Start TSE.
2. Open the file into which you want to insert a date or time.
3. Load or execute the compiled `DTMENU` macro using your normal TSE macro-loading method.
4. Press **Ctrl+Alt+D**.
5. Select the desired entry from the **Date/Time Menu**.
6. The selected date/time text is inserted at the current cursor position.

## Menu Options

The exact values depend on the current local date and time.

| Option | Format pattern | Example shape |
|---|---|---|
| Date | `q/l/t` | `10/4/1994` |
| Time | `c:f:h` | `19:02:52` |
| Day Date (TSE Jr.) | `n q/l/v` | `Tuesday 10/4/94` |
| Date Time | `q/l/v c:f` | `10/4/94 19:02` |
| Day Date Time | `n q/l/v c:f:h` | `Tuesday 10/4/94 19:02:52` |
| CIS | `l-s-v` | `04-Oct-94` |
| Unix | `o, m s t c:f:h x` | `Tue, 4 Oct 1994 19:02:52 EDT` |
| User-defined | Editable | Determined by the format pattern |

## User-Defined Format Help

Choose **User-defined** to open the format work area. It shows both the pattern and its current result.

- Press **Space** to edit the pattern.
- Press **Enter** to accept the pattern and insert the formatted date/time.
- Press **Ctrl+Enter** to insert the pattern itself instead of its result.
- Press **F1** to display the format-code help.
- Press **Escape** to exit without inserting text.

The default user-defined pattern is:

```text
n r m t, b:ge
```

This produces a value shaped like:

```text
Tuesday October 4 1994, 7:02pm
```

## Format Codes

| Code | Meaning | Output style |
|---|---|---|
| `a` | Hour | 12-hour, zero-padded |
| `b` | Hour | 12-hour, no padding |
| `c` | Hour | 24-hour, zero-padded |
| `d` | Hour | 24-hour, no padding |
| `e` | Meridian | `am` or `pm` |
| `f` | Minute | Zero-padded |
| `g` | Minute | No padding |
| `h` | Second | Zero-padded |
| `i` | Second | No padding |
| `j` | Hundredths | Zero-padded |
| `k` | Hundredths | No padding |
| `l` | Day of month | Zero-padded number |
| `m` | Day of month | Number without padding |
| `n` | Day of week | Full name |
| `o` | Day of week | Abbreviated name |
| `p` | Month | Zero-padded number |
| `q` | Month | Number without padding |
| `r` | Month | Full name |
| `s` | Month | Abbreviated name |
| `t` | Year | Four digits, including century |
| `u` | Year | Century only |
| `v` | Year | Two digits, zero-padded |
| `w` | Year | Two digits, no padding |
| `x` | Time zone | `EST` or `EDT` in the supplied source |

Characters that are not recognized as format codes are copied unchanged. For example, slashes, colons, commas, spaces, and hyphens can be placed directly in a pattern.

## Important Notes

### Time-zone configuration

The supplied source is configured for the legacy U.S. Eastern time-zone abbreviations:

```text
EST
EDT
```

The original daylight-saving calculation assumes daylight time from the first Sunday in April through the last Sunday in October. These historical rules may not match current rules or your location. Modify `Standard`, `Daylight`, and `DSTString()` in `DTMENU.S` when another locale or rule is required.

### Time menu source quirk

In the supplied source, the **Time** menu entry displays the result of `c:f:h`, but its action inserts `n q/l/v`, the same day/date pattern used by the next menu entry. To make it insert the displayed time, change:

```text
InsertText(DTFormat("n q/l/v"))
```

on the **Time** menu line to:

```text
InsertText(DTFormat("c:f:h"))
```

### Menu speed

The menu calculates live examples while it opens. On older systems this can make the menu draw visibly. Removing the live example expressions from the menu can improve opening speed.

## Troubleshooting

### Ctrl+Alt+D does not open the menu

- Verify that the macro compiled successfully.
- Make sure the compiled macro is loaded in TSE.
- Check whether another macro already uses **Ctrl+Alt+D**.

### The source does not compile

- Confirm that you are using a TSE SAL compiler compatible with this older SAL syntax.
- Compile from a command prompt so that complete error messages are visible.
- Check whether modern SAL requires updates to legacy array/string declarations or menu syntax.

### The time zone is incorrect

Edit the `Standard` and `Daylight` strings and review the `DSTString()` rules for your location.

### A custom pattern gives unexpected text

Remember that letters `a` through `x` have special meanings. Use punctuation and spaces as literal separators, and consult the format-code table above.

## Version History

| Version | Date | Changes |
|---|---|---|
| 1.0.0.0.0 | 2026-09-05 | Initial Markdown documentation created from the supplied `dtmenu.zip` archive. |

Future documentation revisions should increment the final component sequentially, for example:

- `1.0.0.0.1`
- `1.0.0.0.2`
- `1.0.0.0.3`

## Original Source History

- 1994-10-04 — First version by Todd Fiske.

## License

No license information is included in the supplied archive. Retain the original author attribution and source header when redistributing or modifying the program.
