# FILEFIN2TSE — native TSE SAL filename finder

**Version:** 1.0.0.0.11 (nested external archives)  
**Date:** 2026-11-13  
**Reference code:** FILEFIN2 1.0.0.0.84 and GREPZIPTSE 1.0.0.0.84

## Purpose

FILEFIN2TSE is a new TSE SAL `.si` implementation of the FILEFIN2 filename finder. It does not call `ff.dll`, `zip.dll`, or PowerShell. It uses TSE SAL for DOS wildcard matching, results display, and ZIP/JAR central-directory inspection. It reuses GREPZIPTSE's existing cross-platform shell-based filesystem enumeration and optional external archive extraction (TAR/TGZ via `tar`, RAR/7z via configured tools); this is not a wholly self-contained runtime for those archive types.

## Initial implementation

- Case-insensitive DOS filename masks (`*`, `?`); the mask is compared to the leaf filename, including when the member is in a subdirectory in an archive.
- Recursive filesystem enumeration of one or more semicolon-separated directory specifications.
- Native ZIP/JAR central-directory traversal, including nested ZIP/JAR members with stored (method 0) or DEFLATE (method 8) payloads, using native TSE SAL. The existing DEFLATE decoder is used only for nested archive bytes.
- Result-view syntax highlighting now colors filename portions of plain-path results with the TSE highlight attribute, rather than looking for obsolete GREPZIPTSE `(line,column): [match]` rows.
- Optional TAR/TGZ, 7z and RAR traversal using GREPZIPTSE's existing external-command workflow.
- Results include matching paths and archive member paths in `archive::member` format, plus the original viewer's Enter / left click / Ctrl+Alt+G / Escape workflow, a timer, and optional logging.
- Uses independent search histories. Latest accepted search mask and directory specification are pre-filled in `Ask()`.
- Supports TSE 4.50.33 on Windows and Linux, based on the GREPZIPTSE source, **subject to user compile/runtime tests**.

## Limitations in 1.0.0.0.9

- Version 1.0.0.0.2 was compiled and runtime-tested successfully by the user, including Enter, left-click and right-click navigation. **Version 1.0.0.0.9 is not yet compiled or runtime-tested with `sc32`**; prior version 1.0.0.0.3 was runtime-tested successfully, including highlighting and archive navigation.
- ZIP64 central-directory offsets and split archives are not supported. ZIP/JAR member names longer than 220 bytes are skipped; non-ASCII bytes may appear as `?`.
- ZIP/JAR nesting is limited to 4 levels and 200,000 uncompressed bytes per nested member. ZIP64, encrypted members, and compression methods other than stored/DEFLATE are not decoded.
- Nested ZIP/JAR member selection currently opens the original containing ZIP file (the displayed `::` path tracks nesting, but does not yet provide member-level extraction/navigation).
- Selecting a ZIP/JAR member opens its **containing archive**, not the individual member file. For extracted external archive members, the extracted file may be opened.
- This first release does not yet reproduce FILEFIN2's original size/date/time columns, its exact Yes/No menu UI, or all original INI validation behavior.
- The inherited GREPZIPTSE decoder is now used specifically to obtain bytes for nested DEFLATE ZIP/JAR members; normal filename-only archive listing does not decompress contents.
- Original filesystem enumeration uses `cmd.exe` on Windows or `/bin/sh` on Linux. External archive handling also uses operating system commands.

## Install and test

1. Extract this ZIP to a new directory. Keep `filefin2tse.ini` beside the compiled macro.
2. Compile with **`sc32 filefin2tse.si`**, not `.s`, because indexed SAL integer arrays are used.
3. Run the `filefin2tse` macro in TSE 4.50.33. Test first with a small directory and mask `*.txt`, `SearchArchives=no`.
4. Then test with a directory containing `sample_archives/filefin2tse_test.zip`, `SearchArchives=yes`, mask `*.txt`.
5. Search `*needle*` against the `sample_archives` directory with `SearchArchives=yes`; expect two `needle_found.txt` results under `inner_stored.zip` and `inner_deflated.jar`. Both are nested under `filefin2tse_nested_test.zip`.
6. Check Enter/left click, Ctrl+Alt+G return, right click, Escape, history prefill, version header, result counts, timer, and logging.
7. Record any SAL compiler messages with line and column and send them for the next correction.

## Version 1.0.0.0.11 — compilation fix (2026-11-13)

Moved archive-type helper functions before their use in `ProbeZipCurrent`, fixing SAL error 2335 at line 2014 (`IsSupportedArchiveName` undefined). No change to the nested archive algorithm.

## Version 1.0.0.0.10 — nested TAR/TGZ/RAR/7Z (2026-11-13)

- Extends native ZIP/JAR central-directory recursion to dispatch nested .7z, .rar, .tar, .tgz, and .tar.gz members. Their ZIP payloads are decoded natively, staged byte-for-byte into temporary files, then processed with the already configured external extractors.
- Keeps strict DOS case-insensitive filename matching: an archive name matching the mask never causes a nonmatching member to be returned.
- Existing ZIP/JAR recursion, archive extractors, result navigation, logs and INI settings are retained.
- Expected regression test: filename mask `grepzip_sample_archive.txt`, starting directory `F:\BBC\taal\PROJ0200\`, search archives Yes. Look for 4 entries beneath `proj02001.0.0.0.516.zip::GREPZIP/grepzip_sample.{7z,rar,tar,tgz}`. The earlier v0.9 isolated test yielded 8 entries and omitted these four; the new target is 12 entries for that same unchanged directory.
- **Unverified build:** requires compilation using `sc32 filefin2tse.si` and Windows runtime test. Staging binary data relies on TSE SAL `fWrite()` preserving embedded NUL bytes; inspect extraction warnings if the new four entries are absent. Nested captured members are subject to the pre-existing `FFT_MAX_NESTED_BYTES` limit (200000 bytes).

## Version history

| Version | Date | Changes |
|---|---|---|
| 1.0.0.0.9 | 2026-11-13 | Highlight filename components in result rows; recursively inspect stored/DEFLATE ZIP/JAR members with native SAL capture and depth/size limits |
| 1.0.0.0.2 | 2026-11-13 | Renamed reserved SAL keyword `pos` to `zipOffset` inside `ProbeZipCurrent()` to resolve compiler error 2342; no behavior changes |
| 1.0.0.0.1 | 2026-11-13 | First experimental native SAL filename-matching adaptation; ZIP central directory listing and inherited results navigation |

## Version 1.0.0.0.9 — RAR/7Z compatibility and diagnostics

- Uses `[ArchiveTools]` `SevenZipExecutable` and `RarExecutable` keys from FILEFIN2 1.0.0.0.84 and GREPZIPTSE 1.0.0.0.84. Windows defaults: `C:\Program Files\7-Zip\7z.exe` and `C:\Program Files\WinRAR\Rar.exe`.
- Strip optional surrounding double-quotes before checking configured executable existence.
- Prefer Rar.exe for RAR extraction when present; fall back to 7z.exe. For 7Z use 7z.exe. TAR/TGZ still use OS `tar`.
- Log missing executable and extractor error status; show external archive extraction counters in results footer (successful extractions, failures, RAR and 7z attempts). Log details require `CreateLog=true`.
- Accept FILEFIN2 `[SearchDefaults] filename=` as a higher-priority search default, while still accepting legacy `SearchString=`.
- Preserve the working ZIP/JAR scanning, result highlighting and mouse/keyboard navigation.

For your comparison, set `filename=*grep*`, `topdirectories=f:\bbc\taal\`, `searcharchives=yes` in INI (or enter those values at the prompts). The previous observations were FILEFIN2 400 matches in 00:50.62 and FILEFIN2TSE 1.0.0.0.3 369 matches in 04:45.90. This release has not yet been run to determine the new count.


## Version 1.0.0.0.9 (2026-11-13)

Adds automatic plain-text result snapshot to `filefin2tse_results_YYYYMMDDHHMMSS.txt` beside the macro, falling back to the current directory. No changes to archive extraction or result navigation. Note: archive failures seen in 1.0.0.0.4 are not yet resolved; this build is for exporting exact comparison results.


## Version 1.0.0.0.9 — consolidated logging

`[Logging] CreateLog=true` by default. Each search writes `filefin2tse_*.log` containing INFO messages, MATCH records (full displayed path, including archive members), WARN messages for skipped/failed work, ERROR messages for fatal diagnostics, final statistics and elapsed duration. The separate result `.txt` is produced only when no logging handle is available. Navigation and syntax highlighting are unchanged.


## Version 1.0.0.0.9 — diagnostic extraction compatibility

- Windows 7z command now passes `-o` as a single quoted argument; the optional `--` separator was removed. RAR command also retains its trailing directory separator inside the quote.
- Linux keeps shell-quoted archive paths and configured paths to `/usr/bin/7z` and `/usr/bin/rar`.
- Log the exact extraction command and `Dos()` return status for debugging. The command may contain full local paths.
- Interpret external extraction success from a **nonempty file manifest** rather than assuming `Dos()` returns the extractor's exit code.
- Missing nested ZIPs caused by the current depth/size limits now produce diagnostics where possible.
- Source remains native TSE SAL `.si`; TAR/TGZ extraction deliberately uses external `tar`, and RAR/7Z external tools. No DLL or PowerShell dependency.
- This version is a focused diagnostic/correction release. It does **not** claim to recover all 31 missing entries (some nested compression/archive combinations remain unsupported).
- Tested by static source/ZIP checks only; user must compile and run on Windows, WSL TSE/Linux, and native Linux.


## Version 1.0.0.0.9 (13 November 2026)

The external TAR/TGZ executable is now selected from the INI: `[ArchiveTools] TarExecutable` on Windows and `[Linux] TarExecutable` on TSE for Linux (including WSL). The Windows default is `C:\Windows\System32\tar.exe`; the alternative `;TarExecutable=G:\CYGWIN\bin\tar.exe` is included but **disabled**. To switch, comment out the Windows default and remove the semicolon from the Cygwin line. With `TarExecutable=` blank, the code invokes `tar` through `PATH`; a nonblank invalid path logs an ERROR and skips the archive. TAR and TGZ commands now quote the selected executable. ZIP/JAR native SAL processing and results navigation are unchanged. Logs remain enabled by default. This version is not yet compiled or run on the user's systems.


## Version 1.0.0.0.9 — Cygwin TAR path fix (2026-11-13)

- Detect a configured Cygwin TAR executable by a `/cygwin/` segment in its path (case-insensitive).
- Translate `F:\directory\sample.tar` to `/cygdrive/f/directory/sample.tar` and translate the extracted destination directory similarly. Avoids GNU TAR treating `F:` as a remote host.
- Windows TAR retains native Windows paths; Linux and WSL TAR retain native Linux paths.
- Log selected mode, translated paths and extraction command. Warn when a generated command is 255 characters and risks truncation.
- Commented-out Cygwin option remains in INI: `;TarExecutable=G:\CYGWIN\bin\tar.exe`.
- No changes to native ZIP/JAR, results highlighting or navigation.
- TSE SAL source not compiled here; run `sc32 filefin2tse.si` before testing.
