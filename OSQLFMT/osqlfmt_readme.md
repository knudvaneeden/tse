# OSQLFMT

**Package version:** 1.0.0.0.0  
**Date and time:** 2026-09-26 13:27:28 CEST  
**Original macro:** Carlo Hogeveen, 21 June 2001  
**Package preparation:** OpenAI Codex (GPT-6)

## Description

OSQLFMT reformats Oracle `INSERT` scripts exported by Toad for easier editing in The SemWare Editor (TSE). It joins each SQL statement onto one line when that line fits within TSE's maximum line length. It then aligns fields across groups of statements, left justifying text and right justifying numeric values. A blank line separates groups (typically tables).

The macro changes the current file. Work on a copy if you need to retain the original export.

## Package contents

| File | Purpose |
| --- | --- |
| `OSQLFMT.S` | TSE SAL macro source |
| `INTARRAY.SI` | Required include for integer arrays |
| `osqlfmt.ini` | Final message setting |
| `osqlfmt_readme.md` | These instructions |
| `FILE_ID.DIZ` | Original package description |

## Compile and run

1. Extract all files into the same working directory. Keep `INTARRAY.SI` alongside `OSQLFMT.S` for compilation.
2. From that directory, compile **only** the main source with the 32-bit TSE SAL compiler:

   ```bat
   sc32 OSQLFMT.S
   ```

3. Confirm that compilation creates `OSQLFMT.MAC`. Do not compile `INTARRAY.SI` separately.
4. Keep `osqlfmt.ini` in the current working directory when running the macro. If TSE cannot find it, the source defaults to `silent=false`.
5. Open a Toad-exported Oracle INSERT script in TSE.
6. Run the compiled macro from TSE's macro command, using `osqlfmt` as its name. There are no arguments.
7. Review the reformatted SQL, particularly quoted values and any statements that were too long to join, before saving or executing it.

The macro displays `Working ...` while processing and `Done` when it finishes. By default, it also displays an informative final `Warn()` box. The macro purges itself when finished, so load or run it again for another script.

## Configuration

Edit `osqlfmt.ini` in the directory from which TSE runs the macro:

```ini
[OSQLFMT]
silent=false
```

| Value | Effect |
| --- | --- |
| `silent=false` | Show the final `Warn()` box (default). |
| `silent=true` | Suppress the final `Warn()` box. |

The progress and completion messages remain available regardless of this setting. If a statement cannot be joined because it exceeds TSE's maximum line length, the final box mentions it when `silent=false`.

## Input expectations and limitations

- The input should follow Toad's Oracle export format, including a semicolon terminating each INSERT statement and blank lines separating tables or groups.
- An INSERT statement that exceeds TSE's maximum line length can remain partly wrapped.
- Text values containing embedded single quotes may acquire unwanted spaces. Review these values carefully.
- The macro processes the entire current file, rather than only a marked block.
- The formatting logic has an internal column limit. Check unusually wide INSERT statements.
- The original source is from 2001. This revised package has not been compiled or run in the user's Windows TSE environment; verify with `sc32` and a sample export.

## Version history

| Version | Date and time | Changes |
| --- | --- | --- |
| 1.0.0.0.0 | 2026-09-26 13:27:28 CEST | Added README, INI default, and configurable final user message. |
