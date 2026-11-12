# MULTIREGEX 1.0.0.0.30 — TSE SAL

Built from version 1.0.0.0.29. The only functional change is removal of forced whole-screen `UpdateDisplay()` inside the ring search loop. With `ShowSourceDuringSearch=0`, the source file contents remain buffered while `Message()` reports the current file in the message bar. Search algorithm, result previews, navigation and cleanup are unchanged. Whether TSE 4.50.33 paints each message immediately under `BufferVideo()` must be confirmed by runtime testing.

## Existing INI settings

```ini
[MultiRegex]
ResultPreviewLength=240
```

Valid range is 20–240, default 240 (values outside this range revert to 240). Version 28 used a fixed 72-character preview. The preview uses `GetFoundText()` immediately after `LFind()`, replaces control characters with spaces, and uses `...` if shortened.

**Note on SAL strings:** A result row is still at most 255 characters. The existing filename and `(line,column): ` or `line,column: ` prefix remains complete; the matched-text preview uses the **remaining** space on the same line. Therefore a very long full filename may reduce the displayed preview below 240 characters. No results are split into multiple lines, ensuring the existing row-to-source buffer mapping remains correct. `GetFoundText()` is itself limited by SAL's 255-character string size, so this is a preview rather than a guarantee of the full multiline match.

## Test

1. Compile `sc32 multiregex.s` on TSE 4.50.33.
2. Test `\.si.*\^File:` with `givx` on a known `compile.dat`, or `agivx` across the loaded version files.
3. Confirm results retain filename, line, column and now show up to 240 preview characters (space permitting).
4. Verify Enter and left-click visit the editable source, CtrlAlt G returns to the same result, Escape cleans up temporary buffers and restores the normal keys.
5. Compare match counts/timing with 1.0.0.0.28; the search algorithm has not changed.

## Package

`multiregex.s`, `multiregex.ini`, `multiregex_readme.md`, `multiregex_test.txt`. Only the ZIP filename contains the version.

This source was checked and packaged, but cannot be compiled with the Windows TSE SAL compiler in this environment.

## Display-only change from v29

- A single `UpdateDisplay()` occurs before the outer `BufferVideo()` is started, while the blank results buffer is active.
- Each file is selected and scanned without another `UpdateDisplay()`. Progress is reported through `Message()` only.
- `UnBufferVideo()` is called once at the end, before entering the results viewer.
- Test with `agivx` and `ShowSourceDuringSearch=0`: the large editor pane should stay still; the message bar should ideally show the latest file progress. If TSE buffers messages as well, report this behavior; no unverified low-level screen API was introduced.
