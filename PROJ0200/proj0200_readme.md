# PROJ v2.00 for TSE

Package version: **1.0.0.0.128**  
Prepared: **2026-10-04 19:12**  
Original author: **Chris Antos**  
Package update: **OpenAI Codex (GPT-6)**

## Supported CTags languages

The user has verified F12 navigation for every listed language, including Emacs Lisp and Markdown. This records the packaged example tests, not complete parser coverage.

This package covers **61 language entries**: the **41 built-in parsers** reported by your Exuberant CTags 5.8 plus **19 package-defined regex parsers**, with Emacs Lisp shown separately from Lisp although both use the same parser. The latter provide basic definition indexing, not full language parsing. TSE SAL takes priority for `.s` and `.si`; `.pl` retains Perl priority. This table lists the packaged example extension for each language; your executable's `--list-maps` and the package configuration determine all accepted extensions. Examples are in `CTAGSEXAMPLES/`.

| Language | Example extension | Parser | Navigation test |
|---|---|---|---|
| ABAP | `.abap` | Custom regex | F12 verified |
| ActionScript | `.as` | Custom regex | F12 verified |
| Ada | `.adb` | Custom regex | F12 verified |
| Ant | `.build.xml` | Built-in | F12 verified |
| ASP | `.asp` | Built-in | F12 verified |
| Assembly | `.asm` | Built-in | F12 verified |
| AWK | `.awk` | Built-in | F12 verified |
| Basic | `.bas` | Built-in | F12 verified |
| BETA | `.bet` | Built-in | F12 verified |
| C | `.c` | Built-in | F12 verified |
| C# | `.cs` | Built-in | F12 verified |
| C++ | `.cpp` | Built-in | F12 verified |
| Cobol | `.cob` | Built-in | F12 verified |
| Dart | `.dart` | Custom regex | F12 verified |
| DosBatch | `.bat` | Built-in | F12 verified |
| Emacs Lisp | `.el` | Built-in Lisp | F12 verified |
| Eiffel | `.e` | Built-in | F12 verified |
| Erlang | `.erl` | Built-in | F12 verified |
| Flex (MXML) | `.mxml` | Built-in | F12 verified |
| Fortran | `.f90` | Built-in | F12 verified |
| Go | `.go` | Custom regex | F12 verified |
| Haskell | `.hs` | Custom regex | F12 verified |
| HTML | `.html` | Built-in | F12 verified |
| Java | `.java` | Built-in | F12 verified |
| JavaScript | `.js` | Built-in | F12 verified |
| Kotlin | `.kt` | Custom regex | F12 verified |
| Lisp | `.lisp` | Built-in | F12 verified |
| Lua | `.lua` | Built-in | F12 verified |
| Make | `.mak` | Built-in | F12 verified |
| Markdown | `.md` | Custom regex | F12 verified |
| Maple | `.mpl` | Custom regex | F12 verified |
| Mathematica | `.wl` | Custom regex | F12 verified |
| MatLab | `.m` | Built-in | F12 verified |
| OCaml | `.ml` | Built-in | F12 verified |
| Pascal | `.pas` | Built-in | F12 verified |
| Perl | `.pl` | Built-in | F12 verified |
| PHP | `.php` | Built-in | F12 verified |
| PowerShell | `.ps1` | Custom regex | F12 verified |
| Prolog | `.pro` | Custom regex | F12 verified |
| Python | `.py` | Built-in | F12 verified |
| R | `.r` | Custom regex | F12 verified |
| REXX | `.rx` | Built-in | F12 verified |
| Ruby | `.rb` | Built-in | F12 verified |
| Rust | `.rs` | Custom regex | F12 verified |
| SAS | `.sas` | Custom regex | F12 verified |
| Scala | `.scala` | Custom regex | F12 verified |
| Scheme | `.scm` | Built-in | F12 verified |
| Sh | `.sh` | Built-in | F12 verified |
| SLang | `.sl` | Built-in | F12 verified |
| SML | `.sml` | Built-in | F12 verified |
| SQL | `.sql` | Built-in | F12 verified |
| Swift | `.swift` | Custom regex | F12 verified |
| Tcl | `.tcl` | Built-in | F12 verified |
| Tex | `.tex` | Built-in | F12 verified |
| TSE SAL | `.s`, `.si` | Custom regex | F12 verified |
| TypeScript | `.ts` | Custom regex | F12 verified |
| Vera | `.vr` | Built-in | F12 verified |
| Verilog | `.v` | Built-in | F12 verified |
| VHDL | `.vhd` | Built-in | F12 verified |
| VimScript | `.vim` | Built-in | F12 verified |
| YACC | `.y` | Built-in | F12 verified |

## Description

PROJ manages TSE projects containing many files. It remembers open files and editor state, offers a project file list in the Edit File prompt, associates directories with projects, and can navigate to related files and tags. The included original release is v2.00 (2002). Its original `README.txt` and `SRC/MAC/proj.hlp` provide further details; portions of the original help remain unfinished.

This package adds an optional startup message to `SRC/MAC/proj.si` and supplies `proj0200.ini`. Running `proj` directly can show an informative `Warn()` box that points to the Projects menu; the supplied INI now suppresses it by default. First-run setup still runs, then the Project menu opens automatically. Later direct runs open the Project menu immediately. The message does not appear when PROJ is invoked with an internal command such as `-m`, or when it is autoloaded. `silent=true` hides only the added startup message; existing error warnings and setup dialogs retain their behavior.

## Requirements

- TSE for Windows with a compatible **32-bit** `ProjDLL.dll`. The original documentation describes TSE Pro 2.8, 3.0, and 4.0; the user has compiled all five entry files using SAL 4.50.rc23 and confirmed that PROJ starts, help opens, and a new project can be created.
- A SAL compiler compatible with your installed TSE. The bundled `.mac` files are from the original release and can report “macro compiled with wrong version”; recompile from the supplied sources for your TSE version.
- Optional: `CTAGS.EXE` for tag generation. Download the official [Exuberant Ctags 5.8 Windows ZIP (`ctags58.zip`)](https://sourceforge.net/projects/ctags/files/ctags/5.8/ctags58.zip/download), extract `ctags.exe`, and set its full path in `proj0200.ini` using `ctags=C:\path\to\ctags.exe`. Check `ctags.exe --version` for `+regex`, which the package-defined language rules require. BSC navigation uses the supplied `msbsc60.dll`.

## Install and run

1. Extract this ZIP, preserving `SRC/MAC` and `SRC/DLL` if you want to rebuild the program.
2. From the extracted package root, run `build.bat "F:\WORDPROC\tse32_v45024\sc32.exe"` from that root directory, substituting the path to the compiler matching your TSE version. It compiles the five entry macros and copies the compiled macros and help file to the same directory as both DLLs and the INI. Alternatively, compile `SRC/MAC/proj.si`, `SRC/MAC/pjfile.si`, `SRC/MAC/gethelp.si`, `SRC/MAC/helphelp.s`, and `SRC/MAC/projstart.s` with the SAL compiler supplied for your installed TSE. Compile in `SRC/MAC` so the included `.si` and `.inc` files resolve. The original README suggests `SC32 PROJ.SI`, `SC32 PJFILE.SI`, `SC32 GETHELP.SI`, and `SC32 HELPHELP.S`; also compile `SC32 PROJSTART.S` for this portable package. If your compiler does not accept `.si` as an input extension, make a copy of the top-level `.si` files with `.s` extensions for compilation; keep their includes alongside them.
3. Put the newly compiled `proj.mac`, `pjfile.mac`, `gethelp.mac`, `helphelp.mac`, `projstart.mac`, the included `ProjDLL.dll`, `msbsc60.dll`, and `SRC/MAC/proj.hlp` together in a directory of your choice (the installation directory). Put `proj0200.ini` and `proj0200_ctags_languages.conf` beside `proj.mac`. Ensure TSE can execute macros from that directory, for example by supplying the full path in **Macro -> Execute**. Do not substitute the old bundled `.mac` files for a newer compiler's output.
4. In TSE, choose **Macro → Execute**, enter the full path to `projstart.mac`, and press **Enter**. Follow the first-run prompts. For startup project selection, add the compiled `projstart.mac` to TSE's AutoLoad list yourself. This optional TSE-wide setting is outside the package.
5. The Project menu opens when `projstart.mac` runs. Create or open a project there. Press **Alt+[** to reopen it later. Other default keys include **Alt+H** (associated header), **F12** (file at cursor), **Shift+F8** (grep project), and **F12** (tag at cursor).


## Tags and ctags.exe

**Alt+[ -> CTags -> Generate CTags file** runs the executable named by `ctags=` in `proj0200.ini`. It scans the project source file list and writes a `.tag` index beside the project's `.pj` file, for example `PJ\FOOBAR01.tag`. The index contains symbol definitions such as C functions, types, and variables; it is not a list of every textual occurrence or call. Generate tags again after adding files or changing definitions.

Place the cursor on a symbol use and press **F12** (Goto CTags definition at cursor), or use **Alt+[ -> CTags -> Goto CTags definition** and enter its name. PROJ reads the existing `.tag` file via `ProjDLL.dll` and jumps to the matching definition. F12 does not run `ctags.exe`; when already on a definition, the jump may appear to do nothing because the destination is the current line. For every occurrence, including comments or string literals, search project files as text instead. Exuberant Ctags 5.8 headers are normalized automatically for the bundled DLL.

## Language support (1.0.0.0.37)

The configured Exuberant Ctags 5.8 program supports 41 built-in languages, including C, C++, C#, Java, JavaScript, Python, Perl, PHP, Ruby, Lua, HTML, shell scripts, and many others. The authoritative list is [Exuberant Ctags supported languages](https://ctags.sourceforge.net/languages.html); on your machine run `"g:\utils\ctags.exe" --list-languages` to see the actual languages of your executable. TSE SAL (`.s` and `.si`) takes priority over the built-in Assembly mapping of `.s`: the included `proj0200_ctags_languages.conf` defines a TSESal parser for procedures, menu declarations, and defines, and the first variable declared on a line. Keep that file beside `proj.mac`. It requires a CTags executable built with regular-expression support (`+regex` in `ctags.exe --version`). Other languages retain the executable’s own mappings. The pasted 41-language extension table is not necessarily the mapping in your particular executable; check `ctags.exe --list-maps` as well as `--list-languages`.

PROJ now passes **all files already in the project** to ctags; the earlier C/C++-only filter is gone. Ctags chooses its parser by file extension and ignores files whose language it does not recognize. New project defaults include several common extensions, such as `java`, `py`, `js`, `cs`, `php`, and `rb`. For other languages or an existing project, add the extension to **Project Settings -> Known file types** when scanning a directory, then refresh the file list and generate CTags again. You can also add a specific full filename under **Add files to project**; exact file entries are passed to ctags regardless of the known types list. PROJ does not change the languages built into your `ctags.exe`. With no project open, generation indexes the current file only.

## TSE clipboard commands

Under **Alt+[ -> Clipboards**, the commands are:

- **Load TSE clipboard content from a file**: choose a file and replace TSE's internal clipboard with its saved content. PROJ restores its own `.clp` format including block shape; another text file is loaded as a line block.
- **Save TSE current clipboard content to a file**: choose a filename and write the current internal clipboard, including the block information needed for later loading.
- **View the current TSE clipboard content**: display the internal clipboard in a temporary list without inserting it into the edited file.

When saving a project, PROJ can also save this internal clipboard as a `.clp` file beside the `.pj` file and restore it when that project opens. These commands manage TSE's clipboard, separate from Windows clipboard diagnostics used by `ctagsdebug=true`.

## Configuration

Edit `proj0200.ini` beside `proj.mac`:

```ini
silent=true
ctags=g:\utils\ctags.exe
ctagsdebug=true
```

- `silent=false`: show the added informative `Warn()` box when `proj` runs directly.
- `silent=true` (packaged default): suppress that box.
- `ctags=`: path to a compatible `ctags.exe` for **CTags → Generate CTags file**. The default is `g:\utils\ctags.exe`; an empty setting also uses this default. An absolute path is used as written; a relative path is resolved from the package directory. Paths containing spaces may be enclosed in double quotes.

If the INI file is absent, PROJ behaves as `silent=false`. The `ctags` setting controls the external tag generator; PROJ's project database, paths, and other options use its existing setup and TSE profile settings.

## Notes

The SAL sources no longer call `LoadDir()`. The running macro directory is the installation directory: `Proj.DB`, the default `PJ` project folder, `proj0200.ini`, `proj.hlp`, `gethelp.dat`, are resolved there; `ctags.exe` uses the INI path. Keep `proj.mac`, `pjfile.mac`, and `gethelp.mac` together. The project directory setting and last-project setting still use TSE profile entries, and existing project records can contain absolute file paths; review these after moving the installation.

**DLLs:** The supplied `msbsc60.dll` is 32-bit and exports the `openBrowser` symbol imported by the original `ProjDLL.dll`. Keep both DLLs together beside the compiled macros. `msbsc60.dll` also imports the Windows `MSVCRT.dll` runtime. No new DLL was built; subsequent changes in 1.0.0.0.8 still require user compilation and verification. The original `README.txt` documents original integration commands and history.

## Compiler fix in 1.0.0.0.3

The Windows `CreateDirectoryA` declaration was named `MkDir`, which is a reserved word in SAL 4.50. It is now declared as `PROCCreateDirectory` in both `proj.si` and `pjfile.si`; its call in `pjfile.si` was updated. `gethelp.si` and `helphelp.s` already compiled successfully with SAL Compiler V4.50.rc23 in user testing. The user later compiled and ran both successfully with SAL 4.50.rc23.

## Runtime path fix in 1.0.0.0.4

When TSE loads `proj.mac` from an arbitrary directory, PROJ now loads and invokes the neighboring `pjfile.mac` using its full path. Its help call similarly uses the neighboring `gethelp.mac`; `helphelp.mac` calls that file by full path. Recompile all four macros for this release. Put both DLLs, `proj.hlp`, and `proj0200.ini` beside the macros. A screenshot from the earlier version showed a download directory containing only the four macros and sources; the required DLLs, help, and INI still need copying there.

## DLL loading in 1.0.0.0.5

TSE resolves `dll "projdll.dll"` through its macro search path. After TSE finds the full path, Windows separately resolves DLL imports such as `msbsc60.dll`. On a machine where TSE runs with another working directory, the Windows dependency search can fail even when both DLLs sit together. Run **`projstart.mac`**: it uses the Windows `SetDllDirectoryA` API to add its own directory to this TSE process's DLL search path, then runs `proj.mac` by full path. The DLL search directory stays set for the life of the TSE process. Compile `projstart.s` alongside the four existing entry files.

## Help path fix in 1.0.0.0.6

`gethelp.si` now accepts an existing full path to `proj.hlp` directly before searching for a relative help filename. The previous lookup appended that full path to another directory and displayed "Topic Welcome to PROJ not found" even when `proj.hlp` sat beside the macros. Recompile `gethelp.si`; the other four macros from 1.0.0.0.5 can be reused.

## Project folder fix in 1.0.0.0.7

When saving a new project, `pjfile.si` now creates the configured project folder (by default `PJ` beside `pjfile.mac`) before prompting for the `.PJ` name. It reports a clear error if a file occupies that path or Windows cannot create the directory. Recompile `pjfile.si`; the other compiled macros from 1.0.0.0.6 can be reused.

## Portability and settings fix in 1.0.0.0.8

`pjfile.si` now invokes the adjacent `proj.mac` by full path for internal stop, tags, and file-list operations. After Project Settings closes, it saves the project so edited include paths persist in the `.PJ` file. Compile `pjfile.si` again and copy the resulting `pjfile.mac` beside `projstart.mac`; the other entry macros may be reused from your successful compilation. In the include-path list use **Ins** to add a path, **Enter** to accept it, then leave Project Settings. Confirm the path is still present after reopening the project. When moving an existing installation, old `.PJ` entries and TSE profile paths can still point to the old location; update them as needed.

## Batch build in 1.0.0.0.9

`build.bat` follows the same build workflow using `cd` for relative directory changes from the package root, supported by `cmd.exe` and JPSoft TCC. It runs from the extracted package root, compiles in `SRC\MAC`, then returns to the package root before the `copy SRC\MAC\...` commands. Pass the compiler path as the first argument (quote it if it contains spaces). It stops copying if compilation fails.

## Compiler argument in 1.0.0.0.10

The root-level `build.bat` now takes its compiler path as the first argument: `build.bat "F:\WORDPROC\tse32_v45024\sc32.exe"`. Quoted paths with spaces are accepted. It prints usage when the argument is missing. Run it from the extracted package root.

## Windows batch portability in 1.0.0.0.11

The batch file uses `cd /d` for directory changes, so it can run from Windows `cmd.exe` as well as shells that support this command. It requires a Windows TSE `sc32.exe`; classic MS-DOS does not provide `cd /d` or this compiler.

## Compiler and batch correction in 1.0.0.0.12

`pjfile.si` includes `common.si` before `stubs2.si`, so `GetInstallationDir()` is declared when the latter uses it. This fixes SAL error 2335 on `stubs2.si` line 33 reported with V4.50.rc23. `build.bat` uses plain `cd` for its same-drive relative directory changes; TCC had printed directory messages for `cd /d`. Re-run the batch from the extracted root. This revision has not yet been compiled on the user machine.

## Project reopening and Add Files in 1.0.0.0.13

A `.PJ` project stores **directories** in `[Paths]`. `FOOBAR01.pj` showed `c:\temp\ddd.s` and `c:\temp\ddd.txt` under `[Paths]`, while `[FilesInProject]` remained empty. Enter `C:\TEMP\` in **Project Settings → Add files to project**, then add `txt` under **Known file types** (the default already contains `s`). The file list is generated from those directory paths and known extensions. To restore specific open buffers and cursor positions, open the files in TSE and save the project; `[Buffers]` and `[Windows]` are separate from `[Paths]`. In 1.0.0.0.13, `pjfile.si` rejected individual files in that prompt; version 1.0.0.0.14 accepts them and converts them automatically.

`proj.si` now tries to reopen the last project when TSE starts with a single unnamed buffer, as well as when it starts with no files. PROJ previously skipped this step when `NumFiles()` was one. Verify this with **Options → Open last project** enabled. At TSE's `File(s) to edit` prompt, **Escape** asks for confirmation before exiting. **No** keeps the prompt open; **Yes** exits. **Alt+[** opens the project menu there.

## Automatic directory and file type in 1.0.0.0.14

Version 1.0.0.0.14 converted a full filename to its parent directory and scanned all matching files there. This caused unintended entries when `C:\TEMP\ddd.txt` and `C:\TEMP\ddd.s` were entered. Version 1.0.0.0.15 restores exact filename behavior.

**Clean extraction:** If you delete the entire installation directory (`D`) before extracting a new ZIP, this also deletes `D\PJ\*.pj` and `D\Proj.DB`. To retain projects between package versions, copy the `PJ` directory and `Proj.DB` somewhere else before deleting `D`, then restore them after extraction. The compiled `.mac` files still need to be regenerated with `build.bat`.

## Exact filenames in 1.0.0.0.15

In **Project Settings → Add files to project**, enter `C:\TEMP\ddd.txt` and `C:\TEMP\ddd.s` as two separate entries. Full filenames stay exact in `[Paths]` and contribute only those two files to the generated project file list. A directory entry such as `C:\TEMP\` still scans that directory using **Known file types**. Exact filenames work regardless of Known file types and may be mixed with directory entries. Duplicate file entries are removed during the sorted merge. A changed path list invalidates the old `[FilesInProject]` cache, allowing the next rebuild to reflect the new selection. No DLL rebuild is required; compile `pjfile.si` and `proj.si` via `build.bat`.

## Exact-file sort fix in 1.0.0.0.18

The exact-file merge now saves the existing block selection, marks the temporary file list explicitly, sorts it, and restores the previous selection. This addresses the TSE warning "Block not in current file" reported after creating a project in version 1.0.0.0.15. Recompile using `build.bat` and retry adding two full filenames. The change still needs verification in TSE.

## Last-file close confirmation (1.0.0.0.17)

While PROJ is loaded, closing the only file in TSE's ring shows a Yes/No confirmation. **No** or **Escape** keeps the file open. **Yes** closes it and goes to TSE's **File(s) to edit** prompt; pressing Escape at that prompt asks whether to exit TSE; **No** returns to the prompt. This uses TSE's `_ON_FILE_QUIT_` hook and temporarily enables `QuitToPrompt`, which is required for the hook to run when the ring contains one file. PROJ restores your prior `QuitToPrompt` setting when its macro is purged. Rebuild `proj.mac` using `build.bat` before testing; this change has not yet been compiled or run under TSE here.

## Project file picker keys (1.0.0.0.18)

At the **File(s) to edit** prompt, PROJ now selects the first listed project file when the prompt is empty. Use **Down/Up** to choose a row and **Enter** to open it. Previously an empty prompt left no row selected, so Down opened TSE's History instead. Recompile via `build.bat`; the new behavior still needs testing in TSE.

## Selected filename in the Edit prompt (1.0.0.0.19)

PROJ now writes the highlighted project file's full path into TSE's **File(s) to edit** field. The field updates when Up/Down moves the project list selection, and Enter opens that path. The picker retains its current filter while updating the displayed field. Rebuild with `build.bat`; verify the field and navigation in TSE.

## Reopen the project picker while editing (1.0.0.0.20)

With a project open, choose **File → Open** to show TSE's **File to edit:** prompt. PROJ now also attaches its project file list to this singular prompt, in addition to the startup **File(s) to edit:** prompt. Use the arrow keys to choose a file, then Enter to open it. The previously edited file remains in TSE's ring. Rebuild with `build.bat`; test this menu path in TSE.

## Prompt repaint (1.0.0.0.21)

After returning from the project picker to an editing window, PROJ requests one further full window refresh. This addresses repeated line numbers and `[ End` fragments left at the top of the display by the popup's cleanup timing. These are screen artifacts, not additional open files. Recompile with `build.bat`; the fix needs verification in TSE.

## Project transition repaint (1.0.0.0.22)

Closing and reopening a project could leave repeated `1` and `[ End` fragments in the editing area. PROJ now schedules a full display refresh after the project menu returns to the editor. The earlier picker cleanup also called `UpdateDisplay()` while the prompt was still active; TSE documents that this is unsupported, so that premature call was removed. Recompile with `build.bat`, then repeat **Close project → Open project** several times to verify the screen. This change has not been run under TSE here.

## Single-window project reopen (1.0.0.0.23)

The preceding redraw did not resolve repeated line-number columns after **Close project → Open project**. For a project with one saved edit window, PROJ now uses TSE's current single window instead of reconstructing its saved geometry. It still reopens project buffers and restores their recorded positions. Projects with multiple saved windows keep the original restoration path. Recompile `pjfile.si` using `build.bat`; check repeated close/open of a one-window project in TSE. The behavior has not been run under TSE here.

## CTags path (1.0.0.0.24)

Set `ctags=C:\Tools\ctags.exe` in `proj0200.ini` if the executable is elsewhere. The tag generator reads the setting when **Generate tags file** runs, quotes the executable path for spaces, and warns if the file cannot be found. Existing tag navigation reads previously generated tag files without invoking the executable. Recompile `proj.si` using `build.bat`; the new source has not been compiled under TSE in this workspace.

## Default CTags location (1.0.0.0.25)

The default `ctags` path is `g:\utils\ctags.exe`, including when the INI is missing or `ctags=` is empty. Change the path in the INI if your executable is elsewhere. Recompile `proj.si` with `build.bat`.

## F12 tag name extraction (1.0.0.0.26)

Manual **Goto tag** found `draw_menu` in `FOOBAR01.tag`, while **F12** reported `draw menu` even with no marked block. PROJ now reads the identifier directly from the current line and preserves underscores. The cursor may be anywhere within the identifier or immediately after it. Marked character and column selections retain their existing behavior. Rebuild `proj.si` with `build.bat` and test F12 on `draw_menu`; this source change has not been compiled under TSE here.

## Exact F12 tag lookup (1.0.0.0.27)

Version 1.0.0.0.26 passed `draw_menu` correctly but the DLL exact-lookup flag still reported no result. Manual **Goto tag** succeeds using prefix lookup. F12 now uses that lookup path and checks `Tags_GetSymbol()` for an exact match before navigating. Recompile `proj.si` with `build.bat`; test F12 on `draw_menu` in TSE.

## Inspect CTags command (1.0.0.0.28)

With `ctagsdebug=true`, **CTags → Generate CTags file** copies the actual command line to the Windows clipboard. The generated `proj0200_ctags_run.bat` remains in the installation directory for inspection. For a whole-project build, it also retains the input file list as `proj0200_ctags_files.txt` beside `proj.mac`; if an ignore file is used, it retains `proj0200_ctags_ignore.txt` there. The copied command references these files, so it can be pasted into a command prompt for diagnosis. Set `ctagsdebug=false` after testing to resume temporary input cleanup. This setting also enables the F12 lookup trace described below. Recompile `proj.si` via `build.bat`.

## F12 lookup trace (1.0.0.0.33)

With `ctagsdebug=true`, F12 writes `proj0200_tag_lookup.txt` beside `proj.mac`. It records the exact tag string and its length, tag file path, first DLL lookup index and symbol, and final matched index. The tag generator diagnostics from 1.0.0.0.28 remain available. Recompile `proj.si` with `build.bat`, press F12 on `draw_menu`, and inspect or share the lookup text file.

## F12 lookup fallback (1.0.0.0.33)

If the tag DLL lookup misses an existing symbol, F12 scans the loaded tag entries for an exact symbol match. The trace records the original DLL lookup result and the final match index. Recompile with `build.bat` and test F12 on `draw_menu`.

## ProjDLL source correction (1.0.0.0.33)

`SRC/DLL/tags.cpp` now preserves the `lookExact` flag before removing it from the direction bits. It also scans the loaded tag entries if binary search misses. The archive still contains the original compiled `ProjDLL.dll`; the supplied `SRC/DLL/makefile` uses the Microsoft C++ tools (`nmake`, `cl`, `link`) and requires `msbsc60.lib`. The source correction takes effect only after rebuilding the 32-bit DLL and placing it beside `proj.mac`, then restarting TSE. Keep the original DLL as a backup. The SAL fallback from 1.0.0.0.31 works with the bundled DLL and can be tested independently. The DLL source change has not been compiled in this environment.

## Tag loading trace (1.0.0.0.33)

When `ctagsdebug=true`, the F12 trace also records `tag_count`, `current_tagfile`, and the first three loaded symbols. This distinguishes an empty or wrong loaded tag table from a failed search.

## Exuberant Ctags 5.8 header compatibility (1.0.0.0.34)

The uploaded `FOOBAR01.tag` has six tag entries, including `draw_menu`. Its `!_TAG_FILE_SORTED` header ends in `2=foldcase`, but the bundled original `ProjDLL.dll` requires the older header text exactly. Before loading a tag file, PROJ now changes only that header description to the older form and reloads the DLL tag table. This makes existing and newly generated tag files work without rebuilding the DLL. The DLL source also accepts either sorted-header description when rebuilt. Recompile `proj.si` with `build.bat`, restart TSE, generate tags if needed, then press F12 on `draw_menu`.

## Noninteractive tag header update (1.0.0.0.35)

The version 1.0.0.0.34 header replacement omitted TSE's `n` option, so TSE displayed a Replace (Yes/No/Only/Rest/Quit) prompt. The replacement now runs without confirmation.

## Startup menu and CTags labels (1.0.0.0.37)

Running `projstart.mac` now opens the Project menu after the optional startup message and first-run setup. Press **Alt+[** to reopen the menu later. User-facing tag menu entries and related settings now say **CTags**. The internal `.tag` format and existing project settings names are retained.

## TSE SAL takes priority (1.0.0.0.38)

CTags generation loads `proj0200_ctags_languages.conf` from the package directory. It maps `.s` and `.si` to TSE SAL, including when generating tags for a mixed-language project; `.s` assembly files consequently need a different extension or a separate CTags invocation with another mapping. The configuration recognizes SAL `proc`, `menu`, `keydef`, `datadef`, `helpdef`, and `#define` declarations on one line. It is a simple definition index, not a complete SAL parser. Verify on Windows with `build.bat "C:\path\to\sc32.exe"`, then generate CTags and press F12 on a SAL procedure name. This change was not compiled with SAL in this workspace.

## TSE SAL variable navigation (1.0.0.0.39)

The TSE SAL CTags configuration additionally indexes `integer` and `string` variable declarations, including declarations inside a procedure and at file scope. For a declaration listing several variables on one line, only the first is indexed. The pattern does not match procedure return types (`integer proc` or `string proc`). Generate the CTags file again after changing declarations. F12 uses the nearest same-file variable declaration when several names match, although it does not parse procedure scope. For an unambiguous global, F12 should jump to its declaration. CTags does not show variable values or usages. Verify using your Windows CTags executable; this version was not compiled or run under TSE here.

## Nearest SAL variable declaration (1.0.0.0.40)

F12 on a name in a `.s` or `.si` file prefers a variable declaration (`integer` or `string`) with the same name **above the cursor** in the current file. If none exists, it tries the nearest declaration below. If there is no indexed same-file variable, the existing matching-tags chooser remains available. This is a line-distance heuristic: it does not parse SAL procedure scope, so a nearby declaration in another procedure may still win. Tag generation uses CTags line-number addresses (`--excmd=n`) so the DLL can compare locations reliably. Regenerate the `.tag` file after upgrading and test on your machine; this workspace has no SAL compiler or Windows CTags executable.

## SAL variable search direction (1.0.0.0.41)

For a SAL variable, F12 first picks the closest indexed declaration **above or on the cursor line** in the current file. Only when there is no preceding declaration does it use the closest declaration below. With no same-file variable, the matching-tags chooser remains. This follows the usual declaration-before-use pattern but still does not understand procedure scope. Regenerate the CTags file and compile the updated SAL sources on Windows before testing.

## Backward SAL definition search (1.0.0.0.42)

F12 on an indexed name in a `.s` or `.si` file now applies the same priority to procedures, menus, other named SAL declarations, `#define` names, and variables: the nearest matching tag on or above the cursor line in the current file wins. If there is no preceding same-file match, the nearest later same-file match is used; if there is no same-file match, the usual chooser is shown. Indexing still depends on the simple regex rules in `proj0200_ctags_languages.conf`, and identical names in different scopes cannot be distinguished reliably. Forward declarations may legitimately appear before definitions, so a previous match need not be the full implementation. Regenerate tags after upgrading.

## Rust CTags support (1.0.0.0.43)

Exuberant CTags 5.8 lacks a built-in Rust parser. The package options file `proj0200_ctags_languages.conf` adds a regex-based `ProjRust` language and maps `.rs` to it. It indexes common `fn` (including basic `pub`, `async`, `const`, and `unsafe` qualifiers), `struct`, `enum`, `trait`, `mod`, `type`, `const`, `static`, and `macro_rules!` declarations. The bundled DLL recognizes the one-letter tag kinds used by these rules. This is deliberately a basic index: it cannot parse Rust scopes, generics, attributes, re-exports, or every form of declaration. The file also keeps the TSE SAL `.s`/`.si` priority rules.

For a **new** project, `rs` is now in **Known file types**, so adding a directory can find `.rs` files. An existing project retains its saved settings: add `rs` to **Project Settings → Known file types** if you use directory scanning, or add a specific `.rs` file by its full path. Generate the CTags file again, then place the cursor on a Rust definition name and press F12. Keep the renamed options file beside `proj.mac` after extracting a fresh ZIP. Verify with your Windows CTags executable; this workspace has not run it.

## Additional CTags languages (1.0.0.0.44)

The package options file adds basic regex definition indexing for these languages, on top of the configured executable's built-in parsers. Each listed suffix is in the defaults for new projects.

| Language | Package extensions | Indexed examples |
|---|---|---|
| TypeScript | `.ts`, `.tsx` | functions, types, variables |
| Go | `.go` | functions, methods, types, variables |
| Dart | `.dart` | types, basic functions |
| Haskell | `.hs`, `.lhs` | type signatures, types |
| Maple | `.mpl`, `.maple` | procedures, modules |
| R | `.r` (also `.R` in CTags) | function assignments |
| Mathematica | `.wl`, `.wls` | named definitions and usage declarations |
| Swift | `.swift` | functions, types, variables |
| SAS | `.sas` | macros, data sets |
| Kotlin | `.kt`, `.kts` | functions, types, variables |
| Prolog | `.pro`, `.prolog` | basic predicates |
| PowerShell | `.ps1`, `.psm1`, `.psd1` | functions, filters, classes, enums |
| Scala | `.scala`, `.sc` | definitions, types, variables |
| ABAP | `.abap` | classes, methods, forms, functions, variables |

**Extension priority:** `.pl` remains Perl; `.m` remains MATLAB. Prolog and Mathematica therefore use the other extensions shown above. TSE SAL retains priority for `.s`/`.si`. Each added parser uses single-line regexes and indexes common declarations only; it does not understand full language syntax or lexical scopes. A modern CTags with a native parser for these languages may produce better results without this package's override.

For projects created before this version, saved **Known file types** remain unchanged. Add desired extensions there for directory scans, or add specific files by full path; then regenerate the CTags file. Keep `proj0200_ctags_languages.conf` beside `proj.mac`. Compile the five entry macros with `build.bat` for your TSE version. No SAL compiler or Windows CTags executable is available in this workspace, so verify indexing and F12 on your machine.

## Visible subdirectory scan choice (1.0.0.0.45)

Choose **Alt+[ → Project Settings → Add files or scan directories**. Press **Ins** and enter an exact filename or an existing directory. For a directory, PROJ explicitly asks **“Also scan subdirectories of this directory?”**; Yes enables recursive scanning, No scans that directory only. In the path list, entries with recursion show **“(includes subdirectories)”**. Select a directory and press **Ctrl+S** to toggle that option later; the full shortcut is displayed in the list footer. **Known file types** filters directory scans; an exact filename includes only that file. Save the path list with **Enter**, then generate the CTags file when needed.

## Windows CTags download (1.0.0.0.46)

The upstream [Exuberant Ctags 5.8 download page](https://ctags.sourceforge.net/) lists `ctags58.zip` as its Windows source-and-binary package. The direct [SourceForge download for `ctags58.zip`](https://sourceforge.net/projects/ctags/files/ctags/5.8/ctags58.zip/download) contains the executable. Extract it to a directory of your choice, set `ctags=` in `proj0200.ini` to the full path to `ctags.exe`, and check `"C:\path\to\ctags.exe" --version` for `+regex`. The bundled SAL and extra-language rules rely on this feature. The executable is not redistributed in the PROJ ZIP.

## CTags command length and empty index (1.0.0.0.47)

A user trace for `draw_menu` showed `tag_count=0`, and the attached `FOOBAR01.tag` had only its six CTags header lines. An earlier `.tag` file contained `draw_menu`; the index generation failed before lookup. The project command with the added language-options path can exceed SAL's 255-character string limit (262 characters for a representative command using the user's paths), truncating the output filename. PROJ now builds the complete command incrementally as a line in `proj0200_ctags_run.bat` beside the macros and executes that batch file. It retains the batch file for inspection, copies the full command line to the Windows clipboard when `ctagsdebug=true`, and warns if CTags fails or produces no definitions. The exact project input list remains in `proj0200_ctags_files.txt` when debugging is enabled. After recompiling, regenerate CTags and check the `.tag` file for `draw_menu` before trying F12. If the file remains empty, inspect or run the saved batch file in cmd.exe to see the CTags error.

## CTags project input paths (1.0.0.0.48)

The CTags batch command was complete in user testing, but its input list contained `ddd.cc:\temp\` instead of `c:\temp\ddd.c`. `InsertFileList(FALSE)` writes PROJ DLL's internal `filename` + separator + `directory` format, which CTags cannot open as a path. Tag generation now converts each project entry with `RealPath(FlatFile_GetFilename(...))` before writing `proj0200_ctags_files.txt`. After recompiling, regenerate tags and inspect that list: for the sample it should contain `c:\temp\ddd.c`, and the generated `.tag` file should contain `draw_menu`. The F12 lookup trace is only written after the tag file loads, so it was absent while the index had zero definitions.

## CTags loader completion (1.0.0.0.49)

After CTags writes the tag file, PROJ now waits for the DLL to finish loading it before testing the definition count. A new file previously returned the DLL status “load in progress,” which PROJ mistook for an empty index. A nonzero TSE command return alone no longer raises a warning if the tag file loads with definitions. If generation still fails, the warning includes both the command return and the loaded count; run `proj0200_ctags_run.bat` in cmd.exe and inspect the retained input list. Regenerate CTags after recompiling `proj.si`, then place the cursor on `draw_menu` and press F12.

## TSE SAL uppercase declarations (1.0.0.0.50)

The `.s` test used `PROC FooBar()` and `PROC Main()`. Exuberant CTags 5.8 matched none because the custom SAL regular expressions used lowercase keywords without the case-insensitive flag. All four SAL rules now include `/i`, so uppercase `PROC`, `MENU`, `#DEFINE`, and type keywords are recognized. Re-extract this release and regenerate CTags; `FOOBAR01.tag` should include `FooBar` and `Main` from `ddd.s`. Then press F12 on the `FooBar()` call. Recompilation is optional for this change because only the CTags configuration and documentation changed.

## SAL parser rules (1.0.0.0.51)

The forced `TSESal` parser listed all four rule kinds, yet the earlier complex optional-group procedure expression produced no tags. A direct simple rule found `FooBar` and `Main` at lines 1 and 4 in the user test. The configuration now starts with the exact case-insensitive procedure expression proven to work in the user test, and also includes anchored expressions for public and typed `PROC` declarations; menu and define rules are retained, and the variable rule is simplified. From a clean extraction, build as usual, generate the project CTags file, and check for `FooBar` and `Main` from `ddd.s` before pressing F12 at the call. This configuration-only revision does not require changed macro binaries.

## Windows `.s` language precedence (1.0.0.0.61)

The Exuberant CTags 5.8 verbose trace showed `ddd.s` opening as Asm even after mapping `.s` to `TSESal`. Its Assembly parser also owns uppercase `.S`, which this Windows build matches against the lowercase filename. The configuration now maps both `.s` and `.S` (plus `.si`) to `TSESal`, removing the conflicting Assembly entries. The user already confirmed that the forced `TSESal` parser emits `FooBar` and `Main`. In a clean extraction, regenerate the project tag file and verify that it contains those two SAL entries; F12 on the call should then navigate to the declaration.

## CTags C example

`CTAGSEXAMPLES/ddd.c` is a small standalone C program. Add `ddd.c` to a project, generate the CTags file, place the cursor on `draw_menu` in `main`, and press **F12**. The lookup should jump to `static void draw_menu(void)` near the top of the file. You can compile it with a C compiler (for example `gcc ddd.c -o ddd.exe`), but compilation is not required for the CTags test.

## Included language examples

The `CTAGSEXAMPLES` directory contains six `ddd` examples for languages previously tested for CTags navigation. These are optional test files; add only the ones you want to a test project and regenerate its CTags file after adding them. Open a file, put the cursor on the call named below, and press **F12** to jump to its definition. The `.s` example uses TSE SAL and its included custom language configuration.

| File | Language | F12 on call | Expected definition |
|---|---|---|---|
| `CTAGSEXAMPLES/ddd.c` | C | `draw_menu()` | `static void draw_menu(void)` |
| `CTAGSEXAMPLES/ddd.s` | TSE SAL | `FooBar()` | `PROC FooBar()` |
| `CTAGSEXAMPLES/ddd.py` | Python | `greet()` | `def greet():` |
| `CTAGSEXAMPLES/ddd.rs` | Rust | `greet()` | `fn greet()` |
| `CTAGSEXAMPLES/ddd.ts` | TypeScript | `formatName()` | `function formatName(...)` |
| `CTAGSEXAMPLES/ddd.go` | Go | `makeGreeting()` | `func makeGreeting()` |

The examples are newly supplied test sources; they do not require compilation to build a CTags index.

## Full language test set

The `CTAGSEXAMPLES` directory contains all the sample files and a language/file/symbol checklist in `CTAGSEXAMPLES/README.md`. This now covers 59 language entries across 60 files (both `.s` and `.si` for TSE SAL): the 41 built-in languages plus 18 regex languages, with Ada and ActionScript supplied as regex languages. Each file is a small syntax sample intended for CTags indexing; entries marked **Pending TSE test** have not been verified with your executable. Add a chosen example file to a project, regenerate CTags, and test F12 on the symbol. Some languages require a compiler, runtime, or different CTags parser behavior for their examples to be executable or indexed.

## Example layout in 1.0.0.0.61

All `ddd.*` sources are now together under `CTAGSEXAMPLES/`. When updating a test project created from an earlier release, remove its old `ddd.*` entries and add the new full paths, then regenerate the CTags file.

## Known file types in 1.0.0.0.61

The default **Known file types** list is alphabetical and includes the extension of every `CTAGSEXAMPLES/ddd.*` file. It fits SAL's 255-character string limit (251 characters), so some less common prior defaults that are not used by these examples were removed from the default. You can still add any file explicitly by its full filename.

When opening a project whose Known file types list exactly matches the previous package default, PROJ upgrades that list to the new one; customized lists stay as entered. This permits the existing `FOOBAR01` project to recognize the additional extensions after rebuilding and reopening it. Regenerate the CTags file after reopening. A directory scan determines which files enter the project; if a file still has no tag, check the project file list and then CTags parser behavior.

Default: `abap adb as asm asp awk bas bat bet btm c cc cfg cob cpp cs cxx dart e erl f90 go h hpp hs html hxx inc ini java js kt l lisp lua m mak ml mpl pas php pl pro ps1 py r rb rc rc2 rs rx s sas scala scm sh si sl sml sql swift tcl tex ts ui v vhd vr wl xml`

## Parser inventory correction in 1.0.0.0.61

The tested Exuberant CTags 5.8 reports 41 built-in languages, including Vim and YACC, but not Ada or ActionScript. The configuration now supplies basic regex parsers for Ada (`.adb`, `.ads`, `.ada`) and ActionScript (`.as`). `CTAGSEXAMPLES` adds `ddd.vim` and `ddd.y`, bringing the inventory to 59 language entries and 60 sample files (both SAL extensions are tested). These two new parser rules and samples require testing with your Windows CTags.

The alphabetized default list includes `.vim` and `.y` and remains within SAL's 255-character limit. The previous default list is upgraded on project open; customized lists are preserved. To make room, the default no longer includes `cfg` and `rc2`, which may still be added manually. Rebuild the SAL macros, reopen the project, refresh the file list, and regenerate CTags.

## Mapping correction in 1.0.0.0.61

Your CTags `--list-maps` output shows that its **Flex** parser maps Adobe Flex `.as` and `.mxml`, while `.l` maps to Lisp. The previous `ddd.l` example was a lexer sample mismatched to this executable. It is replaced by `ddd.mxml`, an Adobe Flex MXML candidate. The Ant parser recognizes `*.build.xml`, so the old `ddd.xml` is now `ddd.build.xml`. CTags does not have a generic XML parser. `.sl` maps to S-Lang, not Lisp.

The default Known file types list now includes `mxml`; the `.build.xml` file uses the existing `xml` extension. Earlier unmodified defaults upgrade on project open; custom lists are preserved. The MXML and Ant examples still need your CTags test. The BETA, HTML, Make, S-Lang, and TeX examples remain pending because their mapped parsers produced no tag; diagnose those parsers and sample syntax separately.

## TeX sample correction in 1.0.0.0.61

The Exuberant CTags 5.8 Tex parser maps `.tex` but indexes document parts and sections, not `\newcommand`. The revised `CTAGSEXAMPLES/ddd.tex` defines `\section{TexGreeting}` and uses `TexGreeting` in later text. Regenerate the project CTags file and press F12 on the later occurrence; select the `ddd.tex` entry if a chooser appears. A direct `ctags.exe --excmd=n -f C:\TEMP\ddd_tex.tag C:\Users\knud_\Downloads\D\CTAGSEXAMPLES\ddd.tex` should emit a `TexGreeting` section tag. This replacement still requires verification on your Windows CTags build.

## Make sample correction in 1.0.0.0.61

The tested Exuberant CTags 5.8 Make parser indexes macros (`m`), not targets. The previous `greet:` target produced no tag, so the revised `CTAGSEXAMPLES/ddd.mak` defines `GREETING = Hello from Make` and uses `$(GREETING)` in the `all` recipe. Regenerate tags and press F12 on `GREETING` in the recipe. The TeX `TexGreeting` section sample was verified by the user: F12 jumped from its later occurrence to the section at line 3.

If F12 shows a list of other files, it is listing definitions for the symbol under the cursor. A file does not appear there when it contributed no tag for that symbol. The Make correction still needs testing on Windows.

## HTML sample correction in 1.0.0.0.62

The tested Exuberant CTags 5.8 HTML parser lists named anchors and JavaScript functions. The prior sample's heading `id="greet"` produced no tag. The revised `ddd.html` defines `<a name="HtmlGreeting"></a>` and uses that name in a later hyperlink. Regenerate tags and press F12 on `HtmlGreeting` in the hyperlink. Expected destination: the named anchor at line 5. The user has now verified this HTML jump. Make's `GREETING` example is now verified: F12 jumped from its recipe use to line 1.

## Version 1.0.0.0.63 — startup help

The startup message displays package version **1.0.0.0.63** and explains **F1** help. Dismiss the message to open the Project menu; press **F1** there to open PROJ help. The menu also labels its Help entry with `<F1>`. This F1 binding applies while the Project menu is open. Recompile with `build.bat` before testing.

## Version 1.0.0.0.64 — optional INI prompt overrides

All three settings are empty by default, preserving interactive prompts:

| Setting | When configured |
|---|---|
| `projectdirectoryorfilename` | Bypasses the new-project filename prompt and the Open Project selection. A bare name such as `FOOBAR01` resolves to `PJ/FOOBAR01.pj`; other relative paths resolve from the package directory. Explicit project filenames supplied internally still take priority. Existing overwrite and close/save confirmations remain. |
| `scanpath` | Bypasses “Enter directory to scan or exact filename” when you add a list entry (Insert). An exact filename adds only that file; a directory uses the existing Known file types filter. Relative paths resolve from the package directory. |
| `scansubdirectories` | `yes` scans recursively; `no` scans only the selected directory. Empty keeps the question. Applies only to directories. Other values produce an error message. |

Example for a clean test installation:

```ini
projectdirectoryorfilename=FOOBAR01
scanpath=CTAGSEXAMPLES
scansubdirectories=no
```

Choose **New project** or **Open project** normally; these values do not automatically create a project or start a scan at startup. In **Project settings → Add files or scan directories**, press **Insert** to add the configured scan path, then **Enter** to save the list. Clear `scanpath` to enter other files interactively. Existing list entries are preserved.

HTML navigation has now also been verified by the user: F12 on `HtmlGreeting` in the hyperlink jumps to its named anchor. Recompile this version with `build.bat`; the new INI override code requires testing in TSE.

## Version 1.0.0.0.65 — startup Project menu selection

Set `startprojectmenu=New Project` (default) or `startprojectmenu=Open Project` in `proj0200.ini`. When the startup Project menu appears, the chosen entry is highlighted and waits for your action; press Enter to execute it. Empty also selects New Project. This setting applies to the startup menu; subsequent Alt+[ openings retain the existing menu behavior. Recompile and test the selection in TSE.

## Version 1.0.0.0.66 — BETA ordinary patterns

The supplied tag file contained no definition from `ddd.bet`. The BETA parser disables ordinary pattern tags (`p`) by default. The package configuration now adds `--beta-kinds=+p`, enabling them without replacing the built-in parser. `ddd.bet` is now multiline: `greet` is defined on line 4 and used on line 6.

Regenerate project CTags after installing this version. Press F12 on `greet` on line 6; expected destination is line 4. The project tag file should contain a `greet` entry for `ddd.bet` with kind `p`. This change still requires confirmation with your Windows Exuberant CTags 5.8 executable.

To isolate generation from the editor, run:

```bat
g:\utils\ctags.exe --options=proj0200_ctags_languages.conf --excmd=n -f C:\TEMP\ddd_beta.tag CTAGSEXAMPLES\ddd.bet
type C:\TEMP\ddd_beta.tag
```

Run these commands from the extracted package's main directory.

## Version 1.0.0.0.67 — CTags navigation keys

| Key | Action |
|---|---|
| F12 | Go to the definition of the symbol at the cursor |
| Ctrl+F12 | Enter a symbol name to look up |
| Shift+F12 | Go to the definition in a second window |
| Alt+Shift+F12 | Open the CTags menu |

All package source bindings, labels, example instructions, and README key references now use F12. Prior successful navigation tests were performed with the previous key binding; the replacement keys still need testing in TSE. Compile with `build.bat` and restart TSE to load the rebuilt macros.

This version includes the BETA ordinary-pattern fix from version 66. Regenerate CTags, then test **F12** on `greet` at line 6 of `CTAGSEXAMPLES/ddd.bet`; expected destination is line 4.

## Version 1.0.0.0.68 — resolve duplicate F12 binding

The previous version assigned F12 to both CTags lookup and Open file at cursor, producing warning 1106 and stopping `build.bat`. Open file at cursor now uses **Ctrl+Alt+F12**. CTags keeps **F12**, **Ctrl+F12**, **Shift+F12**, and **Alt+Shift+F12**. Recompile this version; compilation and navigation still require confirmation in TSE.

## Version 1.0.0.0.69 — Ant target indexing

The supplied project tag file had no entries from `ddd.build.xml`. The configuration now supplements the Ant parser with an explicit target-name regex. This indexes a target whose `name` attribute immediately follows `<target`, as in the packaged sample; it is not a general XML parser. The filename remains `ddd.build.xml` for Ant language detection.

Regenerate CTags and press **F12** on `AntGreeting` in `depends="AntGreeting"` at line 5. Expected destination: the target declaration at line 2. The lookup list shows only generated definitions, so a missing `.build.xml` entry previously meant that no matching Ant definition had been generated. Windows testing of this fix remains pending.

BETA navigation is now confirmed working by the user.

## Version 1.0.0.0.70 — explicit Ant filename-pattern mapping

The version 69 trace correctly extracted `AntGreeting` but the generated tag file still contained no Ant entry. This version adds `--langmap=Ant:+(*.build.xml)`: an explicit filename wildcard rather than reliance on the executable's compound extension mapping. The explicit target regex remains. The mapping change needs verification with Windows Exuberant CTags 5.8.

After rebuilding and regenerating, test F12 on `AntGreeting` at line 5 of `ddd.build.xml`; expected destination is line 2. To check generation independently, run these commands from the package directory:

```bat
g:\utils\ctags.exe --options=proj0200_ctags_languages.conf --verbose --excmd=n -f C:\TEMP\ddd_ant.tag CTAGSEXAMPLES\ddd.build.xml
type C:\TEMP\ddd_ant.tag
```

The verbose output should identify the file as Ant and the output should include `AntGreeting`. If it still does not, force the parser to isolate filename detection:

```bat
g:\utils\ctags.exe --options=proj0200_ctags_languages.conf --language-force=Ant --excmd=n -f C:\TEMP\ddd_ant.tag CTAGSEXAMPLES\ddd.build.xml
```

## Version 1.0.0.0.71 — Ant detection for Windows CTags 5.8

The user's direct tests confirm that forced Ant parsing generates `AntGreeting` at line 2, while automatic detection reports `ddd.build.xml` as an unknown language. The configuration now uses `--langmap=Ant:+.xml` instead of the compound filename pattern. This maps all `.xml` files to Ant; it indexes Ant projects and targets, not arbitrary XML elements. Other language mappings remain unchanged.

Regenerate project CTags, then test F12 on `AntGreeting` at line 5 of `ddd.build.xml`. Expected destination: line 2. Automatic detection with the new simple extension mapping still needs confirmation on Windows.


## Version 1.0.0.0.72 — SLang example compatible with Exuberant CTags 5.8

The `ddd.sl` function header and body now occupy separate lines. The built-in SLang parser rejects header lines containing a semicolon, so the previous one-line function produced no tag. Regenerate the project CTags file, open `CTAGSEXAMPLES/ddd.sl`, and press F12 on `greet` in the final call (line 6). The expected destination is the definition on line 1. This change still needs testing in TSE on Windows.

## Version 1.0.0.0.73 — CTags chooser starts at the current file

When F12 finds multiple definitions, the chooser initially highlights the first matching definition from the current file. If none exists, it highlights the first match with the same file extension. Otherwise it retains the first match. All matches remain available, and Enter opens the highlighted definition. The list scrolls to show the selected row. Existing nearest preceding TSE SAL lookup remains in effect.

SLang, Ant, and Java example navigation has now been confirmed by user testing. The new chooser selection still needs compilation and testing in TSE on Windows.

## Version 1.0.0.0.74 — Remember the project file picklist selection

Reopening the project file picklist highlights the last selected filename and scrolls it into view. The filename field follows that selection. Selection is remembered while the macro remains loaded, for the most recently used project; restarting TSE clears it. If that file is removed or a different project is opened, normal initial selection applies. CTags chooser selection from version 73 was confirmed by user testing. The new file picklist behavior needs compilation and testing in TSE on Windows.

## Version 1.0.0.0.75 — Edit history for every Ask prompt

All 11 executable `Ask()` calls now explicitly use `_EDIT_HISTORY_` as their history argument, including project filenames, directory scan prompts, search paths, associated extensions, project display names, CTags lookup/reference prompts, and Windows help prompts. Previously custom CTags and path prompt histories now use the shared edit history too. Configured INI overrides still skip their corresponding prompts. Recompile using build.bat; SAL compilation and runtime verification must be performed on Windows.

## Version 1.0.0.0.76 — Vera example with a top-level task

The Vera example now declares `task greet()` outside the `program` block and calls it inside that block. Previously the generated tags contained only the program name `ddd`. Regenerate CTags, open `ddd.vr`, and press F12 on `greet` in line 8; the expected destination is line 1. This example still requires testing with Windows Exuberant CTags 5.8.

YACC `.y` navigation was confirmed: test lowercase `greet` in `start: greet;`, rather than uppercase token `GREET`. SQL contains separate tags for table `greeting` and column `greeting.message`; the duplicate SQL file-picklist row remains under investigation and requires the project `.pj` file.

## Version 1.0.0.0.77 — Exact symbol filtering in the CTags chooser

The chooser now checks each returned symbol explicitly. Looking up `greeting` excludes `greeting.message`, even when the DLL returns that prefix match despite the exact lookup flag. Multiple definitions with the exact requested name remain selectable. A single exact definition opens directly. The SQL file list was confirmed to contain one filename; its two CTags rows represented a table and a column. Vera navigation has now been confirmed by user testing. Recompile and test F12 on `greeting` in line 3 of `ddd.sql`; it should jump directly to line 1.

## Version 1.0.0.0.78 — Alt+[ replaces Alt+P

The Project menu shortcut is now **Alt+[** (Alt plus the left square bracket). Startup instructions and documentation use the new shortcut. The help viewer print shortcut was changed too, so this package no longer binds Alt+P. Recompile all five macros using build.bat and restart TSE to load the new bindings. Version 77 remains the user-tested stable baseline; the version 78 key binding needs compilation and testing on Windows.

## Version 79: project reopen diagnostics and uppercase examples directory

Examples are stored in `CTAGSEXAMPLES/`. Recompile all five macros with `build.bat` using the compiler for the TSE version being tested.

Project reopening now avoids passing zero IDs to the previous-project and temporary-buffer cleanup calls. This is a defensive change for the reported rc24 exit, whose root cause is not yet confirmed. Every Open Project attempt writes `proj0200_project_open_trace.txt` beside the installed macros. The file is replaced at the start of each attempt and saved at each checkpoint, including before project-file loading, list restoration, previous-buffer cleanup, and the empty-ring file prompt. If TSE exits, retain this file before another attempt. Supply the rc24 and 4.50.30 traces separately, together with the corresponding project files. CTags traces describe symbol lookup and do not diagnose project reopening.

In customized TSE menus, use the command that invokes `EditFile()` to reopen the full project picklist; a Buffer List shows only currently loaded files. The user verified SAL definition lookup through the CTags menu in rc24; an existing F12 binding prevented the keyboard shortcut from reaching PROJ.

The SAL changes require compilation and runtime verification on Windows; no TSE compiler is available in the package preparation environment.

## Version 80: visible loaded-language summary

While a project is open and the editor status line is enabled, its right-hand portion shows `Languages: Python / C / C++`, for example. The summary lists distinct recognized languages of files currently loaded in the normal file ring, updates after commands and on idle, and restores the current buffer and cursor after inspecting the ring. Files included in the project but not loaded are not counted. Unknown file extensions are omitted; `None` means no recognized language is currently loaded. `.s` and `.si` always mean TSE SAL, and `.pl` means Perl. This indicator describes filename mappings; it does not prove that a particular CTags parser indexed a file.

The status summary occupies up to 70 columns, limited to half the screen width, replacing the existing information in that portion of the status line while a project is open. Longer summaries end in `...`. Use **Alt+[ -> Loaded languages...** to view the summary (up to SAL's 255-character limit). The ordering follows the loaded file ring; each language appears once. Recompile all five macros. Compilation and visual behavior still require testing in Windows TSE rc24 and 4.50.30.

## Version 81: Delete Project

Use **Alt+[ -> Delete project...**, select a saved project, and confirm. Close the selected project first if it is currently open; this prevents later autosaving from recreating its file. Cancellation keeps the saved files. The command validates the PROJ file identifier, deletes the `.pj` file and its adjacent same-name `.tag` file, and removes the project from the Open Project list. It clears a matching last-project profile value. Source files and directories, custom/shared CTags locations, and clipboard/history/key-macro sidecars are retained. Matching AutoLoad associations are removed from the project database. Errors are reported. This release also includes version 80's loaded-language indicator. Recompile and test on Windows TSE.

## Version 82: Delete Project compiler fix

The Delete Project profile cleanup now uses the literal `LastProject` key in the support macro. Its earlier reference to `c_stIniLastProject` failed because that constant is conditionally declared only for the main macro. Recompile all five macros. The user confirmed compilation of the main macro in version 81; the corrected support macro still requires Windows compilation and runtime testing.

## Version 83: language message wording

The Loaded languages message now reads `Current computer language(s) loaded:`, suitable for either one or several languages. Recompile with `build.bat`.

## Version 84: Escape from the Load prompt

When files are already in the editor ring, Escape cancels the File(s) to edit / Load prompt and returns to the current file without an exit question. The exit confirmation appears only when the ring is empty, where cancelling that prompt can exit TSE. Recompile all five macros and verify the loaded-file and empty-ring cases in your TSE configuration.

## Version 85: language indicator visibility and position

Corrected the reversed QueryEditState check that suppressed the indicator during ordinary editing. The language summary now begins just right of the screen midpoint and leaves the final 25 columns untouched for date/time information. If fewer than 16 columns remain for it, the status indicator is omitted; the Loaded languages menu entry remains available. Long lists are shortened with `...`. Recompile and check the status line while editing, outside a prompt.

## Version 86: Emacs Lisp and VimScript

Emacs Lisp (`.el`) is now a separate language label and example; VimScript (`.vim`) was already included under Vim and is now labelled explicitly. There are 60 displayed language entries and 61 example source files, not two newly added parsers: Exuberant CTags 5.8 uses its existing Lisp and Vim parsers. Explicit `.el` and `.vim` mappings are included in the options file. The alphabetized default Known file types list now includes `el`; projects using the prior default are upgraded, while custom lists are kept. If your project has a customized extension list, add `el` manually before scanning a directory.

Recompile the macros, refresh the project file list, add the examples, and regenerate CTags. In `CTAGSEXAMPLES/ddd.el`, press F12 on `emacs-greet` in the call at line 5; expected definition is line 2. The identifier reader now supports hyphens and colons in `.el` symbol names. In `CTAGSEXAMPLES/ddd.vim`, press F12 on `Greet` in the call at line 6; expected definition is line 2. Both labels are included in the loaded-language status indicator. These examples require Windows CTags/TSE testing.

## Version 87: CTags generation diagnostics

Removed a plain comment from the Exuberant CTags options file for compatibility. Emacs Lisp continues to use the built-in Lisp parser and the `.el` mapping. Generation now saves standard output and errors in `proj0200_ctags_output.txt` beside the macros, including when debugging is disabled. The saved batch command shows the actual output tag filename after `-f`; check that filename when inspecting the generated index. Rebuild with `build.bat`, regenerate CTags, and test F12 on `emacs-greet` in `CTAGSEXAMPLES/ddd.el`. If generation fails, send `proj0200_ctags_output.txt` and `proj0200_ctags_run.bat`. Windows SAL compilation and runtime testing remain to be performed on the user machine.

## Version 88: Emacs Lisp navigation verified

The user confirmed that F12 navigation works for Emacs Lisp. All listed languages now have F12 verified status in the language table and example inventory. This release updates documentation and version labels; CTags behavior is unchanged from version 87.

## Version 91: Markdown

Markdown is recognized in the loaded-language indicator and by the custom `ProjMarkdown` CTags parser. `CTAGSEXAMPLES/ddd.md` demonstrates heading navigation: regenerate project CTags, put the cursor on `Greet` in `See Greet for the greeting above`, and press F12 to jump to `## Greet`. Markdown indexes headings rather than functions or every word occurrence. The parser covers ATX headings (`#` through `######`), including optional closing hashes; Setext underlined headings and fenced-code awareness are not implemented. For headings containing spaces, use the CTags name prompt and enter the full heading title. The `.markdown` alias is also mapped; add it manually to Known file types when scanning that extension.

The default Known file types list now includes `md`. To stay within SAL's 255-character string limit, the optional `btm` batch alias was removed from that default; custom lists are preserved. Projects with the previous default automatically receive the new default. There are now 62 example source files. Markdown F12 navigation is pending user verification; Windows SAL compilation and CTags runtime testing are required.

## Version 92: editor-session tools from PROJECTS

Open the project menu with **Alt+[**, then choose **Session tools**. This opens an integrated companion macro, `projsession.mac`, adapted from the attached `projects.s` by **Ian Campbell**, with later revisions credited in its source. The original `projects.s` is part of the TSE **Potpourri** options. Its adapted implementation is `SRC/MAC/projsession.s`; the unused original-source copy is omitted from this package. Rebuild using the usual `build.bat` command; the build now compiles and copies six macros, including `projsession`.

| Menu | Added functionality |
|---|---|
| File / Save session snapshot | Save named editor session and a `!!LAST!!.PRJ` copy; save modified disk files |
| File / Restore session snapshot | Restore saved files and editor context; existing ring files are retained |
| File / Save snapshot & Exit | Save successfully, then use TSE's normal Exit command |
| File / Save & switch session | Choose a snapshot, save the present session, close saved files, and restore the chosen snapshot |
| File / Add another snapshot's files | Add files and saved context from another snapshot to the current editor ring |
| File / List Open | Sortable ring list; name, path, extension and buffer-order sorting; recent-file cycling |
| Search | Audit bookmark navigation; find/repeat/find-word in a file or across open ring files; multi-file replace; toggle previous file |
| Utility | Standard TSE `clipview`, `timelog`, and `cmp2bkup` macros if installed |

Snapshots store normal file names, cursor/view coordinates, ordinary and audit bookmarks, the marked block, main and up to 26 named clipboards, histories, keystroke macros, working directory, editor version, insert/autoindent/wrap/margin state, video mode, and binary/hex state. The imported implementation uses TSE's internal history format; incompatible editor-version histories are skipped by default. SAL macro reloading remains disabled by default. Restoring a snapshot applies its editor settings and clipboards globally. Saving collapses split windows with `OneWindow()`; window layouts are not stored. Unsaved unnamed buffers are not captured as document contents. Source files must still exist on disk for restoration.

The portable snapshot store is **`PRJ/` beside `projsession.mac`**, created on first save. Snapshot sidecars are `.CLP` and `.KBD`. Native PROJ0200 project definitions and CTags remain in `PJ/`; `.PRJ` snapshots do not replace `.PJ` project membership, scan settings, or CTags configuration. Files restored into the ring are not automatically registered in the current `.PJ` project. Add them through the native project menu when needed. Multi-file searches operate on the editor ring, including files outside the active project. From the snapshot selection list, Delete offers confirmation to remove the snapshot and its sidecars; source files are kept.

Global Ctrl-K and right-click assignments and automatic startup takeover from PROJECTS were omitted. List-dialog shortcuts stay local to their dialogs; path sorting uses Alt+[. Existing PROJ0200 Alt+[ and F12 assignments remain in use. Session tools load on demand, retain audit/recent-file hooks after use, and can be reopened from the same project menu. Optional direct calls are `ExecMacro("projsession -save")`, `ExecMacro("projsession -restore")`, and `ExecMacro("projsession -append")`. No separate auto-loading setup is required. Macro-path lookup must find the package, as for the other PROJ0200 macros.

The integration preserves filename case, widens path variables to SAL's 255-character limit, adds `_EDIT_HISTORY_` to imported Ask prompts, avoids recursive control-file restoration, checks snapshot write results, and keeps TSE running when restored files are missing. Canceling the switch selection leaves the ring intact. Markdown navigation is now marked F12 verified following the user's successful test.

**Validation:** archive integrity and integration wiring were checked here. Windows SAL compilation and interactive session save/restore tests are still required. Test a named snapshot using a few saved files, a bookmark, a clipboard and changed cursor positions; restart TSE, open Session tools, restore it, and verify the state. Also test cancellation and mixed `.PJ`/`.PRJ` use before adopting the session tools for everyday work.

## Version 93: session menu compiler correction

Fixed the Configure entry in the session menu bar: SAL requires a menu there, so it now opens `ConfigMenu()`, whose information item displays the integration message. The reported version 92 compiler error at line 2113 is corrected. The first five macros compiled successfully in the user test; `projsession.s` still needs recompilation and runtime testing.

Package version labels in the active sources are synchronized to **1.0.0.0.96**, including `projstart.s`. Original upstream version numbers and historical release notes identify their original versions and remain unchanged.

## Version 94: launching Session tools

The Project menu now queues the Session tools request and launches the companion menu bar after closing the Project menu and restoring its menu state. Previously the companion menu bar was invoked inside the still-active Project menu. Missing or incompatible `projsession.mac` now produces an explicit warning. Rebuild, restart TSE, choose Alt+[ then Session tools, and verify that the File/Search/Utility/Configure/Help menu bar appears. This launch correction still requires runtime verification on the user machine.

## Version 95: advance the file picklist

When reopening the project file picklist, highlight the file immediately below the previously selected file in the same project. For example, selecting and editing `ddd.asp` then returning to the file list highlights `ddd.awk`. The prompt filename also follows that highlighted row. At the final row, keep the final file selected rather than wrap to the first. If the prior file is no longer listed or the project changes, use the usual initial selection. CTags lookup lists retain their existing selection behavior. Rebuild and test this change in TSE.

## Version 96: context above the next file

Reopening the project picklist still highlights the next file, but now shows up to three preceding filenames above it. Near the beginning of the list it shows as many preceding entries as exist. Small picklist windows reduce that context so the selected row stays visible. CTags result lists are unchanged. Rebuild and verify in TSE.

## Version 97: keep editor files open during project setup

New Project no longer asks to close all open files and no longer saves or abandons document buffers as part of that question. Open Project also keeps previous document buffers rather than silently abandoning unchanged files absent from the opened project. Existing unsaved edits stay in the ring. Project metadata can still be saved or replaced; ring membership and project membership are separate. Explicit file-close, editor-exit, and session save/switch commands retain their stated actions. Rebuild and verify New/Open Project with both saved and modified files already open.

## Version 98: Escape cancels without exiting

Escape at the package-managed File/File(s) to edit prompt no longer asks to exit TSE. With files in the ring it cancels the prompt and returns to the editing context from which it was opened. Version 99 replaces the empty-ring fallback described in the original version 98 implementation: Escape keeps the empty file prompt active without creating a document. Further Escape presses in editing have the editor configuration's normal binding; PROJ0200 does not assign them to Exit. Explicit exit commands remain available. Rebuild, restart, and verify repeated Escape from the file list and project menus, including an initially empty ring.

## Version 99: Escape never creates an unnamed document

Escape at a package-managed file prompt returns to the existing editing context when files are open. If the file ring is empty, Escape leaves the file prompt active instead of creating an unnamed buffer or requesting editor exit. New/Open Project keep existing document buffers open. Explicit editor exit commands remain available. Rebuild and restart TSE to test this change.

## Version 100: Escape behavior tested

This release carries forward version 99 without functional changes and uses the unambiguous archive name `proj02001.0.0.0.100.zip`. All package version labels in the source code have been updated to 1.0.0.0.100.

On 2026-10-01, the user tested the Escape behavior in version 1.0.0.0.99 and confirmed that it works correctly: cancelling the file picklist returns to the existing editing context without asking to exit TSE or creating an unnamed buffer. This tested behavior is retained in version 100. The empty-file-ring behavior remains to keep the file prompt active; it was not separately confirmed by this test.

## Version 101: Missing project file diagnostics

Opening a missing project now reports the full project filename and explains that the file or PJ directory may have been deleted. Restore the project metadata or create a new project. A failed project save also reports its filename and asks you to check whether the directory still exists and is writable. These messages do not recreate deleted project membership. The Escape behavior tested in version 99 is unchanged.

## Version 102: Opening projects does not save or close documents

Removed the changed-file save questions from Open Project. Switching project membership leaves existing open documents and their unsaved edits in the ring. Existing buffers are also kept when a saved project requests binary mode; they are not discarded to change mode. Project metadata may still be saved by project operations. Explicit document Save, Close and editor Exit commands retain their normal behavior. Session snapshot Save/Switch is a separate explicit operation. Rebuild and restart TSE, then test opening another project with modified documents in the ring.

## Version 103: Quiet startup by default

The supplied `proj0200.ini` now sets `silent=true`, so opening the Project menu does not repeatedly display the informative startup box. Set `silent=false` to show that information again. Error warnings and setup dialogs remain available. The source fallback when the INI is missing remains `silent=false`.

## Version 104: Change Projects menu entry

Use **Alt+[ → Change Projects…** to choose another existing project. This entry uses the same project selector as Open project. Existing open documents and unsaved edits remain in the ring; project membership changes to the selected project. Open project remains available. Rebuild and restart TSE to load the updated menu.

## Version 105: One-time launcher introduction

`showbeginmessage=true` is the new default in `proj0200.ini`. The first successful run of `projstart.mac` in a TSE session shows the introductory Warn() message once. Subsequent launcher runs and Project menu openings do not repeat it. Restarting TSE resets the one-time state; purging/reloading the launcher does not. Set `showbeginmessage=false` to disable the one-time launcher message. This setting is independent of `silent=true`, which continues to suppress the ordinary repeated introduction. With `silent=false`, ordinary direct runs of proj can still show that introduction. Error warnings are unaffected. Rebuild and restart TSE to test.

## Version 106: Change Projects menu hotkey

Change Projects now underlines **g** (`Chan&ge Projects...` in SAL). Open the Project menu with **Alt+[**, then press **G** to choose Change Projects. G does not conflict with another active entry in this menu. Rebuild and restart TSE to apply the menu change.

## Version 107: Project selector highlighting and selection

The project selector clears the copied block before displaying its list, preventing block highlighting from making several project rows look selected. Choosing an existing project explicitly disables the separate filename prompt and uses that selected project path. Only Open other project file requests a filename. This applies to the shared project selector. Rebuild and restart TSE, then test Change Projects with two saved projects.

## Version 108: Project menu stays available

After a completed Project menu action, the menu is shown again. Press Escape in the Project menu to leave it and return to the editing context. Session tools still opens outside the active Project menu and returns to it afterwards. Ordinary file-picklist and F12 navigation commands are unchanged. Rebuild and restart TSE; verify New Project, Open Project, Change Projects, Close Project and Escape.

## Version 109: Show current active project

Use **Alt+[ → Show current active project…**, or press **A** in the Project menu. It displays the current project name followed by its full saved `.pj` filename. If no project is active, it reports that explicitly; an unsaved project is identified as having no saved filename. This information command does not change projects or documents and keeps the menu available. Rebuild and restart TSE to test.

## Version 110: Active-project command declaration

Added the forward declaration of PROJ_ShowActiveProject before the Project menu definitions, correcting the undefined-symbol error reported when compiling version 109 with SAL Compiler V4.50.rc23. The command behavior is unchanged. Rebuild to verify compilation on your machine.

## Version 111: Project selector navigation

Replaced the project selector's legacy List call with lList, as used by the other project lists. The selected project is read from the selector buffer after acceptance. Explicit CursorUp/CursorDown bindings move one row in the indicated direction and stop at the first/last row. Selector keys are disabled on cleanup. These changes address the reported failure to switch projects and confusing arrow navigation; they need testing with the two saved projects on your TSE installation. Rebuild and restart TSE.

## Version 112: Preserve project-name case

The project selector now displays project names and directories in their stored case, without title-casing names or lowercasing directory labels. For example, PROJ0200CTAGSEXAMPLES stays uppercase. Case-insensitive path comparisons remain for matching Windows filenames; they do not modify the stored names. Rebuild and restart TSE to apply the display change.

## Version 113: Native project-list highlighting

Removed the project selector's custom drawing hook, which applied menu-letter colors to the entire project name and made unselected names look highlighted. TSE now draws the project list with its native list colors and selected-row highlighting. Names retain their stored case; stored directory paths may appear directly in the list. Rebuild and restart TSE, then verify one selected row while moving Up/Down.

## Version 114: Package cleanup

Removed COMDATABASEMYSQL.BAT: it is unrelated to PROJ0200 and is not part of this package. Project selector highlighting in version 113 was tested by the user and confirmed to work as expected. Program behavior is unchanged in this cleanup release.

## Version 115: View all projects

Use **Alt+[ → View all projects…**, or press **V** in the Project menu, to view the saved project names recorded in the project database. Enter or Escape closes the view and returns to the Project menu. Viewing does not open, switch, save or delete a project. Use Change Projects to activate another project. Rebuild and restart TSE to test the new command.

## Version 116: Export and import project records

The Project menu includes Export Project, Export All Projects, Import Project and Import All Projects. These transfer saved `.pj` records containing filenames, membership and project settings; they never copy source-file contents. Export Project selects a registered project and asks for a destination `.pj` filename. Export All Projects writes the registered saved projects to an existing directory. Import Project copies one `.pj` into the package project directory and registers it; Import All Projects imports every `.pj` in the selected directory, without recursion. Replacing an existing destination requires confirmation. Import does not activate the project or close documents.

Exports use the last saved project record: explicitly Save Project first if you want recent membership changes included. Referenced document paths are preserved, so those documents must remain available at those paths after import. Only `.pj` records are transferred; CTags indexes and session sidecars are excluded. Regenerate CTags when needed. Cancelled or skipped files are not counted in the transfer total. Rebuild and restart TSE; these new commands need Windows SAL compile and runtime testing.

## Version 117: Import helper declaration

Added the forward declaration for EnsureProjectDirectory before the new import code, correcting the undefined-symbol error reported for version 116. Export/import behavior is unchanged. Rebuild with your SAL compiler to verify.

## Version 118: Validate saved-project entries

Project selection, View all projects and batch transfers validate database entries against an existing `.pj` containing the PROJ project-file identifier. Stray document names and missing/invalid project records are excluded from these views and batch exports. The underlying database is not deleted or rewritten by this filtering. A name containing a period remains valid if it actually has a matching saved project. Rebuild and restart TSE to verify the lists.

## Version 1.0.0.0.121

The project file picklist preserves filename and directory capitalization instead of applying title case or lowercase. The forced rebuild introduced in version 119 has been rolled back in version 120 because it caused flickering. Case-insensitive filename matching remains available. Recompile with build.bat and restart TSE. These SAL changes require testing in TSE.

## Version 1.0.0.0.121

Removed the forced file-list rebuild at File > Open. The earlier refresh behavior is restored, while filenames and directory names retain their original capitalization. Recompile and restart TSE; runtime verification is still required.

## Version 1.0.0.0.121

The project menu now has hotkeys X for Export All Projects and M for Import All Projects. The ampersand marks the selected letter in each menu definition. These two letters do not conflict with other current project-menu hotkeys. Recompile with build.bat and restart TSE.

## Version 1.0.0.0.122: buffer-based Known file types

Known file types are now held in a temporary buffer, one extension per line, and saved in the project `[KnownFileTypes]` section. There is no 255-character limit on the whole list. New projects use `proj0200_filetypes.txt`; edit the defaults through Options > Known file types. Old `Extensions=` entries are not read or migrated. Create new projects for this format.

Project settings > Known file types opens the line list. Insert adds a new extension at the top, Delete removes the selected entry, and Escape returns. Each extension is entered without a leading dot. New entries retain all existing entries. Save Project retains the settings.

Directory scanning gathers filenames and then filters them against the buffer directly. If no recognized files exist but unrecognized extensions were found, a list shows the missing extensions and a Yes/No question offers adding them at the top. Accepting filters the existing scan results again; it does not start a second directory scan. Normal File > Open does not force continuous rebuilding. Exact file sources continue to be included directly.

The supplied `proj0200_binarytypes.txt` contains the user's excluded extensions, one per line, without a leading dot. Matching is case-insensitive. These types are excluded from suggestions; an explicitly selected file remains the user's choice. This is an extension exclusion list, not a content-based binary detector.

Recompile with build.bat and restart TSE. The ZIP and buffer/filter invariants were checked locally. SAL compilation and TSE runtime testing remain necessary on Windows.

## Version 1.0.0.0.123: load every project file

Open or change to the desired project, then choose Load all files in current project (menu hotkey 2). This opens all files from the project picklist. Already open files are skipped, preserving unsaved edits. Files missing from disk are skipped and counted; no empty replacement document is created. A final message reports loaded, already open, and missing/failed counts. If the directory scan is pending, loading follows its completion. A project switch cancels any queued load. The previously active document is restored after loading.

Recompile and restart TSE. Windows SAL compilation and runtime testing remain required.

## Version 1.0.0.0.124: Rename project and explicit menu hotkeys

Open the project to rename, then choose R: Rename project. Enter its new name; capitalization is preserved. The project is saved under the new name in the same directory, its database entry and AutoLoad references are updated, and the old .pj file is removed after a successful save. Existing destination projects are not overwritten. Source files and open documents are kept. Regenerate CTags afterward; old tag/history/keyboard sidecar files may remain under their previous names.

The main project menu uses the explicit &character: Label notation from the supplied example. Hotkeys are N New, Y Copy, O Open, G Change, A Active, V View all, L Load all files, E Export, X Export all, I Import, M Import all, S Save, C Close, D Delete, R Rename, 2 CTags, B Clipboards, 3 Refresh, 4 Settings, 5 Options, 6 Help, 7 Languages, and 8 Session tools. Press F1 for help as before.

Recompile and restart TSE. The ZIP and menu hotkey uniqueness were validated locally; SAL compilation and runtime testing remain required.

## Version 1.0.0.0.125

All occurrences of the word projects in the main project-menu labels are lowercase. Hotkey prefixes remain unchanged. Recompile and restart TSE.

### Updated hotkeys in version 1.0.0.0.125

The main project menu uses unique uppercase letters before digits or punctuation. First letters are preferred where available; conflicting labels use another letter. The current keys are N New, Y Copy, O Open, G Change, A Active project, V View all, L Load all files, E Export, X Export all, I Import, M Import all, S Save, C Close, D Delete, R Rename, T CTags, B Clipboards, F Refresh, P Project settings, Q Options, H Help, U Loaded languages, and J Session tools. The label format is &character: Label. F1 still opens help.

## Version 1.0.0.0.126

The single-project menu labels now read &I: Import project... and &E: Export project..., with project in lowercase. Existing uppercase hotkeys are retained. Recompile and restart TSE.

## Version 1.0.0.0.127: close saved project files in the editor ring

Open or change to the desired project, then choose K: Close saved files in current project. This closes only currently open files present in that project's picklist. It keeps modified buffers, files not yet saved to disk, and buffers outside the project. Project membership, directory sources, and disk files are unchanged. Load all files in current project can reopen them later.

If closing the last editor buffer would exit TSE, that buffer is retained. No unnamed replacement buffer is created. A final message reports closed files, unsaved files retained, and last-buffer protection. If the file scan is pending, closing follows its completion; changing or closing the project cancels a queued operation.

Recompile and restart TSE. ZIP integrity, menu hotkey uniqueness, and the unsaved/last-buffer guards were checked locally. SAL compilation and Windows runtime testing remain pending.

## Version 1.0.0.0.128: close saved files across all projects

K: Close saved files in current project closes only members of the active project's picklist. W: Close saved files from all projects closes saved named files across the entire editor ring, including open files not associated with a project. It does not require an active project. Both actions retain modified buffers, unnamed buffers, files not yet saved to disk, and the last buffer needed to keep TSE running. Neither changes project membership, saves source files, or deletes files on disk. A final message reports what was closed and retained.

Recompile and restart TSE. ZIP integrity, unique hotkeys, and source guards were checked locally; SAL compilation and runtime tests remain pending.
