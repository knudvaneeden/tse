# TSE Calculator Source Package

**README version:** 1.0.0.0.1  
**Current converted package version:** 1.0.0.0.7  
**Original package version:** 0.9 (9 August 1993)

## Description

This package contains four calculator macros for The SemWare Editor (TSE): algebraic and Reverse Polish Notation calculators in integer and floating-point versions.

The original floating-point calculators used the embedded `FPLOW.BIN` file. Modern TSE no longer supports the old SAL `binary` directive, so version `1.0.0.0.7` replaces it with a 32-bit Windows DLL compiled using Borland C++ command-line compiler 5.5.1.

The working version passes decimal text between SAL and the DLL. Direct transfer of the historical 10-byte floating-point values produced corrupted results on modern TSE. Text interchange avoids that incompatibility while retaining more precision than the calculator displays.

## Calculators

| Source | Type | Arithmetic |
| --- | --- | --- |
| `ACALC.S` | Algebraic | Integer |
| `FPCALC.S` | Algebraic | Floating point |
| `ICALC.S` | RPN stack calculator | Integer |
| `CALC.S` | RPN stack calculator | Floating point |

## Main files

| File | Purpose |
| --- | --- |
| `CALC.INC` | Helper procedures for `CALC.S` |
| `ICALC.HLP` | Help screen for `ICALC.S` |
| `FP_MIN.S` | Complete modern floating-point helper |
| `FP_MIN_DLL.S` | DLL declarations supplied separately for reference |
| `fplow.c` | Borland C source for `fplow.dll` |
| `fplow.def` | Export-interface documentation; do not pass it to `bcc32` |
| `build_fplow.bat` | Borland DLL build script |
| `CALC.DOC` | Original 1993 documentation |
| `original_reference/` | Original `FPLOW.BIN` and `FP_MIN.S` for reference only |

The compiled `fplow.dll` is created locally by `build_fplow.bat`.

## Requirements

- 32-bit Microsoft Windows.
- TSE Pro/32 with `sc32.exe`.
- Borland C++ command-line compiler 5.5.1 (`bcc32.exe`).
- All active sources and includes kept together during compilation.

TSE requires a 32-bit DLL for this interface.

## Build `fplow.dll`

1. Extract the complete package into a new directory.
2. Open a command prompt configured for Borland C++ 5.5.1.
3. Change to the extracted directory.
4. Run:

```text
build_fplow.bat
```

The build command is:

```text
bcc32 -WD -O2 -w- -efplow.dll fplow.c
```

Success is indicated by:

```text
Built fplow.dll successfully.
```

Do not add `fplow.def` to this command. Borland otherwise attempts to compile it as C source.

## Restart TSE after rebuilding

TSE retains a loaded DLL in memory. Replacing `fplow.dll` on disk does not update the copy already loaded by TSE.

After every DLL rebuild:

1. Close every TSE instance.
2. Put the new `fplow.dll` beside the calculator macros or in TSE's DLL search path.
3. Remove or rename obsolete copies that TSE might find first.
4. Restart TSE.
5. Recompile the floating-point calculators.

If TSE reports `Cannot locate DLL entry point: FPTEXTFORMAT`, it has normally loaded an older DLL.

## Compile

Compile all SAL sources with:

```text
sc32 *.s
```

Or compile only the executable calculators:

```text
sc32 acalc.s
sc32 fpcalc.s
sc32 icalc.s
sc32 calc.s
```

`FP_MIN.S` and `FP_MIN_DLL.S` are helper sources, not standalone calculators. Their unused-procedure notes are harmless.

Modern compatibility changes include:

- `GetStr` renamed to `cursorNumberS` because `GetStr` is reserved.
- `UpCase()` replaced by `Upper()`.
- The obsolete `binary "FPLOW.BIN"` block replaced by Pascal-convention DLL declarations.
- Active floating-point interchange changed from binary values to decimal text.

## Run

Run the compiled macros from TSE:

```text
ExecMacro("acalc")
ExecMacro("fpcalc")
ExecMacro("icalc")
ExecMacro("calc")
```

Press `Esc` to close a calculator.

## Algebraic operation

`ACALC.S` and `FPCALC.S` use:

```text
first number  operator  second number  =
```

For example:

```text
1.5 + 2.5 =
```

The algebraic display shows only the current number or result. Operators `+`, `-`, `*`, `/`, `%`, and `=` are intentionally not shown. They are stored internally like a traditional pocket calculator.

The visible sequence for the preceding example is:

```text
1.5
2.5
4.0000
```

## RPN operation

`ICALC.S` and `CALC.S` use:

```text
first number  Enter  second number  operator
```

Example:

```text
25 Enter 17 +
```

The X register should show `42`. The RPN versions provide X, Y, Z, and T stack registers and do not need `=` for normal calculations.

## Verified `FPCALC.S` tests

These tests passed with version `1.0.0.0.7`:

| Keys | Result |
| --- | ---: |
| `1.5 + 2.5 =` | `4.0000` |
| `10 / 4 =` | `2.5000` |
| `7.25 * 3 =` | `21.7500` |
| `100 - 37.5 =` | `62.5000` |
| `0.25 + 0.25 =` | `0.5000` |

If these produce incorrect results, verify that TSE was restarted after installing the current DLL.

## Main keys

Press `H` inside a calculator for its built-in help.

| Key | Action |
| --- | --- |
| `H` | Help |
| `Esc` | Exit |
| `G` | Get number under the edit cursor |
| `P` | Paste the displayed value into the edit buffer |
| `Delete` | Clear current entry or X register |
| `Ctrl` + cursor key | Move the calculator window |
| `+`, `-`, `*`, `/` | Arithmetic |
| `F` | Select displayed decimals in floating-point versions |
| `W`, `O`, `T`, `X` | Binary, octal, decimal, hexadecimal display |
| `&`, `|`, `^`, `N` | AND, OR, XOR, NOT in integer versions |
| `<`, `>` | Shift left and right in integer versions |
| `R` | Set bit-operation word size |

The RPN versions additionally support `Enter`, Last X, X/Y exchange, roll-up, roll-down, and clearing the stack.

## Display precision

Floating-point calculators initially display four decimal places. Press `F` followed by `0` through `9` to select the displayed number of decimals. For example:

```text
F 2
```

This changes only the display, not the retained value.

## Troubleshooting

### Cannot locate a DLL entry point

Close every TSE process, install the newly built DLL, and restart TSE. Check for an older `fplow.dll` elsewhere in TSE's search path.

### `GetStr` is reserved

Use version `1.0.0.0.4` or later.

### `UpCase` is undefined

Use version `1.0.0.0.5` or later.

### Borland reports unresolved `_strtold`

Use version `1.0.0.0.3` or later.

### Results are huge, unrelated, or otherwise corrupted

Use version `1.0.0.0.7`, rebuild `fplow.dll`, close all TSE instances, and restart TSE.

### Operators are not visible in `FPCALC.S`

This is expected. Only operands and results are displayed.

## Version history

### README

| Version | Changes |
| --- | --- |
| 1.0.0.0.1 | Updated for converted package `1.0.0.0.7`, including DLL compilation, compatibility changes, restart instructions, verified tests, operator-display behavior, and troubleshooting. |
| 1.0.0.0.0 | Initial documentation for `calc_src.zip`. |

Future README versions should increment the final component: `1.0.0.0.2`, `1.0.0.0.3`, and so on.

### Converted package

| Version | Changes |
| --- | --- |
| 1.0.0.0.7 | Replaced active binary transfer with working decimal-text DLL operations. |
| 1.0.0.0.6 | Attempted eight-byte binary interchange; corruption remained. |
| 1.0.0.0.5 | Replaced `UpCase()` with `Upper()`. |
| 1.0.0.0.4 | Renamed reserved `GetStr` variables. |
| 1.0.0.0.3 | Removed the unavailable Borland `_strtold` dependency. |
| 1.0.0.0.2 | Added all calculator sources and dependencies to one package. |
| 1.0.0.0.1 | Corrected the Borland build command and batch failure handling. |
| 1.0.0.0.0 | Initial DLL source conversion. |

## Credits

The original package was written by L. A. Vonderscheer. Its floating-point support was based on work by Tim Farley and the University of California at Riverside floating-point library by Randall Hyde. See `CALC.DOC` and the original source headers for historical distribution information.
