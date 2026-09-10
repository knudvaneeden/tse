# GETDATE

## Description

GETDATE is a TSE Pro / TSE Pro/32 SAL macro that lets you select a calendar date and insert it into the current text file. It opens a small date-selection window, calculates the corresponding day of the week, and then offers several output formats.

The macro starts with the computer's current system date. You can move by day, month, or year before choosing the format to insert. The original source was written by Jim Sylva, and its date algorithms are copyright TurboPower Software Company and were redistributed with permission to SemWare Corporation.

## Package contents

- `GETDATE.S` — TSE SAL source code.
- `FILE_ID.DIZ` — original short package description.

## Requirements

- The SemWare Editor Professional (TSE Pro or TSE Pro/32).
- The TSE SAL compiler (`SC32.EXE`) if the supplied source must be compiled.
- A writable text buffer with the cursor positioned where the date should be inserted.

The package dates from 1994 and identifies TSE Pro and TSE Pro/32 as its original targets. Compatibility with a particular newer TSE release should therefore be confirmed by compiling and testing the macro in that release.

## Installation

1. Extract `getdate.zip` into a working directory.
2. Copy `GETDATE.S` to the directory where you keep TSE SAL macros.
3. Open a command prompt in that directory.
4. Compile the source:

   ```text
   sc32 getdate.s
   ```

5. Confirm that the compiler creates `GETDATE.MAC`.
6. Place `GETDATE.MAC` in a directory from which TSE can load macros, if the compilation directory is not already on TSE's macro path.

## How to run GETDATE

1. Open or create a text file in TSE.
2. Put the cursor at the position where the date is to be inserted.
3. Execute the macro by entering its name through TSE's macro execution command:

   ```text
   getdate
   ```

4. The date-selection window opens with the current system date.
5. Use the keys described below to select another date, or keep the current date.
6. Press `Enter` to open the **Date Formats** menu.
7. Select the desired format with its menu number or move to it and press `Enter`.
8. GETDATE inserts the selected text at the cursor. It observes TSE's current insert/overwrite state.

Press `Esc` in the date-selection window to cancel without inserting a date.

## Date-selection keys

| Key | Action |
| --- | --- |
| `Down Arrow` | Move forward one day |
| `Up Arrow` | Move backward one day |
| `Left Arrow` | Move backward one month |
| `Right Arrow` | Move forward one month |
| `Ctrl+Left Arrow` | Move backward one year |
| `Ctrl+Right Arrow` | Move forward one year |
| `Enter` | Accept the displayed date and open the format menu |
| `Esc` | Cancel the macro |

The corresponding grey numeric-keypad cursor keys are also supported.

## Available date formats

The exact result depends on the selected date. For 10 September 2026, the menu formats are represented by examples such as:

1. `09/10/26`
2. `09/10/26 Th`
3. `09/10/26    Thu`
4. `Thursday, 09/10/26`
5. `September 10, 2026`
6. `Thursday, September 10, 2026`

The numeric formats use month/day/year order and a slash separator.

## Important note about the original source

Although the menu displays six formats, the final acceptance test in the supplied 1994 source explicitly recognizes `Enter` and numeric choices `1` through `4`. Direct numeric selection of formats `5` and `6` may therefore not complete the insertion as expected. This README documents the supplied source without changing it.

## Calendar range and behavior

- The source defines a calendar range from 1600 through 3999.
- Leap years and the day of the week are calculated internally.
- Two-digit years supplied internally are interpreted using the macro's original threshold logic.
- GETDATE temporarily changes TSE's date-format and date-separator settings while it runs, then restores them when it finishes normally.

## Troubleshooting

### The macro does not run

Make sure `GETDATE.MAC` was created successfully and is stored in a location where TSE can find compiled macros.

### The date overwrites existing text

GETDATE follows TSE's insert/overwrite state. Enable Insert mode before running the macro if existing characters must be shifted to the right.

### A compiler error is reported

The source was originally released in 1994. A newer SAL compiler may require small compatibility changes. Keep an untouched copy of the original source before adapting it, and record each change in the version history below.

### The date is not inserted

Press `Enter` after choosing a date, then choose one of the supported format entries. If direct choices `5` or `6` do not work, see the note about the original source above.

## Version history

| Version | Date and time | Description |
| --- | --- | --- |
| 1.0.0.0.0 | Thursday 10-09-2026 13:15:30 CEST | Initial Markdown documentation based on `GETDATE.S` and `FILE_ID.DIZ` from the supplied archive. |

Future revisions should increment the final component, for example `1.0.0.0.1`, `1.0.0.0.2`, and so on.

## Document information

- Document: `getdate_readme.md`
- Version: 1.0.0.0.0
- Created: Thursday 10-09-2026 13:15:30 CEST
- Prepared by: OpenAI Codex (GPT-5)
