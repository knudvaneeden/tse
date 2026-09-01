# CalendUS

**README version:** 1.0.0.0.0  
**Program:** `CALENDUS.S`  
**Original release:** December 1994  
**Author:** Egon Bosved

## Description

CalendUS is a TSE (The SemWare Editor) SAL macro that displays a compact U.S. calendar for the current month.

The calendar:

- opens at the current month and year;
- highlights the current day;
- emphasizes Sundays and recognized holidays;
- provides keyboard navigation by month and year;
- supports years from 1968 through 2099; and
- closes with **Esc** and returns to the normal TSE display.

CalendUS includes calculations for fixed and movable dates such as New Year's Day, Valentine's Day, Good Friday, Easter, Independence Day, Halloween, Christmas, Martin Luther King Jr. Day, Presidents' Day, Memorial Day, Labor Day, Columbus Day, Veterans Day, and Thanksgiving.

## Files

| File | Description |
| --- | --- |
| `CALENDUS.S` | TSE SAL source code for the calendar macro. |
| `calendus_readme.md` | Description, help, compilation, and usage instructions. |

## Requirements

- The SemWare Editor (TSE) for DOS or a compatible TSE version with a SAL compiler.
- The TSE SAL compiler, such as `SC32.EXE`, when using a 32-bit TSE installation.

The source is a legacy 1994 SAL macro. Depending on the TSE version in use, minor source compatibility changes may be required before it compiles.

## Installation and compilation

1. Extract `calendus.zip` into a working directory.
2. Confirm that `CALENDUS.S` is present.
3. Open a command prompt in that directory.
4. Compile the source with the SAL compiler used by your TSE installation. For a 32-bit installation, the command is typically:

   ```text
   sc32 CALENDUS.S
   ```

5. Confirm that compilation completes without errors. The compiler should create the compiled macro file, normally `CALENDUS.MAC`.
6. Place the compiled macro where TSE can find it, or run it directly from the directory in which it was compiled.

If `sc32` is not on the system `PATH`, enter its full path or run the command from the TSE installation directory while supplying the full path to `CALENDUS.S`.

## How to run CalendUS

1. Start TSE.
2. Run the compiled `CALENDUS` macro using TSE's macro execution command or Macro menu.
3. The calendar opens at the current month.
4. Use the arrow keys to navigate.
5. Press **Esc** to close the calendar.

The exact macro-loading command can differ between TSE releases and personal configurations. Select `CALENDUS` or `CALENDUS.MAC` when prompted for the macro name.

## Keyboard help

| Key | Action |
| --- | --- |
| **Left Arrow** | Show the previous month. |
| **Right Arrow** | Show the next month. |
| **Up Arrow** | Show the same month in the previous year. |
| **Down Arrow** | Show the same month in the next year. |
| **Esc** | Exit CalendUS and restore the normal TSE window. |

The macro enables these keys exclusively while the calendar is displayed.

## Calendar display

- The title shows the selected month and year.
- The weekday headings run from Sunday through Saturday.
- The current day uses a different display attribute when the current month is shown.
- Sundays and recognized holidays use the holiday color.
- Some special dates use two-letter abbreviations or character symbols instead of the normal day number.

Examples of abbreviations include:

| Mark | Meaning |
| --- | --- |
| `NY` | New Year's Day |
| `GF` | Good Friday |
| `ED` | Easter Day |
| `ML` | Martin Luther King Jr. Day |
| `Pr` | Presidents' Day |
| `Mm` | Memorial Day |
| `ID` | Independence Day |
| `La` | Labor Day |
| `Co` | Columbus Day |
| `Vt` | Veterans Day |
| `Th` | Thanksgiving Day |
| `Xm` | Christmas |

## Supported date range

CalendUS restricts navigation to:

```text
1968 through 2099
```

Attempting to navigate beyond either limit keeps the calendar at the applicable boundary year.

## Important compatibility notes

- The source contains DOS-era box-drawing and symbol characters. Preserve the original file encoding when editing it. Converting it to UTF-8 may alter the calendar frame or special symbols because legacy TSE versions generally use an OEM/ANSI character set rather than UTF-8.
- The holiday rules were written in 1994 and the source itself warns that its U.S. holiday information may require correction. Do not rely on it as an authoritative modern holiday calendar.
- Some holidays are displayed using compact two-character labels in place of the date number.
- The date algorithms intentionally stop before 2100 and use simplified leap-year handling appropriate to the supported range.
- The calendar window uses fixed screen coordinates and is best suited to the traditional TSE text display.

## Troubleshooting

### `sc32` is not recognized

Add the TSE compiler directory to the command search path, run the compiler from that directory, or use the full path to `SC32.EXE`.

### The macro cannot be found in TSE

Verify that `CALENDUS.MAC` was created and either copy it to a directory searched by TSE or select it by its complete path.

### The frame contains incorrect characters

Restore the original `CALENDUS.S` file and compile it without converting its legacy encoding. Also confirm that the active console/font supports DOS box-drawing characters.

### Holiday dates appear incorrect

The holiday table and rules are historical. Review and update the corresponding `Case DayInYear` entries and `CertainWeekdayInMonth()` calculations in `CALENDUS.S` if modern rules are required.

### The current day is not highlighted

The current-day attribute applies when the displayed day matches the date obtained when the macro starts. Navigate back to the current month and year, or restart the macro after the system date changes.

## Version history

| Version | Changes |
| --- | --- |
| 1.0.0.0.0 | Initial Markdown documentation for the original CalendUS archive, including description, requirements, compilation, usage, keyboard help, limitations, and troubleshooting. |

Future documentation revisions can continue as `1.0.0.0.1`, `1.0.0.0.2`, and so on.

## Disclaimer

CalendUS is legacy software supplied for archival, educational, and personal use. Verify holiday dates independently when accuracy is important.
