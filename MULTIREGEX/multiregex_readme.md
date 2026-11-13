# MULTIREGEX 1.0.0.0.41

**Date:** 2026-11-13  
**Status:** Experimental disk-search diagnostic release. Pure TSE SAL; intended for TSE 4.50.33 on Windows, WSL Linux and native Linux. Source not yet compiled or executed on these hosts.

## Changes from version 1.0.0.0.40

**Both disk-mode Ask() prompts now present their most recently accepted entries first.** `Top directories` and `File masks` each use dedicated native histories, seeded from the INI only if empty. Accepted entries are promoted to the newest history position and immediately saved to `multiregex.ini`. Older entries remain accessible through TSE's Ask history. Canceling the file-mask prompt will not lose a previously accepted directory change.

No changes were made to multiline matching, disk traversal, result rendering, highlighting, or navigation.

## Previously implemented changes from version 1.0.0.0.39

1. **Fixed stale/overwritten results-screen text after scrolling.** The `HookDisplay()` callback now snapshots `VWhereY()` immediately, before calling text/attribute operations; previously it read the target row at the end of the callback.
2. **Always redraws the complete visible row**, padding short header/summary lines with spaces (and corresponding default attribute bytes) rather than leaving characters from a previously displayed long match on screen. Output is bounded by the SAL 255-character limit.
3. **No changes to regex matching, enumeration, match coordinates, result mapping, or logging**. Disk-only `dgivx`, ring-only `agivx`, and combined `adgivx` are retained.
4. The earlier zero-match report was caused by using `dgiv` rather than `dgivx`; regex option `x` is required. The user's version-39 log demonstrates successful disk searching with 240 matches. The reported extra match compared to the 239-file ring search comes from the broader disk search scope and should not automatically be treated as a duplicate.

**Testing:** Repeat the same `dgivx` query, scroll from bottom to top and back, and confirm that the summary stays intact and that no old characters remain to the right of shorter lines. Test the keyboard and mouse navigation. This release is source-patched and ZIP-verified but not compiled or tested in TSE.

## Logging configuration

```ini
[Logging]
; true: create a timestamped log (optional, disabled by default).
CreateLog=false
; Empty: create the log beside the running multiregex.mac file.
; Absolute paths are accepted. Relative paths resolve under the macro directory.
; If unwritable, falls back to macro directory, then CurrDir().
LogDirectory=
```

Set `CreateLog=true` temporarily to diagnose disk searches, and restore `false` after testing. Example log filename: `multiregex20261113210518.log`.

## Reproduce the zero-match discrepancy

- Keep the version 38 disk expression and options unchanged: `\.si.*\^File:.*\}` with `dgivx`.
- Use the same top directory and `*.dat` file mask as the failed search (e.g. `G:\WORDPROC\TSE`).
- Compare the number of matches with the prior ring-wide `agivx` baseline: 239 matches across 239 `compile.dat` files.
- Inspect the log for `ERROR`, `WARNING`, `PROBE`, and `BEGIN disk file` entries; check that `active=` matches `disk file=`. Distinguish a missing `.si`/`^File:` from a failure of the combined multiline regex itself.
- If full disk search still returns zero, test one known `compile.dat` by limiting `TopDirectories` and `FileMasks` or by running a disk search with the simpler pattern `\.si` to separate disk loading from multiline matching.

## Important limitations

The ring-only implementation from version 35 is the known stable reference. Disk and ring+disk searching remain experimental; version 39 has now been observed finding 240 disk matches with the `x` option enabled. TSE's SAL string length and source-line adaptive limit still apply. Some very long lines may be skipped, and skipped counts mean the search was not exhaustive. Archive member search is not implemented yet.

Compile via `sc32 multiregex.s`, explicitly refresh the loaded macro, and verify version `1.0.0.0.41` in both the search prompt and results header.
