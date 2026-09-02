# GETSTDGF - GetTimeStr() Time-Difference Calculator

**README file:** `getstdgf_readme.md`  
**Program file:** `getstdgf.s`  
**README version:** `1.0.0.0.0`  
**Date:** 2026-09-02  
**Time:** 21:30:32 UTC  
**Language:** TSE SAL  
**Created with:** OpenAI Codex  

---

## Description

`getstdgf.s` is a TSE SAL program that calculates the time difference between two values returned by `GetTimeStr()`.

The expected time format is:

```text
HH:MM:SS
```

For example:

```text
10:00:00
10:05:15
```

The difference between these values is:

```text
315 seconds difference
```

The program initially places the current `GetTimeStr()` value in both input fields. The user can edit the old and new time values before performing the calculation.

---

## Main functionality

The program performs the following operations:

1. Calls `GetTimeStr()` to obtain an initial old time.
2. Calls `GetTimeStr()` again to obtain an initial new time.
3. Displays an input prompt for the old time.
4. Displays an input prompt for the new time.
5. Converts both `HH:MM:SS` values to seconds.
6. Subtracts the old value from the new value.
7. Displays the difference in seconds using `Warn()`.

The calculation is performed by:

```sal
FNStringGetTimeDifferenceGettimestrS()
```

---

## Time-to-seconds calculation

Each time value is converted using this formula:

```text
seconds = (hours * 3600) + (minutes * 60) + seconds
```

For example:

```text
10:05:15
```

is converted as follows:

```text
(10 * 3600) + (5 * 60) + 15
= 36000 + 300 + 15
= 36315 seconds
```

If the old time is `10:00:00`, its value is:

```text
(10 * 3600) + (0 * 60) + 0
= 36000 seconds
```

The difference is therefore:

```text
36315 - 36000 = 315 seconds
```

---

## Midnight handling

If the new time is earlier than the old time, the program assumes that midnight was crossed.

For example:

```text
Old time: 23:59:50
New time: 00:00:10
```

The program adds 24 hours to the new time before calculating the difference.

The result is:

```text
20 seconds difference
```

This calculation assumes that the two times are no more than 24 hours apart.

---

## Requirements

To compile and run the program, you need:

- The SemWare Editor Professional
- The TSE SAL compiler
- A TSE version supporting `GetTimeStr()`
- The source file `getstdgf.s`

The program uses only standard TSE SAL functionality. It does not require external DLLs or include files.

---

## How to compile

### Compile inside TSE

1. Open `getstdgf.s` in TSE.
2. Select the macro compilation command from TSE's macro menu.
3. Compile the source file.
4. Confirm that the compiler reports no errors.

### Compile from the command line

Open a command prompt in the directory containing `getstdgf.s` and run:

```text
sc32 getstdgf.s
```

A successful compilation creates the compiled TSE macro file.

Depending on the TSE configuration and compiler version, the generated file will normally be named:

```text
getstdgf.mac
```

---

## How to run

After compiling the program, run the macro from TSE.

Enter the macro name through TSE's macro execution command:

```text
getstdgf
```

The program displays an input prompt containing the first `GetTimeStr()` value.

Enter or edit the old time:

```text
10:00:00
```

The program then displays a second input prompt.

Enter or edit the new time:

```text
10:05:15
```

The result is displayed using `Warn()`:

```text
315 seconds difference
```

---

## Example calculations

### Example 1: Five minutes and fifteen seconds

```text
Old time: 10:00:00
New time: 10:05:15
Result:   315 seconds difference
```

### Example 2: One second

```text
Old time: 12:30:10
New time: 12:30:11
Result:   1 seconds difference
```

### Example 3: One hour

```text
Old time: 08:00:00
New time: 09:00:00
Result:   3600 seconds difference
```

### Example 4: Crossing midnight

```text
Old time: 23:59:50
New time: 00:00:10
Result:   20 seconds difference
```

### Example 5: Identical values

```text
Old time: 14:25:30
New time: 14:25:30
Result:   0 seconds difference
```

---

## Input format

Enter both time values using this format:

```text
HH:MM:SS
```

Where:

- `HH` is the hour from `00` through `23`.
- `MM` is the minute from `00` through `59`.
- `SS` is the second from `00` through `59`.

Valid examples include:

```text
00:00:00
08:05:09
12:30:45
23:59:59
```

For predictable results, always use two digits for the hour, minute, and second.

---

## Cancelling input

If an input prompt is cancelled, the macro ends without displaying a calculated result.

The macro also ends if an empty time value is submitted.

---

## Function reference

### `FNStringGetTimeDifferenceGettimestrS()`

Calculates the number of seconds between two `GetTimeStr()` values.

Conceptual declaration:

```sal
string proc FNStringGetTimeDifferenceGettimestrS(
    string getTimeStr1,
    string getTimeStr2
)
```

Parameters:

- `getTimeStr1` - the old time in `HH:MM:SS` format.
- `getTimeStr2` - the new time in `HH:MM:SS` format.

Return value:

```text
<number> seconds difference
```

Example:

```text
315 seconds difference
```

---

## Limitations

- The input values must use the `HH:MM:SS` layout.
- The program expects valid time values.
- The calculation only compares times; it does not compare dates.
- When the new time is earlier than the old time, one midnight crossing is assumed.
- The calculated interval therefore covers a maximum of 24 hours.
- The program does not detect intervals spanning multiple days.

---

## Troubleshooting

### The result is incorrect

Verify that both values use the complete format:

```text
HH:MM:SS
```

Do not omit leading zeroes.

Correct:

```text
08:05:09
```

Avoid:

```text
8:5:9
```

### The seconds are ignored

Make sure you are using the version that reads seconds from character positions 7 and 8 of the `GetTimeStr()` value.

### A negative difference was expected

The program interprets a new time earlier than the old time as a midnight crossing. It therefore returns a positive elapsed time.

For example:

```text
23:00:00
01:00:00
```

returns:

```text
7200 seconds difference
```

### The macro cannot be executed

Confirm that:

1. `getstdgf.s` compiled successfully.
2. The compiled macro is accessible through TSE's macro path.
3. You are running the compiled macro using the name `getstdgf`.

---

## Version history

### Version 1.0.0.0.0 - 2026-09-02 21:30:32 UTC

- Created the initial Markdown documentation.
- Documented the `HH:MM:SS` input format.
- Documented conversion of hours, minutes, and seconds.
- Added compilation and execution instructions.
- Added calculation examples.
- Documented midnight-crossing behavior.
- Added troubleshooting information.

Future documentation versions should be numbered sequentially:

```text
1.0.0.0.1
1.0.0.0.2
1.0.0.0.3
```

---

## License

No separate license information was supplied with the program. Retain the original source-code comments, author information, and notices when modifying or redistributing it.
