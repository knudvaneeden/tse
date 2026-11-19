# REGEXENGINE 1.0.0.0.23

Standalone pure-TSE-SAL regex engine with extended multi-line search and native `Find()` optimizations.

## Release changes

- Preserves the previously tested fast native two-endpoint search and 59 legacy automated compatibility checks.
- Adds **16 automated Local selection-boundary predicate checks**; total **75** automated checks.
- Updates source, INI, includes, test runner, diagnostic log header, and docs to version **1.0.0.0.23**.
- Uses the required include syntax `#include ["regexengine.inc"]` and `#include ["regexengine_test.inc"]`.
- The `.inc` files are included when `regexengine.s` is compiled; compile only the `.s` file.

## Running tests

Keep all sources and the `tests/` folder together, compile with `sc32 regexengine.s`, set `[Tests] RunTests=1` in `regexengine.ini` beside `regexengine.mac`, and run the macro. The report is `regexengine_test_report.txt` beside the macro. Set `RunTests=0` for interactive searches.

## Important distinction about the new Local tests

The 16 added checks run `RxLocalSpanOK()` using **synthetic marked-block coordinates**. They exercise the engine's actual boundary predicates for line, inclusive/noninclusive character, and column blocks. They do **not** set a real TSE selection and therefore do **not** prove native `Find(..., 'l')` or TSE `Query(BlockBegLine)` integration. Test actual marked-block searches manually before treating Local mode as validated end-to-end. The 59 existing tests still use the real regex parser and matcher.

## Supported options

`i` ignores case for literal text; bracket classes remain case-sensitive. `m` enables synthetic newline matching across lines; `l` restricts matching to a marked block (experimental). `v` (View) lists multiple hits with contextual source previews. The `x` search-mode letter is accepted for familiarity but regex compilation is already the engine's default.

## General multi-line example

`Ampersand{.|\n}*manager`

Matches the nearest following `manager` after `Ampersand` across arbitrary characters and line boundaries. For this universal-gap pattern, the native two-endpoint optimizer avoids SAL scanning of intervening millions of characters. `@` uses maximum closure and selects the last reachable suffix in the optimized form.

## Limitations

- The Local mode is experimental and needs marked-block interaction testing, including native prefix searches.
- The engine may fall back to slower SAL matching for regex forms that cannot be proven safe for native search.
- The 75-case suite is not proof of complete compatibility with all TSE semantics, particularly captures and replacements.
- This release has not been compiled or run using SAL compiler 4.50.33 in this environment; previous REGEXENGINE releases passed the 75-case suite in the user’s TSE installation.

## Portability and naming

All resources are resolved against `CurrMacroFilename()`; not `CurrDir()`. Variables follow the suffix convention: local `I`/`S`/`B`, globals `GI`/`GS`/`GB`. No external DLLs, Python, or PowerShell are used by the program.


## All-files search (`a` option) — 1.0.0.0.23

`a` searches **all ordinary files in the current TSE file ring**, starting with the current file. Without `a`, the engine searches only the current file. The first matching file remains active and its match-start (or `\c`) position is selected. If no match is found, the original file and cursor are restored. Hidden and system buffers, including REGEXENGINE's temporary storage, are excluded.

Combine `a` with `i` and `m` (e.g. `aim`). **`a` and `l` together are rejected**: Local refers to a marked block in the current file. `v` is implemented with contextual results and a TSE `HookDisplay()` highlighting callback. The 75 regression tests do not directly inspect live ring traversal or rendered pixels; both have been manually exercised in earlier releases, but highlighting in this new release requires verification.

To test: open two distinct files, put the target expression only in the second, select the first, run with `aim`, and verify the editor switches to the second and navigates to the match. Then use a nonexistent expression and verify the original file/cursor are restored.


## Experimental v (View) option (1.0.0.0.23)

Use `imv` to list all nonoverlapping matches in the current file, or `aimv`
for all ordinary ring files. Native two-endpoint and prefix searches remain
active for suitable patterns. `v` builds a temporary TSE SAL result buffer,
shows `List()`, and uses the selected row to navigate to its source buffer.
Press Enter on a result; after the source-location message, OK reopens the
list; Escape exits the list. This version does **not yet** implement
free source editing or Ctrl+Alt+Shift+G to return from an arbitrary edit.
Clicking follows TSE's native `List()` selection behavior; exact mouse
behavior should be tested with SAL 4.50.33.

Results are nonoverlapping; zero-length matches advance at least one
position. `MaxResults` in `[View]` defaults to 2000 to bound result collection.
An extremely common unanchored expression or a no-literal-prefix expression
can still be slow on large files. The highlighting callback added in version 1.0.0.0.23 is not yet runtime verified.
`a` + `l` remains unsupported.

## View (`v`) context previews — 1.0.0.0.23

Instead of showing only the first match word, View lists text preceding and following the start position. For matches spanning several lines it also shows a snippet near the last match position, separated by ` ... `. For example:

```text
c:\TEMP\ddd.txt  4:2 - 8:10  Ampersand ... manager
```

Only the first and last lines are read for each preview, so this change does not traverse enormous spans between endpoints. Existing View navigation and 75 test cases are unchanged. Run the automated tests with `[Tests] RunTests=1`, then set it to `0` and manually test `imvx` and `aimvx` with multi-line results.

### Syntax highlighting status

The results list uses TSE `HookDisplay()` to highlight the visible matched characters with your configured `HiLiteAttr` color. On a multi-line match, the visible portions on both endpoint lines are highlighted; an ellipsis represents the intervening gap. The surrounding preview text remains in the ordinary list text color. The selected row retains cursor-line styling for unhighlighted text. No source files are modified. The display hook is installed only during `List()` and immediately removed afterward. The existing source editor syntax highlighting is preserved.
This requires a separate TSE display hook and testing with SAL 4.50.33.
The context preview is provided now without altering the verified matcher.

## Results-list match highlighting — v1.0.0.0.23

A TSE `HookDisplay()` callback draws each result row and applies the editor's `HiLiteAttr` to the exact visible match portions. Each result stores its highlight positions in private buffer variables, so the renderer performs no new regex searches, does not scan multi-million-line spans, and does not modify source files. For a multi-line match the start and end segments are both highlighted; the ` ... ` separator is not. `UnhookDisplay()` restores TSE's display mode as soon as the list closes.

**Manual test:** with `RunTests=0`, use `imvx` on `Ampersand{.|\n}*manager` in a file containing repeated pairs. Verify both words show your configured highlight color within the list, other text does not, selection remains usable, and Enter and Escape work. Repeat with `aimvx` across two files.

**Verification:** The established 75 automated search tests are unchanged and do not inspect screen colors; SAL compilation and visual behavior require local TSE 4.50.33 testing.
