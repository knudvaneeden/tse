# NoLines

**Package version:** 1.0.0.0.4  
**Updated:** 2026-09-25 00:15:17 UTC  
**Original macro:** Carlo Hogeveen, version 3 (2004-10-03)  
**Packaging and startup message:** GPT-6

## Description

NoLines hides the eight-character line-number column in TSE Pro Find results created with the `V` search option. The results list also remains without those line numbers when opened for editing with <Alt E>. Running the macro again toggles line numbers back on. When the macro loads, line numbers are hidden by default.

## Requirements

- The SemWare Editor Professional and its SAL compiler. The original author specifies TSE Pro 2.5 or later.
- This version is self-contained. The original source invoked `clipbord.mac`; this package stores the line-number column in its own temporary buffer and does not need `Global.zip`, `MacPar3.zip`, `ClipBor2.zip`, or `clipbord.mac`.

## Install and run

1. Extract `NoLines.s`, `nolines.ini`, and the included documentation into your working directory.
2. Compile `NoLines.s` in TSE using **Escape &#8594; Macro &#8594; Compile**, or compile it with your compatible `sc32` compiler. Keep the resulting `NoLines.mac` in the current directory or a TSE macro search directory.
3. Add `NoLines` to TSE's **Macro AutoloadList** and restart TSE. Its hooks will then apply to Find results. At startup, line numbers are hidden unless `show_line_numbers=true` is set in `nolines.ini`.
4. Place `nolines.ini` in the directory that was current when TSE started. This is the `StartUpPath` used by the macro. Set `show_line_numbers=true` to show line numbers from the start, or `silent=true` to suppress the message when toggling.
5. Run the `NoLines` macro through TSE's macro execution command to toggle line numbers from the configured initial state. Run a Find with the `V` option to display its results list. With `silent=false`, each manual toggle reports its state in a `Warn()` box.

## Configuration

```ini
[nolines]
show_line_numbers=false
silent=false
```

`show_line_numbers=false` (the default, including when the INI is missing) hides the line numbers when the macro loads. Set it to `true` to show them from startup; running NoLines then toggles the current state.

`silent=false` (the default, including when the INI is missing) displays the status `Warn()` box each time you run the macro. `silent=true` suppresses that box; the toggle still happens. The `silent` setting affects the manual toggle message, not the Find results hooks. Restart TSE or reload the macro after changing `show_line_numbers`; it is read by `WhenLoaded()` when the macro loads.

## Notes

The macro changes the presentation of generated Find lists. It stores the removed column in an internal temporary buffer so that TSE can restore it during list cleanup when appropriate. It leaves the clipboard untouched. The original source and `File_Id.diz` are included; the source retains its original author and version history. Version 1.0.0.0.4 defaults the initial state to hidden line numbers. The package does not call `clipbord.mac`. Compile and run it in your TSE installation to verify compatibility with your installed dependency versions.
