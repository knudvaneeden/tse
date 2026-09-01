# CALDAVE Calendar Macro for TSE

## Version

**README version:** 1.0.0.0.0  
**Source file:** `CALENDAR.S`  
**Original author:** Richard Hendricks  
**Modifications:** Dave Navarro, Jr.  
**Last source modification:** October 25, 1993

Future README revisions can use the sequence `1.0.0.0.1`, `1.0.0.0.2`, and so on.

## Description

`CALENDAR.S` is a TSE SAL calendar macro. It displays a monthly calendar in a pop-up window, initially selects the current date, and lets you navigate by day, month, or year.

Pressing **Enter** closes the calendar and inserts the selected date at the current cursor position in the active document. The inserted date uses this format:

```text
September 1, 2026
```

Pressing **Escape** closes the calendar without inserting anything.

## Archive contents

The supplied `caldave.zip` archive contains:

| File | Description |
| --- | --- |
| `CALENDAR.S` | TSE SAL source code for the calendar macro |

## Requirements

- The SemWare Editor (TSE) with a compatible SAL compiler.
- A text-mode environment that supports the legacy line-drawing characters used by the calendar window.
- Write access to the directory in which the compiled macro will be created.

This is legacy 1993 SAL source. Depending on the TSE/SAL version being used, small compatibility changes may be required before it compiles.

## Installation and compilation

1. Extract `caldave.zip` to a working directory.
2. Open a command prompt in that directory.
3. Compile the source using the SAL compiler supplied with TSE. For example:

   ```bat
   sc32 CALENDAR.S
   ```

4. Confirm that the compiler creates the compiled calendar macro.
5. Place the compiled macro where TSE can find and load it, or run it directly from the working directory using your normal TSE macro-loading method.

The exact compiler command and compiled filename can differ between TSE releases. Use the compiler appropriate for your installed TSE version.

## How to run

1. Start TSE.
2. Open the document into which you may want to insert a date.
3. Put the cursor at the required insertion position.
4. Load or execute the compiled `CALENDAR` macro using TSE's macro command or your assigned key.
5. Navigate to the required date.
6. Press **Enter** to insert it, or **Escape** to cancel.

## Keyboard controls

| Key | Action |
| --- | --- |
| **Left Arrow** | Select the previous day |
| **Right Arrow** | Select the next day |
| **Up Arrow** | Display the previous month |
| **Down Arrow** | Display the next month |
| **PgUp** | Display the next year |
| **PgDn** | Display the previous year |
| **Home** | Select the first day of the displayed month |
| **End** | Select the last day of the displayed month |
| **Ctrl+Home** | Select January 1 of the displayed year |
| **Ctrl+End** | Select December 31 of the displayed year |
| **Alt+T** | Return to today's date |
| **Enter** | Insert the selected date and close the calendar |
| **Escape** | Close the calendar without inserting a date |

## Usage example

Suppose the cursor is positioned after this text:

```text
Meeting date: 
```

Run the calendar, select September 1, 2026, and press **Enter**. The document becomes:

```text
Meeting date: September 1, 2026
```

## Notes

- The calendar opens with the current system date selected.
- The selected date is visually highlighted.
- Moving beyond the first or last day of a month automatically changes the month and, when necessary, the year.
- Leap years are taken into account when calculating the number of days in February.
- The month name is inserted in English.
- The macro inserts only a date. It does not create appointments, reminders, or calendar files.
- The source uses legacy extended characters for its box border. Preserve the original file encoding; saving it as UTF-8 may damage those characters in TSE.

## Troubleshooting

### The macro does not compile

Make sure you are using the SAL compiler supplied for your TSE version and that `CALENDAR.S` is being compiled as SAL source. Because the source dates from 1993, a modern compiler may report syntax or compatibility issues that require source updates.

### The calendar border is garbled

The source contains legacy DOS/OEM line-drawing characters. Restore the original `CALENDAR.S` from the ZIP and avoid converting it to UTF-8. Also check that the active console font and code page support those characters.

### The date is inserted in the wrong place

Before running the macro, place the TSE cursor at the exact insertion position in the active document.

### I only wanted to inspect a date

Press **Escape** instead of **Enter**. The calendar closes without changing the document.

## Version history

| Version | Date | Changes |
| --- | --- | --- |
| 1.0.0.0.0 | 2026-09-01 | Initial Markdown documentation for the supplied `caldave.zip` archive and `CALENDAR.S` macro |

## License

No license information is included in the supplied archive. The original authors retain any applicable rights. Review the source's distribution terms, if available from its original source, before redistributing or modifying it.
