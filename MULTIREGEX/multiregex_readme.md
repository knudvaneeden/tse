# MULTIREGEX 1.0.0.0.27 — TSE SAL

Repackaged from the previously tested version 24 source, retaining the version 22 process lifecycle. This release has NOT yet been separately compiled or tested using TSE SAL 4.50.33. Keep the prior working release as backup.


**Version 26 rollback release.** This package restores the *exact search, ring progress, results viewer, and temporary-buffer cleanup behavior of version 1.0.0.0.24*. Version 1.0.0.0.25 progress-display changes are not included. Source code differences from version 24 are limited to the version label. No improvement to the 1/2 → 2/2 progress display is claimed. Version 24 was tested on the two large ring files; version 26 itself has not yet been compiled in TSE.

## Changes in 1.0.0.0.27

- **Ring-file progress refresh:** Immediately before processing each ring file, display `searching ring file N/total: filename` and call the native SAL `UpdateDisplay()` to request repainting. The refresh happens once per file, not once per line, to avoid harming large-file search performance. Repainting in a synchronous Windows editor process must be verified at runtime.
- **Results-buffer cleanup:** When the interactive viewer ends via Escape or `<CtrlAltShift X>` (in the results list or after visiting a source), `EndProcess()` returns to the waiting `MR_ViewResults()` procedure. Only then are the temporary result-to-source mapping buffer and the temporary results buffer abandoned with `AbandonFile()`. A normal editable source file is never deliberately abandoned by this cleanup.
- **No search changes:** `g`, `i`, `l`, `v`, `x`, `a`, `<Ctrl L>` for normal searches, clickable source navigation, `<CtrlAltShift G>`, adaptive windows, and profiling remain as in version 23.

## Suggested tests for 1.0.0.0.27

1. Compile `multiregex.s` with `sc32 multiregex.s`. Confirm there are no errors.
2. On two small loaded files, run `agivx`. Confirm the results list displays matches from both files. The `2/2` progress message may not visibly repaint (known behavior of version 24).
3. Click a result in the second file, make and undo a temporary edit, and return with `<CtrlAltShift G>`.
4. Press Escape either in the results buffer or while visiting an editable source. Verify the results `*` buffer no longer remains in the buffer list, and the original source is still open and unmodified except for any edits you deliberately retained.
5. Verify `<Shift Tab>` works normally, MULTIREGEX can be purged, and normal non-view `<Ctrl L>` repeat is unchanged.
6. Only after passing these tests, compare against the earlier 26-million-line benchmark.

**Status:** Version 24 logic restored. Version 26 has not been separately compiled or runtime-tested with TSE 4.50.33 in this environment. Keep version 24 as a rollback copy.

## New: `a` option (all normal buffers in the TSE ring)

Use options **`agivx`** to search all loaded, visible TSE buffers from the beginning of each file, ignoring case, using the TSE regex syntax, and producing a combined view. The new `a` option sorts before the existing `gilvx` options.

Only the ring-wide **`g` + `v`** workflow is supported in this first release of `a`. The `a` and `l` options cannot be combined. Existing single-file and local block search options remain available.

- TSE's normal loaded buffers are enumerated once at search start. Hidden and system buffers (including MULTIREGEX's temporary buffers) are excluded.
- The search uses the **in-memory contents** of each loaded buffer, including unsaved edits, not disk copies.
- Each result displays `filename(line,column): expression`. A separate hidden result map stores the authoritative buffer ID, line and column.
- Left-click a result to open its original loaded buffer for **normal editing**. Save with your existing TSE binding. `<CtrlAltShift G>` returns to the same result. `<Escape>` or `<CtrlAltShift X>` exits the nested results viewer and restores normal editing keys.
- Results are a snapshot: after edits affecting line positions or matches, rerun `agivx` to refresh them. If a source buffer is closed during the session, its old result may no longer be navigable.
- Search summary at top includes total files scanned, total lines, match count, elapsed time, throughput and diagnostics.

## Safety and lifecycle

The `Process()`/`EndProcess()` cleanup from version 22 is preserved. Ring-wide searching is synchronous in pure SAL. The only temporary nested editor session is the results viewer. When Escape (or CtrlAltShift X) calls EndProcess(), control returns to the waiting macro, which disables its temporary keydefs, abandons its hidden mapping buffer, abandons its own volatile results buffer, and returns to the original file. No other * buffers or source buffers are abandoned. `<Ctrl L>` remains active for ordinary (non-view) searches as in version 22.

## Test sequence

1. Back up version 22. Unpack the four files into a test macro directory and compile `sc32 multiregex.s`.
2. Open `multiregex_test.txt`, a second source file with the same transaction expression, and a third source file with no matches. Optionally edit one file without saving it to confirm in-memory search.
3. Execute MULTIREGEX using expression `BEGIN TRANSACTION.*COMMIT TRANSACTION`, options `agivx`. Confirm results carry different filenames, correct line/column positions, and the correct file count.
4. Left-click a result in the second file, edit text, return with `<CtrlAltShift G>`, and verify the result selection is preserved. Press Escape and ensure `<Shift Tab>` (your menu) works again. Verify MULTIREGEX can be purged.
5. Also run the established `givx` and `gilvx` regressions before testing million-line buffers.

## Existing limits

The search engine is unchanged from 1.0.0.0.22; windows cannot guarantee matches longer than configured context, and physical lines longer than `AdaptiveWindow=30000` can be skipped. Results on huge files are not guaranteed exhaustive. Profiling and adaptive-window behavior are unchanged.

### Package contents

`multiregex.s`, `multiregex.ini`, `multiregex_readme.md`, `multiregex_test.txt`. Only the ZIP filename includes the version number.


## 1.0.0.0.27 - Optional source display while scanning

The new `[MultiRegex]` INI setting `ShowSourceDuringSearch=0` (default)
keeps the source file contents offscreen during long searches, avoiding
repeated visible redraws as MULTIREGEX scans each buffer. Set it to `1`
to restore version 26's on-screen source scrolling.

Implementation: TSE's native `BufferVideo()` / `UnBufferVideo()` pair.
Ring-wide `a` searches use one matched pair around the entire search and
finish buffering before opening the clickable results viewer. Single-file
searches similarly restore the display before normal editing resumes.
No extra prompts, DLLs, files searched, or regex algorithm changes.

**Test note:** Compile and test on TSE 4.50.33 first. Confirm that normal
display, Escape, <Ctrl L>, <CtrlAltShift G>, and Shift-Tab work after the scan.
The performance impact must be measured; reduced screen drawing is expected
but not yet benchmarked on the user's 16-million-line file.
