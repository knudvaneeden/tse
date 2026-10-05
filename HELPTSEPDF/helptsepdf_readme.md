# HELPTSEPDF

Version: **1.0.0.0.0**  
Created: **2026-10-05 15:15:37 UTC**  
LLM: **GPT-6.1**  
Requested session name: **Create HELPTSEPDF Readme**

## Description

HELPTSEPDF provides the supplied TSE help information as a PDF reference and a small Windows TSE SAL launcher. The PDF contains 446 pages covering editor operation, configuration, keyboard commands, macro programming, and SAL command reference material. It was produced in 2012, so features of later TSE versions may differ.

The launcher opens the PDF through the Windows file association. Adobe Acrobat Reader or another PDF viewer can be used. It does not import the PDF into TSE's native help system or provide context-sensitive topic selection.

## Package contents

| File | Purpose |
| --- | --- |
| `testhelphyperlinktseadobe.pdf` | Original supplied help PDF, unchanged. |
| `helptsepdf_readme.md` | Description, configuration, and instructions. |
| `helptsepdf.ini` | PDF filename and startup-message setting. |
| `helptsepdf.s` | New ASCII SAL launcher source, version 1.0.0.0.0. |

Archive: `helptsepdf1.0.0.0.0.zip`. A compiled `.mac` is not included.

## Open the help directly

1. Extract the ZIP to a directory of your choice.
2. Double-click `testhelphyperlinktseadobe.pdf`.
3. Use the viewer's **Ctrl+F** command to find a command or topic, such as `Ask`, `GetProfileStr`, or `Compiling Macros`.
4. Use **Ctrl+Home** to return to the beginning in viewers supporting that shortcut.
5. Try the contents links and your viewer's Back command to navigate. Link handling depends on the viewer; any links pointing to the original HTML files may require files that are not included. Text search remains available.

## Compile and run from TSE

Requirements: Windows, TSE Pro with its SAL compiler (`sc32.exe`), and a default PDF viewer.

1. Keep the extracted PDF, INI, and SAL source together.
2. Open a command prompt in that directory and compile:

   ```bat
   sc32 helptsepdf.s
   ```

   If `sc32` is not on PATH, use the full path to your SAL compiler.
3. Compilation should create `helptsepdf.mac` in that directory.
4. In TSE, invoke **Execute Macro** (normally **F9**), enter the full path to `helptsepdf.mac`, and press Enter. Alternatively, place the package in a directory on your TSE macro search path and execute `helptsepdf`.
5. The PDF opens in the default viewer. With `silent=false`, TSE displays an informative `Warn()` box; dismiss it and switch to the viewer if necessary.

You can also invoke the compiled macro from SAL using `ExecMacro("helptsepdf")` when it is on the macro search path.

## Configuration

```ini
[helptsepdf]
silent=false
pdffilename=testhelphyperlinktseadobe.pdf
```

- `silent=false`: show the final informative `Warn()` box, including launch problems detected by the macro.
- `silent=true`: suppress that box. The PDF still opens. Errors detected by the macro are also suppressed.
- `pdffilename`: a bare filename is resolved beside the running `.mac` file. For another location, supply a complete absolute Windows path without surrounding quotes. Keep the path simple; shell expansion characters such as `%` should be avoided.

The macro checks the current working directory for `helptsepdf.ini` first, then the compiled macro's directory. It passes an explicit INI path to the profile functions. If no INI exists, the defaults above apply. Use a full absolute PDF path for directories other than the macro directory.

## Informative message in main()

The supplied PDF had no separate launcher source. This package therefore includes a new `helptsepdf.s`. Its `main()` reads the INI, checks the PDF, requests that Windows open it, and ends with a conditional `Warn()` call. No `LoadDir` dependency or DLL is used.

## Troubleshooting and verification

- **PDF not found:** check `pdffilename` and keep the PDF next to `helptsepdf.mac`, or configure an absolute path.
- **No viewer opens:** open the PDF manually and configure Windows to associate `.pdf` files with your preferred viewer. Successful command dispatch does not guarantee that the viewer loaded the document.
- **Path too long:** the launcher accepts PDF paths up to 220 characters to stay within SAL's 255-character command string limit. Move the package to a shorter directory.
- **Macro not found:** execute it using its full path or add its directory to the macro search path.
- **INI edits have no effect:** check for a different `helptsepdf.ini` in TSE's current working directory, which takes precedence.

Package checks: the original PDF is copied unchanged, the INI contains `silent=false`, and archive integrity is checked. SAL compilation and Windows viewer launching have not been tested in this environment; compile and run locally, then repeat with `silent=true` to confirm the message disappears.

## Version history

- **1.0.0.0.0** - Initial README, INI, and SAL launcher; original TSE help PDF included.
