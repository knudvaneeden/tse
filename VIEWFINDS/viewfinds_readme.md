# ViewFinds Extension for TSE

Version: 1.0.0.0.20  
Release date: 6 November 2026

## Overview

ViewFinds enhances TSE's native View Finds picklist with syntax coloring,
comment coloring, and search-term highlighting. The list can be opened by a
search with the `v` option, Compressed View, or the `grep` macro.

Version 1.0.0.0.20 also remembers the highlighted result when you return to the
same compressed-view picklist. This works around the native behavior in
which redisplaying the list returns the highlight to its first row.

The position-restoration workaround has been tested successfully by Knud van
Eeden in his TSE installation. No changes to `tse.ui` are required.

## Compatibility

- TSE v4.50 (26 October 2024) upwards: comment and search-term highlighting,
  including regular expressions.
- TSE v4.50.26 (1 July 2026) upwards: full syntax-highlighting support.
- The existing extension supports TSE variants including TSE for Linux.
  The new position-restoration workaround has not been separately verified
  on every supported version or platform.

The SAL source uses ASCII text and Windows CRLF line endings.

## Installation and upgrading

1. Put `ViewFinds.s` in your TSE macro directory or working directory.
2. Open it in TSE and compile it using the Macro Compile menu. Compilation
   creates `ViewFinds.mac`.
3. Add `ViewFinds` to TSE's Macro AutoLoad List if it is not already present.
4. Restart TSE to load the compiled version. This is especially important
   when upgrading an already loaded copy.

Alternatively, arrange for your startup macro to load ViewFinds, or use the
TSE command-line option `-eViewFinds` with the compiled macro available in
TSE's macro search path.

The extension must remain loaded to track the picklist position. Merely
keeping the source file in a directory does not activate it.

## Using the compressed-view position workaround

1. Open Compressed View and enter your search expression and options.
2. Move to a result well down the picklist.
3. Press Enter to visit that result in its source file.
4. Choose **Redisplay View PickList**, or press **Alt+Shift+V** with the
   standard bindings in the supplied `tse.ui`.
5. The same list should reopen with its previously highlighted result
   selected instead of returning to the first row.

You can repeat this sequence while navigating the results. The macro
remembers the result's row in the picklist, rather than the source file's
line number. For example, source line 1,000,000 might correspond to result
row 500.

The menu and key binding continue to call native `ViewFinds()`. The extension
adds its workaround through list and display hooks.

## Configuration

Execute `ViewFinds` through the Macro Execute menu to open its configuration
menu. Running it this way opens settings; it does not redisplay the results.

- **Current line background color:** Choose a background that makes the
  highlighted result easier to identify, or use the editor's default color.
- **Trailing spaces color:** Color the unused part of short result rows like
  editor text or like the menu.

These settings are saved in `tse.ini` under the macro's configuration
section. Position tracking is automatic and needs no new configuration.

## How position restoration works

The display callback records the highlighted row as the list is drawn.
When the list opens again, the macro compares the results-buffer ID, row
count, search history and options, first and last rows, and saved row text.
If these checks match, it restores the saved row once through a temporary
`_BEFORE_GETKEY_` hook, after native list initialization.

This uses a few direct row checks rather than scanning the entire results
list. Highlighting retains the existing lazy-evaluation path for lists with
more than 2,000 rows and for older supported TSE versions.

## Limitations

- The remembered position exists only while the macro remains loaded.
  Restarting TSE or purging the macro clears it.
- The macro remembers one results list at a time.
- If the identity or content checks do not match, it leaves the native
  initial selection in place. Editing or deleting results may cause this.
- A newly generated identical list that reuses the same buffer and passes
  all checks cannot be distinguished from redisplaying the previous list.
- The workaround restores the highlighted result row. It does not promise
  the exact previous screen placement or horizontal scroll position.
- Multi-line comment coloring can be inaccurate, particularly in files
  loaded on demand by older TSE versions. Existing size and traversal limits
  also restrict highlighting work on large files.

## Troubleshooting

If the list still returns to the first row, check that you compiled version
1.0.0.0.20 and restarted TSE with that compiled macro in its active macro path.
Create a list, select a result, and use Redisplay View PickList to reopen it.
Performing a new compressed search can create a different results list.

If compilation fails, record the compiler's error message and line number.

## Version history

### 1.0.0.0.20 - 6 November 2026

- Added tracking of the highlighted View Finds result row.
- Added delayed restoration when the same results list reopens.
- Added list identity and content checks before restoring a saved row.
- Confirmed successful position restoration in the user's TSE installation.

### 1.1.18 - 21 August 2026

- Fixed a SAL compiler syntax error caused by variable declarations placed
  after executable statements in the attribute-list procedure.

Earlier releases introduced syntax and search-term highlighting, lazy
result coloring, and limits intended to reduce long parsing delays. See
`ViewFinds.s` for the complete earlier history.

## Credits and source

Original extension: Carlo Hogeveen.  
Original website: <https://ecarlo.nl/tse>

The attached source includes subsequent adaptations and the version 1.0.0.0.20
position-restoration workaround.

Repository link supplied with the previous readme:
<https://github.com/knudvaneeden/tse/blob/TRUNK/VIEWFINDS>
