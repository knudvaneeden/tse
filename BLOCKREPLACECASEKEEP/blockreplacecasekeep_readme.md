# BLOCKREPLACECASEKEEP — 1.0.0.0.2

## Purpose

`FNBlockReplaceCaseKeepB()` is a self-contained TSE SAL function for **case-preserving replacement only inside a marked block** in the current file. Based on Carlo Hogeveen's original `ccRepl.s` (30 June 1999).

Source file: `blockreplacecasekeep.s`. Configuration: `blockreplacecasekeep.ini`.

## Installation and usage

1. Put the three unpacked files together in a directory on TSE's `TSEPath` (or one of its searched locations).
2. Compile `blockreplacecasekeep.s` using the TSE SAL compiler (`sc32 blockreplacecasekeep.s`).
3. Mark a block in the current file. Run the compiled macro, or integrate the function into your SAL library and call `FNBlockReplaceCaseKeepB()`.
4. Enter **Search for**, **Replace with**, and search options. The most recent successful response to each prompt appears as the initial value on the next invocation, even after restarting TSE, because it is saved in the INI file.

### Function

```sal
integer replacements = FNBlockReplaceCaseKeepB()
```

Returns the number of performed replacements (`0` if no marked block, cancelled, or no replacements). `Main()` is a small convenience wrapper for direct execution; remove it when including in a combined source file that already has a `Main()`.

## Scope and options

- **`l` means Local (marked block)**; it is always forced by the function.
- **`b` means Backwards**, **not Block**. This implementation removes `b` to maintain forward traversal.
- `i` (ignore case) is the default option; `n` performs replacements without individual confirmations. Other ordinary non-regex `lFind` options are passed through.
- `g` (global), `+` (wrap/continuation control) and numerical count suffixes are handled internally. `g` is removed to ensure block-only behavior. A numerical count optionally limits the number of attempted matches.
- `v` (compressed view) and `x` (regular expressions) are rejected.
- This is **not a multiline-regex engine**: matches are found one line at a time, but the operation can traverse multiple lines within the block.

Interactive confirmation keys: `Y` yes, `N` skip, `O` replace only this one, `R` replace the rest without prompting, `Q` quit (Escape also quits).

## Case-preserving example

Search `road`, replace `path` (with option `i`):

| Input | Output |
| --- | --- |
| `road` | `path` |
| `Road` | `Path` |
| `ROAD` | `PATH` |
| `rOaD` | `pAtH` |

When replacement text is longer than a match, the last matched character's case controls any additional characters.

## INI persistence

`blockreplacecasekeep.ini` contains `[History]` values `SearchFor`, `ReplaceWith`, and `Options`. Each accepted `Ask()` response is saved immediately with TSE's `WriteProfileStr()`; the existing value is loaded with `GetProfileStr()` before prompting. Named TSE history lists additionally support scrolling through earlier in-session entries. TSE's own persistent-history setting may preserve those lists between sessions; INI persistence independently restores the **last answer**.

The function first searches for the INI along `TSEPath` and common search locations; if it cannot find one, it uses `StartUpPath` as the fallback. Keep the INI writable if you want history saved. No external helper program or DLL is required.

## Limitations / test status

- Marked blocks must be in the **current** buffer.
- Stream, line and column block behavior—especially column blocks with length-changing replacements—should be verified in TSE 4.50.33 before use on irreplaceable data.
- Searching does not match an expression spanning a line boundary.
- No live compiler/runtime test was performed for this release. Back up important files before batch replacement.

## Release notes — 1.0.0.0.2 (2026-11-13)

- Renamed to `blockreplacecasekeep.s`.
- Added companion `blockreplacecasekeep_readme.md` and `blockreplacecasekeep.ini`.
- Added persistent, pre-filled `Ask()` defaults for the search string, replacement string, and options.
- Added named, separate Ask history lists.
- Removed backwards (`b`) as well as global (`g`) options to keep forward, local searches.
