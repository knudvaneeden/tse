# PICKLITE

Version: **1.0.0.0.17**  
Date and time: **26 September 2026, 20:39 CEST**  
Original idea and macro: Christopher Antos. Win32 adaptation: OpenAI Codex.

## Description

PICKLITE highlights directory rows in TSE's file picklist. The SAL macro reads visible TSE screen rows and updates the attributes of matching rows without rewriting their characters. The color calculation runs entirely in SAL and gives directory text its own background and foreground colors.

## Build and run

1. Extract the archive to one directory. Run `sc32 PICKLITE.S` to compile `PICKLITE.MAC` for your TSE version.
2. In TSE File PickList Settings, either the `[dir]` directory marker shown in your screenshot or the **Precede Directory Entries with Slash** option is supported.
3. Put the newly built `PICKLITE.MAC` and `picklite.ini` together in the macro directory. Execute the new macro and open a file picklist. Rows beginning with `[dir]` or a space followed by `\` should display contrasting directory text through their last non-space character.

## Configuration

```ini
[Picklite]
silent=false
debug=false
```

With `silent=false`, running the macro displays an informative `Warn()` box. With `silent=true`, it does not; highlighting still works. The macro reads the INI from the directory containing the compiled `PICKLITE.MAC` (using `CurrMacroFilename()`). Debug reports are off by default. Set `debug=true` temporarily to see callback counts, matched rows, and the first old/new attribute values.

## Troubleshooting

The old **Introduction to PICKLITE.MAC** help panel in version 1.0.0.0.2 came from the unchanged `Main()` source mistakenly packaged in that version. This version replaces that `Main()` with the requested `Warn()` setting. If highlighting is absent, check whether a directory marker is visible. No DLL is required.

The SAL source was not compiled in this environment; the Win32 GUI behavior needs to be checked in TSE. With `debug=true`, open and close a picklist, then execute PICKLITE again to show the counters. This second invocation also works if the cleanup callback did not run.

## Version 1.0.0.0.12

Corrected the directory-prefix check so it requires an actual space and backslash instead of comparing two characters with a single space. Highlighting ends at the last visible non-space character, leaving the remainder of the picklist row uncolored.

## Version 1.0.0.0.13

This version passed foreground value `14` directly to the DLL. Subsequent diagnostics showed that the DLL still returned zero for an old attribute of `112`.

## Version 1.0.0.0.14

The latest diagnostic actually showed `old/new=112/0`; the DLL returned a black-on-black attribute. Attribute calculation is now done in SAL. A light gray background (`112`) gets dark blue text (`113`); a blue selection background gets bright white text. No DLL or C compiler is needed.

## Version 1.0.0.0.15

Directory entries now use yellow text on blue (`30`). When selected, they use black text on cyan (`48`). The color covers the entry text, ending at its last non-space character; file rows retain their TSE colors.

## Version 1.0.0.0.16

Prevent repeated idle callbacks from changing directory color `30` into `48` or repainting already colored characters. This addresses the observed blinking while preserving the two directory colors.

## Version 1.0.0.0.17

Set `debug=false` by default in `picklite.ini`. Directory highlighting remains active; diagnostic reports are available by setting `debug=true`.
