# SAINT Text Integrator for TSE
**Version:** 1.0.0.1.63 COMMUTATIVE

## Background & History
This project is a modernized, text-based implementation of **SAINT** (Symbolic Automatic INTegrator), originally created by James Robert Slagle in 1961 using LISP. Slagle's pioneering program was one of the earliest examples of artificial intelligence applied to symbolic mathematics, capable of solving freshman calculus integration problems at the level of a good college student.

This version brings the spirit of SAINT into The SemWare Editor (TSE) using the Semware Application Language (SAL).

## How It Works
Unlike Slagle's original 1961 architecture, which relied on complex heuristic problem-solving and an expanding AND/OR tree to navigate possible algebraic substitutions, this TSE SAL implementation takes a streamlined, deterministic approach:
*   **No AND/OR Trees or Heuristics:** It eliminates the computational overhead of recursive heuristic searching.
*   **Direct Pattern Matching:** The macro normalizes the input expression and aggressively scans against a comprehensive database of known integral templates and standard forms.
*   **Wildcard Variable Expansion:** It uses generalized wildcard parameters (e.g., `#a`, `#b`, `#c`) to instantly capture and map variables, constants, and coefficients from the input expression to the exact algebraic solution.
*   **Commutative Permutations:** To handle order-independent operations (like `sin(x) * cos(x)` versus `cos(x) * sin(x)`) without the memory overhead of generating a full Abstract Syntax Tree (AST), the engine dynamically generates swapped permutations for root-level multiplication and addition operators, testing all logical variations against the rule database.

## Supported Platforms
This macro features conditional compilation paths and is fully compatible with:
*   **TSE Pro for Windows** (Local execution)
*   **TSE for Linux** (Local execution via compatibility paths)
*   **Web / Remote Server** (Acts as a backend, parsing standard output via HTTP queries)

## Files Included
To successfully run the integrator, the following files are utilized:
*   **`saint.s`**: The core compiled macro engine containing the parser and pattern-matching logic.
*   **`saint_rules.txt`**: The mandatory ruleset database. This file must be located in the same directory as `saint.s` (or configured via the OS-specific load paths) for the engine to load the integration templates.
*   **`saint_examples.txt`**: A supplementary file containing a testing suite of normalized `int ... dx` expressions. It is not required to run the macro, but it is useful for batch testing.
*   **`saint_readme.md`**: This documentation file.

## Usage Instructions
Once `saint.s` is compiled, you can execute the macro in several distinct ways:

1.  **Interactive Input:** Run the macro directly without any highlighted text. An input box will prompt you to type the integral manually (e.g., `int x * exp( 300 * x ) dx`).
2.  **Command-Line Parameter:** Pass the expression string directly as a parameter when executing the macro from the command line.
3.  **Batch Execution:** Highlight a block of text containing multiple `int ... dx` expressions (such as those found in `saint_examples.txt`). Running the macro will automatically evaluate every expression in the highlighted block sequentially and output the results, alongside the engine's reasoning, into a newly created `SAINT_Result` buffer.
4.  **Web Browser Interface:** When compiled with `#DEFINE TSEREMOTESERVER 1`, the macro intercepts integral strings from URL queries and returns the resulting solution directly to standard output (`_STDOUT_`). To run SAINT TSE online, use the following URL format:
    `http://108.181.171.91/ddd.php?tseMacroS=c:/bbc/taal/saint.mac^%20-p^%20int^%20x^%20dx`

## Changelog
*   **2026-08-20:** Bumped to v1.0.0.1.63 - Implemented dynamic commutative permutations in the advanced forms parser to correctly match order-independent operations without needing to duplicate rules.
*   **2026-08-19:** Bumped to v1.0.0.1.62 - Added support for executing the macro on TSE for Linux and introduced a web browser interface for remote server environments, including the direct live URL for testing.
*   **2026-08-19:** Bumped to v1.0.0.1.54 - Eliminated all remaining "No solution" errors; finalized generalized `#a`, `#b`, `#c` wildcard mapping for elliptic integrals and complex radical denesting.
*   **2026-08-19:** Updated to v1.0.0.1.48 - Restored complete ruleset database to bypass file truncation issues.
*   **2026-08-19:** Updated to v1.0.0.1.46 - Expanded variable extraction to natively map higher-order wildcards (`#d`, `#e`) in the macro engine.
*   **2026-08-19:** Updated to v1.0.0.1.43 - Added fallback generalized literals to the ruleset.
*   **[Initial]**: Initial text-based SAL port inspired by Slagle's 1961 architecture.

## Related Projects
A similar implementation of this text-based integration engine has been developed in Python.
*   **Source Code:** Available on GitHub at [https://github.com/knudvaneeden/integrator/](https://github.com/knudvaneeden/integrator/)
*   **Live Demo:** Run the Python version online at [http://108.181.171.91/integrator/](http://108.181.171.91/integrator/)
