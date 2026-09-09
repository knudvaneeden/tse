# BH Portable proof of concept

**Version:** 1.0.0.0.12  
**Date:** 2026-09-09  
**Test file:** `win32.hlp`

## Result

This package is a 32-bit Win32 replacement path for the original 16-bit `BH.EXE`. A 32-bit executable built with Borland C++ 5.5 runs under 64-bit Windows through WOW64.

The supplied `win32.hlp` was successfully decompiled during development:

- HLP size: 24,804,587 bytes
- Topic offsets detected: 16,971
- Phrases detected: 16,512
- Decompiler RTF output: approximately 51 MB
- Searchable HTML output: approximately 13 MB
- Verified search text: `CreateWindowEx`

The generated HTML is a readable/searchable proof of concept. It prioritizes recovering text and searchability. It does not yet reproduce every WinHelp layout, popup, macro, hyperlink, or image placement exactly.

## Included programs

- `helpdeco.exe` when built: decompiles compressed Windows HLP files into RTF and resources.
- `rtf2html.exe` when built: converts the recovered RTF text to one searchable HTML file.
- `hlp2html.exe` when built: runs the preceding two stages.
- `bh.exe` when built: accepts an HLP path and search word, converts when needed, updates `bh.ini`, and opens the active search.
- `bh.ini`: automatically remembers the most recently selected converted HTML Help file.

HelpDeco is included from the GPL-licensed HelpDeco project. Its original `LICENSE` is included. The BH wrapper and conversion front end in this proof of concept are supplied as source code.

## Build with Borland C++ 5.5

1. Extract this package to a writable directory.
2. Verify the compiler path near the start of `build.bat`:

   ```bat
   set BCCBIN=g:\language\computer\cpp\embarcadero\borland\bcc55\bin
   ```

3. Keep the supplied `helpdeco.exe` in the package directory. It is a 32-bit Windows console executable built from the same included GPL source using LLVM/MinGW GCC-compatible tooling. It replaces the Borland build that stopped at topic 1253.
4. Run:

   ```bat
   build.bat
   ```

5. A successful build reports:

   ```_pycon
   Kept the supplied 32-bit helpdeco.exe.
   Built rtf2html.exe, hlp2html.exe and bh.exe successfully.
   ```

The supplied HelpDeco and the expected Borland products are ordinary 32-bit Win32 executables. They are not 16-bit applications.

The supplied `helpdeco.exe` has SHA-256:

```text
0c834f0df9b642d677d280f59cb9eda2c83d1e6ed59c9e25ed93664f1b530efd
```

## Optional manual conversion

1. Copy `win32.hlp` into the directory containing the built programs.
2. Run:

   ```bat
   hlp2html.exe win32.hlp win32_html
   ```

   Alternatively, run `convert_win32.bat`.

3. Wait for decompilation and conversion. The large test file can take time and temporarily needs substantial disk space.
4. Confirm that this file exists:

   ```text
   win32_html\win32.html
   ```

5. Open it in a modern browser and search for a Win32 API name such as `CreateWindowEx`.

## Automatic configuration

Manual HTML conversion and manual editing of `bh.ini` are no longer required. Give `bh.exe` the HLP filename and search text. BH creates `<name>_html\<name>.html` beside the HLP file when the HTML does not already exist, writes that HTML path to `bh.ini`, and opens the search result.

Keep `bh.exe`, `hlp2html.exe`, `helpdeco.exe`, `rtf2html.exe`, and `bh.ini` together. The HLP file may be in that directory or supplied by complete path.

## Run BH

Automatic conversion and search:

```bat
bh.exe "C:\Help\win32.hlp" "CreateWindowEx"
```

On the first run for that HLP file, BH effectively runs:

```bat
hlp2html.exe "C:\Help\win32.hlp" "C:\Help\win32_html"
```

It then records `C:\Help\win32_html\win32.html` in `bh.ini`. Later searches reuse the existing HTML, so conversion is skipped. BH opens the HTML in the default browser, highlights all matching text, reports the number of matches, and provides a **Find next** button.

The earlier command form remains available and uses the last `HelpFile` stored in `bh.ini`:

```bat
bh.exe "CreateWindowEx"
```

## Run BH automatically from TSE Pro

Version `1.0.0.0.12` includes the portable TSE SAL macro `bh.s`.

1. Keep `bh.s`, the compiled `bh.mac`, `bh.exe`, and `bh.ini` in the same directory. No installation and no Windows `PATH` change are required.
2. Compile `bh.s` in that directory with the TSE SAL compiler:

   ```bat
   sc32 bh.s
   ```

3. Load or execute the resulting `bh.mac` in TSE. You may specify its complete path to `ExecMacro()`; TSE then loads it from that directory.
4. Place the cursor on a word such as `CreateWindowEx` and run the macro.
5. Enter the complete path to the HLP file when prompted, for example `C:\Users\knud_\Downloads\bh_portable_1.0.0.0.12\win32.hlp`.

TSE's documented filename-entry shorthand is supported. All these inputs are treated as the same filename:

```text
C:\Help Files\win32.hlp
"C:\Help Files\win32.hlp
"C:\Help Files\win32.hlp"
```

The macro removes the optional leading and trailing input quotes, then safely adds a matching pair around the filename when it constructs the Windows command line.

The macro uses the documented `GetWord(1)` function to read the word at, or immediately left of, the cursor. It uses `CurrMacroFilename()` and `SplitPath()` to find its own directory, then runs the `bh.exe` located beside `bh.mac`. It therefore works even when TSE's current directory is somewhere else.

Conceptually, it runs:

```text
"<macro directory>\bh.exe" "C:\Help\win32.hlp" "CreateWindowEx"
```

If the cursor is not on a word, the macro displays a `Windows Help search` input box. It next asks for the HLP filename. Pressing Escape cancels the corresponding step and BH is not launched.

The macro uses `_DONT_PROMPT_`, so TSE does not display an additional DOS-command confirmation.

To invoke it from another TSE SAL macro, use `ExecMacro()` with the compiled macro's full path, for example:

```sal
proc mWinHelp()
    ExecMacro("C:\Tools\BH\bh.mac")
end
```

Only the calling macro needs that location. Once loaded, `bh.mac` resolves `bh.exe` relative to itself. Moving the complete BH directory only requires updating the caller's `ExecMacro()` path or TSE macro configuration.

## Current limitations

- This first version produces a single large HTML document.
- RTF formatting is simplified.
- WinHelp macros and popups are not executed.
- Internal WinHelp hyperlinks are not fully reconstructed.
- Extracted graphics are retained by HelpDeco but are not yet positioned in the HTML.
- Some HelpDeco diagnostic messages can occur for malformed or unusual browse links. The supplied `win32.hlp` still produced recoverable content.

## Version history

### 1.0.0.0.12 — 2026-09-09 22:56 CEST

- Added support for TSE's single-leading-double-quote filename notation.
- Normalized HLP input by removing an optional leading quote and optional trailing quote.
- Added one correct matching quote pair when passing the filename to `bh.exe`.
- Prevented the HLP filename from becoming part of the browser search URL.

### 1.0.0.0.11 — 2026-09-09 22:20 UTC

- Replaced the undefined `GetWordAtCursor()` call with the documented SAL `GetWord(1)` function.
- Added an HLP filename prompt to the TSE macro.
- Added the automatic `bh.exe "helpfile.hlp" "search text"` mode.
- Automatically runs `hlp2html.exe` when the expected HTML file is absent.
- Automatically writes the generated HTML path to `bh.ini`.
- Reuses existing converted HTML for later searches.
- Kept the executable files portable in one directory, without a Windows `PATH` requirement.

### 1.0.0.0.10 — 2026-09-09 22:05 UTC

- Added the standalone TSE SAL macro `bh.s`.
- Made the macro search immediately for the word under the cursor.
- Added an input prompt only when the cursor is not on a word.
- Quoted the search term passed to `bh.exe`.
- Made the macro portable by resolving `bh.exe` beside the running `bh.mac` with `CurrMacroFilename()` and `SplitPath()`.
- Removed the Windows `PATH` requirement and any dependency on TSE's current directory.
- Added TSE compilation and execution instructions.

### 1.0.0.0.9 — 2026-09-09 22:00 UTC

- Added a generated `bh_launch.html` intermediary because Windows `ShellExecute` and Chrome removed query strings and fragments from directly opened local-file URLs.
- Made the launcher page redirect inside the browser to `win32.html#q=...`, preserving the requested search term.
- Added URL encoding for spaces and other special characters in the configured HTML path.
- Added clear error messages when the launcher file cannot be created or opened.

### 1.0.0.0.8 — 2026-09-09 21:50 UTC

- Changed BH search transport from a local-file query string to `#q=...`, which Chrome preserves for `file:///` pages.
- Updated generated HTML to read the initial search term from the URL fragment.
- Added a dedicated **Search** button while retaining **Find next**.
- Reset the global regular expression for every HTML text node so matches are not skipped.
- Kept compatibility with older HTML files that use the `?q=...` query format.

### 1.0.0.0.7 — 2026-09-09 21:45 UTC

- Replaced the unstable Borland HelpDeco build with a supplied 32-bit LLVM/MinGW build.
- Verified that the executable is PE32 Intel 80386 Windows console format.
- Limited its runtime imports to standard `MSVCRT.DLL` and `KERNEL32.DLL` dependencies.
- Changed `build.bat` to retain the supplied `helpdeco.exe` while Borland builds the three BH-specific programs.
- Added an optional, clearly marked diagnostic batch file for reproducing the Borland HelpDeco build.
- Added the SHA-256 checksum of the supplied executable.

### 1.0.0.0.6 — 2026-09-09 20:12 UTC

- Disabled Borland optimization for the HelpDeco build using `bcc32 -Od`.
- Targeted the Borland-only `TopicDump` termination observed at topic 1253.
- Retained optimization for `rtf2html.exe`, `hlp2html.exe`, and `bh.exe`.
- Continued to reject partial RTF output when HelpDeco exits abnormally.

### 1.0.0.0.5 — 2026-09-09 20:06 UTC

- Changed the HelpDeco invocation to dedicated RTF mode: `/r /y /n`.
- Bypassed the unnecessary rebuild-source first pass that caused unknown topic-command and table-type diagnostics in the Borland build.
- Verified this route against `win32.hlp`: exit code `0`, no interactive prompt, and a 51,148,578-byte RTF output.
- Kept `/n` so topic page breaks do not inflate the intermediate searchable document unnecessarily.

### 1.0.0.0.4 — 2026-09-09 20:00 UTC

- Changed unsupported first-pass table types into non-interactive warnings.
- Changed unsupported external-jump modifiers into non-interactive warnings.
- Prevented the `Unknown TableType 148` condition from displaying the `Press CR to continue` prompt.
- Kept file access, memory allocation, invalid-header, and other serious error handling unchanged.

### 1.0.0.0.3 — 2026-09-09 19:55 UTC

- Changed unknown topic commands such as `Unknown 00` into non-interactive warnings.
- Prevented HelpDeco from pausing for `Press CR to continue` on that recoverable condition.
- Kept serious file, memory, header, and corruption errors fatal or interactive as originally designed.
- Added Borland's `conio.h` declaration for `getch()`.

### 1.0.0.0.2 — 2026-09-09 19:50 UTC

- Changed the Windows HelpDeco options from `-y -g` to the required `/y /g`.
- Fixed the `Internal file -y not found` runtime error.
- Added an explicit check that the expected RTF output exists before starting HTML conversion.
- Made `hlp2html.exe` locate `helpdeco.exe` and `rtf2html.exe` relative to its own executable directory.

### 1.0.0.0.1 — 2026-09-09 19:45 UTC

- Replaced the unsupported Borland `_chdir()` calls with `chdir()`.
- Fixed the unresolved external `__chdir` linker error in `hlp2html.exe`.
- Confirmed that the HelpDeco and `rtf2html.exe` stages had already compiled and linked successfully with Borland C++ 5.5.1.
- Retained upstream HelpDeco compiler warnings because they are non-fatal and do not prevent the executable from being produced.

### 1.0.0.0.0 — 2026-09-09

- Created the first 32-bit BH replacement proof of concept.
- Added HLP decompilation using the GPL HelpDeco source.
- Added searchable HTML conversion.
- Added the `bh.exe` command-line launcher source.
- Tested content recovery using the supplied `win32.hlp`.
