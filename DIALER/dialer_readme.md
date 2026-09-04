# DIALER — TSE Telephone Dialer Macro

**README version:** 1.0.0.0.0  
**Created:** 2026-09-04 21:58:44 UTC  
**Original macro:** DIALER 1.1  
**Original author:** Bob Fehrenbach

## Description

`DIALER.S` is a legacy SAL macro for The SemWare Editor (TSE). It reads a telephone number from the text under the cursor and sends Hayes-compatible dialing commands to a modem.

The macro can:

- Dial the telephone number under the cursor.
- Accept the cursor at any position within the number.
- Ignore hyphens embedded in a telephone number.
- Dial numbers containing seven digits or fewer directly.
- Add a leading `1` to a number longer than seven digits when one is not already present.
- Open a configurable text file that serves as a telephone directory.
- Hang up the modem after the user presses a key.

## Archive contents

| File | Description |
| --- | --- |
| `DIALER.S` | TSE SAL source code for the telephone dialer macro. |

## Requirements

- The SemWare Editor (TSE) with a compatible SAL compiler such as `SC32`.
- A modem that accepts conventional Hayes commands.
- A working serial port, configured as `COM2` by default.
- A telephone line connected to the modem.

This is legacy software intended for modem-based telephone dialing. Modern systems may not provide a physical serial port or support direct `COM`-port output without additional hardware and configuration.

## Default key bindings

| Key | Action |
| --- | --- |
| `Ctrl+Shift+Z` | Dial the telephone number under the cursor. |
| `Alt+Shift+Z` | Open the configured telephone-directory text file. |

## Configuration

Open `DIALER.S` in a text editor and review the following settings before compiling it.

### 1. Select the modem port

The macro uses `COM2` in both modem commands:

```sal
Dos ("echo ATDT" + phone_num + ">com2", _DONT_CLEAR_)
Dos ("echo ATH >com2", _DONT_CLEAR_)
```

If the modem uses another port, replace both occurrences of `com2` with the correct port, such as `com1`.

### 2. Configure an outside-line prefix

The source contains this disabled example:

```sal
//   phone_num = "9," + phone_num
```

Remove the leading `//` if the telephone system requires `9` before an outside call. Change `9,` when a different prefix or pause sequence is required.

### 3. Set the telephone-directory file

The default directory command opens:

```text
C:\docs\phones.txt
```

Change the path in this source line if the telephone list is stored elsewhere:

```sal
EditFile ("c:\docs\phones.txt")
```

### 4. Review modem commands

The macro uses:

- `ATDT<number>` to dial using tone dialing.
- `ATH` to hang up.

Modify these commands only if the modem requires a different command set.

## Installation and compilation

1. Extract `dialer.zip` into a working directory.
2. Copy `DIALER.S` to the TSE macro directory, if desired.
3. Edit the serial port, outside-line prefix, and telephone-directory path as described above.
4. Open a command prompt in the directory containing `DIALER.S`.
5. Compile the source with the TSE SAL compiler:

   ```bat
   sc32 DIALER.S
   ```

6. Confirm that compilation completes without errors.
7. Load the compiled macro in TSE or add it to the TSE autoload list according to the installed TSE version and configuration.
8. Restart TSE if required for an autoload-list change to take effect.

## How to run the dialer

1. Open a text file containing a telephone number, for example:

   ```text
   Office: 555-1234
   ```

2. Put the cursor anywhere on `555-1234`.
3. Press `Ctrl+Shift+Z`.
4. The macro removes the hyphen and sends `ATDT5551234` to the configured serial port.
5. Wait while the modem dials.
6. When TSE displays the message asking you to pick up the receiver, pick it up.
7. Press any key. The macro then sends `ATH` to hang up the modem connection and refreshes the TSE status line.

To open the configured telephone-directory file, press `Alt+Shift+Z`.

## Accepted telephone-number format

- Digits `0` through `9` are accepted.
- Embedded hyphens are ignored.
- The telephone number must be one whitespace-delimited item.
- Spaces, parentheses, plus signs, periods, or other nonnumeric characters inside the number are not accepted.

Examples:

| Text under cursor | Number sent to modem |
| --- | --- |
| `555-1234` | `5551234` |
| `1-212-555-1234` | `12125551234` |
| `212-555-1234` | `12125551234` |

If an unsupported character is encountered, the macro displays `Not a valid phone number` and stops without dialing.

## Troubleshooting

### The modem does not respond

- Confirm that the modem is connected and powered on.
- Verify the correct `COM` port in Windows Device Manager.
- Change both `com2` references in `DIALER.S` when the modem uses a different port.
- Test whether the modem understands the `ATDT` and `ATH` commands.
- Check whether another application has already opened the serial port.

### The telephone-directory shortcut cannot open the file

- Confirm that the file exists.
- Replace `c:\docs\phones.txt` with its actual full path.
- Keep the path inside double quotation marks in the `EditFile()` call.

### A number is rejected

Use digits and optional hyphens only. Remove parentheses, spaces, `+`, and other punctuation from the number.

### Long-distance dialing is incorrect

The macro assumes that a number longer than seven digits needs a leading `1`. Adjust this logic when the local telephone system uses a different numbering plan.

## Safety notes

- Verify the telephone number before dialing.
- Calls may incur telephone charges.
- The macro sends commands directly to the selected serial port.
- Test configuration changes with care, especially when an outside-line or long-distance prefix is enabled.

## Version history

| README version | Date and time (UTC) | Changes |
| --- | --- | --- |
| 1.0.0.0.0 | 2026-09-04 21:58:44 UTC | Initial Markdown documentation based on the supplied `dialer.zip` archive and `DIALER.S` source. |

## Version-numbering convention

Future revisions of this README can increment the final component:

- `1.0.0.0.0` — initial documentation release
- `1.0.0.0.1` — first revision
- `1.0.0.0.2` — second revision
- `1.0.0.0.3` — third revision

