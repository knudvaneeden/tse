# CAL_ESP - Spanish Pop-up Calendar for TSE

**README version:** 1.0.0.0.0  
**Program:** `CAL_ESP.S` / `CAL_ESP.MAC`  
**Original author:** Richard Hendricks  
**Spanish adaptation and enhancements:** Miguel Farah

## Description

CAL_ESP is a pop-up calendar macro for The SemWare Editor (TSE). It displays a navigable calendar inside TSE and can insert a small text calendar at the current cursor position.

The calendar was adapted for Spanish use. Month and weekday names are in Spanish, and each week runs from Monday through Sunday. It includes corrections and enhancements to the calendar originally supplied with TSE-Pro 2.5, including a corrected leap-year calculation.

## Features

- Three display layouts:
  - medium single-month calendar;
  - small single-month calendar;
  - three-month calendar.
- Spanish month and weekday names.
- Monday as the first day of the week.
- Navigation by day, week, month, year, or century.
- Quick return to today's date.
- A "pseudo-today" command that selects today's month and day while retaining the year currently being viewed.
- Insertion of a small calendar directly into the active text file.
- Leap-year handling.

## Files in the archive

| File | Purpose |
| --- | --- |
| `CAL_ESP.S` | TSE SAL source code. |
| `CAL_ESP.MAC` | Precompiled TSE macro supplied with the original package. |
| `CAL_ESP.TXT` | Brief original description. |
| `FILE_ID.DIZ` | Short archive description. |

## Requirements

- The SemWare Editor (TSE) or a compatible TSE-Pro installation.
- The TSE SAL compiler if the supplied source must be recompiled.

The included `CAL_ESP.MAC` is an old precompiled macro. If it is incompatible with your current TSE version, compile `CAL_ESP.S` with the SAL compiler that belongs to your installed TSE version.

## Installation

### Recommended: compile the source

1. Extract `cal_esp.zip` to a working directory.
2. Place `CAL_ESP.S` in your TSE SAL source or working directory.
3. Compile it using TSE's SAL compile command or from a command prompt with the appropriate compiler, for example:

   ```text
   sc32 CAL_ESP.S
   ```

4. Confirm that the compiler creates an updated `CAL_ESP.MAC`.
5. Put the compiled macro where TSE can find it, or run it directly from its current directory.

### Alternative: use the supplied macro

1. Extract `CAL_ESP.MAC` from the ZIP archive.
2. Copy it to your TSE macro directory, or another directory in which TSE can locate macros.
3. If it does not load or run correctly, use the recommended compilation procedure above.

## How to run CAL_ESP

1. Start TSE.
2. Load or execute the macro named `CAL_ESP` using your normal TSE macro command.
3. The calendar opens at the current system date.
4. Use the keys listed below to browse dates, change the layout, or insert a calendar.
5. Press **Escape** to close the calendar and return to normal editing.

Depending on your TSE setup, you may also assign `CAL_ESP` to a key or add it to your macro autoload configuration.

## Keyboard commands

| Action | Key |
| --- | --- |
| Next day | **Right Arrow** |
| Previous day | **Left Arrow** |
| Next week | **Down Arrow** |
| Previous week | **Up Arrow** |
| Next month | **Page Down**, **Space**, or **Enter** |
| Previous month | **Page Up** or **Backspace** |
| Next year | **Numeric keypad +** |
| Previous year | **Numeric keypad -** |
| Next century | **Ctrl + Numeric keypad +** |
| Previous century | **Ctrl + Numeric keypad -** |
| First day of the current month | **Home** |
| Last day of the current month | **End** |
| First day of the current year | **Ctrl + Home** |
| Last day of the current year | **Ctrl + End** |
| Return to today (`Hoy`) | **Alt + H** |
| Select today's month/day in the displayed year | **Ctrl + H** |
| Change calendar layout | **Alt + C** |
| Insert a small calendar into the active file | **Alt + I** |
| Exit the calendar | **Escape** |

`Alt + C` cycles through the medium single-month, small single-month, and three-month displays.

## Inserting a calendar into a text file

1. Open or create a text file in TSE.
2. Position the cursor where the calendar should be inserted.
3. Run `CAL_ESP`.
4. Navigate to the required month and date.
5. Press **Alt + I**.
6. A small Spanish calendar is inserted into the active file, with the selected day enclosed in square brackets.
7. Press **Escape** when you are finished with the pop-up calendar.

Example layout:

```text
+--------------------+
|26 de febrero   1996|
|lu ma mi ju vi sa do|
|          1  2  3  4|
| 5  6  7  8  9 10 11|
|12 13 14 15 16 17 18|
|19 20 21 22 23 24 25|
[26]27 28 29         |
+--------------------+
```

## Notes and limitations

- The interface and inserted calendar use Spanish names and abbreviations.
- Weeks start on Monday and end on Sunday.
- `Ctrl + H` is the pseudo-today function: it uses today's month and day but keeps the year currently displayed.
- Dates before 15 October 1582 are not adjusted for the historical introduction of the Gregorian calendar. Their displayed weekday can therefore be incorrect.
- Appearance depends on TSE's character set, screen mode, and color configuration.
- The source was written for an older TSE-Pro release. A modern SAL compiler may report compatibility issues that require small source changes.

## Troubleshooting

### The supplied `.MAC` file does not run

Compile `CAL_ESP.S` with the SAL compiler included with your current TSE installation, then use the newly generated `CAL_ESP.MAC`.

### TSE cannot find the macro

Place `CAL_ESP.MAC` in TSE's configured macro directory, add its directory to the relevant TSE search path, or execute it from the directory in which it was compiled.

### The numeric keypad plus or minus commands do not work

Use the **+** and **-** keys on the numeric keypad. Keyboard layout, Num Lock state, or key remapping may affect how TSE recognizes these keys.

### Box borders or accented text look incorrect

The original macro predates Unicode and uses the character encoding expected by older TSE versions. Select a compatible DOS/ANSI code page and a suitable fixed-width font.

## Version history

| README version | Changes |
| --- | --- |
| 1.0.0.0.0 | Initial README with description, installation, compilation, usage, keyboard reference, limitations, and troubleshooting. |

Future README revisions can continue as `1.0.0.0.1`, `1.0.0.0.2`, and so on.

## Original program history

- **5 April 1993:** Original release by Richard Hendricks.
- **8 April 1993:** Corrected the starting weekday in the adjacent-month displays.
- **30 August 1994:** Corrected compatibility with COLORS and added a help line.
- **27 July 1995:** Miguel Farah revised keyboard handling and adapted the calendar to Spanish conventions, including Monday-first weeks.
- **26 February 1996:** Added previous/next century navigation, pseudo-today, further comments, and a corrected `IsLeapYear()` function.
