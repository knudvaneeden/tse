# FORTHPARSER 1.0.0.0.5

2026-11-19. Standalone pure TSE SAL lexer, syntax parser, and semantic interpreter for a deliberately restricted, integer-only FORTH language. Inspired by the preceding LISPPARSER project, but independently implemented.

## Files

- `forthparser.s` — SAL lexer, parser, interpreter, interactive UI
- `forthparser.ini` — input and action defaults
- `forth.ebnf` — formal grammar for the supported subset
- `example.fth` — runnable FORTH test
- `example_invalid.fth` — missing-semicolon negative test
- `forthparser_output.txt` — generated on execution, not shipped

## Compile and run

Place all files in one directory. From that directory, run `sc32 forthparser.s` using the SAL compiler for TSE Pro 4.50.33. Run the resulting `forthparser.mac` in TSE. The macro prompts for a file and the action (`L`, `P`, or `E`) using persistent named Ask histories and defaults from the INI. The INI is the authoritative default for **each** Ask() prompt; the latest history item no longer overrides the source filename default. Relative files and output resolve beside `forthparser.mac` via `CurrMacroFilename()`; absolute paths are supported. The macro writes `forthparser_output.txt` in that directory and opens it.

## Supported FORTH subset

The lexer recognizes whitespace, signed integers, word names, colon and semicolon delimiters, backslash-to-end-of-line comments, parenthesized comments, and one-line `.'"'` strings (FORTH syntax: `."text"`). FORTH names are case-insensitive. Definitions use `: NAME ... ;` and can be called after declaration or before it (definitions are discovered over the whole file). The interpreter handles `+`, `-`, `*`, `/`, `MOD`, `=`, `<`, `>`, `DUP`, `DROP`, `SWAP`, `OVER`, `.`, `.S`, `CR`, `IF`, `ELSE`, `THEN`, printed strings, and defined words. Comparisons push -1 for true, 0 for false. Arithmetic uses SAL signed 32-bit integers. Integer division truncates according to SAL integer division behavior.

The semantic engine is stack-based. `IF` consumes a flag. Only executable top-level items run automatically; definitions are invoked by name. Output includes printed values and final stack depth.

This is **not an ANS Forth interpreter**: no `VARIABLE`, `CONSTANT`, `CREATE`, `DOES>`, `DO/LOOP`, `BEGIN/UNTIL`, return stack, I/O, floating-point, strings on the data stack, or compilation semantics. The EBNF documents the grammar; it is not dynamically loaded or converted by BNFPARSER. `IF` nesting is handled by the runtime.

## Example expected output (action E)

```
FORTH EXECUTION - 1.0.0.0.5
Square of 5: 
25
Cube of 3: 
27
Absolute value of -8: 
8
3 + 4 = 
7
5 is greater than 2: 
yes
Remaining stack: 
Stack depth: 0
Execution complete. Stack depth: 0
```

## Safety limits and compiler verification

- Maximum 12,000 tokens, 1,024 stack entries, 50 nested word calls, and 100,000 executed steps.
- Lexer reads at most 255 characters per physical input line; longer lines are outside this version's contract.
- A printed string cannot cross a physical line.
- The grammar/parser checks word-definition placement and balancing of `:` and `;`, but does not statically prove stack effects, all unknown names, or control-flow correctness. Those are checked where encountered by the execution engine.
- This package has not been compiled or run with an installed `sc32` compiler in the authoring environment; it is an initial implementation intended for compilation/testing with TSE 4.50.33.

## Version history

1.0.0.0.5 (2026-11-19): initial FORTH lexer, parser and integer semantic engine.

## Version 1.0.0.0.5

Renamed integer, string and boolean identifiers to use suffixes I, S, B and global GI, GS, GB. In particular, the reserved identifier `pos` is now `PositionI`. Not yet compiler-tested.

## INI and Ask() inputs

Both Ask() inputs have defaults in `forthparser.ini`: `input=example.fth` (filename) and `action=E` (choice). Possible actions are `L` (lexer), `P` (parser), and `E` (execute); the INI documents each and provides commented examples. Every accepted choice is written back to the INI, while the existing named Ask() histories remain available.

## Version 1.0.0.0.5

Ensured every Ask() input is represented and documented in the INI. The INI source-file default no longer gets silently replaced by the last item from persistent history.


## Fix in 1.0.0.0.5 (2026-11-19)

- Corrected token-buffer initialization: line 1 now holds an explicit
  `0|0|@TOKEN_HEADER@` record. The parser previously assumed such a line
  existed, but never inserted it. This could cause the first `:` token to
  be skipped and give a misleading `Unexpected ;` parse error.
- Corrected stack-buffer initialization in the same way. Stack elements
  are accessed at lines `depth + 1`, so line 1 now contains a header.
- Kept both Ask() defaults in `forthparser.ini` and the persistent history.
- No change to the language subset or supported words.

### Reproduction test

With `input=example.fth` in `forthparser.ini`, run `L` first.
The first tokens should be `2:1 :`, `2:3 SQUARE`, `2:10 DUP`,
`2:14 *`, `2:16 ;`. Next run `P`, then `E`.
Expect results including `25`, `27`, `8`, `7`, `yes`, and a final
empty-stack summary. The `SQUARE` definition must no longer give an
`Unexpected ;` error.

Build: `sc32 forthparser.s` (TSE SAL 4.50.33).

Compiler/runtime verification is still required on Windows with TSE;
`sc32` is not available in the package build environment.

## Fix in 1.0.0.0.5 (2026-11-19)

- Recognize the FORTH `\` single-line comment delimiter using `Chr(92)` instead of an ambiguous string literal. The rest of that source line is skipped.
- Use `Chr(92)` also when deriving the compiled macro directory from `CurrMacroFilename()` and resolving rooted Windows paths.
- Select the new source buffer before calling `InsertFile()` to ensure the input is loaded into the intended buffer.
- No new Ask() prompts were added; `input` and `action` remain in `forthparser.ini`, with persistent Ask() histories.

Test with `input=example.fth`, `action=E`. The lexer should ignore the first-line `\` comment and the execution must not report `Unknown word '\' at 1:1`.

This release has not been compiled against sc32 4.50.33 in the build environment.
