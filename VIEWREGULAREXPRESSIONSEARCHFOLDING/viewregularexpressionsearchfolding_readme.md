# VIEWREGULAREXPRESSIONSEARCHFOLDING

Version: **1.0.0.0.1**  
Updated: **2026-09-28 10:44 CEST**  
Original creator: **Zhong Zhao**  
Package update: **OpenAI Codex (GPT-6)**

## Description

Zhong Zhao describes code folding as one use of a broader **compressed view**: show selected code lines so important structures are easier to scan. For C/C++, the supplied macro applies his regular expression through TSE's `Find()` command with the `ixav` options. The expression is embedded in the `.s` source. No text is deleted from the file.

A compressed view can be useful beyond function declarations. Zhong Zhao's examples include opening and closing resources, initialization and cleanup, memory allocation and release, database connections, configuration reads and writes, GUI message handling, locks, branches, and loops. This package contains **one C/C++ expression**; those examples describe possible uses of language-specific expressions, not guaranteed matches of the bundled expression.

The macro is a one-command example of that approach. It does not implement conventional expand/collapse controls, fold markers, or automatic recognition of every code structure.

## Package files

| File | Purpose |
| --- | --- |
| `viewregularexpressionsearchfolding.s` | SAL source with the original search expression |
| `viewregularexpressionsearchfolding.ini` | Startup message preference |
| `viewregularexpressionsearchfolding_readme.md` | Description and usage |

## Install and run

1. Extract the ZIP. Keep the `.s` and `.ini` files together.
2. Compile the source with the Win32 TSE SAL compiler:

   ```bat
   sc32 viewregularexpressionsearchfolding.s
   ```

3. In TSE, open the file you want to search and run the compiled `viewregularexpressionsearchfolding.mac` (for example via TSE's Execute Macro command).
4. By default, a `Warn()` box explains the macro. Dismiss it to run the `Find()` expression.
5. Inspect the results in TSE. The view and navigation depend on the installed TSE version and its interpretation of `ixav`.

The search expression is hard-coded. To change what is matched, edit the string passed to `Find()` in the source and compile again. TSE uses its own regular-expression syntax, which differs from PCRE.

## Configuration

The macro looks for `viewregularexpressionsearchfolding.ini` beside the compiled macro. Its default is:

```ini
[viewregularexpressionsearchfolding]
silent=false
```

`silent=false` shows the introductory `Warn()` box on each run. Set `silent=true` to skip that box and run the search directly. If the INI file is missing, the macro behaves as `silent=false`.

## Background

Zhong Zhao explained that compressed view can show chosen operations and structures across a program, while code folding is one narrower application. A different language needs a different `func_expr_str` expression. The expression in this package is his C/C++ example.

## Notes

This source supplies no key assignment. Set one up in TSE if you want a shortcut. The bundled regular expression was preserved exactly from the supplied source; its matches depend on TSE's regex engine and the file being searched. Compile and run it in your own TSE installation to verify the results.
