# MULTIREGEX 1.0.0.0.31 — TSE SAL

Based on version 1.0.0.0.30. Optimizes chunk construction for small source buffers in ring-wide (`a`) searches, without changing the regular-expression engine, character-window limit, source position mapping, overlap calculation, results, keyboard/mouse navigation or cleanup.

## Root cause and fix

The previous search used a hard limit of **256 physical source lines per chunk**, even when the lines were very short. With `MaximumWindow=4000` and `Overlap=2000`, a 256-line chunk shorter than 2000 characters could force advancement by **only one line**, copying almost identical chunks over and over. This explains why the 239-file search built ~378,502 chunks from only 439,447 lines, making planning and copy/flatten dominate runtime.

Version 31 allows up to **4096 physical source lines** within the same `MaximumWindow`/`AdaptiveWindow` byte budget for ring-mode files of at most 10,000 lines. For large files and non-ring searches, the established 256-line cap remains unchanged.

New `[MultiRegex]` INI setting:

```ini
; Limit for files of <=10000 lines in a ring-wide search. Range 256..4096.
RingMaxChunkLines=4096
```

Set `RingMaxChunkLines=256` for a strict A/B comparison against version 30. The previous settings, including `FastPlan=0`, `Overlap=2000`, `MaximumWindow=4000`, `ShowSourceDuringSearch=0` and `ResultPreviewLength=240`, are retained.

The displayed macro version has been corrected in both `Ask()` and the search-results header to **1.0.0.0.31**.

## Testing

1. Compile `sc32 multiregex.s`, explicitly reload `multiregex.mac` into TSE, and confirm the version 31 search prompt and results header.
2. Repeat the 239-file `compile.dat` search with `agivx`; compare **239 matches** and 439,447 lines with the previous run, as well as the number of chunks and elapsed time.
3. Set `RingMaxChunkLines=256`, reload and rerun as an A/B control, if desired.
4. Test BIBTSE.S with `givx` (single file) to ensure the 256-line large-file path remains intact.
5. Verify Enter/left click, CtrlAlt G, Escape and editable source navigation.

**Status:** Source changes and packaging checked; no `sc32` compiler is available in this environment, so compilation and runtime speed/correctness must be confirmed on TSE 4.50.33.
