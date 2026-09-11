# ISQRT - Integer Square Root for TSE

Version: 1.0.0.0.0  
Date: 2026-09-11  
Time: 22:09:33 CEST

## Description

`ISQRT.S` is a TSE SAL source file that calculates the integer square root of a non-negative integer. It uses a bit-by-bit algorithm and does not require floating-point arithmetic.

The integer square root is the whole-number part of the mathematical square root. If the input is not a perfect square, the result is rounded down.

Examples:

| Input | Mathematical square root | ISQRT result |
|---:|---:|---:|
| 0 | 0 | 0 |
| 9 | 3 | 3 |
| 10 | approximately 3.162 | 3 |
| 16 | 4 | 4 |

The supplied `Main()` procedure demonstrates the calculation `isqrt(10)` and displays:

```text
Sqrt(10): 3
```

## Files

- `ISQRT.S` - TSE SAL source code containing `top2bits()`, `isqrt()`, and a demonstration `Main()` procedure.

## Requirements

- The SemWare Editor (TSE) with a compatible SAL compiler.
- The supplied source uses integer and bit-shift operations only.

## How to compile

1. Extract `ISQRT.S` from `isqrt.zip`.
2. Place `ISQRT.S` in a directory of your choice.
3. Open a command prompt in that directory.
4. Compile the source with the TSE SAL compiler:

   ```text
   sc32 isqrt.s
   ```

5. Confirm that the compiler creates `ISQRT.MAC` without errors.

## How to run

1. Start TSE.
2. Run the compiled macro `ISQRT.MAC` using TSE's macro execution command.
3. The demonstration displays `Sqrt(10): 3` in a warning message.

Depending on the TSE setup, the macro can also be started from TSE's command line by entering its macro name:

```text
isqrt
```

## How to use the procedure in another SAL macro

Call `isqrt()` with a non-negative integer and store or display the returned integer value. For example:

```sal
integer resultI

resultI = isqrt(144)
Warn("Integer square root: " + Str(resultI))
```

This returns `12`.

If the source is incorporated into another macro, remove or replace the supplied demonstration `Main()` procedure as appropriate, so that the combined source has the intended entry point.

## Notes and limitations

- The procedure is intended for non-negative integer input.
- It returns the floor of the square root, not a fractional result.
- It performs 16 iterations to produce a result for a 32-bit integer value.
- The original demonstration uses the fixed input value `10`. Edit `Main()` to test another value.
- No external DLL or binary helper is required.

## Troubleshooting

### The macro does not run

Verify that `ISQRT.S` compiled successfully and that `ISQRT.MAC` is in a directory from which TSE can load macros.

### The result has no decimal part

This is expected. `isqrt()` is an integer square-root procedure and deliberately rounds the result down.

### A negative value gives an unexpected result

Negative values are outside the intended input range. Validate the value before calling `isqrt()`.

## Version history

### 1.0.0.0.0 - 2026-09-11 22:09:33 CEST

- Created the Markdown description and help file.
- Documented the supplied demonstration, compilation, execution, reuse, and limitations.
- Based on the contents of the supplied `isqrt.zip` archive.

