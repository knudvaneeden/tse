# LISP Parser for TSE SAL — 1.0.0.0.3

Date: 2026-11-18

A lexer, syntax parser, token viewer, syntax-tree viewer, and **small integer-Lisp evaluator** operating on the currently selected TSE source buffer. This package is 100% SAL: no PowerShell, Python, DLL, or subprocess is required at runtime.

## Build

Keep the files together and compile:

```bat
sc32 lispparser.s
```

Run the compiled macro in TSE with a Lisp source buffer active. The macro reads its defaults from `lispparser.ini` beside the macro and prompts via TSE `Ask()` with persistent history.

**Status:** v1.0.0.3 source has not been tested with the user's actual SAL compiler (4.50.33). The lexer/parser/listing/tree modes are based on the previously tested v1.0.0.2 source.

## Modes

| Key | Mode |
| --- | --- |
| P | Syntax validation |
| L | Lexical scan |
| K | Token table (position/type/value) |
| T | Indented syntax tree |
| E | **Evaluate integer Lisp** |

K mode now prints only the token total, rather than incorrectly claiming zero top-level forms.

## Evaluate: first test

Open `example_evaluate.lisp` in TSE, run `lispparser`, enter `E`.

```lisp
(define square
    (lambda (x)
        (* x x)))
(square 5)
```

Expected Evaluation buffer:

```text
LISP Evaluation - version 1.0.0.0.3
Integer Lisp evaluator (define/lambda, + - * /)
Result 1: defined square
Result 2: 25
OK: ... tokens, 2 top-level forms
```

The token count in E mode may include re-scanning function bodies when called; it is **not** a unique-source-token count. P/L/K/T retain their original separate behavior.

## Supported interpreter semantics

- Signed **32-bit integer** numbers (do not use decimal literals in E mode).
- Arithmetic list forms `(+ a b ...)`, `(- a b ...)`, `(* a b ...)`, `(/ a b ...)`. Division uses SAL integer arithmetic; behavior for non-exact division is language/compiler-dependent.
- Function definitions at top level: `(define name (lambda (x [y [z]]) body))`.
- Named function calls with 0–3 positional numeric arguments.
- Nested arithmetic, variable lookup for the current invocation, nesting named function calls, and redefinitions of named functions.
- Function bodies have exactly one expression. Functions do not capture outer lexical environments; there are no closures.
- Top-level evaluation output is displayed in a new TSE buffer. Original source content is not edited.
- A 2000-expression evaluation step limit mitigates runaway recursion. This is not a comprehensive sandbox for malicious inputs.

**Not implemented in E mode:** strings as runtime values; quoted lists; dotted pairs; `if`, `cond`, `let`, `set!`, `begin`; floating point; built-in I/O; closures; global value definitions `(define x 5)`; variable-arity functions; arbitrary Scheme/Lisp compatibility. These may still be lexically/syntactically accepted by the other modes, which validate the simpler surface grammar, not semantic correctness.

## Error messages and buffers

Errors include line and column using the shared lexer error mechanism. Undefined functions, unbound variables, wrong argument count, division by zero, unsupported literals and malformed `define` are reported. The evaluator uses a separate temporary `[LISP Runtime]` TSE buffer for function/parameter records. This runtime buffer may remain in the TSE ring after evaluation; it is not a disk file. An `Evaluation` result buffer is also created.

This interpreter deliberately starts small. It is not a complete implementation of Lisp or Scheme. Test `example_evaluate.lisp` first, then `example_evaluate_more.lisp`.

## Version history

- **1.0.0.0.3:** E mode (integer evaluator), define/lambda/function calls, arithmetic, separate evaluation test cases, K-mode summary fix.
- **1.0.0.0.2:** token listing K and syntax-tree T modes.
- **1.0.0.0.1:** lexer, syntax parser, syntax-error positioning.
