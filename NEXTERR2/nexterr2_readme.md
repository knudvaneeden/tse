# NEXTERR2

**Version:** 1.0.0.0.2  
**Date and time:** 2026-09-24 23:12:08 UTC

## Description

NEXTERR2 is a historical enhancement to TSE's `UI.S` compile macro. Its supplied `NEXTERR.DOC` describes routines for navigating to the next or previous compiler error in `$ERRORS$.TMP`, opening the reported source file and positioning the cursor at the reported line and column where available. It describes support for the output of the Microsoft Basic and C compilers used by the original author in 1993.

This updated package also includes `nexterr2.s`, a standalone companion that searches a loaded `$ERRORS$.TMP` window for Microsoft C compiler diagnostic lines. The original `NEXTERR.DOC` remains the reference for the historical `UI.S` integration. The new source has not been compiled with `sc32` in this environment.

## Run the standalone macro

1. Place `nexterr2.s` and `nexterr2.ini` in the working directory. Compile with `sc32 nexterr2.s` and load the resulting `nexterr2.mac` in TSE.
2. Compile C source so `$ERRORS$.TMP` is loaded in a second TSE window and contains the Microsoft C format described in `NEXTERR.DOC`. Keep the source window active.
3. Execute `nexterr2.mac`: `Main()` shows a version and action message unless `silent=true`, then searches for the next error. The message does not stop navigation. Alternatively use `<CtrlAlt N>` for next or `<CtrlAlt P>` for previous after loading the macro.
4. Adjust `GSRegSearch` in the source if your compiler produces a different diagnostic format. The standalone macro does not invoke your compiler.

## Original UI.S integration

1. Back up your current `UI.S` and `UI.KEY`. Read `NEXTERR.DOC` in full before editing either file.
2. In `UI.S`, locate the global variables and `mCompile` sections. Follow the original document's directions for adding the `BASLANG` and `CLANG` constants, initializing `language`, declaring `regsearch` and `SetLanguage`, and incorporating `FindError`, `NextError`, `bCompile`, and `SetLanguage`. Integrate references to existing UI variables and procedures carefully; the document is an example rather than a ready-to-build source file.
3. Adapt `bCompile` to the compiler and diagnostic format actually in use. The sample calls `bc` and expects specific 1993 Microsoft compiler messages in `$ERRORS$.TMP`. Verify compiler commands, regexes, paths, and TSE API compatibility before compiling `UI.S`.
4. In `UI.KEY`, assign keys to `NextError(TRUE)` and `NextError(FALSE)`, as shown in `NEXTERR.DOC` (its examples use `<F3>` and `<F4>`). Rebuild and load the customized UI using the procedure for your TSE version.
5. Compile source through the integrated `bCompile` procedure so an error result buffer is available. Use the assigned keys to move forward or backward through errors. The example expects a source and error buffer in separate windows.

## Configuration

`nexterr2.ini` contains `[nexterr2] silent=false`. The standalone macro reads it from the current directory. Set `silent=true` to suppress the introductory `Warn()` from `Main()`; navigation and operational error messages still run. The historical `UI.S` excerpt in `NEXTERR.DOC` does not read the INI file.

## Included files

- `NEXTERR.DOC` — original instructions and sample code by Andreas Martini, dated 1993-07-20.
- `nexterr2.s` — standalone navigation source, with `Main()` and key definitions.
- `nexterr2.ini` — startup message setting.
- `nexterr2_readme.md` — this guide.
