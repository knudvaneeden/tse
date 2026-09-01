# BYTE2BIT for TSE

**README version:** 1.0.0.0.1
**Original program:** Todd Fiske
**Original release date:** September 14, 1993
**Language:** SemWare Application Language (SAL)
**Source file:** `BYTE2BIT.S`
**Compiled macro:** `BYTE2BIT.MAC`

## Description

BYTE2BIT is a collection of TSE SAL routines for converting characters into eight-character bit strings and converting those bit strings back into characters.

By default, BYTE2BIT represents binary values as follows:

- `x` represents binary `1`.
- `.` represents binary `0`.

For example, the uppercase character `A` has byte value 65 and is represented as:

```text
.x.....x
```

This corresponds to the conventional binary representation:

```text
01000001
```

The characters used for binary `1` and `0` can be changed while the macro is running.

BYTE2BIT can:

- Display the bit representation of the character under the cursor.
- Display the character represented by the next eight bit characters.
- Replace a character with its eight-character bit string.
- Replace an eight-character bit string with its corresponding character.
- Change the characters used to represent binary `1` and binary `0`.

The macro was originally created for editing bitmap graphic-font data directly inside TSE.

## Included files

### `BYTE2BIT.S`

The SAL source code for the macro.

### `BYTE2BIT.TXT`

The original documentation written by Todd Fiske.

### `BYTE2BIT.MAC`

The compiled macro produced from `BYTE2BIT.S`.

This file may already be included in the original package. Otherwise, compile `BYTE2BIT.S` using the SAL compiler supplied with your TSE installation.

## Requirements

- The SemWare Editor Professional, commonly called TSE.
- A compatible SAL compiler if the supplied source must be compiled.
- A TSE version capable of running the resulting compiled macro.

The source was originally written for the prerelease version of SAL 1.0. Minor source changes might be necessary when compiling it with a substantially newer TSE SAL compiler.

## Compiling the macro

Open a command prompt in the directory containing `BYTE2BIT.S`.

Compile it using the compiler appropriate for your TSE installation. For a modern 32-bit TSE installation, the command will commonly be:

```text
sc32 BYTE2BIT.S
```

Older TSE installations may instead use:

```text
sc BYTE2BIT.S
```

A successful compilation should create:

```text
BYTE2BIT.MAC
```

If the compiler is not in the current directory, specify its complete path or add its directory to the system `PATH`.

## Loading and running BYTE2BIT

BYTE2BIT can be used as a standalone macro or incorporated into your bound TSE macro configuration.

### Method 1: Load it as a standalone macro

1. Start TSE.
2. Open the TSE macro loading menu.

   The default key in the original TSE configuration is:

   ```text
   Ctrl+F10
   ```

3. Select or enter `BYTE2BIT.MAC`.
4. Load the macro.
5. BYTE2BIT displays a short help message on the TSE message line.

The message shows the current characters used for binary `1` and `0`, together with the primary conversion keys.

### Method 2: Add it to a bound macro

BYTE2BIT can also be incorporated into `TSE.S` or another bound macro source file.

The original documentation recommends binding it using the SAL compiler's `-B` option.

Consult the documentation for your TSE version because the exact bound-macro procedure and filenames may differ between releases.

## Default key assignments

| Key | Procedure | Purpose |
|---|---|---|
| `Shift+F6` | `ShowByte()` | Show the character represented by the next eight bit characters |
| `Alt+F7` | `ShowBit()` | Show the bit string for the character under the cursor |
| `Alt+F8` | `Char2Bits()` | Replace the character under the cursor with its bit string |
| `Alt+F9` | `Bits2Char()` | Replace the next eight bit characters with one character |
| `Shift+F9` | `SetOneChar()` | Change the character representing binary `1` |
| `Shift+F10` | `SetZeroChar()` | Change the character representing binary `0` |

The key assignments are grouped at the end of `BYTE2BIT.S`, making them easy to change before compiling the macro.

## How to use the commands

### Show the bits for a character

1. Place the cursor on a character.
2. Press `Alt+F7`.
3. The eight-character bit representation appears on the TSE message line.

For example, placing the cursor on `A` displays:

```text
.x.....x
```

This command does not modify the file.

### Show the character represented by a bit string

1. Place the cursor at the beginning of an eight-character bit string.
2. Press `Shift+F6`.
3. The corresponding character appears on the TSE message line.

For example:

```text
.x.....x
```

represents:

```text
A
```

This command does not modify the file.

If the eight-character sequence contains anything other than the configured one and zero characters, BYTE2BIT reports:

```text
Invalid character found
```

### Replace a character with a bit string

1. Place the cursor on the character to convert.
2. Press `Alt+F8`.
3. BYTE2BIT deletes that character.
4. It inserts the corresponding eight-character bit string at the same position.

For example:

```text
A
```

becomes:

```text
.x.....x
```

#### Converting a word or string

The original BYTE2BIT macro converts only one character at a time. It does not
accept a complete string in a prompt, and it does not automatically process a
marked block or an entire word. `Char2Bits()` reads only the character under the
cursor by calling `CurrChar()`.

For example, to convert `Todd`:

1. Type `Todd` in the current TSE buffer.
2. Place the cursor on `T`.
3. Press `Alt+F8` to convert that character.
4. Repeat the operation for `o`, `d`, and `d`.

With the default `x` and `.` notation, the individual results are:

```text
T = .x.x.x..
o = .xx.xxxx
d = .xx..x..
d = .xx..x..
```

Combined without separators, `Todd` becomes:

```text
.x.x.x...xx.xxxx.xx..x...xx..x..
```

Automatic multiple-character conversion would require an additional loop or a
new procedure; that functionality is not implemented in the original macro.

### Replace a bit string with a character

1. Place the cursor at the first character of an eight-character bit string.
2. Press `Alt+F9`.
3. BYTE2BIT reads the next eight characters.
4. It deletes those eight characters.
5. It inserts the corresponding character.

For example:

```text
.x.....x
```

becomes:

```text
A
```

If fewer than eight characters are available, the macro displays:

```text
Couldn't get 8 characters
```

If an invalid character occurs in the sequence, the macro displays an explanatory message and does not perform the replacement.

### Change the binary-one character

Press:

```text
Shift+F9
```

Enter the single character that should represent binary `1`.

The one character cannot be the same as the zero character.

### Change the binary-zero character

Press:

```text
Shift+F10
```

Enter the single character that should represent binary `0`.

The zero character cannot be the same as the one character.

The new settings remain active for the currently loaded instance of the macro. The original source does not save them permanently.

To change the defaults permanently, edit these declarations near the beginning of `BYTE2BIT.S` and compile it again:

```text
sOneChar[1]  = 'x'
sZeroChar[1] = '.'
```

## Available SAL routines

### `Byte2Bits(integer i)`

Returns the supplied integer as an eight-character bit string.

The routine examines the byte from the most significant bit to the least significant bit, using masks from 128 through 1.

### `Bits2Byte(string s)`

Converts an eight-character bit string into an integer byte value.

It returns the value stored in `iInvalidChar`, initially 256, if the input contains a character other than the configured one or zero character.

### `ShowBit()`

Reads the character under the cursor and displays its bit representation on the TSE message line.

### `ShowByte()`

Reads eight characters beginning at the cursor, converts them into a byte, and displays the corresponding character on the message line.

### `Char2Bits()`

Replaces the character under the cursor with its eight-character bit representation.

It does nothing when the cursor is at or beyond the end of the line.

### `Bits2Char()`

Replaces the eight-character bit string beginning at the cursor with the corresponding character.

### `SetOneChar()`

Changes the character representing binary `1`.

### `SetZeroChar()`

Changes the character representing binary `0`.

### `Main()`

Displays a short sign-on and help message containing the current one and zero characters and the main key assignments.

## Customizing the keys

The default key assignments appear at the end of `BYTE2BIT.S`:

```text
<Shift F6>    ShowByte()
<Alt F7>      ShowBit()

<Alt F8>      Char2Bits()
<Alt F9>      Bits2Char()

<Shift F9>    SetOneChar()
<Shift F10>   SetZeroChar()
```

Change these definitions if any of the keys conflict with existing TSE macros or editor commands. Compile the source again after making changes.

Do not bind `Byte2Bits()` or `Bits2Byte()` directly to keys. They require arguments and are intended to be called by the user-interface procedures.

## Notes and limitations

- Every conversion uses exactly eight bits.
- Conversion is limited to one character at a time; whole-string and marked-block conversion are not implemented.
- BYTE2BIT operates on byte-sized character values rather than Unicode characters.
- The original default notation is `x` for `1` and `.` for `0`.
- The one and zero characters must be different.
- Settings changed with `SetOneChar()` and `SetZeroChar()` are not written to a configuration file.
- Some converted byte values may represent control characters rather than visible text.
- `Bits2Char()` modifies the current file by replacing eight characters with one character.
- `Char2Bits()` modifies the current file by replacing one character with eight characters.
- Save or back up important files before performing extensive conversions.
- TSE SAL uses an ASCII-oriented text environment; save modified SAL source in an ASCII-compatible encoding rather than UTF-8 if required by your compiler.

## Troubleshooting

### The macro does not load

Verify that:

- `BYTE2BIT.S` compiled without errors.
- `BYTE2BIT.MAC` exists.
- You selected the compiled `.MAC` file rather than the `.S` source file.
- The macro was compiled for a TSE version compatible with the editor being used.

### A key does not run the expected command

The key may already be assigned by TSE or another loaded macro.

Edit the key assignments at the end of `BYTE2BIT.S`, choose unused keys, and compile the source again.

### "Invalid character found" appears

The next eight characters do not consist entirely of the currently configured one and zero characters.

With the defaults, all eight characters must be either `x` or `.`.

### "Couldn't get 8 characters" appears

There are fewer than eight characters between the cursor and the end of the line.

Move the cursor to the beginning of a complete eight-character bit string.

### The converted result is not visible

The resulting byte may represent a space, tab, line-control value, or another nonprinting character. Use the conversion on ordinary printable character values when testing the macro.

## Version numbering

This README uses the following version sequence:

```text
1.0.0.0.0
1.0.0.0.1
1.0.0.0.2
1.0.0.0.3
```

For each future update, increment the final component unless a larger structural version change is required.

## Version history

### Version 1.0.0.0.1

- Clarified that BYTE2BIT converts only the character under the cursor.
- Added step-by-step instructions and expected bitstrings for converting `Todd` one character at a time.
- Documented that automatic whole-string and marked-block conversion are not implemented.

### Version 1.0.0.0.0

- Created `bytbit_readme.md`.
- Documented the original `BYTE2BIT.S` and `BYTE2BIT.TXT` files.
- Added compilation, loading, running, customization, and troubleshooting instructions.
- Documented all default key assignments and conversion procedures.

## Original revision history

- September 10, 1993: First version.
- September 14, 1993:
  - Added the global `sOneChar` and `sZeroChar` values.
  - Added procedures for changing the one and zero characters.
  - Added the `Main()` help message.
  - Cleaned up and commented the source for distribution.

## License

Todd Fiske placed `BYTE2BIT.MAC` and `BYTE2BIT.S` in the public domain.

The original author requested that the macros be used for "grand and noble purposes."
