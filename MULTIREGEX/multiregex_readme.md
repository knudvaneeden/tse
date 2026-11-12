# MULTIREGEX 1.0.0.0.34 — Beginning/end match highlighting

Based on version 1.0.0.0.33. Retains version 31's ring-wide small-file speed fix, version 32's right-click / CtrlAlt G navigation, and the version 33 display hook. Search algorithm, source text, results format, file/line/column and scan-time behavior are unchanged.

## Results viewer

Only the matched-text preview is colored, not the filename, line number or column number.

- The first **15** characters of the actual match preview receive `Query(HiLiteAttr)` by default.
- The last **25** characters also receive the same highlight **when the displayed match preview is not truncated**.
- The middle remains in normal `TextAttr`.
- If the result ends in `...` (the truncation marker), or fills the full 255-character results line, only the beginning is highlighted; this avoids claiming that the end of the preview is the end of the true match. A literal result ending in three dots is treated conservatively as potentially truncated.
- Very short matches may have their beginning/end highlighted ranges overlap.
- The existing cursor-row highlighting for the filename/coordinates is preserved.

## Configuration

Within `[MultiRegex]` in `multiregex.ini`:

```ini
HighlightMatchBeginning=15
HighlightMatchEnding=25
```

Both accept 1..80, with the above defaults. Results previews still use `ResultPreviewLength=240` and never alter underlying source content.

## Source highlighting

Unchanged from 1.0.0.0.33: source navigation attempts a native first-line highlight only. It does **not** yet highlight full multiline spans. Return to the results via right-click or CtrlAlt G.

## Verification

Source and ZIP are checked, but **not compiled or executed in TSE 4.50.33** in this environment.

1. `sc32 multiregex.s`, then explicitly reload the new macro in TSE.
2. Test a short result, a long untruncated result, and a result ending in `...`.
3. Confirm filenames/coordinates remain unchanged and horizontal scrolling works.
4. Recheck navigation and ring-wide `agivx` results (239 matches in the previous dataset).
5. Confirm no searching-time redraws/highlighting; close with Escape to unhook.
