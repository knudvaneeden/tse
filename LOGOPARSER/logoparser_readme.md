# LOGOPARSER 1.0.0.0.1

19 November 2026. A standalone TSE SAL lexer, recursive-descent parser and LOGO semantic interpreter, modeled on the approach of the earlier LISP and FORTH projects.

## Files

- `logoparser.s` — complete TSE SAL implementation (no external runtime).
- `logoparser.ebnf` — EBNF specification for the implemented language subset; it documents the grammar and is **not dynamically loaded** or interpreted by the macro.
- `logoparser.ini` — defaults, all user-facing input file/output/trace/token settings.
- `example.logo` — working sample with nested `REPEAT`, arithmetic, variables and turtle motion.
- `example_error.logo` — intentionally invalid program for testing syntax diagnostics.

## Compile and execute

1. Extract all files into one directory, preferably TSE's macro directory.
2. Compile from a terminal using `sc32 logoparser.s` (TSE SAL 4.50.33 target).
3. Run `logoparser.mac` from TSE. The program-file prompt offers `example.logo` as its INI default on first use and retains its own persistent history (231).
4. Inspect `logoparser_output.txt` written beside the compiled macro. It contains a token stream (optional), `PARSE OK`, and the execution trace.
5. Run again using `example_error.logo` to check syntax-error reporting.

All default paths are resolved relative to `CurrMacroFilename()`, not `CurrDir()`. Absolute Windows drive paths are honored. The output file is overwritten on each run. All source files and the EBNF are preserved.

## Supported LOGO subset

`FORWARD/FD`, `BACK/BK`, `RIGHT/RT`, `LEFT/LT`, `PENUP/PU`, `PENDOWN/PD`, `HOME`, `CLEARSCREEN/CS`, `MAKE`, `PRINT/PR`, and nested `REPEAT n [ ... ]`. One command per physical line. `REPEAT` blocks may span lines; `]` ends the block. Comments begin with `;`.

Integer arithmetic: `+`, `-`, `*`, `/`, unary `+/-`, parentheses, and variables (`:SIDE`). Define a variable using `MAKE "SIDE 80`. Integer division truncates. The turtle begins at `(0,0)`, facing north (heading zero), with pen down. RIGHT rotates clockwise. All execution stays in the SAL macro. The result is a **textual turtle trace**, not a drawn graphical canvas.

The sine/cosine engine uses a fast integer approximation (Bhaskara) for positions; coordinates are internally scaled by 1000, and displayed positions are rounded/truncated to integer units. It is not intended for mathematically exact graphics. There is a 32-level nested REPEAT guard, a 64-level expression guard, a 100,000-step guard, and maximum REPEAT count 10,000. Integer overflows remain possible for very large inputs.

## Implementation notes and limits

Lexer reads each source line, produces tokens with line and column, and preserves newline tokens. Parser first validates the whole syntax without executing. Semantic pass then evaluates expressions, maintains variables and turtle state, and replays a saved token index for every `REPEAT` iteration. A syntax error aborts evaluation and reports line/column. A runtime problem such as undefined variable or division by zero also aborts execution.

No `TO` user-defined procedures, `IF`, lists as values, decimal/floating arithmetic, `SETXY`, colors or graphical plot rendering in this initial version. Source lines and individual tokens should fit within the TSE SAL 255-character string limit. TSE SAL itself is case-insensitive; LOGO command names and variable names are converted to uppercase.

## Important testing status

Source has been generated and examined, but a Windows TSE SAL 4.50.33 compiler is not available in this environment. **Compilation and actual TSE execution have not been verified.** Please report `sc32` diagnostics and the resulting output file for fixes.

## Version history

- **1.0.0.0.1** — initial lexer, LOGO EBNF, parser, execution engine, input configuration, persistent Ask history, and examples.
