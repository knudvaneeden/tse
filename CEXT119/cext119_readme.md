# CurrExt 1.1.9 for TSE Pro

**README version:** 1.0.0.0.0  
**Original macro version:** 1.1.9  
**README created:** 2026-09-01 20:58:56 UTC  
**Original release date:** 2002-06-19  
**Author:** Michael Graham

## Description

CurrExt is a TSE Pro SAL macro that determines the logical type of the current file. It allows several filename extensions to be treated as one common extension.

For example, SAL source and include files may use `.s`, `.si`, or `.ui`. With CurrExt configured, all three can be reported as `.s`. This lets TSE and other macros apply one set of syntax, indentation, template, function-list, and other language-specific settings to related files.

CurrExt can also identify extensionless scripts from their first `#!` (shebang) line. The calculated type is stored in the session-global string named `CurrExt`.

## Compatibility and requirements

- TSE Pro 2.x, 3.x, or 4.x, as documented by the original package.
- The DOS edition of TSE Pro 2.5 additionally requires the separate **Profile** package.
- `CurrExt.s`, `FindProf.si`, and `SetCache.si` must be available when compiling.
- A writable TSE settings file, normally `TSE.INI` or `TSEPRO.INI`, is needed for custom mappings.

This is an older 2002 package. Newer TSE releases may require source adjustments before it compiles or integrates correctly.

## Files in `cext119.zip`

| File | Purpose |
| --- | --- |
| `CurrExt.s` | Main TSE SAL source file |
| `CurrExt.txt` | Original detailed documentation |
| `FindProf.si` | Include file that locates the applicable profile/INI file |
| `SetCache.si` | Include file used to detect settings changes and refresh cached values |
| `sample.ini` | Example extension, shebang, and UI configuration |
| `FILE_ID.DIZ` | Short package description |

## Installation

1. Extract `cext119.zip` into a temporary directory.
2. Copy `CurrExt.s`, `FindProf.si`, and `SetCache.si` to your TSE macro source directory.
3. If `FindProf.si` or `SetCache.si` already exists there, compare versions before replacing it. Other macros may share these include files.
4. If using TSE Pro 2.5 for DOS, install the Profile package according to that package's instructions.
5. Open `CurrExt.s` in TSE.
6. Compile the macro using TSE's **Macro Compile** command. This should create `CurrExt.mac` in the configured macro location.
7. Add `CurrExt` to TSE's macro autoload list. Put it at the **bottom** of the list so that it is loaded last; the original documentation requires CurrExt to run first for the `_ON_CHANGING_FILES_` hook.
8. Add the desired configuration to `TSE.INI` or `TSEPRO.INI`. Use `sample.ini` as a guide, but merge only the relevant sections rather than replacing your complete settings file.
9. Restart TSE, or load and run the compiled macro manually.

## Basic configuration

### Map related filename extensions

Add mappings to `[Extension_Aliases]`. Do not include the leading period:

```ini
[Extension_Aliases]
si=s
ui=s
h=c
pm=pl
cgi=pl
```

With this example, `.si` and `.ui` are reported as `.s`, `.h` is reported as `.c`, and `.pm` and `.cgi` are reported as `.pl`.

The syntax is:

```text
source_extension=logical_extension
```

### Recognize extensionless scripts

CurrExt can inspect the first line of a file for a shebang:

```ini
[Shbang_Aliases]
perl=pl
bash=sh
sh=sh
```

Example script:

```sh
#!/bin/sh
echo "hello world"
```

By default, CurrExt checks the shebang only when the file has no extension and expects the first line to begin with `#!`.

### General CurrExt settings

```ini
[CurrExt]
Always_Check_Shbang_Line=0
Loose_Definition_of_Shbang_Line=0
Shbang_Match_Options=w
Return_Actual_Extension_When_Suspended=0
```

- `Always_Check_Shbang_Line=1` checks the first line even when the file has an extension.
- `Loose_Definition_of_Shbang_Line=1` allows matching without requiring `#!` at the start.
- `Shbang_Match_Options` supplies TSE find options used for shebang matching. The original default is `iw`; use `none` for no options.
- `Return_Actual_Extension_When_Suspended=1` stores the real extension instead of an empty string while CurrExt is suspended.

## How to run and test it

1. Open a file whose extension is present in `[Extension_Aliases]`, such as `example.ui`.
2. Run the macro with the `-v` switch:

   ```text
   CurrExt -v
   ```

3. TSE should show the logical current extension on the macro status line. With `ui=s`, `example.ui` should be reported as `.s`.
4. Switch between files and repeat the test if necessary.
5. To see each derived extension while changing files, enable debug mode:

   ```text
   CurrExt -d
   ```

6. Turn debug mode off when finished:

   ```text
   CurrExt -n
   ```

## Command-line switches

| Command | Action |
| --- | --- |
| `CurrExt` | Refreshes the global value if the current buffer changed |
| `CurrExt -f` | Forces recalculation for the current file |
| `CurrExt -v` | Recalculates and displays the current logical extension |
| `CurrExt -d` | Enables debug messages when extensions are calculated |
| `CurrExt -n` | Returns to normal mode and disables debug messages |
| `CurrExt -z` | Suspends CurrExt lookups |
| `CurrExt -r` | Resumes CurrExt lookups |
| `CurrExt -h` | Enables the built-in `_ON_CHANGING_FILES_` hook |
| `CurrExt -u` | Disables the built-in `_ON_CHANGING_FILES_` hook |

## Using CurrExt from another SAL macro

CurrExt stores its result in the session-global string `CurrExt`. A macro can retrieve it with:

```sal
string currExtS[20]

currExtS = iif(IsMacroLoaded("CurrExt"),
               GetGlobalStr("CurrExt"),
               CurrExt())
```

This uses the mapped extension when CurrExt is loaded and falls back to TSE's built-in `CurrExt()` function otherwise.

## Optional TSE UI integration

The original documentation describes modifying the TSE UI source so CurrExt is called directly from `OnChangingFiles()`. This avoids dependence on macro hook order:

1. In the UI's `WhenLoaded()` procedure, run `ExecMacro("CurrExt", "-u")` to disable CurrExt's own changing-files hook.
2. At the beginning of the UI's `OnChangingFiles()` procedure, run `ExecMacro("CurrExt")`.
3. Read the result through `GetGlobalStr("CurrExt")`.
4. Recompile the customized UI.

UI modification is optional and should be attempted only after backing up the existing UI source. See Appendix B of `CurrExt.txt` for the complete original examples.

## Reloading settings

CurrExt uses the supplied SetCache support to detect settings changes. The original instructions recommend editing the INI file and running the separate `SReload` macro to reload settings without restarting CurrExt. If `SReload` is unavailable, restart TSE or reload CurrExt after changing the configuration.

## Troubleshooting

### The reported extension is unchanged

- Confirm that the mapping is under `[Extension_Aliases]` in the active TSE INI file.
- Do not put periods in the mapping keys or values: use `ui=s`, not `.ui=.s`.
- Run `CurrExt -f` to bypass the current-buffer cache.
- Run `CurrExt -v` to display the currently calculated type.
- Enable `CurrExt -d`, switch files, and inspect the displayed filename and result.

### The macro does not compile

- Verify that `FindProf.si` and `SetCache.si` are in TSE's macro source/include path.
- TSE Pro 2.5 for DOS also needs the Profile package and its `profile.si` file.
- Keep the package's original ASCII-compatible source encoding; older TSE versions do not support modern UTF-8 source reliably.

### Settings changes are not visible

- Run `CurrExt -f`.
- Run `SReload` if installed.
- Otherwise unload/reload CurrExt or restart TSE.

### Another macro performs INI processing under DOS TSE 2.5

The old Profile implementation is not fully re-entrant. Suspend CurrExt before critical INI processing with `CurrExt -z`, then resume it with `CurrExt -r`.

## Version history

| README version | Date and time (UTC) | Changes |
| --- | --- | --- |
| 1.0.0.0.0 | 2026-09-01 20:58:56 | Initial Markdown README created from `cext119.zip`, `CurrExt.txt`, the SAL source, and `sample.ini` |

Future README revisions should increment the final component sequentially: `1.0.0.0.1`, `1.0.0.0.2`, `1.0.0.0.3`, and so on.

## License and disclaimer

The original package states that CurrExt is free software distributed under the Perl Artistic License. Copyright (c) 2002 Michael Graham. The software is supplied at the user's own risk. Refer to `CurrExt.s` and `CurrExt.txt` in the archive for the original notice and authoritative documentation.
