# REGEXENGINE 1.0.0.0.23 — automated test instructions

1. Extract all files including the `tests` directory into a single project directory.
2. Verify `regexengine.s` contains `#include ["regexengine.inc"]` and `#include ["regexengine_test.inc"]`.
3. Compile only `regexengine.s`: `sc32 regexengine.s`.
4. In `regexengine.ini` beside `regexengine.mac`, set `[Tests] RunTests=1`.
5. Run `regexengine.mac` inside TSE 4.50.33.
6. Read `regexengine_test_report.txt` in that directory. Expected number of executed tests: **75** (59 regex tests + 16 synthetic Local boundary tests).
7. Set `RunTests=0` for normal interactive searches.

The newly added Local checks simulate coordinates and call the real boundary predicates. **They do not create TSE marked blocks**; manual real-mark tests remain necessary. Check a line block, inclusive/noninclusive stream block, column block, no selected block, a match beginning inside but ending outside, and fast native `Find()` behavior with `l`.

No testing result is assumed in advance. Please provide the generated report and any compiler messages.


### Manual editor-ring tests for `a` (1.0.0.0.23)

1. Set `RunTests=0`. Open two normal TSE files with different text. Start on the first file, search with `aim` for a literal present only in the second. Verify that a match opens the second file at the correct position.
2. Repeat with a missing literal; verify the original file and cursor are restored.
3. Repeat without `a`; verify only the current file is searched.
4. Enter `alm` with a marked block; verify an explanatory warning rather than a search.
5. Run the original 75-test suite using `RunTests=1`; all should still pass. The suite currently contains no live editor-ring tests.


### Manual View tests (v1.0.0.0.23)
1. Set RunTests=0. Search `Ampersand` using `imv` in a file containing multiple hits.
2. Check the results list, select Enter and check source navigation. OK should return to list; Escape should exit.
3. Repeat with `aimv` across two editor-ring files.
4. Try `^$` with `mv` (zero-length matches must terminate).
5. Repeat the original 75 automated cases with RunTests=1.

## Manual View preview regression — 1.0.0.0.23

With `RunTests=0`, create three occurrences of `Ampersand` followed by `manager` on later lines. Search for `Ampersand{.|\n}*manager` with `imvx`. Confirm each row contains a context snippet from both endpoint lines, and Enter still navigates to the correct buffer. Repeat with `aimvx` over two ring files.

Note: custom List() rows currently do not color individual matched characters; verify the source-file syntax highlighting remains intact on navigation.

## Manual list color checks — v1.0.0.0.23

1. Run the existing 75 tests, then set `RunTests=0`.
2. Search `Ampersand{.|\n}*manager` with `imvx`. Verify both endpoint substrings have `HiLiteAttr`, while the separator and context do not.
3. Select different list rows and press Enter; return using OK. Confirm the list highlighting is reconstructed.
4. Repeat with `aimvx` for two open files, then Escape. Ensure the source editor displays normally.
5. Search a single-line literal like `Ampersand` and verify only that substring is colored.
