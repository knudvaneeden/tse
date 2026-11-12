# MULTIREGEX 1.0.0.0.32 — TSE SAL

Based on 1.0.0.0.31, preserving its small-file ring-wide performance optimization, search algorithm, INI parameters, match preview, and buffer cleanup.

## New in version 32

- While viewing an opened **source file**, `<RightBtn>` calls the existing `MR_ReturnResults()` routine, exactly as `<CtrlAlt G>` does.
- The results list continues to use `<Enter>` or `<LeftBtn>` to open an editable source file.
- `<Escape>` still closes the results session; `<CtrlAlt G>` still returns to the results.
- Version references in the `.s`, `.ini`, and README were updated to 1.0.0.0.32.

## Highlighting status

The separately requested colored highlighting of match previews and source spans is **not implemented** in this package. It requires a verified TSE display-hook or non-destructive highlighting method; adding temporary marks without preserving existing user marks could damage editor state. This release is a focused, low-risk mouse-navigation improvement.

## Testing

1. Compile `sc32 multiregex.s`, and **explicitly reload** the new `.mac` in TSE.
2. Search with `agivx`, enter a result using `<Enter>` or left click, and right-click inside the source file to return to the same results row.
3. Check `<CtrlAlt G>` and `<Escape>` still work and source text stays editable.
4. Test on Windows TSE 4.50.33, and on Linux TSE if mouse support is enabled in your terminal.

**Status:** Package checked, not compiled or run in TSE (no `sc32` available here).
