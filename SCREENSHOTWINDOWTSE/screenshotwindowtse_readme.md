# SCREENSHOTWINDOWTSE

**Version:** 1.0.0.0.18  
**Date:** 2026-09-20  
**Package:** `screenshotwindowtse1.0.0.0.18.zip`  
**Prepared with:** GPT-5.6 Sol

## Description

`SCREENSHOTWINDOWTSE` captures the currently active TSE window, equivalent in
target to Windows **Alt+PrtScreen**.

Version `1.0.0.0.10` moves all configuration and input handling into the TSE
SAL macro. The DLL no longer reads `screenshotwindowtse.ini` and does not choose
the output pathname.

Supported output types are:

- `png` - default
- `jpg`
- `jpeg` - accepted as an alias for `jpg`
- `bmp`

PNG is the distributed default.

## Files

- `screenshotwindowtse.s` - TSE SAL front end.
- `screenshotwindowtse_dll.c` - Borland C++ 5.5.1 Win32 helper.
- `screenshotwindowtse.ini` - defaults read by TSE SAL.
- `build.bat` - builds the DLL and compiles the macro.
- `screenshotwindowtse_readme.md` - this documentation.


## Internal structure

Version `1.0.0.0.11` keeps the `Ask()` and parameter logic in `Main()` and the actual
implementation.

The two main procedures are:

- `Main()` - reads the INI file, reads macro parameters, shows `Ask()` prompts when needed, and then calls the implementation.
- `PROCDoScreenshotWithValues(filename, directory, filetype, showFinalResultB)` - performs the actual screenshot implementation.

This keeps the code in one `.s` file while allowing other SAL code to bypass
the interactive prompts and call the implementation directly.

### Calling the implementation directly

From another SAL procedure, call:

```sal
PROCDoScreenshotWithValues("batchshot", "C:\TEMP", "png", FALSE)
```

This bypasses the `Ask()` prompts and uses the supplied values directly.

If the filename is empty, the implementation still generates the default
timestamped filename:

```sal
PROCDoScreenshotWithValues("", "C:\TEMP", "jpg", FALSE)
```

### Main entry point

`Main()` now contains the `Ask()` and parameter logic directly and then calls `PROCDoScreenshotWithValues()`.

## What is handled in TSE

The SAL macro handles:

1. locating `screenshotwindowtse.ini`;
2. reading `filetype`, `filename`, and `directory`;
3. reading macro parameters;
4. showing `Ask()` prompts;
5. applying the selected extension;
6. generating the default timestamped filename;
7. resolving relative directories;
8. creating the output directory;
9. constructing the complete output pathname;
10. passing the final pathname and numeric format to the DLL.

The DLL does not parse the INI file.

## INI file

```ini
[Save]
filetype=png
filename=
directory=screenshots
showfinalresult=true
windowtitle=
```

### `filetype`

Accepted values:

```text
png
jpg
jpeg
bmp
```

`jpeg` is normalized to `jpg`.

Invalid or empty values fall back to `png`.

### `filename`

If empty, TSE generates a timestamped filename such as:

```text
screenshotwindowtse_20260920_091530.png
```

The extension is always adjusted to match the selected file type.

A fixed value is also allowed:

```ini
filename=myshot
```

With `filetype=jpg`, the proposed filename becomes:

```text
myshot.jpg
```

### `directory`

The distributed default is:

```ini
directory=screenshots
```

This means a `screenshots` subdirectory beside the running macro.

An absolute path can also be used:

```ini
directory=F:\screenshots\tse
```


### `showfinalresult`

Controls only the final success/error result box shown by TSE after the capture.

```ini
showfinalresult=true
```

shows the final `Warn()` result box.

```ini
showfinalresult=false
```

suppresses the final result box.

The values `false`, `no`, `0`, and `off` disable the final result box.
Any other value, including an empty or missing setting, leaves the result box enabled.

This option does not suppress the filename, directory, or file-type `Ask()` prompts.
To avoid those prompts in a batch-style invocation, pass all three macro parameters.

## Interactive use

Run:

```text
screenshotwindowtse
```

TSE prompts for:

1. file type;
2. filename;
3. directory;
4. window title.

The values from the INI file are used as initial proposals. The user can edit
them before the screenshot is made.

## Macro parameters

Filename, directory, and optionally file type can be passed to the macro.

The parameter separator is `|` so Windows paths containing spaces remain easy
to pass.

Syntax:

```text
screenshotwindowtse filename|directory|filetype|silent|windowtitle
```

Examples:

```text
screenshotwindowtse testshot|C:\TEMP
```

This supplies the filename and directory. The file type is still prompted.
The final result box still follows the INI setting.

```text
screenshotwindowtse testshot|C:\TEMP|jpg
```

This saves:

```text
C:\TEMP\testshot.jpg
```

```text
screenshotwindowtse report|F:\shots|bmp
```

This saves:

```text
F:\shots\report.bmp
```

A parameter overrides the corresponding INI/interactive default.


### Fourth macro parameter: silent or not

The fourth macro parameter overrides the INI setting `showfinalresult`.

Accepted values include:

```text
silent
nosilent
true
false
yes
no
1
0
on
off
```

Meaning:

- `silent`, `false`, `no`, `0`, `off` -> do **not** show the final result box
- `nosilent`, `true`, `yes`, `1`, `on` -> **do** show the final result box

When the fourth parameter is omitted, the macro uses the INI setting
`showfinalresult=`.


## Precedence

For each supplied field, the effective priority is:

```text
macro parameter
    over
Ask() value
    over
INI proposal
    over
built-in default
```

This also applies to the silent/non-silent final-result setting, except that
there is no `Ask()` prompt for that setting.

The built-in defaults are:

```text
filetype=png
filename=<timestamped screenshotwindowtse name>
directory=<macro directory>\screenshots
```


## Selecting another window by title


When running interactively, the macro now also asks for the target window title.

- Enter an empty value to capture the current foreground window.
- Enter a full title or title fragment to capture another visible top-level window.
- Single or double outer quotes are accepted and stripped by TSE SAL.

If the fifth macro parameter is supplied, that parameter still overrides the interactive prompt.


Version `1.0.0.0.17` can capture a different visible top-level Windows window.

The fifth macro parameter is an optional complete window title or title
fragment:

```text
screenshotwindowtse filename|directory|filetype|silent|windowtitle
```

Examples:

```text
screenshotwindowtse notepad|C:\TEMP|png|silent|"Untitled - Notepad"
```

```text
screenshotwindowtse browser|C:\TEMP|jpg|nosilent|'Mozilla Firefox'
```

```text
screenshotwindowtse calc|C:\TEMP|png|silent|Calculator
```

The title may be unquoted, enclosed in double quotes, or enclosed in single
quotes. TSE SAL strips matching outer quotes before passing the title to the
DLL.

The window-search order is:

1. visible top-level window with an exact case-insensitive title match;
2. otherwise, the first visible top-level window containing the supplied text
   case-insensitively.

If `windowtitle` is empty, the current foreground window is captured exactly as
in earlier versions.

The INI file also supports:

```ini
windowtitle=
```

An empty value preserves foreground-window behavior. A non-empty value supplies
the default target window. A non-empty fifth macro parameter overrides it.

The window title is transferred to the DLL one character at a time, just like
the output pathname, so no writable SAL string pointer is passed across the DLL
boundary.

The reusable implementation procedure is now:

```sal
PROCDoScreenshotWithValues(STRING filenameS, STRING directoryS, STRING fileTypeS, INTEGER showFinalResultB, STRING windowTitleS)
```

For example, another SAL routine can bypass `Main()` and capture Notepad
directly:

```sal
PROCDoScreenshotWithValues("notepad", "C:\TEMP", "png", FALSE, "Notepad")
```

Or pass an empty title to retain foreground-window capture:

```sal
PROCDoScreenshotWithValues("current", "C:\TEMP", "png", FALSE, "")
```


## DLL interface

The SAL/DLL boundary avoids passing SAL string pointers.

The final pathname is transferred one character at a time through:

```text
SWTSResetOutputPath()
SWTSAddOutputChar()
```

The format is transferred numerically through:

```text
SWTSSetFileType()
```

Values are:

```text
1 = PNG
2 = BMP
3 = JPG
```

The capture is then performed by:

```text
SWTSCaptureActiveWindow()
```

The DLL uses Windows GDI for capture and dynamically loads `gdiplus.dll` for
PNG, JPG, and BMP encoding.

No GDI+ import library is required at build time.

## Build

Run:

```bat
build.bat
```

The DLL command is:

```bat
bcc32 -tWD -O2 -u- -escreenshotwindowtse.dll screenshotwindowtse_dll.c
```

The SAL source is then compiled with:

```bat
sc32 screenshotwindowtse.s
```

After a successful build:

```text
screenshotwindowtse.dll
screenshotwindowtse.mac
```

are created.

Restart TSE after replacing the DLL because the old DLL can remain loaded in
the editor process.

## Testing

### PNG

Keep:

```ini
filetype=png
```

Run the macro and confirm that the saved file opens as PNG.

### JPG

Set:

```ini
filetype=jpg
```

or enter `jpg` at the file-type prompt.

Confirm that the result has `.jpg` and opens as JPEG.

### JPEG alias

Set:

```ini
filetype=jpeg
```

The macro normalizes this to:

```text
jpg
```

and saves a `.jpg` file.

### BMP

Set:

```ini
filetype=bmp
```

Confirm that a BMP is produced.

### Macro parameters

Run:

```text
screenshotwindowtse abc|C:\TEMP|png
```

and confirm:

```text
C:\TEMP\abc.png
```


### Procedure header style

The implementation routine now uses the conventional parameter style directly
in the procedure header:

```sal
PROCDoScreenshotWithValues(STRING filenameS, STRING directoryS, STRING fileTypeS, INTEGER showFinalResultB)
```

Because TSE SAL string parameters are read-only, the procedure copies those
incoming string parameters to local strings internally only when it needs to
modify them.


## Version history

### 1.0.0.0.18 - 2026-09-20

- Added an interactive `Ask()` prompt for the window title to capture.
- The interactive order is now: file type, filename, directory, window title.
- An empty window-title input keeps the existing behavior and captures the current foreground window.
- A non-empty window-title input captures another visible top-level window by title.
- The fifth macro parameter still overrides the interactive window-title prompt.
- INI `windowtitle=` remains the default proposal for the new prompt.

### 1.0.0.0.17 - 2026-09-20

- Added optional capture of another visible top-level window by title.
- Added fifth macro parameter `windowtitle`.
- Accepts unquoted titles and titles enclosed in matching single or double quotes.
- Added INI setting `windowtitle=`.
- Empty title retains the existing foreground-window behavior.
- DLL searches exact case-insensitive title first, then first case-insensitive partial match.
- Added `SWTSResetWindowTitle()`, `SWTSAddWindowTitleChar()`, and `SWTSCaptureWindow()`.
- Added result code `-6` when no matching target window is found.
- Extended `PROCDoScreenshotWithValues()` with a `STRING windowTitleS` parameter.

### 1.0.0.0.17 - 2026-09-20

- Added a fourth TSE SAL macro parameter for silent or non-silent operation.
- Macro syntax is now `screenshotwindowtse filename|directory|filetype|silent|windowtitle`.
- The fourth parameter overrides the INI `showfinalresult` setting.
- Accepted values include `silent`, `nosilent`, `true`, `false`, `yes`, `no`,
  `1`, `0`, `on`, and `off`.
- `silent` suppresses the final result box.
- `nosilent` forces the final result box to be shown.

### 1.0.0.0.15 - 2026-09-20

- Moved the file-type `Ask()` to the end of the interactive input sequence.
- The interactive order is now filename, directory, then file type.
- After the final file-type selection, `Main()` reapplies the matching
  `.png`, `.jpg`, or `.bmp` extension to the filename before calling
  `PROCDoScreenshotWithValues()`.
- Macro parameters continue to bypass the corresponding `Ask()` prompts.

### 1.0.0.0.12 - 2026-09-20

- Kept the implementation routine parameters directly in the procedure header
  as `filenameS`, `directoryS`, `fileTypeS`, and `showFinalResultB`.
- Adjusted the implementation routine to copy those string parameters into
  local strings internally before modifying them.
- This keeps the usual TSE SAL procedure style while still respecting the rule
  that string parameters are read-only.

### 1.0.0.0.11 - 2026-09-20

- Moved the `Ask()` and macro-parameter handling back into `Main()`.
- Removed the separate `PROCDoScreenshotInteractive()` wrapper.
- Kept `PROCDoScreenshotWithValues(filename, directory, filetype, showFinalResultB)`
  as the reusable non-interactive implementation routine.
- This matches the usual TSE SAL structure: `Main()` gathers inputs and then
  calls a subroutine outside `Main()` for the real work.

### 1.0.0.0.10 - 2026-09-20

- Separated the interactive `Ask()` handling from the actual implementation.
- Added `PROCDoScreenshotInteractive()` for INI reading, macro-parameter parsing,
  and user prompts.
- Added `PROCDoScreenshotWithValues(filename, directory, filetype, showFinalResultB)`
  for the real screenshot implementation.
- `Main()` now calls only the interactive wrapper.
- This keeps the code in one `.s` file and allows other SAL code to bypass the
  prompt logic and call the implementation directly.

### 1.0.0.0.9 - 2026-09-20

- Added INI setting `showfinalresult=true`.
- `showfinalresult=false` suppresses the final TSE success/error result box.
- `false`, `no`, `0`, and `off` are treated as disabled.
- The option controls only the final result box; it does not suppress `Ask()` input prompts.
- All handling remains in TSE SAL. The DLL is unchanged functionally.

### 1.0.0.0.8 - 2026-09-20

- Fixed the leading space in automatically generated screenshot filenames.
- `GetTimeStr()` may return a single-digit hour with a leading space and may
  include `AM` or `PM`, depending on the active TSE/Windows time format.
- The SAL macro now parses the time numerically and generates a fixed
  24-hour `HHMMSS` timestamp.
- Example corrected filename:
  `screenshotwindowtse_20260920_091200.png`.
- No change to PNG/JPG/BMP support or parameter/INI precedence.

### 1.0.0.0.7 - 2026-09-20

- Fixed SAL compiler error `cannot reassign constant string parameter`.
- TSE SAL string parameters are read-only.
- `FNNormalizeFileTypeS()` now copies its input parameter to a local string before modifying it.
- `FNApplyFileTypeS()` now copies both input strings to local strings before modifying them.
- `FNResolveDirectoryS()` now copies its directory input parameter to a local string before modifying it.
- Proactively fixed every string-parameter reassignment in the new version instead of only the first reported line.
- No change to PNG/JPG/BMP support, INI layout, macro-parameter syntax, or DLL behavior.

### 1.0.0.0.6 - 2026-09-20

- Added PNG output and made PNG the default.
- Added JPG output.
- Added `jpeg` as an alias for `jpg`.
- Retained BMP output.
- Moved INI reading entirely into TSE SAL.
- Added INI `filetype`, `filename`, and `directory` settings.
- Added TSE `Ask()` input for file type, filename, and directory.
- Added macro parameters for filename, directory, and optional file type.
- Added explicit precedence between parameters, Ask input, INI proposals, and
  built-in defaults.
- The DLL no longer reads or interprets the INI file.
- The final path is passed to the DLL one character at a time to avoid unsafe
  SAL string-pointer exchange.
- PNG/JPG/BMP encoding uses dynamically loaded Windows GDI+.
- Avoids string-valued `#define`; text constants use normal SAL strings.

### 1.0.0.0.5

- First confirmed working BMP build and runtime capture.

Future versions should continue with `1.0.0.0.7`, `1.0.0.0.8`, and so on.
