# SPEAK.DLL — Borland C++ 5.5.1 source

Version 1.0.0.0.0 — 2026-09-13

This is a new 32-bit implementation for TSE. It does not use the earlier Visual C++ source, ATL, `sapi.h`, or `sphelper.h`. It accesses the Windows `SAPI.SpVoice` COM Automation object using standard Win32 and OLE Automation headers supplied with Borland C++ 5.5.1.

Put `speak_bcc55.cpp`, `speak.def`, and `build.bat` in the same directory, then run:

```bat
build
```

The output is `speak.dll`. Copy it beside the TSE `speak.s`/`speak.mac` files and restart TSE before testing a replacement DLL.

The DLL exports all eleven names declared by the supplied SAL interface. Speech text uses the active Windows ANSI code page, matching TSE's non-UTF-8 strings.

Asynchronous speech supports up to 32 active identifiers. The pause/resume implementation suspends/resumes its worker thread, and stop terminates that worker thread, matching the operational behavior of the original DLL closely.
