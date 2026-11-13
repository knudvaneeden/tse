# MULTIREGEX 1.0.0.0.38

**Date:** 2026-11-13  
**Status:** Experimental cross-platform disk-search update. Compile and test with TSE 4.50.33 on Windows, Linux under WSL, and native Linux (Ubuntu).  
**Implementation:** Pure TSE SAL. No external DLL, PowerShell, shell commands, or Python.

## Changes since 1.0.0.0.37

- Added combined **ring + disk** mode `adgivx`. The existing disk-only `dgivx` and ring-only `agivx` modes remain available.
- In combined mode, search a snapshot of user-owned normal TSE ring buffers first. Then recursively visit on-disk files using the same directories, masks and exclusions as disk-only mode.
- A disk-discovered file whose buffer ID was in the original ring snapshot is **not searched again** in combined mode. This avoids duplicate matches when an open file also falls under `TopDirectories`.
- The private results map distinguishes native ring matches (real buffer IDs) from disk-only matches (ID zero plus path). Enter/left-click navigation uses the corresponding source; `<CtrlAlt G>` / right-click still return to the same results view.
- The search, chunk planner, preview highlighting, video buffering, Ask() histories, and portable filesystem helpers remain unchanged. No archive-content search yet.
- Corrected visible version strings to 1.0.0.0.38.

**Important:** This is a source-level experimental release. The package is checked, but not compiled or run in TSE 4.50.33 in this environment.

## Disk search

Use `dgivx` for recursive disk-only searching, `adgivx` for disk **plus** all normal files loaded in the TSE ring, `agivx` for ring only, or `givx` for the current file. Both disk modes prompt for root directories and file masks. With `adgivx`, a ring buffer is scanned even if it falls outside the disk roots or does not match the filename masks. If that file is also found on disk, its ring results take precedence and it is not searched again. Option `l` cannot be combined with `a` or `d`. Disk/ring modes require `g` and `v`.

```ini
[MultiRegex]
TopDirectories=.
FileMasks=*.s;*.si;*.txt;*.dat
Recursive=1
ExcludeDirectories=.git;node_modules
DiskMaxFiles=10000
DiskMaxDepth=32
```

### Platform-specific path examples

| Host | `TopDirectories` example |
|---|---|
| Windows | `F:\BBC\TAAL` |
| Linux under WSL | `/mnt/f/BBC/taal` |
| Native Ubuntu Linux | `/home/user/projects` |

Use host-native directory names and matching case on Linux. Windows drive-letter paths do **not** automatically map to `/mnt/...` in WSL. To work across hosts without editing the INI, use `TopDirectories=.` and start TSE in the intended directory. Semicolons separate roots and masks, so a literal semicolon in a directory name cannot be represented by this setting.

## Suggested test sequence

1. On **Windows**, run `sc32 multiregex.s`, explicitly reload `multiregex.mac` in TSE, and test `dgivx` with a small directory containing nested `.txt` files.
2. On **WSL Linux**, compile the same `.s` with the Linux `sc32`; use `/mnt/f/...` paths or `.`. Test recursion, results, and Enter/left-click navigation.
3. On **native Ubuntu Linux**, compile with Linux `sc32`, use a local `/home/...` tree, and repeat the test with case-sensitive filenames.
4. On each host, check that `<CtrlAlt G>` and right-click return to results; Escape ends the search session; previously loaded editor files are preserved. Compare `agivx`, `dgivx`, and `adgivx` with an overlapping test: one source file open in the ring and inside the disk root, one ring-only file outside the root, and one disk-only file. Expect exactly one search for the overlapping file in `adgivx`.
5. Only then expand testing to large directories. Keep 1.0.0.0.35 as the stable pre-disk-search baseline.

## Present limitations

This is a **source-level portability improvement, not verified cross-platform compatibility**. No TSE `sc32` compiler is available in the packaging environment, so compilation and runtime verification must occur on the three target hosts. Directory symlinks are not followed, avoiding cycles; some files can be skipped when the path is too long or inaccessible. Disk files discovered more than once from overlapping masks or roots may still be searched more than once. Combined mode only deduplicates files already present in the initial TSE ring snapshot. Archive contents are not searched. The disk scanner uses temporary buffers to hold directory and file queues. The current implementation's disk-search file and queue caps remain unchanged.
