# POV30TSE: POV-Ray 3.0 syntax template for TSE

Version: **1.0.0.0.0**  
Prepared: **26 September 2026, 20:59 CEST (Europe/Amsterdam)**

## Description

`povcolor.tse` is a syntax template for The SemWare Editor (TSE). It identifies POV-Ray 3.0 reserved words and punctuation for TSE's template-based coloring. The original author says the list includes the version 3.0 reserved words except for some obsolete words. The template begins with `!EnableCaseChecking`, so capitalization matters when matching its entries.

This package preserves the original `povcolor.tse`, `readme.txt`, and `file_id.diz`.

## Files

| File | Purpose |
| --- | --- |
| `povcolor.tse` | Original TSE syntax-coloring template for POV-Ray 3.0. |
| `pov30tse.ini` | Requested configuration placeholder; the template itself cannot read an INI file. |
| `readme.txt`, `file_id.diz` | Original archive notes. |
| `pov30tse_readme.md` | This guide. |

## How to run it

1. Extract the ZIP and copy `povcolor.tse` to a location where your TSE installation looks for syntax templates.
2. In your TSE syntax-coloring configuration, associate POV-Ray scene files (normally `.pov`) with `povcolor.tse`. The exact menu or configuration command depends on the installed TSE version and coloring setup.
3. Open a `.pov` file and enable TSE's template-based syntax coloring if it is not already active.
4. Check a few POV-Ray keywords and comments. If nothing changes, verify the template association and that your editor's syntax-coloring support is enabled.

You do **not** compile `povcolor.tse` with `sc32`: it is a syntax template, not a SAL source file. No `.s` file, `main()`, or runnable macro was present in the supplied archive.

## `silent` setting

`pov30tse.ini` contains `silent=false` as requested. This has **no effect** on the included template: it does not execute SAL code or display a `Warn()` box. Consequently there is no `main()` in which to add an introductory message. A future SAL launcher could read this setting and show a message when `silent=false`.

## Compatibility

The keyword list was written for POV-Ray 3.0. Later POV-Ray language features may require additional entries. The actual colors depend on TSE's configured template color groups.
