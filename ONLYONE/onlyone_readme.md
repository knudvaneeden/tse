# ONLYONE for TSE

**Package version:** 1.0.0.0.1  
**Date and time:** 2026-09-26 12:19:48 CEST  
**Prepared with:** OpenAI GPT-6

## Description

ONLYONE is a Windows 32-bit TSE SAL macro originally by Rick VanNorman, with later changes by Michael Graham. It keeps one primary TSE editor session. Starting another TSE instance with a filename passes that request to the running editor. The original optional `+f` mode can keep the new process hidden until its file is closed, useful for an external editor invoked by another program.

This package adds an initial informational `Warn()` message controlled by `onlyone.ini`. The original `OnlyOne.txt` contains detailed explanations of its focus and client/server settings.

## Contents

- `OnlyOne.s` — SAL source, including the startup message.
- `onlyone.ini` — startup message setting.
- `onlyone_readme.md` — these instructions.
- `OnlyOne.txt` — original detailed documentation.
- `FILE_ID.DIZ` — original package description.

## Install and run

1. Extract all files into a working directory. Keep `onlyone.ini` in TSE's current working directory when starting TSE.
2. Compile with the 32-bit SAL compiler matching your TSE installation: `sc32 OnlyOne.s`.
3. Add the resulting `OnlyOne.mac` to TSE's **Macro → AutoLoad List**. The macro's `WhenLoaded()` calls `Main()`, which shows the notice and initializes ONLYONE once.
4. Start TSE with a file, for example `g32 readme.txt`. While it stays open, run `g32 another.txt` from a command prompt. The existing TSE session should open the second file.
5. To make an external application wait until its file is closed, use `g32 +f message.txt`; consult `OnlyOne.txt` for the other supported modes and their limitations.

The macro also supports inclusion in a custom `.UI` source as described at the start of `OnlyOne.s`. In that setup, call `Main()` in the UI `WhenLoaded()` routine, and compile with `USE_AS_STANDALONE_MACRO` set to `FALSE`.

## Configuration

`onlyone.ini` contains:

```ini
[Settings]
silent=false
```

With `silent=false`, `Main()` shows a `Warn()` box describing ONLYONE at startup. Set `silent=true` to suppress this startup box. An absent INI or absent key defaults to `false`. This setting controls only the added startup message; existing error messages and optional debug warnings remain available. If TSE starts in another working directory, put the INI there or start TSE from the directory containing it. Restart or reload the macro after changing the setting.

## Help

- If a second TSE window remains open, confirm the compiled macro is in the AutoLoad List and that you are using the Win32 TSE build.
- If compilation fails, use the matching version of the 32-bit SAL compiler and inspect the original source's Windows DLL declarations.
- If the startup notice appears unexpectedly, verify that `onlyone.ini` is in TSE's current working directory and contains `silent=true` under `[Settings]`.
- For `+f` behavior, focus handling, and configuration constants, read `OnlyOne.txt` before changing them.

## Version history

- **1.0.0.0.1** — Moved `Main()` after `OnlyOne()` to resolve SAL compiler error 2335 on the forward call.

- **1.0.0.0.0** — Added this README, `onlyone.ini`, and a configurable informational startup `Warn()` in `Main()`.
