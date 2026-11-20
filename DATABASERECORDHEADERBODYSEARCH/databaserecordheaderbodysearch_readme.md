# databaserecordheaderbodysearch 1.0.0.0.35

## Validated full-scale test; logging disabled by default

Following the successful user test of two files totaling approximately 26 million lines (including the `ai` TSE-ring search), this release changes **only** the default INI setting to `logenabled=0`. To enable timestamped diagnostics again, set `logenabled=1`; entries retain the `YYYY-MM-DD HH:MM:SS` prefix introduced in version 1.0.0.0.34.

Search logic, forward-only separator navigation, results display, progress indicators, log routines and navigation remain unchanged. The runtime test was reported for the preceding version; this configuration-only release has not independently been compiled or run with TSE SAL 4.50.33.

---

# databaserecordheaderbodysearch 1.0.0.0.34

## Minimal update: timestamps on diagnostics, logging enabled

The INFO/WARN/ERROR log now prefixes **every entry** with a local date/time
`YYYY-MM-DD HH:MM:SS`, for example:

```text
2026-11-20 00:45:32 | INFO | HEADER_FOUND | file=BIBTSE.S | line=54428 | hits=1
```

`GetDate()` and `GetTime()` are called only when creating a log entry. The
search algorithm, record boundaries, output format, navigation, progress
reporting, and existing log checkpoints/periodic disk saves are unchanged.

For the next diagnostic run `logenabled=1` is the default in the INI.
`loglevel=INFO`, `logintervalheaders=250`, `logsaveinterval=100`,
`logsaveintervalseconds=30`, and `logsaveonerror=1` remain in effect.
Set `logenabled=0` again when speed is more important than diagnostics.

**Performance measurement:** Timestamped SEARCH_BEGIN and SEARCH_END entries
let you compare wall clock times, but this release does not add an elapsed-time
field, nor change the existing final line counters. A clock change during a
run will affect wall-clock differences. Existing output is preserved.

**Testing:** ZIP structure and source edits checked. Compilation/runtime
with the TSE SAL 4.50.33 compiler have not been performed here.

---

# Previous version: 1.0.0.0.33

## Performance-oriented forward-only record boundaries

**Change:** Each matching `Q.` header now uses one forward-only `LFind()` of the
existing configured, anchored **box-drawing record separator** expression.
The record is selected directly using `MarkLine(headerLineI, endLineI)`.
The BODY search still begins five lines below `A.` and is local to that
record. Only the first BODY occurrence counts, producing at most one result.
If there is no trailing separator, the final record extends to EOF.

The active scan **no longer calls** `PROCRecordSelectMark_CurrentSeparator()`,
`recogont.mac`, or `gotowist.mac`, and does not walk backward to find a
separator. The older library procedures are left as unused definitions for
source compatibility, but they are **not invoked during searching**.

**Separator correctness:** The separator pattern itself is unchanged. In
particular, ASCII `-` is different from the official box-drawing `─`. The
program does not attempt to infer a separator from its length. Data containing
actual official separators inside a BODY may still split records; such input
must be corrected. The recent successful run after correcting the ASCII
separator supports preserving this strict distinction.

**Logging:** `logenabled=0` is now the INI default, to reduce overhead. Set it
to `1` when diagnostics are needed; the version 1.0.0.0.32 periodic log-saving
settings remain available. `showmessageprogress=1` stays enabled by default.
`showsearchprogress=0` continues to avoid expensive editor redraws.

**Unchanged:** Search options (`a/l`, `i/w/x`), distinct GetFreeHistory Ask()
inputs, ring traversal, result filename mapping, two-color result highlights,
BODY preview, and `<CtrlAlt G>` / RightBtn overview navigation.

**Validation:** Static source checks and ZIP integrity only. The sc32 4.50.33
compiler is not available in this environment. First compile and test on a
small database, then compare throughput on the previously working files.

---

# databaserecordheaderbodysearch 1.0.0.0.32

## New: optional INFO | WARN | ERROR diagnostic log

The previous 1.0.0.0.29 searching and results-view behavior is preserved.
Version .30 adds a separate diagnostic log, useful for investigating unexpectedly
slow record processing with the 10-million- and 16-million-line databases.

```ini
logenabled=1
loglevel=INFO
logfilename=databaserecordheaderbodysearch.log
logintervalheaders=250
```

- `logenabled=0` disables all file logging for the fastest search.
- `loglevel=INFO` records informational checkpoints, warnings and errors;
  `WARN` records warnings and errors; `ERROR` only errors.
- Log checkpoints include `SEARCH_BEGIN`, `FILE_BEGIN`, `HEADER_FOUND`,
  `BODY_SEARCH_BEGIN`, `BODY_MATCH` or `BODY_NO_MATCH`, `RECORD_ADVANCE`,
  `FILE_END` and `SEARCH_END`. A missing `A.` or invalid BODY start is a warning.
- Each log line has a severity, stage, filename, source line and running hit
  count. The log is saved on each checkpoint, preserving evidence when a scan
  is manually interrupted.
- With `logintervalheaders=250`, detailed stages are written only for every
  250th matching `Q.` header. File start/end always have their own entries.
  For reproducing a local stall and pinpointing its exact stage, reduce this to
  `1`, with the tradeoff of more disk writes and slower performance.
- `showsearchprogress=0` and `showmessageprogress=1` remain independent of
  logging. The log file is excluded from all-files TSE-ring search.
- Logging is configured via INI only; it does not add extra Ask() prompts.

**Important:** The line in the last saved checkpoint is an instrumented stage,
not necessarily the precise physical line at which an unresponsive search is
executing. The log file is overwritten on each new run: copy it aside before
starting another diagnostic search.

**Verification:** Static source structure and ZIP integrity checked. The TSE
SAL 4.50.33 compiler is not available here; run compilation and a small
single-file diagnostic test before starting a full multi-million-line search.

---

# databaserecordheaderbodysearch 1.0.0.0.29

## Change in 1.0.0.0.29: correct KEYDEF declaration order

- Move `KEYDEF DBResultsReturnKeys` ahead of every `Enable( DBResultsReturnKeys )` call. TSE SAL requires keydefs to be declared before they are referenced.
- Fixes SAL Compiler error 2336 `(335,10) 'KeyDef' type expected` from version 1.0.0.0.27.
- Keeps existing shortcut bindings, results view and search logic unchanged.
- Compilation with TSE 4.50.33 and runtime shortcut operation still require testing.

## Previous change in 1.0.0.0.27: restore result-return shortcuts

- Define a dynamic `KEYDEF DBResultsReturnKeys` with `<CtrlAlt G>` and `<RightBtn>` instead of using standalone external-macro bindings.
- Explicitly `Enable( DBResultsReturnKeys )` after the search completes, after the modal results `List()` closes, and after jumping to a selected source record.
- This is intended to restore returning to the existing overview **without rerunning the search**. The results and mapping files remain untouched.
- For the first test, search, pick a result, press `<CtrlAlt G>`, select another result, then use `<RightBtn>`.
- If the shortcuts are still blocked, confirm the macro remains loaded and report any key-binding conflicts with other TSE macros.
- **Compilation / runtime with TSE 4.50.33 has not been tested here.**

## Previous change in 1.0.0.0.26: lightweight message-bar progress

The fast default remains `showsearchprogress=0` (no `UpdateDisplay()` for
search results). A separate message-bar progress indicator is now enabled
by default:

```ini
showmessageprogress=1
messagelineinterval=10000
```

During each source-file scan, the status bar shows the source filename,
current source line, total source lines, and accumulated matching records.
`Message()` and `IF WaitForKeyPressed( 0 ) ENDIF` run only at the start,
on reaching the configured line interval, and at the end of each scanned file.

**Accuracy / responsiveness:** This is **sampled progress** at a matching `Q.`
header, not an update after every physical line. When the header finder
passes many lines without any match, the next update can be delayed until a
matching header is found or that file ends. The counter is the actual
`CurrLine()` reached, not a percentage or a prediction. `Message()` itself
can have a cost, so leave the line interval reasonably large for very big files.

All original results-view features, multi-file mode, highlights and navigation
are retained. As with prior releases, SAL 4.50.33 compilation is not available
here and must be verified in TSE.

## Previous change in 1.0.0.0.25: default to fast search without record previews

- `showsearchprogress=0` is now the default (including when the setting is absent).
- With `0`, there are no per-match `ScrollToTop()`, `MarkLine()`, `UpdateDisplay()` or `WaitForKeyPressed(0)` calls.
- With `1`, matched records can still be displayed using the existing `progressinterval` setting.
- The final results list and all searching, highlighting, multi-file navigation and return shortcuts remain unchanged.

## Previous change in 1.0.0.0.24: fix filename helper compilation

Moved `FNDBBaseNameS()` out of the forward declaration block, kept its `FORWARD STRING PROC` declaration, and restored `FORWARD STRING PROC FNDBMacroDirectoryS()`. This corrects the `Undefined symbol pathS` compiler error. No search logic changes.

## Change in 1.0.0.0.23: filenames in the results overview

Each result row now begins with its source line number and the source filename:

```text
47: [ddddatabaseexample.txt] Q. Computer: Editor: Text: TSE ... | BODY: the ...
1880: [ddd.dok] Q. Computer: Editor: Text: TSE ... | BODY: the ...
```

The filename is also displayed for single-file searches. The original full path
and Q. header line number are kept in the separate `.map` file, preserving
correct navigation from multi-file searches. Filenames longer than 60 characters
are abbreviated in the results view only. Header highlighting ignores the new
filename prefix; BODY highlighting remains independent. Result text is limited
to the TSE SAL 255-character string size. No search-scope changes.

**Verification:** ZIP structure and source edits checked; SAL 4.50.33 is not
available in this environment, so compilation and visual behavior are untested.


## Change in 1.0.0.0.22: HEADER remains at the top, BODY line marked

During scanning, when both HEADER and BODY match and a progress refresh is due,
TSE moves to the record's `Q.` header, calls `ScrollToTop()` and then
marks the BODY line by its **absolute line number** with
`MarkLine( sourceLineI, sourceLineI )`. This does **not** move the editor
cursor to the BODY line first. Therefore the `Q.` header is at the top
and the matching BODY line is highlighted if it fits in the visible window.
The normal editor line-number margin is retained. The selected block and
cursor position are restored after `UpdateDisplay()` and
`IF WaitForKeyPressed( 0 ) ENDIF`.

**Physical screen limitation:** If the matching BODY line is farther down
than the window height, it cannot be visible simultaneously with the `Q.`
header at the top. It is still selected; the results overview retains the
matched BODY preview. This release prioritizes the HEADER-at-top rule.
The selection uses TSE's configured block color, not a separate INI color.

**Compilation:** SAL 4.50.33 is not installed here; compilation and visual
behavior require testing in TSE Pro.

## Change in 1.0.0.0.20: visible BODY line and restored line numbers

During the search, only complete HEADER + BODY matches cause an editor refresh.
For each such match, the macro temporarily selects the **entire matched BODY line** using
TSE's native `MarkLine()` and positions it at the top using `ScrollToTop()`.
It calls `UpdateDisplay()` and `IF WaitForKeyPressed( 0 ) ENDIF`, then restores
the original marked record block and cursor position.

**Why:** Previous custom `HookDisplay()` source painting could hide TSE's normal
line-number margin, and a BODY match far below the `Q.` header was offscreen.
The native line selection avoids overriding editor gutter rendering. Selection
color follows the editor's configured block-highlight attribute, rather than
`progressbodycolor`; the old `progressbodycolor` INI setting is no longer used.
The separate two-color highlighting of the results overview is unchanged.

**Important:** This version has not been compiled or run under SAL 4.50.33.
Please check native block selection, line numbers, and match navigation.

## Previous functionality


## Correction in 1.0.0.0.19

- Corrected an off-by-one error in the BODY results-list display hook: the color range now begins on the first character of the body match, rather than the second. For a search result `BODY:the`, all three characters `t`, `h`, and `e` should receive `bodycolor`. The number of highlighted characters is unchanged. This affects the overview only, not the original database or BODY search.

## Changes since 1.0.0.0.17

- While searching, a temporary `HookDisplay()` highlights the exact matched BODY substring in the source editor using `progressbodycolor` (default 242, green on a light background). This uses the actual line, column, and length of `GetFoundText()` before the cursor is repositioned at the matching `Q.` header.
- The HEADER match receives `headercolor` where the header expression can be located in the visible header line.
- The hook is installed immediately before `ScrollToTop()` and `UpdateDisplay()` and removed after `WaitForKeyPressed( 0 )`, so no extra screen refresh is introduced. Existing body/result highlighting remains independent.
- This is a source-display-only effect: the database and results file are unchanged. Regex header coloring may cover an approximate length (length of the pattern), whereas BODY match length is exact.

## Existing behavior (from 1.0.0.0.17)

- Separate `headersearchoptions` and `bodysearchoptions` INI defaults and Ask() inputs with separate persistent `GetFreeHistory()` identifiers.
- Header scope `a` scans the TSE file ring; `l` limits search to the current file (default if neither is specified). `a` and `l` together produce a warning. `a` and `l` in BODY options produce a warning; the BODY is always restricted to its record.
- `i`, `w`, and `x` independently apply to HEADER and BODY. Header always uses TSE regex mode internally to recognize the `Q.` line prefix.
- BODY search begins **five lines below `A.`** and uses only the first matching occurrence in each qualifying record.
- The results display hook now locates the BODY marker using `BODY:` instead of relying on the entire separator string. Header and BODY foreground attributes can be set separately in the INI.
- `ScrollToTop()` is applied to the matching `Q.` header during successful-match progress updates, and to the `Q.` header when navigating from the list; the `.map` file stores the header line number and source filename.
- Expensive `UpdateDisplay()` calls happen only for full HEADER+BODY matches, at the configurable `progressinterval`. Each is followed by `IF WaitForKeyPressed( 0 ) ENDIF`.
- `<CtrlAlt G>` and `<RightBtn>` reopen the results list from a selected result. The macro must remain loaded.

## Usage

Compile `databaserecordheaderbodysearch.s` using `sc32`, open a Q&A database file and press `<F12>`. The prompts ask for header pattern, body pattern, header options, body options, and results filename. The results list uses the configured colors and displays the matched BODY text followed by up to `bodyaftermax` characters, taken strictly after the match on that line.

Example: `headersearchoptions=aiwx` with `bodysearchoptions=ix` searches all TSE-ring files, whole-word ignoring case in headers, and case-insensitive regex in bodies. Use `liwx` or `iwx` for a single file. `a` and `l` are mutually exclusive.

The macro stores the results file and `.map` next to the `.mac` when configured with a relative path. The first source file remains the source for the single-file search.

## Validation

The ZIP and procedure structure were checked. A local TSE SAL 4.50.33 compiler is not available; compile and runtime-test in TSE before using the macro on a large database. In particular, verify `HookDisplay` color behavior and mouse RightBtn on your TSE installation.


## 1.0.0.0.22: All-files (`a`) ring traversal fix

The previous version used `NextFile()` after the scanning procedure had switched
to the results and map files. This could prevent remaining database files from
being visited. This version keeps both output buffers open, counts the ring **after** opening the results/map
buffers, skips those buffers as search sources, and explicitly restores the
currently scanned buffer ID before calling `NextFile()`.

**Regression test**: Load two Q&A database files in the TSE ring; use
HEADER `TSE`, BODY `the`, HEADER options `ai`, BODY options `i`. Results
should include matches from both source files. Follow a hit from each file,
then use CtrlAlt G to reopen the combined results. Also compare with
single-file options `i`/`i` to confirm the original behavior remains intact.

This release was checked for ZIP integrity and source structure, but has not
been compiled or executed under TSE 4.50.33 in this environment.


## Version 1.0.0.0.29 - Return shortcuts

Restores the direct macro key bindings used by the earlier working version:
`<CtrlAlt G> PROCDBShowResults()` and `<RightBtn> PROCDBRightBtn()`.
Removes the dynamic `KEYDEF`/`Enable()` layer introduced in 1.0.0.0.27 and
1.0.0.0.28. Right-click can reopen the last results whenever results are
available; it no longer depends on the transient `dbViewHitGB` flag.
A list-open guard prevents the shortcut from recursively opening the modal
overview. The search logic and message-bar progress are unchanged.

Compile with your TSE SAL 4.50.33 compiler, and test both shortcuts after
selecting a result. Compilation and runtime testing have not been performed
in this environment.


## Version 1.0.0.0.32

Corrected SAL compiler error 2302 at the log-file collision check: the `.map` path is now first assigned to a local STRING before filename comparisons. No search behavior changes.


## Version 1.0.0.0.32 — periodic durable diagnostic log

`logsaveinterval=100` saves the log buffer after 100 newly written entries.
`logsaveintervalseconds=30` also saves accumulated entries when 30 seconds
have elapsed **at the next reachable checkpoint**. `logsaveonerror=1`
forces an immediate save after each ERROR message. At search start, at
sampled `BODY_SEARCH_BEGIN` checkpoints, file completion, and search end,
the log is also saved explicitly. The previous disk contents are retained
between saves within the same search; a new search starts a new log.

These are limits on unflushed entries, **not** a background timer. If SAL
is blocked within a single `LFind()` operation, no additional SAL logging
or disk save can execute until that operation returns. To diagnose the
location more precisely, use `logintervalheaders=1` for a short test.
The logger never changes the HEADER/BODY search logic or result mapping.
