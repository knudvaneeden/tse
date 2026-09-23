# MULTI1

Version: **1.0.0.0.2**  
Package date and time: **2026-09-23 10:40:49 UTC**  
Original MULTI.S: Reed Esau, 1993 (version 1.1). Package update: GPT-6.

MULTI1 extends TSE SAL search with finding, counting, replacing, and repeating across open editor buffers. The package preserves the original author's copyright and distribution notice in `MULTI.S`.

## Files

- `MULTI.S` — SAL source with the original routines and key assignments, plus a direct-run `Main()` message.
- `multi1.ini` — controls the direct-run message.
- `multi1_readme.md` — these instructions.

## Install and run

1. Extract all files into a working directory.
2. Compile `MULTI.S` using your TSE SAL compiler, for example `sc32 MULTI.S`.
3. Load the resulting `MULTI.MAC` in TSE. Its source defines Ctrl+F for Find, Ctrl+R for Replace, and Ctrl+L to repeat. Check for conflicts with existing key assignments before using these shortcuts.
4. Run the macro directly to display its usage message. Keep `multi1.ini` in TSE's **current working directory** when running it; if missing, the message is shown.
5. With one or more files open, use Ctrl+F, Ctrl+R, or Ctrl+L. Enter a search expression and options when prompted. To count, assign `mMultiCount(TRUE)` to a key or menu entry in your TSE UI source and compile that UI source.

## Options and prompts

| Option | Meaning |
| --- | --- |
| `m` | Search across open buffers; cannot combine with `l`. |
| `b` | Search backward. |
| `g` | Global search where supported; count explicitly rejects this option. |
| `l` | Local search; cannot combine with `m`. |
| `i` | Ignore case. |
| `w` | Match whole words. |
| `n` | Replace without prompting for every occurrence; also accepted by count's prompt. |
| `x` | Regular expression search. |

At each prompted replacement choose Y/Enter (yes), N (no), O (only this one), R (replace rest), or Q/Esc (quit). Save edited files after reviewing replacements. All `Ask()` prompts use TSE's `_EDIT_HISTORY_`.

## Configuration

`multi1.ini` contains `silent=false` by default. Set `silent=true` to suppress the informative `Warn()` box when `Main()` runs. Search, count, and replace functions do not show that box. The INI reader accepts `silent=true` and `silent=false` as complete lines, case insensitively, with surrounding whitespace; it ignores other lines. The last recognized setting wins.

## Notes

The original installation comments describe TSE 1.0 and rebuilding an old editor executable. The steps above use a current standalone SAL compiler; actual key loading depends on your TSE setup. The source was reviewed and packaged, but could not be compiled or executed here because `sc32` and TSE are unavailable in this environment.
