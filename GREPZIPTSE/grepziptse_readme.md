# GREPZIPTSE 1.0.0.0.44 — stable cross-platform baseline

Changes from 1.0.0.0.43:
- Sets `[Logging] CreateLog=false` in `grepziptse.ini`. Set it to `true` when diagnostic logs are needed.
- Updates the source and documentation version identifiers to 1.0.0.0.44.
- No changes to search logic, result navigation, command execution, or archive fixtures.
- Version 1.0.0.0.43 was reported working on Windows, Linux WSL, and native Ubuntu Linux. Version 44 still requires a compile/runtime test.

---

# GREPZIPTSE 1.0.0.0.43 — native Ubuntu navigation diagnostic

Changes from 1.0.0.0.42:
- Centralized all seven external `Dos()` call sites via `RunCommand()`.
- Windows uses the undocumented `_START_HIDDEN_` flag to avoid console flicker; Linux keeps its previous flags.
- Ordinary-file search-result navigation now passes `targetRef` directly to `EditFile()` without shell-style double quotes.
- Added validation and a separate per-navigation log (because the original search log is already closed when Enter is pressed) with checkpoints around result opening and navigation to help localize the native Ubuntu crash.
- `grepziptse.ini` now sets `Logging/CreateLog=true` for the requested diagnostic test.
- Original search expressions, sample archives, and member data are unchanged.

**Native Ubuntu test:** compile `grepziptse.si` to `grepziptse.mac`, run the `foobar` test, press Enter on an ordinary-file result. If the editor crashes, inspect the timestamped `grepziptse_*.log` near the macro and report its final entries. Note that a fatal signal may prevent buffered log writes from reaching disk.

---

# GREPZIPTSE 1.0.0.0.43 — sample archive consolidation and optional diagnostics

- All unchanged ZIP regression fixtures now reside in `sample_archives/`, alongside the JAR, 7z, TAR, TGZ, TAR.GZ and genuine `r.rar` sample.
- `sample_archives/r.rar` is a genuine RAR 2.0 archive containing `docs/match.txt` (`foobar\n`) and `docs/other.txt` (`no match in this line\n`). Its entries and stored contents were verified independently with `rarfile`.
- `[Diagnostics] ShowStartupDiagnostics=false` suppresses two informational startup `Warn()` dialogs by default. Set to `true` to show them. The integer-array smoke test continues to run and **still warns and aborts if it fails**.
- All test values, existing sample bytes, default search string/options, decoder logic, result handling, and `<CtrlAlt G>` shortcut are unchanged.
- Console windows: external commands go through `RunCommand()`; Windows uses `_DONT_PROMPT_ | _START_HIDDEN_`, Linux retains `_DONT_PROMPT_` during native Ubuntu regression testing.
- Compile with `sc32 *.si` (not tested with TSE SAL compiler here).

# GREPZIPTSE 1.0.0.0.41 — TAR/TGZ, shortcut, logging, samples

- Recognizes `.tar`, `.tgz`, and `.tar.gz` (also recursively inside extracted archives).
- Uses `tar` from PATH to extract TAR/TGZ on Windows or Linux. Windows requires an available `tar.exe`; Linux requires `tar`. ZIP/JAR remain native SAL decoding; RAR/7z still require configured extractors.
- Changes the return-to-results shortcut to `<CtrlAlt G>` to accommodate native Linux TSE key handling.
- Sets `[Logging] CreateLog=false` in the INI, and uses false as the default for a missing or invalid setting.
- Includes comparable sample archives; see `sample_archives/README.md` for generated formats and limitations.
- **Not compiled with sc32** in this environment; run `sc32 *.si` to validate before deployment.
- Only extract archives from trusted sources. Extracted members are placed into a temporary working directory.

# GREPZIPTSE 1.0.0.0.40 — SAL string literal compilation fix

Version 40 fixes the SAL compiler error 2330 (String not terminated) at line 2018 in version 39, and corrects all equivalent Linux shell-command literals. Linux shell double quotes are inserted using `Chr(34)` rather than `\"`, which is not a valid SAL double-quote escape. Windows/Linux runtime `WhichOS()` detection remains unchanged; no `#IFDEF` was introduced.

Compilation command: `sc32 *.si` (integer arrays require `.si`). This version has not been compiled with the user's Windows SAL compiler here; please test compilation and report any remaining errors.

## Previous version notes

# GREPZIPTSE 1.0.0.0.39 — final SemWare Linux OS constant

Version 1.0.0.0.39 preserves version 38's Windows/Linux implementation and
uses SemWare's final Linux OS constant.

## Version 39 change

- Replaces the temporary `OS_LINUX` name with `_LINUX_`.
- Linux is detected at runtime with `WhichOS() == _LINUX_`.
- Windows remains detected with `_WINDOWS_` and `_WINDOWS_NT_`.
- There is still no `#IFDEF`; Windows and Linux use the same compiled macro.
- All search, archive and navigation behavior is otherwise unchanged.

## Version 38 change

- Detects Windows with `WhichOS() == _WINDOWS_` or
  `WhichOS() == _WINDOWS_NT_`.
- Detects Linux with `WhichOS() == _LINUX_`.
- Keeps the existing Windows `cmd.exe` recursive enumeration and temporary
  directory commands unchanged.
- Uses `/bin/sh`, `find`, `rm` and `mkdir` for the equivalent Linux work.
- Uses `TMPDIR`, then `TEMP`, then `TMP`, and finally `/tmp` as the Linux
  temporary-directory fallback.
- Uses `/` when constructing Linux manifests, decoded-member files and
  extraction directories.
- Adds a `[Linux]` INI section with Linux top-directory and optional archive
  executable defaults.
- Native Stored/DEFLATE ZIP and JAR parsing, multiple DEFLATE blocks, nested
  ZIP/JAR handling, TSE regular expressions and result navigation use the same
  SAL implementation on both platforms.
- RAR and 7Z remain optional. On Linux they are searched only when the paths
  configured under `[Linux]` exist.

The Linux backend is deliberately marked experimental until it has been
compiled and exercised in TSE for Linux. Version 37 remains the verified
Windows reference if a platform-specific regression is found.

## Version 37 change

- Writes each decoded searchable ZIP/JAR member to the run's temporary work
  directory while also building the native TSE search buffer.
- Archive-result mappings now open that stable decoded text file instead of
  referring to a temporary TSE buffer number.
- Releases decoded search buffers after matching, preventing later archive
  processing from invalidating or reusing a result's target buffer.
- Enter and left-click consequently open the expanded member text at the
  recorded line and column, including nested ZIP/JAR members.
- Temporary decoded files remain available for the result list until the next
  GREPZIPTSE archive search recreates its work directory.
- Search expressions, matching, totals and archive decoding are unchanged.

## Version 36 change

- Stores the visible result buffer ID, hidden result-map buffer ID, first
  result line and match count in named TSE global integer variables.
- Enter, left-click and Ctrl+Alt+Shift+G reload this state before acting.
- This prevents the result buffer from being treated as an ordinary file when
  the original `Main()` invocation has finished or its ordinary macro globals
  have been reset.
- Search, native nested ZIP/JAR decoding and RAR/7Z behavior are unchanged.

## Version 35 change

- Detects `.zip` and `.jar` member names while parsing a ZIP/JAR.
- Captures the member's decoded bytes losslessly as hexadecimal data in a
  temporary TSE buffer.
- Passes that buffer recursively through the same native SAL ZIP parser.
- Supports Stored and method-8 DEFLATE nested ZIP/JAR members, including
  multiple DEFLATE blocks.
- Preserves complete result names such as
  `outer.zip::folder/inner.zip::document.txt`.
- Uses the common 16-level archive nesting limit.
- Requires no external executable for ZIP-inside-ZIP or JAR-inside-ZIP.

## Version 34 changes

- Adds `SearchArchives=yes` and the dedicated `Search archived files
  (yes/no)` prompt/history.
- Adds configurable paths for `7z.exe` and `Rar.exe`.
- Searches `.rar` and `.7z` archives by extracting them below a temporary
  GREPZIPTSE work directory and applying native TSE `lFind()` to their files.
- Searches nested `.rar`, `.7z`, `.zip` and `.jar` files found inside an
  extracted RAR/7Z archive, up to 16 archive levels.
- Uses `Rar.exe` for RAR when available; otherwise it tries configured
  `7z.exe`. It uses `7z.exe` for 7Z archives.
- Aligns result instructions and Escape handling with GREPZIP: Escape is not
  intercepted by the macro; TSE handles it normally. Ctrl+Alt+Shift+G returns
  to the retained result list.

## Multiple-block DEFLATE

- Continues reading block headers until a block has `BFINAL=1`.
- Supports arbitrary sequences of Stored (`BTYPE=0`), Fixed-Huffman
  (`BTYPE=1`) and Dynamic-Huffman (`BTYPE=2`) blocks.
- Preserves the 32 KiB LZ77 history across block boundaries.
- Preserves the output/search buffer across block boundaries.
- Handles byte alignment and LEN/NLEN validation for Stored blocks.
- Logs every block number, starting bit position, BFINAL and BTYPE.
- Rejects reserved `BTYPE=3`, truncated streams and output-size mismatches.

## Results and navigation

- Every match is shown in one TSE result list as `name(line,column): text`.
- Ordinary-file hits are listed first.
- Hits from decoded ZIP members are grouped at the end.
- Press Enter or left-click a result to open it at its line and column.
- Ordinary hits open the original disk file.
- ZIP-member hits open a stable temporary decoded text file.
- Press `<CtrlAlt G>` to return to the retained result list.
- Escape retains its normal TSE behavior, as in GREPZIP.

```ini
[ArchiveTools]
SevenZipExecutable=C:\Program Files\7-Zip\7z.exe
RarExecutable=C:\Program Files\WinRAR\Rar.exe

[SearchDefaults]
SearchArchives=yes

[Linux]
TopDirectories=/tmp/
SevenZipExecutable=/usr/bin/7z
RarExecutable=/usr/bin/rar
```

If an executable is absent, ordinary files and natively decoded ZIP/JAR files
are still searched. Only archive types requiring the missing executable are
skipped and recorded in the log.

```ini
[Logging]
CreateLog=false
LogDirectory=
```

- `CreateLog=true`: create the usual timestamped log.
- `CreateLog=false` (default): do not create a log.
- Accepted true values: `true`, `yes`, `1`, `on`.
- Accepted false values: `false`, `no`, `0`, `off`.
- An invalid value produces a warning and defaults to `false`.

## First Linux test

1. Compile `grepziptse.si` normally. No `#IFDEF` or platform-specific build is
   used; the same compiled macro selects its backend with `WhichOS()`.
2. Keep that `grepziptse.mac`, `grepziptse.ini` and the test archives together
   on the Linux computer.
3. Set `[Linux] TopDirectories` to the test directory.
4. Search for `foobar` with options `ix` and archived files `yes`.
5. Confirm ordinary-file, ZIP, nested-ZIP and multiple-block DEFLATE hits.
6. Press Enter and left-click archive hits, then use
   `<CtrlAlt G>` to return to the result list.
7. If anything differs, enable logging and provide the timestamped Linux log.

Disabling logging does not change searching, filename progress or the final
match summary.

## What GREPZIPTSE searches

- Ordinary files below one or more top directories, recursively.
- Supported members of every `.zip` file encountered during that traversal.
- `.jar` files through the same native ZIP decoder.
- `.rar` and `.7z` files through the configured external tools when archive
  searching is enabled.
- Explicit files and wildcard file specifications.
- A semicolon-separated list mixing directories, files and specifications.

The four prompts are prefilled from `grepziptse.ini`:

```ini
[SearchDefaults]
SearchString=foobar
SearchOptions=ix
TopDirectories=c:\temp\
SearchArchives=yes
```

`TopDirectory` is also accepted as a compatibility fallback when
`TopDirectories` is empty or absent.

## TSE search options

- Blank: case-sensitive literal search.
- `i`: case-insensitive literal search.
- `x`: case-sensitive TSE regular-expression search.
- `ix`: case-insensitive TSE regular-expression search.
- `xi` is normalized to `ix`.

Matching uses TSE's native `lFind()`. Therefore the regular-expression syntax
is the syntax supported by the installed TSE version, including `.`, `^`, `$`,
`|`, `?`, `[]`, `[~]`, `*`, `+`, `@`, `#`, `{}` and the backslash escape.
TSE regular expressions are single-line.

## Implementation notes

- Pure TSE SAL `.si` source for searching and ZIP decoding.
- Windows `cmd.exe` `DIR` is used only to create the recursive file manifest.
- No PowerShell helper or DLL is used. Native ZIP/JAR searching requires no
  external utility; RAR/7Z searching uses the configured executables.
- Progress filenames appear on TSE's message bar.
- Matches and decoder diagnostics are written to a timestamped log.
- Compile `grepziptse.si`; `.si` is required for its integer arrays.

## Current ZIP limitations

The decoder supports Stored ZIP members and method-8 DEFLATE streams containing
one or more Stored, Fixed-Huffman or Dynamic-Huffman blocks, including nested
ZIP/JAR members. It does not yet support data-descriptor entries, ZIP64,
encryption, split archives or every compression method. Large-member,
member-name and 16-level nesting limits remain.

Ordinary files are not affected by those ZIP limitations.

## Suggested regression tests

1. Set `TopDirectories` to a small directory containing ordinary text files
   and the supplied sample ZIP files.
2. Search for `foobar` using `ix`.
3. Test a second semicolon-separated directory.
4. Test `^foobar` using `ix` to confirm native TSE regex matching.
5. Search `grepziptse_sample_multiblock.zip` for `foobar` with `i`. Expected:
   400 matches in `multiblock.txt` and multiple `DEFLATE block #` log entries.
6. Review the generated `grepziptse_YYYYMMDDHHMMSS.log`.
7. Search `grepziptse_sample_nested.zip` for `foobar` with `i`. Expected:
   2 matches through
   `grepziptse_sample_nested.zip::grepziptse_sample_stored.zip::...`.

Version 1.0.0.0.35 remains the preceding fallback version.
