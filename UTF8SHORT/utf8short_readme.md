# UTF8SHORT 1.0.0.0.4

**Open files with Unicode filenames in TSE by using a verified ASCII short pathname.**

TSE may display non-ASCII UTF-8 filename bytes incorrectly under Windows code
page 65001. This program attempts to obtain an ASCII alias for the original
file, then passes that alias to TSE's file-opening command. It does not rename
or copy the file, and it does not convert the file's contents.

**How the implemented method works:**

1. Choose the filename input method:
   - **Method 1 (default): Unicode Windows file picker.** The DLL receives the
     selected pathname directly as UTF-16, bypassing TSE's filename display.
   - **Method 2: raw UTF-8 pathname.** SAL passes the original UTF-8 filename
     bytes to the DLL. The DLL calls `MultiByteToWideChar(CP_UTF8, ...)` to
     convert those bytes to UTF-16.
2. The DLL calls `GetShortPathNameW()` using the UTF-16 pathname.
3. It verifies that the **entire returned path is ASCII**, including every
   directory component, and fits within SAL's 255-byte string limit.
4. SAL retrieves the ASCII path from the DLL and passes it to `EditFile()`.

**If Windows cannot provide a usable ASCII short pathname, the program reports
that explicitly.** Short names are not guaranteed to exist. This is a filename
workaround; it does not add full Unicode support to TSE.


Created by OpenAI Codex (GPT-6). Windows / 32-bit TSE SAL demonstration.

All release files use version **1.0.0.0.4**, including the prebuilt DLL.

## What is included

- utf8short.s: portable launcher; finds its own package directory.
- utf8short_run.s: ASCII SAL worker; opens a file through an ASCII path.
- utf8short.inc: reusable DLL declarations.
- utf8short.dll: prebuilt Intel x86 / PE32 DLL, not a 64-bit DLL.
- utf8short.c and utf8short.def: DLL source and export definitions.
- build.bat: optional Borland C++ 5.5.1 DLL rebuild and SAL compilation.
- create-samples.ps1: creates ASCII, accented and Chinese sample filenames.
- test-dll.ps1: independent Windows DLL tests using 32-bit PowerShell.

## First test in TSE

1. Extract all files into any directory, including a USB drive directory.
   Keep utf8short.dll, utf8short.mac and utf8short_run.mac together.
   Adding this directory to the macro search path is not required.
2. Open CMD or TCC in that directory and compile the SAL source:

   ```bat
   F:\WORDPROC\tse32_v45024\sc32.exe utf8short.s
   F:\WORDPROC\tse32_v45024\sc32.exe utf8short_run.s
   ```

3. Optionally create sample files (either 32-bit or 64-bit PowerShell works):

   ```bat
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File create-samples.ps1
   ```

4. In TSE, use the Execute Macro menu with the full launcher pathname, for
   example `"G:\Portable Tools\UTF8SHORT\utf8short.mac"`. Use your actual
   extracted directory. If the directory is already on the macro search path,
   the short name `utf8short` also works.
5. Leave the method at `1` and select one sample through the Windows dialog.
   This dialog handles Unicode filenames without TSE having to render them.
6. If Windows supplies a fully ASCII short pathname, the macro calls EditFile()
   with that path and reports exactly which ASCII path was passed to TSE.
   Inspect the opened content. Save and reopen a disposable sample before
   relying on saving Unicode-named files through your particular TSE version.

The prebuilt DLL is ready to use; rebuilding the DLL is optional. No .mac is
included because a TSE SAL compiler was not available in the build environment.
Both supplied .s files must be compiled on your Windows TSE installation.

## Portable package loading

The launcher obtains its directory with CurrMacroFilename() and SplitPath().
It calls LoadLibraryA with the full pathname of utf8short.dll before invoking
utf8short_run.mac by its quoted full pathname. The worker uses the Windows DLL
lookup form <utf8short.dll>, so it can bind to the module already loaded from
the package directory. No SetDllDirectory call or persistent PATH changes are
needed. The launcher releases its own LoadLibrary reference after the worker
returns; Windows/TSE manage any reference held by the worker separately.

All companion files must remain together. The package directory is limited by
SAL's 255-byte strings. Its pathname must also be usable by TSE itself; this
workaround cannot fix loading the launcher from a pathname TSE cannot handle.
Restart TSE when replacing a DLL version already loaded by a worker macro.

## Raw UTF-8 mode

Method `2` accepts an existing pathname encoded as raw UTF-8 bytes, maximum
255 bytes, without surrounding quotes. It calls MultiByteToWideChar with
code page 65001 and MB_ERR_INVALID_CHARS, then GetShortPathNameW.
Use this only when you know the input contains actual UTF-8 bytes. A filename
typed into an ordinary TSE prompt or pasted through a legacy clipboard path
is not guaranteed to have that encoding. Method 1 avoids that ambiguity.

## Expected limitations

- Windows does not guarantee that short filenames exist. On ReFS they are
  unsupported; NTFS files can also have no short name.
- A successful GetShortPathNameW can return a Unicode long name unchanged.
  The DLL checks every character and rejects such a path rather than silently
  substituting characters or opening another filename.
- The entire pathname, including parent directories, must be ASCII and no
  longer than 255 bytes. The Unicode picker itself has a larger buffer.
- The macro does not alter short-name settings, rename files, copy files to
  temporary aliases, or change Windows code pages.
- It does not repair TSE's built-in lists, Explorer startup handling, or Unicode
  display. TSE can still expand the ASCII alias back to a long filename.
- This package addresses filenames only. It does not convert file contents.
- Calls are synchronous and the DLL stores one current result per process.
- A final Warn() reports success or failure by default; cancellation is quiet.

## Status values returned by UniSelect / UniFromUtf8

| Value | Meaning |
| --- | --- |
| 1 | Verified ASCII pathname available through UniByte() |
| 0 | Windows file picker cancelled |
| -1 | Windows API failure; UniError() provides the code |
| -2 | No entirely ASCII short pathname available |
| -3 | Path exceeds the SAL output limit |
| -4 | Empty/invalid UTF-8 or embedded NUL input |
| -5 | Selected pathname identifies a directory |

UniByte(index) uses indices 1 through 255; zero means end of result or an
invalid index. Results are cleared before every new operation.

## DLL interface and calling convention

SAL passes a normal string as a pointer to its two-byte length followed by
the data bytes. UniFromUtf8 reads that format and never modifies it.
The other functions take one integer or no arguments. Their Win32 stdcall
exports match the SAL PASCAL declarations: using at most one argument avoids
any multi-argument ordering differences. No output-string marshalling is
required; SAL reconstructs the ASCII path with UniByte() and Chr().

DLL exports are exactly UniSelect, UniFromUtf8, UniByte and UniError.
The prebuilt DLL imports only KERNEL32.dll and COMDLG32.dll, with no external
C runtime dependency.

## Windows DLL tests

From the extracted package directory, run:

```bat
C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -File test-dll.ps1
```

The test uses a uniquely named temporary directory. It verifies malformed
UTF-8, missing files, directories, result clearing and filename resolution.
Where an ASCII alias exists it checks that the returned path opens the original
content. Where none exists it accepts the explicit -2 result. It removes only
its own temporary test directory afterwards. It does not invoke TSE.

## Optional DLL rebuild

PART 1 of build.bat defaults to your Borland C++ 5.5.1 installation:

```bat
set "BCCROOT=G:\LANGUAGE\COMPUTER\CPP\EMBARCADERO\BORLAND\BCC55"
```

Other users can edit BCCROOT to their installation directory, without \Bin.
Keep build.bat beside the DLL source files in the extracted package.
Then run, in CMD or TCC:

```bat
build.bat F:\WORDPROC\tse32_v45024\sc32.exe
```

The script pauses and prints the build exit code. Omitting the parameter builds
only the DLL. With the parameter, both SAL macros are compiled. The Borland rebuild script has not been executed here.

The included DLL was cross-compiled with Zig's Clang compiler for
`x86-windows-gnu`, using its Windows SDK headers, the .def exports and a direct
DllMain entry point without CRT startup.

## Verification performed for this release

- Compiled DLL C source with warnings treated as errors.
- Confirmed PE32 / Intel 80386 architecture, the four exact exports, and imports.
- Executed the compiled x86 DLL exports in an emulator with mocked Windows APIs.
  Checked SAL string layout, UTF-8 arguments, ASCII validation, 255-byte boundary,
  missing-file/directory failures, picker layout, cancellation, error propagation,
  byte bounds and stdcall stack cleanup.
- All those compiled-DLL checks passed.
- The portable launcher's path-loading workflow has
  been reviewed but has not been executed inside TSE.
- Actual Windows API execution, Borland rebuild, SAL compilation, TSE opening and
  saving remain to be tested on Windows. This is a runnable demonstration package,
  not a claim of end-to-end verification inside TSE.

References:
- https://learn.microsoft.com/en-us/windows/win32/api/stringapiset/nf-stringapiset-multibytetowidechar
- https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-getshortpathnamew
- https://learn.microsoft.com/en-us/windows/win32/api/commdlg/nf-commdlg-getopenfilenamew
- https://ecarlo.nl/tse/files/TseHelp.html (Using DLLs / DLL Parameters and Return Values)
