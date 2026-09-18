# FILEFIN2 Win32 DLL port

**Version:** 1.0.0.0.30  
**Date:** 2026-09-18  
**Time:** 11:42 CEST (UTC+02:00)  
**LLM:** OpenAI Codex  

## Description

This package ports the 1994 FILEFIN2 macro to 32-bit TSE Pro 4.50 on Windows 11. The unsupported SAL `binary` declarations have been removed. Their DOS `.BIN` modules are replaced by two Win32 DLLs whose source can be compiled with Borland C++ command-line compiler 5.5.1.

- `ff.dll` replaces `FF.BIN` and uses the Win32 file-search API.
- `zip.dll` replaces the old `LOWLEVEL.BIN`-based ZIP reader. It reads ZIP and JAR central directories directly and delegates TAR, TGZ, RAR, 7z, and mixed nested archives to the included helper.
- Modern ZIP support includes data-descriptor archives, UTF-8 member names, and ZIP64 sizes and offsets.
- ZIP member masks are evaluated once per central-directory entry in `zip.dll`; the former SAL repeat-search loop and its duplicate output are removed.
- Directory traversal is recursive below the supplied starting directory and includes normal, read-only, hidden, and system directories while avoiding reparse-point loops.
- Complete depth-first directory traversal now runs inside `ff.dll`. Win32 search handles remain on an internal stack until every sibling branch has been visited; traversal no longer depends on recursive SAL locals or temporary-buffer queue positioning.
- The DLL sources use Win32 functions only and do not require unresolved Borland C runtime functions such as `strlen`, `memcpy`, `atol`, or `sprintf`.
- The reserved SAL names `FindFirst` and `FindNext` are replaced by `FNFindFirstI` and `FNFindNextI`.
- Separate DLL search contexts preserve recursive searches.
- The search input is split into two prompts: first the filename or wildcard mask, then the top directory. Both prompts use TSE's `_EDIT_HISTORY_`, so earlier entries can be recalled independently.
- Search defaults come from `filefin2.ini`. When `searcharchive` is nonempty, its first character is queued with `PushKey()` and acts as the menu accelerator, automatically choosing **Yes** or **No**.
- `FF.S` is standalone: its DLL declarations and ZIP helper are embedded directly, so compiling it does not open or retain `FF.INC` or `ZIP.INC` editor buffers.
- Double quotes are ignored in both inputs. For example, `FF.S` and `"FF.S"`, or `C:\TEMP` and `"C:\TEMP"`, produce the same search.
- Pressing **Ctrl+Alt+Shift+F** runs the FILEFIN2 search prompt directly while the compiled macro is loaded.
- Filename masks accept `*` or `.*` anywhere for zero or more characters and `?` anywhere for exactly one character. This applies identically to ordinary filenames and members of ZIP, JAR, TAR, TGZ, RAR, and 7z archives.
- Archive masks are matched against the final member filename, not its internal directory prefix. Thus `FF.S` can find `folder/FF.S`, while the complete internal path remains visible in the results.
- Result columns use a right-aligned ten-character size field and explicit two-space separators between size, date, time, and filename. Full-width values can no longer run into the following date.
- Archive searching supports `.zip`, `.jar`, `.tar`, `.tgz`, `.rar`, and `.7z`, including mixed nesting. Nested entries use a `::` separator, such as `inner.7z::source.tar::folder/FF.S  <-  outer.rar`.
- ZIP and JAR top-level members are read directly by `zip.dll`. TAR, TGZ, RAR, 7z, and nested archive members are read by `zip_nested.ps1` through Windows PowerShell. RAR and 7z decoding uses the external 7-Zip command-line program.
- Before scanning an archive, the message bar displays `Scanning archive:` followed by its path and immediately refreshes the TSE display.
- While `zip.dll` waits for the PowerShell helper, it services Windows paint and synchronous message traffic so TSE can repaint instead of appearing frozen or **Not Responding**.

## Files

| File | Purpose |
|---|---|
| `FF.S` | Updated main TSE SAL macro |
| `ff_dll.c` | Borland C source for `ff.dll` |
| `zip_dll.c` | Borland C source for `zip.dll`, including ZIP/JAR central-directory support and archive-helper integration |
| `zip_nested.ps1` | PowerShell helper for recursively reading ZIP, JAR, TAR, TGZ, RAR, and 7z members |
| `filefin2.ini` | Editable defaults for the two search prompts, archive-menu choice, and external archive-tool paths |
| `build.bat` | Builds both 32-bit DLLs |

## Build the DLLs

1. Open a Windows command prompt.
2. Make the Borland C++ 5.5.1 `Bin` directory available through `PATH`, or run `build.bat` from a command prompt in which `bcc32.exe` is already available.
3. Change to the extracted FILEFIN2 directory.
4. Run:

   ```bat
   build.bat
   ```

5. A successful build ends with:

   ```text
   Build completed: ff.dll and zip.dll
   ```

The batch file uses:

```bat
bcc32 -tWD -O2 -u- -eff.dll ff_dll.c
bcc32 -tWD -O2 -u- -ezip.dll zip_dll.c
```

`-tWD` creates a Win32 DLL. `-u-` disables Borland's leading underscore on exported C names so TSE can resolve the exact names declared in the SAL `dll` blocks. The exported functions use the Pascal/WinAPI calling convention required by 32-bit TSE DLL calls.

## Compile the SAL macro

After both DLLs build successfully, compile the updated macro with the TSE SAL Compiler:

```bat
sc32 FF.S
```

No `.INC` files are required. Version 1.0.0.0.9 embeds the declarations directly in `FF.S`.

## Install and run

1. Put the compiled `FF.MAC` where TSE loads macros.
2. Keep `ff.dll`, `zip.dll`, `zip_nested.ps1`, and `filefin2.ini` together with the FILEFIN2 macro package in a directory from which Windows can load the DLLs.
3. Restart TSE after replacing either DLL, because Windows/TSE may retain a loaded DLL in memory.
4. Execute the `FF` macro, or press **Ctrl+Alt+Shift+F** while it is loaded. The macro creates and displays a dedicated results buffer.
5. At the first prompt, enter the filename or wildcard mask only, such as `FF.S`, `*.S`, `e.*list`, `elist.?`, or `FILE?.TXT`.
6. At the second prompt, enter the top directory only, such as `C:\TEMP` or `F:\WORDPROC\tse32_v45024\MACDOWNLO`.
7. Choose whether member names inside ZIP, JAR, TAR, TGZ, RAR, and 7z files, including nested and mixed archives, should also be searched. With the distributed blank `searcharchive=` setting, the menu remains visible for this choice.

Both prompts retain their own TSE edit history. Cancelling either prompt stops the operation without starting a search.

The macro recursively appends matching filenames, sizes, dates, and times to its dedicated results buffer. Searching starts at the separately supplied top directory.

## Search defaults in `filefin2.ini`

The `[Search]` section supplies the editable initial values displayed by the
two `Ask()` prompts and the archive menu:

```ini
[Search]
filename=*foobar*
topdirectory=c:\temp\
searcharchive=
```

- `filename` may contain the supported `*`, `.*`, and `?` wildcards.
- `topdirectory` is the initial recursive-search directory.
- The distributed default is `searcharchive=` so no key is queued and the user
  can choose normally. Setting `searcharchive=yes` queues the `y` accelerator,
  while `searcharchive=no` queues `n`. TSE immediately activates the matching
  entry; no separate `<Enter>` is queued or required, and the menu might not be
  visibly displayed.

`FF.S` first establishes its built-in defaults. Only nonempty INI values
override those initial values. Blank keys preserve the original empty/history-
driven prompts and archive-menu history. The user can still edit either
`Ask()` value or choose another menu entry, so interactive input is final.

## Wildcard examples

| Mask | Matches |
|---|---|
| `e.*list.s` | Names beginning with `e`, followed by any characters, and ending in `list.s`; for example `eList.s` |
| `elist.?` | `elist.` followed by exactly one character, such as `elist.s` |
| `*elist*` | Any name containing `elist` |
| `file?.txt` | Names such as `file1.txt` or `fileA.txt`, but not `file10.txt` |

## Troubleshooting

### TSE reports that a DLL or procedure cannot be found

- Confirm that both DLLs are reachable from the TSE process.
- Restart TSE after rebuilding the DLLs.
- Run `tdump -ee ff.dll` and `tdump -ee zip.dll` to inspect the export tables.
- Confirm that the exported names match the `dll` declarations near the top of `FF.S` exactly.
- Confirm that `-u-` is present in both `bcc32` commands.

### The SAL compiler still reports `Binary not supported`

Compile the updated standalone `FF.S`. It contains no `binary` declarations and needs no FILEFIN2 include files.

### The SAL compiler reports that `FindFirst` is reserved

You are compiling an older source. Version 1.0.0.0.9 is standalone and contains no `FindFirst` or `FindNext` SAL procedures.

### Archive searching fails

For ZIP and JAR files, the DLL searches the central directory, so compression method and data descriptors do not affect member-name listing. Classic ZIP and ZIP64 metadata are supported. Multi-disk/spanned archives are not supported. UTF-8 ZIP/JAR member names are converted to the active Windows ANSI code page because TSE 4.50 SAL strings are not Unicode.

TAR/TGZ and nested archive searching require `zip_nested.ps1` beside `zip.dll` and Windows PowerShell 5.1 or later. Standard TAR/USTAR names and GZip-compressed TAR archives are supported. Encrypted, corrupted, unsupported, or incorrectly named archive members are skipped.

RAR and 7z searching uses the optional paths in `filefin2.ini`, which must be
kept beside `FF.S` and `zip_nested.ps1`:

```ini
[ArchiveTools]
SevenZipExe=C:\Program Files\7-Zip\7z.exe
RarExe=C:\Program Files\WinRAR\rar.exe
```

Quotes around a path are optional. A blank or invalid setting causes automatic
discovery. `7z.exe` handles both 7z and RAR files. When `7z.exe` is unavailable,
`rar.exe` can search RAR files, but not 7z files.

The helper searches automatically in this order when an INI setting is blank
or invalid:

1. Beside `zip_nested.ps1`.
2. On the Windows `PATH`.
3. In the standard 7-Zip or WinRAR installation directories.

For a portable installation, copy `7z.exe` and its required companion files, such as `7z.dll`, beside `zip_nested.ps1`. Password-protected archives are skipped when they cannot be opened non-interactively.

Recursion is limited to eight archive levels, 256 MiB per nested archive member, and 512 MiB cumulative expanded nested data per outer archive.

### Large file sizes show `2147483647`

TSE SAL integers are signed 32-bit values. Sizes above 2,147,483,647 bytes are clamped to that maximum value.

## Version history

| Version | Date | Changes |
|---|---|---|
| 1.0.0.0.30 | 2026-09-18 | Left the distributed `searcharchive=` value blank so the archive menu remains visible and user-controlled; documented that nonempty `yes` or `no` automatically activates the matching menu entry |
| 1.0.0.0.29 | 2026-09-18 | Moved `[Search]` INI reading entirely into `FF.S`; blank values now preserve the macro's original empty/history-driven prompts and unforced archive-menu history |
| 1.0.0.0.28 | 2026-09-18 | Added `[Search]` INI defaults for the filename mask, top directory, and archive-menu selection; the first character of `searcharchive` positions the menu through `PushKey()` |
| 1.0.0.0.27 | 2026-09-15 | Corrected PowerShell 5.1 parsing errors in the automatic 7-Zip and WinRAR installation-path detection code |
| 1.0.0.0.26 | 2026-09-15 | Added editable `filefin2.ini` settings for complete `7z.exe` and `rar.exe` paths, automatic-discovery fallback, and direct RAR searching through `rar.exe` when 7-Zip is unavailable |
| 1.0.0.0.25 | 2026-09-15 | Increased the filename or file-mask input capacity from 80 to 255 characters so long pasted names are not truncated |
| 1.0.0.0.0 | 2026-09-07 | Documentation of the original DOS `.BIN` package |
| 1.0.0.0.1 | 2026-09-07 | Replaced both `.BIN` interfaces with Borland C++ 5.5-compatible Win32 DLL sources and updated SAL code |
| 1.0.0.0.2 | 2026-09-07 | Removed Borland C runtime dependencies, added TSE 4.50/Windows 11 compatibility updates, and replaced the ZIP reader with central-directory, UTF-8, data-descriptor, and ZIP64 support |
| 1.0.0.0.3 | 2026-09-07 | Removed Borland C++ W8012 signed/unsigned comparison warnings in the ZIP64 extra-field parser |
| 1.0.0.0.4 | 2026-09-07 | Corrected full-path input parsing, added a dedicated visible results buffer and an explicit no-results message, and removed the obsolete conversion include |
| 1.0.0.0.5 | 2026-09-08 | Fixed repeated ZIP-member duplicates and made recursion cover all ordinary subdirectories while excluding reparse-point loops |
| 1.0.0.0.6 | 2026-09-08 | Replaced recursive SAL directory enumeration with an explicit queue so child searches cannot overwrite the parent search state |
| 1.0.0.0.7 | 2026-09-08 | Moved complete recursive traversal into `ff.dll` after the SAL queue still skipped sibling branches |
| 1.0.0.0.8 | 2026-09-08 | Added `_EDIT_HISTORY_` to the search prompt and made `FF.S` standalone so compiling it no longer loads or retains include-file buffers |
| 1.0.0.0.9 | 2026-09-08 | Fixed quoted and accidentally half-quoted search input by removing double quotes before splitting the starting directory and file mask |
| 1.0.0.0.10 | 2026-09-08 | Added the **Ctrl+Alt+Shift+F** key assignment for starting a search |
| 1.0.0.0.11 | 2026-09-08 | Documented and exposed `*` and `?` wildcard searching in the prompt, including `e.*list` and `elist.?` examples |
| 1.0.0.0.12 | 2026-09-08 | Made `.*` a wildcard alias for `*`, so a mask such as `e.*list.s` matches `eList.s` |
| 1.0.0.0.13 | 2026-09-08 | Fixed ZIP searches by matching the mask against each member's basename instead of its complete internal directory path |
| 1.0.0.0.14 | 2026-09-08 | Aligned result fields, added explicit separators so file size, date, time, and path never concatenate, and renamed the package documentation to `filefin2_readme.md` |
| 1.0.0.0.15 | 2026-09-08 | Added recursive filename searching inside ZIP files nested in other ZIP files, with `::` archive-chain display and safety limits |
| 1.0.0.0.16 | 2026-09-08 | Added an `INVALID_FILE_ATTRIBUTES` compatibility definition for the older Windows headers supplied with Borland C++ 5.5.1 |
| 1.0.0.0.17 | 2026-09-08 | Removed the Borland `_llmul` linker dependency by parsing the already-capped nested member size with bounded 32-bit arithmetic |
| 1.0.0.0.18 | 2026-09-13 | Split search input into two `_EDIT_HISTORY_` prompts: filename or mask first, then the top directory; cancelling either prompt stops cleanly |
| 1.0.0.0.19 | 2026-09-15 | Added recursive `.jar`, `.tar`, and `.tgz` searching alongside `.zip`, including mixed nested archive chains |
| 1.0.0.0.20 | 2026-09-15 | Made archive searching default to **Yes**, refreshed the current archive path before scanning, and kept TSE repainting while the PowerShell helper runs |
| 1.0.0.0.21 | 2026-09-15 | Corrected the archive-menu default by queuing `<CursorUp>` before `ZipSearch()`, so the visible initial choice is **Yes** |
| 1.0.0.0.22 | 2026-09-15 | Replaced the queued-key workaround with documented variable menu history: `history = archiveMenuItemI`, reset to entry 2 (**Yes**) before every menu call |
| 1.0.0.0.23 | 2026-09-15 | Restored the original plain `history` archive menu and removed all forced-default variables and queued keys because current TSE versions behave inconsistently with forced selection |
| 1.0.0.0.24 | 2026-09-15 | Added recursive `.rar` and `.7z` filename searching through `7z.exe`, including mixed nested archive chains and automatic 7-Zip executable discovery |
