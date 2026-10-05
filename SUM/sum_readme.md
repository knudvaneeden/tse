# SUM - description, help and usage

Version: **1.0.0.0.1**  
Date and time: **2026-10-05 13:49:46 +02:00**  
Original macro: SemWare; modifications and documentation: GPT-6 (OpenAI).

SUM adds numbers in a marked COLUMN block in the current TSE file. It offers Decimal, Hexadecimal and Mixed modes and lets you insert the result at the cursor or at the end of the block. No key is assigned.

## Install and run

1. Extract `sum1.0.0.0.1.zip`.
2. Place `sum.s` and `sum.ini` in your TSE macro directory.
3. Compile `sum.s` using TSE's SAL compiler, for example `sc32 sum.s`. This produces `sum.mac`; use the compiler supplied with your TSE version.
4. Open the file containing numbers and mark them as a COLUMN block, with one number per line.
5. Run `sum` using Execute Macro, or select Sum from Potpourri if it is listed there.
6. Choose Decimal, Hexadecimal or Mixed.
7. Review the sum and choose an insertion option. Escape cancels the menu.

## Overflow protection

The maximum is **2^31 - 1 = 2147483647**; the minimum is **-2147483648**. The macro checks each input number, each integer addition before unsafe arithmetic. Fractional input is rejected: this version accepts integers only. On overflow it stops, restores the marked block and cursor, and offers no result for insertion. With warnings enabled, it displays a warning after cleanup advising: "Run the TSE SAL macro BigIntSum instead."

The running total must remain within these limits at every step: a later negative number cannot rescue an earlier overflow. Hexadecimal inputs are signed numeric magnitudes, so positive `80000000h` is rejected; `-80000000h` is accepted.

## Configuration

```ini
[sum]
silent=false
```

`silent=false` shows the final Warn box: an overflow/error warning, or usage information after a normal run or cancellation. `silent=true` suppresses that box. Overflow protection remains active in silent mode. Menus remain interactive.

The macro searches for `sum.ini` in the current directory first, then beside the running macro. Missing settings default to `silent=false`.

## Number formats and limits

Decimal mode accepts signs, a leading dollar sign, commas, accounting negatives such as `(100)`. Fractional numbers are rejected. Hexadecimal mode accepts an optional `0x` prefix or `h` suffix. Mixed mode uses hexadecimal indicators to choose the base. The selected block can be at most 32 columns wide. Invalid characters retain the original macro's parsing behavior; use clean numeric columns.

## Checks to try in TSE

Mark each example as a separate column block:

| Numbers on separate lines | Expected behavior |
| --- | --- |
| 2147483646; 1 | Sum 2147483647 |
| 2147483647; 1 | Overflow warning, no insertion |
| 2147483648 | Input overflow warning |
| 2147483647.1 | Integer-only warning, no insertion |
| 1.5; 2 | Integer-only warning, no insertion |
| -2147483648; -1 | Underflow warning, no insertion |
| -2147483648 | Accepted |
| 7FFFFFFFh; 1h | Overflow in Hexadecimal mode |

Semicolons above separate lines; do not type them into the block. Repeat an overflow check with `silent=true`: no warning box should appear and no result should be inserted.

## Validation

Arithmetic boundary checks were verified independently. TSE compilation and interactive execution were not available in the delivery environment; compile and run the checks above in your TSE installation. The ZIP contains source, configuration and this README, without a compiled `.mac`.

The original SemWare copyright and distribution notice remain in `sum.s`.

## Version 1.0.0.0.1

Replaced the unsupported Replicate call with a SAL loop that builds the progress-bar string. Added explicit BY 1 to the digit loop. Compilation with SAL V4.50.rc23 still needs to be confirmed in TSE.
