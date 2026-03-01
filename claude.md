# CLAUDE.md - TSE SAL Development Environment

## Project Overview

This project involves development with **The Semware Editor Professional (TSE)**
and its **SAL (Semware Application Language)** on **Windows 11 Professional**.

---

## Environment

- **OS**: Windows 11 Professional (64-bit)
- **Editor/IDE**: The Semware Editor Professional (TSE)
- **Primary Language**: SAL (Semware Application Language)
- **Shell**: TCC (Take Command Console) preferred; PowerShell as fallback
- **Secondary Languages**: C/C++ (Borland C++ 5.5), PowerShell, AutoHotkey
- **WSL**: Available (Ubuntu) for cross-platform testing and Linux tooling
- **Version Control**: Subversion (SVN)

---

## SAL Language Specifics

### Critical Constraints

- **String length limit**: SAL strings are limited to **255 characters maximum**
  - always design around this; use chunking, temp files, or IPC where needed.
- **No native threading** - SAL is single-threaded; use external processes for
  async or parallel work.
- **Integer types**: SAL uses 32-bit signed integers; be mindful of overflow.
- **No native JSON/XML parsers** - parse structured data via external tools
  (PowerShell, Python) and pipe results back.

### Naming and Style Conventions

- Macro names: `PascalCase` (e.g., `ScrollMenu`, `CompileAndRun`)
- Local variables: `camelCase` starting with a lowercase letter (e.g. `thisIsAVariable`, `thisIsAnInteger`, `aString`)
- Constants: `UPPER_SNAKE_CASE`
- Global variables: camelCase with uppercase `G` suffix (e.g. `thisIsAGlobalIntegerG`, `thisIsAGlobalStringG`)
- Procedures: noun-verb format (e.g. `FileBuildList`, `LogOpenWindow`)

### File Extensions

- SAL source files: `.s`, `.si`
- Compiled macro files: `.mac`
- TSE configuration: `.ui`, `.cfg`, `.dat`, `.ini`, `.kbd`
- TSE DLL: `.dll`
- TSE syntax highlighting: `.txt` (source), `.syn` (compiled)
- TSE documentation: `.me`, `.doc`
- TSE help: `.hlp`

### Common Patterns

- Use `ExecMacro()` to call other macros by name
- Use `Set(Expansion, OFF)` / `Set(Expansion, ON)` to control key expansion
- Prefer `Warn()` for debugging; remove before release
- Use `GetEnvStr()` to access Windows environment variables
- File I/O: prefer `EditFile()`, `SaveFile()`; otherwise use `fOpen()`, `fRead()`, `fWrite()`, `fClose()` idioms
- Always declare all variables at the top of a function or procedure, immediately
  after the function/procedure name - never deeper inside the body:
  ```
  // Correct:
  PROC Main()
   INTEGER i = 0
   STRING s1[255] = ""
   STRING s2[255] = ""
   Warn( i )
   Warn( s1 )
   Warn( s2 )
  END

  // Not correct:
  PROC Main()
   STRING s1[255] = ""
   //
   IF ( 1 > 0 )
   ENDIF
   //
   INTEGER i = 0
   STRING s2[255] = ""
   Warn( i )
  END
  ```
- For Windows API calls: use the `DllCall()` facility where available

---

## Build and Compilation

- Compile SAL macros from within TSE using the built-in compiler or via macro
- **Semware Compiler (32-bit)**: `F:\WORDPROC\tse32_v45024\sc32.exe`
- For C/C++ components: use **Borland C++ 5.5** (`bcc32.exe`)
- Build scripts live in TCC `.bat` batch files where possible
- Output binaries go to `F:\BBC\TAAL\`

### Typical Compilation Workflow

```
sc32.exe mymacro.s               # compile SAL macro from command line
G:\LANGUAGE\COMPUTER\CPP\EMBARCADERO\BORLAND\BCC55\Bin\bcc32.exe -w -O2 mybridge.c  # compile C bridge component
```

---

## Architecture Notes

### MCP Python Bridge

When SAL's 255-char string limit is a bottleneck for MCP (Model Context Protocol)
integration, the architecture uses:

1. **SAL side**: writes request payload to a temp file, spawns Python via `Dos()`
2. **Python bridge** (`mcp_bridge.py`): reads temp file, calls MCP/Claude API,
   writes response back to another temp file
3. **SAL side**: reads response temp file, processes in chunks ó 255 chars

Always keep temp files in `%TMP%\tse_mcp\` and clean up after each call.

### Window Management

- On **Windows**: use `DllCall()` to Windows API (`user32.dll`) for window ops

  Example:
  ```
  // ---------------------------
  // Windows Win32 API
  // ---------------------------
  DLL "<kernel32.dll>"
   INTEGER PROC _GetConsoleWindow() : "GetConsoleWindow"
  END
  DLL "<user32.dll>"
   INTEGER PROC ShowWindow( INTEGER hWnd, INTEGER flags ) : "ShowWindow"
  END
  DLL "<user32.dll>"
   INTEGER PROC GetForegroundWindow() : "GetForegroundWindow"
  END
  DLL "<user32.dll>"
   INTEGER PROC _IsZoomed( INTEGER hWnd ) : "IsZoomed"
  END
  integer proc Windows_IsMaximized()
      integer h = 0
      h = _GetConsoleWindow()
  end
  ```
- On **WSL/Linux**: use `wmctrl` and `xdotool` via `Dos()` calls
- Guard platform-specific code with `WhichOS()` checks (preferred):
  ```
  IF ( ( WhichOS() == _WINDOWS_ ) OR ( WhichOS() == _WINDOWS_NT_ ) )
  ENDIF
  IF ( WhichOS() == _LINUX_ )
  ENDIF
  ```
  Only use preprocessor directives if `WhichOS()` is not otherwise possible:
  ```
  #IFDEF WIN32
    // do something
  #ENDIF
  #IFDEF LINUX
    // do something
  #ENDIF
  ```

---

## Cross-Platform Guidelines

- Always test macros in both **Windows native TSE** and **TSE under WSL** where applicable
- Use `WhichOS()` to detect the platform (see Window Management section above)
- Path separators: use `\` for Windows paths, `/` for Linux; abstract via a
  `NormalizePath()` helper macro

---

## Coding Standards for Claude

When generating SAL code, please:

1. **Respect the 255-char string limit** - never construct strings that may
   exceed this; split across multiple variables.
2. **Include version comments** at the top of each file:
   ```
   // MyMacro.s  v1.0  YYYY-MM-DD  Brief description
   ```
3. **Comment non-obvious logic** - SAL syntax is unfamiliar to most readers.
4. **Avoid deprecated TSE calls** - prefer current API equivalents.
5. **Always increase the version number** in the file header comment. The version
   is stored in the header as `<version>1.0.0.0.1</version>` - always increment
   the last number by 1 when modifying a file. Example header format:
   ```
   // library: file: create: screenshot: to: file <description></description> <version control></version control> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=creafitf.s) [<Program>] [<Research>] [kn, ri, fr, 20-02-2026 15:18:24]
   ```
   Increment sequence: `1.0.0.0.1`  `1.0.0.0.2`  `1.0.0.0.3`  ...
6. **Use TCC `.bat` scripts** for shell automation.
7. **Use PowerShell** for tasks requiring JSON, HTTP, or complex string ops
   that SAL cannot handle natively.
8. **Wrap Windows API calls** in error-checked helpers; log failures to a TSE
   scratch buffer named `*MCP-Log*` or `*Debug*`.

---

## Key Files and Directories

```
.\                          Project root
.\src\                      SAL source files (.s)
.\mac\                      Compiled macros (.mac)
.\bin\                      C/C++ compiled binaries
.\scripts\                  PowerShell and TCC helper scripts
.\bridge\                   Python MCP bridge scripts
.\docs\                     Documentation
.\svn\                      Subversion working copy metadata
%TMP%\tse_mcp\              Temp files for MCP bridge IPC
```

## TSE Installation

- **TSE executable**: `F:\WORDPROC\tse32_v45024\tse32.exe`
- **TSE root**: `F:\WORDPROC\tse32_v45024\`
- **SAL macro source**: `F:\WORDPROC\tse32_v45024\mac\`
- **Compiled macros**: `F:\WORDPROC\tse32_v45024\mac\` (`.mac` files alongside `.s`)
- **TSE help file**: `F:\WORDPROC\tse32_v45024\help\tsehelp.hlp`

When referencing TSE paths in scripts or macros, use `F:\WORDPROC\tse32_v45024\`
as the base. In WSL, this maps to `/mnt/f/WORDPROC/tse32_v45024/`.

## Personal SAL Working Directory

- **Windows**: `F:\BBC\TAAL\`
- **WSL**: `/mnt/c/TEMP/tse_linux/knud/`
- All personal `.s` (SAL source) and `.mac` (compiled macro) files live here.
- When generating new SAL files or referencing existing ones, default to this
  directory unless otherwise specified.

## Python

- **Python executable**: `G:\LANGUAGE\COMPUTER\PYTHON\PYTHON\python.exe`
- **Python bin directory**: `G:\LANGUAGE\COMPUTER\PYTHON\PYTHON\`
- **WSL equivalent**: `/mnt/g/LANGUAGE/COMPUTER/PYTHON/PYTHON/`
- Use this Python for all MCP bridge scripts and any SAL-invoked Python tooling.
- When generating `Dos()` calls from SAL that invoke Python, use the full path.

## Borland C++ 5.5

- **Compiler executable**: `G:\LANGUAGE\COMPUTER\CPP\EMBARCADERO\BORLAND\BCC55\Bin\bcc32.exe`
- **Bin directory**: `G:\LANGUAGE\COMPUTER\CPP\EMBARCADERO\BORLAND\BCC55\Bin\`
- **WSL equivalent**: `/mnt/g/LANGUAGE/COMPUTER/CPP/EMBARCADERO/BORLAND/BCC55/Bin/bcc32.exe`
- Use the full path when generating build scripts or `Dos()` calls that invoke the compiler.

## Subversion (SVN)

- **Executable**: `G:\CYGWIN\bin\svn.exe`
- **WSL equivalent**: `/mnt/g/CYGWIN/bin/svn.exe`
- Use the full path when generating scripts or `Dos()` calls that invoke SVN commands.

## AutoHotkey

- **Executable**: `G:\MACRORECORDER\AUTOHOTKEY\AutoHotkey64.exe`
- **WSL equivalent**: `/mnt/g/MACRORECORDER/AUTOHOTKEY/AutoHotkey64.exe`
- Use the full path when generating `Dos()` calls from SAL or scripts that invoke AutoHotkey scripts.

## WSL / Linux TSE

- **WSL distro**: Ubuntu
- **Startup command**:
  ```
  start wsl -d Ubuntu -- xterm -fa Monospace -ge 118x29 -fs 8 -e "/mnt/c/temp/tse_linux/tse45014working/e" -r -e "/mnt/c/temp/tse_linux/knud/knudstartlinux" "/mnt/c/temp/tse_linux/knud/ddd.s"
  ```
- **Linux TSE executable**: `/mnt/c/temp/tse_linux/tse45014working/e`
- **Linux TSE personal startup macro**: `/mnt/c/temp/tse_linux/knud/knudstartlinux`
- **Linux TSE personal working file**: `/mnt/c/temp/tse_linux/knud/ddd.s`
- **xterm settings**: Monospace font, 118x29 columns/rows, 8pt font size
- Use this command verbatim when generating scripts that launch TSE under WSL/Linux.

---

## Do Not

- Do **not** use `localhost` HTTP calls from within SAL - route through the
  Python bridge instead.
- Do **not** generate SAL string literals longer than ~200 chars (leave buffer).
- Do **not** use PowerShell `Write-Host` in bridge scripts - use `Write-Output`
  or file output so SAL can capture it.
- Do **not** assume Unicode support in SAL - ASCII/ANSI only.

---

## References

- TSE SAL Reference: local help via `<F1>` in TSE, or `tse.hlp`
- Borland C++ 5.5: `bcc32 --help`
- TCC documentation: `help` command in TCC shell
- MCP specification: https://modelcontextprotocol.io/
- Anthropic API docs: https://docs.claude.com/

---

*This file is read by Claude Code and Claude AI to understand project context.*
*Keep it up to date as the architecture evolves.*
