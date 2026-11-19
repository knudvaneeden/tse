# databaserecordheaderbodysearch 1.0.0.0.24

## Change in 1.0.0.0.24: fix filename helper compilation

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
