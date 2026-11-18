# BNFPARSER 1.0.0.0.7 — Pure TSE SAL BNF/EBNF parser generator

**Status:** Source release for compilation and runtime testing in TSE Pro 4.50.33. The earlier 1.0.0.0.4 version compiled and validated `example.ebnf` successfully on the user's computer. Version 1.0.0.0.7 has **not** yet been compiler-tested with `sc32`.

## Purpose

Reads an EBNF grammar, lexes and validates it, writes a flat token-based intermediate representation, and emits a **standalone SAL parser recognizer** (`generatedparser.s`) by incorporating that grammar into a generic recursive parser runtime. The generated parser parses one text string through a persistent-history `Ask()` prompt and reports whether the *entire input* matches the starting rule. Nothing calls external executables, DLLs, PowerShell, or Python at runtime.

## Contents

- `bnfparser.s`: main grammar lexer, validator, IR writer and code generator
- `bnfparser_runtime.txt`: SAL source template for a generic generated recognizer
- `bnfparser.ini`: filenames and defaults
- `example.ebnf`: valid arithmetic language test grammar
- `example_invalid.ebnf`: deliberately invalid grammar
- `bnfparser_readme.md`: documentation

## Compile / run

1. Extract **all files to the same directory**. The program resolves relative paths from the executing .mac directory, independent of TSE's current directory.
2. `sc32 bnfparser.s`
3. Run `bnfparser` in TSE and accept `example.ebnf`.
4. With no grammar errors, check `bnfparser_ir.txt`, `bnfparser_tokens.txt`, `bnfparser_errors.txt` and `generatedparser.s`.
5. Compile the generated source with `sc32 generatedparser.s`. This produces `generatedparser.mac`.
6. Run `generatedparser` and supply a test expression.

### Suggested tests

| Input | Expected recognizer result |
| --- | --- |
| `(12 + 5) * 3` | PARSE OK |
| `42` | PARSE OK |
| `1+2*3` | PARSE OK |
| `1+` | PARSE FAILED |
| `(1+2` | PARSE FAILED |

### Format and supported grammar syntax

- `name = expression ;` or `name ::= expression ;`
- Double/single-quoted terminal literals; IDs reference other productions
- `,` sequence; `|` choice; `(...)` grouping; `[...]` optional; `{...}` zero-or-more
- `(*...*)` comments and `//` line comments
- First production is the start rule
- Names case-sensitive; 255-character lexer line limit (reported as an error)

### Important limitations

- **Recognizer only** in version 5: no lexer token classes, parse-tree output, semantic actions, FIRST/FOLLOW or left-recursion checks.
- Generic backtracking evaluator; it is *not yet* an LL(1) optimized generated parser. Direct or indirect left recursion may be rejected by recursion-depth guard rather than diagnosed as a grammar error.
- Prefix matching for quoted literals; spaces/tabs skipped before each literal (so whitespace is not significant between individual terminals). Input is a single string, at most 255 characters.
- Repetitions use a progress check to avoid infinite loops, and currently cap repetitions at 255.
- A choice uses ordered backtracking; a successful earlier alternative can prevent a later alternative from being tried if a subsequent sequence atom fails. Consequently ambiguous or non-predictive grammars are **not** guaranteed correct. Test with predictive grammars such as `example.ebnf`.
- `SaveAs(..., _OVERWRITE_)` overwrites configured output files, including the generated parser.
- The source template is required at **generation time**. `generatedparser.s` is independent of it at **runtime**.
- Compilation of the generated parser has not yet been verified in a local TSE environment. Please report the exact compiler line and diagnostic for further fixes.

## Version history

- **1.0.0.0.7** — Intermediate grammar output and standalone recognizer source generation; remove known unused variables from v4.
- **1.0.0.0.4** — Correct SAL `==` comparisons; compilation and initial valid-grammar runtime confirmed.

## Version 1.0.0.0.7: Portable macro-relative file access

The file base directory is now obtained from `SplitPath(CurrMacroFilename(), _DRIVE_ | _PATH_)`.
The program never uses `CurrDir()` or changes TSE's current working directory.
Relative paths in `bnfparser.ini` and in the grammar prompt are resolved against the directory containing the executing `.mac`.
The `.ini` is read there, and the grammar, runtime template, token listing, error report, IR, and generated parser use that same directory by default.
Explicit absolute paths are preserved (Windows drive paths, UNC paths, and Unix `/` paths).

**Verify:** Unzip all files together, compile `sc32 bnfparser.s`, run `bnfparser` while TSE has a different current working directory, and confirm the template and generated files are read/written in the `.mac` directory.

**Status:** Source revised; not compiler- or runtime-tested using TSE SAL 4.50.33 in this environment.

## Version 1.0.0.0.7 — Persistent Ask history with INI fallback

- `bnfparser.s`: enables `PersistentHistory` and uses history list **211** for the grammar filename. The fallback is `[Files] Grammar=` in `bnfparser.ini`, with `example.ebnf` as a built-in final default.
- `bnfparser_runtime.txt`: generated parsers enable `PersistentHistory` and use independent history list **212** for the input text. The fallback comes from `[Defaults] InputText=` in `generatedparser.ini`, with `(12 + 5) * 3` as a built-in final default.
- `generatedparser.ini` is optional and is searched for beside the executing `generatedparser.mac` via `CurrMacroFilename()`. It must be copied beside that .mac file if a customized fallback is desired.
- Existing persistent Ask history entries are preserved and are not reset by the defaults.
- No use of `CurrDir()` for file discovery; explicit absolute grammar file paths remain supported.
- The generated parser does not require the INI to run, since it has a built-in input default.
- The EBNF parser/validator/generator algorithms are otherwise unchanged from v6.

**Build:** `sc32 bnfparser.s`, run `bnfparser`, then `sc32 generatedparser.s` and run `generatedparser`. Test the first run with no prior history and a changed INI default, followed by repeated calls to confirm persistent history.

**Test status:** Source changes verified textually; no TSE SAL 4.50.33 compiler available in this environment.

## Version 1.0.0.0.9 — Avoid displaying internal grammar buffer

Generated recognizer records the original editor buffer before creating its temporary grammar-token buffer, then restores the original buffer on both normal completion and cancellation of the input Ask dialog. The token records use `Chr(9)` as a delimiter, which TSE may display with visible special-character glyphs. The change affects only generated parser screen focus; parsing logic is unchanged. The grammar buffer is still kept in the ring during the current macro execution; explicit deletion is not attempted here. Re-run the generator and recompile generatedparser.s to apply the template fix. Source not compiler-verified locally.


## 1.0.0.0.9 — generated syntax / derivation tree

The `generatedparser.mac` now saves `generatedparser_tree.txt` in the **executing macro directory** whenever an entire input expression is recognized. Its tree includes indentation for nested grammar-rule calls and terminal matches, and stores the 1-based input start column of nodes. Backtracking checkpoints use SAL `DelLine()` to remove speculative nodes from failed alternatives, optional branches, and repetitions. The result is a derivation tree rather than a semantically reduced AST. No arithmetic evaluation is performed. For failed input, the tree file is overwritten with a failure message to prevent confusion with a previous successful parse.

The standard `Ask()` persistent history and the optional `generatedparser.ini` fallback are preserved. No `CurrDir()` or external runtime dependencies. Version 1.0.0.0.9 has **not** yet been compiled or executed against SAL 4.50.33; test it in that environment.

**Test:** `sc32 bnfparser.s`, run `bnfparser` using `example.ebnf`, `sc32 generatedparser.s`, then run `generatedparser` with `(12 + 5) * 3`. Inspect `generatedparser_tree.txt` in the macro directory. Check `42`, `1+2*3`, and invalid `1+` as well.

## Version 1.0.0.0.10 — Derivation-tree display and positions

This version is based on the successfully tested v1.0.0.0.9 implementation.
Only the generated recognizer's runtime tree rendering is modified:

- A `RULE` node is written at its parent's child depth **before** incrementing
  `gTreeDepth`; the rule's children are written one indentation level deeper.
  The root rule therefore begins at column 1 of the saved text file.
- Before recording a rule's start position, `GPSkipWhite()` advances beyond
  spaces and tabs. This makes the reported column consistent with its first
  matching terminal for the current whitespace-insensitive grammar mode.
- Rule parse success/failure still balances `gTreeDepth` and rolls back
  abandoned nodes during backtracking, optional groups and repetition.
- The existing recognizer algorithm, macro-relative file resolution
  (`CurrMacroFilename()`), output filename, Ask() persistent histories and
  INI fallback values remain unchanged.

**Testing:** compile `bnfparser.s`, run it against `example.ebnf`,
compile its newly generated `generatedparser.s`, and run
`generatedparser` with `(12 + 5) * 3`. Open `generatedparser_tree.txt`.
The root should be unindented; `LITERAL 5` should be nested below
`RULE digit`, and the enclosing `RULE number` should start at column 7
(the same as the matched `5`). Also test `42`, `1+2*3` and invalid
inputs such as `1+`, `(1+2` to check no regressions.

**Status:** Source change and archive checked; requires compilation and
runtime verification with TSE SAL v4.50.33.

## Version 1.0.0.0.11 — Farthest failure and expected terminals

Generated recognizers now track the **farthest attempted input column** even if
a grammar alternative backtracks or a repetition ends. Literal mismatches
contribute their expected terminal(s). When the parser consumes a valid prefix
but leaves extra input, it records `end of input`. The resulting failure location
and expected symbols are both shown in the `Warn()` dialog and saved to
`generatedparser_tree.txt`. A depth-limit failure is also annotated.

**Tests:** Regenerate and recompile `generatedparser.s`. Test valid
`(12 + 5) * 3` and invalid `(1 +`, `1+`, `abc`, `1+2xyz`.
Expected diagnostics identify the farthest reached input column rather than
always reporting column 1. Actual expected tokens may include alternatives
explored during backtracking.

All code remains pure SAL and macro-relative. Existing tree indentation,
positions, Ask histories and INI fallback remain unchanged.

**Limitations:** This is a best-effort expected-terminal diagnostic, not a full
FIRST/FOLLOW error analyzer. Speculative paths can contribute candidates.
Not yet compiler or runtime verified on TSE SAL 4.50.33.

## Version 1.0.0.0.12 — Generated SAL version header

The code generator now prepends a comment header to **every** newly generated
`generatedparser.s` containing the generated source version (1.0.0.0.12),
the generating BNFPARSER version, and the full source grammar filename.
This is performed by `BNFGenerate()` so it also works when the runtime template
is replaced with an alternative. The previous template is otherwise unchanged,
including tree output, farthest-failure diagnostics, and Ask history.

To test: compile and run `bnfparser.s`, open the newly written
`generatedparser.s` and check its first lines, then compile that file.
The uploaded `generatedparser_tree(3).txt` confirms that v11 error
diagnostics were active (column 4 plus expected terminals).

Not independently compiled with sc32 4.50.33 in this environment.

## Version 1.0.0.0.13 — Repeated expression testing

Generated `generatedparser.s` stays running after parsing each expression.
The program loads its embedded grammar once and then loops over the
persistent-history `Ask("Input text to parse (Escape to quit):", ..., 212)`.
Press **Escape** at that Ask dialog to exit. A successful parse and a
failed parse both display a result using Warn(), then return to Ask().

- On every new input the syntax-tree buffer is cleared using
  `GPTreeRollback(0)`, and depth, input position, farthest-failure column,
  and expected terminals are reset. No previous attempt's nodes or error
  state can carry into the next input.
- Each attempt writes `generatedparser_tree.txt` beside the executing .mac
  and overwrites the previous result, just as in earlier versions.
- Ask history remains persistent across program executions. The previous
  input stays as the next editable Ask value. The optional
  `generatedparser.ini` is still the initial fallback.
- Escape returns control to the original editor buffer, and there is no
  dependency on `CurrDir()`.
- Each regenerated `generatedparser.s` has a header showing version
  `1.0.0.0.13`.

**Test:** `sc32 bnfparser.s`; run `bnfparser` with `example.ebnf`;
`sc32 generatedparser.s`; run `generatedparser`. Enter `(12+5)*3`,
then `42`, then `1+`, then `1+2`, and press Escape on the subsequent Ask
dialog. No macro rerun should be needed between inputs.

**Status:** Source inspected and ZIP assembled; compile/runtime testing
against SAL 4.50.33 must be performed in your TSE installation.

## Version 1.0.0.0.14 — Generic syntax, optional evaluation

**BNFPARSER remains a general-purpose BNF/EBNF grammar recognizer/generator.**
No language-specific arithmetic logic is used while lexing/validating grammars
or by generated parsers when `SemanticModule=none` (the default).

To evaluate the supplied `example.ebnf` arithmetic language, edit
`bnfparser.ini` beside `bnfparser.mac` and set:

```ini
[Generator]
SemanticModule=arithmetic
```

Run `bnfparser` against `example.ebnf` and recompile the newly generated
`generatedparser.s`. For successful inputs it shows `PARSE OK. RESULT = ...`
and appends `RESULT = ...` to `generatedparser_tree.txt`. The expression
calculator is **not automatically applicable to arbitrary grammars**. It is
injected from the standalone source template
`bnfparser_semantics_arithmetic.txt`, and uses its own precedence-climbing
arithmetic interpretation after the general parser validates the expression.

The arithmetic example supports integer literals (up to eight digits each),
parentheses, unary `+`/`-`, and `+`, `-`, `*`, `/` with integer arithmetic.
Division by zero produces a semantic error rather than terminating the macro.
SAL integer range and overflow behavior constrain large results; floating
point, variables and automatic semantic actions are not yet supported.

Diagnostics now prioritize the expected end of input when a valid prefix
remains and label speculative candidates as *possible* terminals rather than
definitively required ones. This does **not** eliminate all speculative
expected candidates: a proper grammar-level predictive diagnostic pass remains
future work.

**Tests** (with arithmetic module enabled): `42` => 42;
`(12 + 5) * 3` => 51; `1+2*3` => 7; `8/2` => 4;
`1+` => parse failure; `1/0` => semantic error. Also regenerate with
`SemanticModule=none` and with a non-arithmetic EBNF grammar to confirm the
general parser requires no arithmetic semantics.

All generated code is pure TSE SAL. The macro directory is resolved through
`CurrMacroFilename()`; persistent `Ask()` history and repeated input sessions
are retained from v13. Version 14 has **not** been compiled or tested using
TSE SAL 4.50.33, and might require syntax adjustments on your installation.
