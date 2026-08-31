# Visual Bookmark Macros v3.0 for TSE

**README version:** 1.0.0.0.0  
**Original macro version:** 3.0  
**Original source file:** `BOOK.S`

## Description

Visual Bookmark Macros v3.0 is a set of macros for The SemWare Editor (TSE). It provides quick bookmark placement and visual lists from which bookmarks can be selected, visited, replaced, or deleted.

Each bookmark is identified as `@A` through `@Z`. The visual list shows:

- the bookmark letter;
- the bookmarked file name;
- the line number; and
- the first nonblank text on the bookmarked line.

The bookmark-selection buffer is created dynamically whenever it is needed and is removed afterward. The macros can coexist with TSE's regular bookmark commands.

## Archive contents

| File | Description |
| --- | --- |
| `BOOK.S` | TSE SAL source code for the Visual Bookmark Macros v3.0. |
| `FILE_ID.DIZ` | Brief description of the original package. |

## Main commands

| Macro | Default key | Purpose |
| --- | --- | --- |
| `mPlaceBookMark()` | `Alt+Backtick` | Places the first available bookmark at the current position. The backtick key is `` ` ``. |
| `mGotoBookMark()` | `Alt+Backslash` | Displays all active bookmarks and goes to the selected bookmark. |
| `mNextBookMark()` | `Ctrl+Backslash` | Goes backward through the active bookmarks, wrapping from `A` to `Z`. |
| `mDelBookMark()` | `Ctrl+8` | Displays the active bookmarks and deletes the selected bookmark. |

You may change these key assignments at the end of `BOOK.S` before compiling it.

## Requirements

- The SemWare Editor (TSE) with its SAL compiler.
- The extracted `BOOK.S` source file.

This is legacy source dated 1993. The original instructions use the classic `SC` compiler command. A newer TSE/SAL compiler may require minor source modernization if it rejects older syntax.

## How to compile and run it

### 1. Extract the archive

Extract `bookmrk3.zip` to a working directory. The directory must contain `BOOK.S`.

### 2. Open a command prompt

Change to the directory containing `BOOK.S`, or make sure the TSE SAL compiler is available through your `PATH`.

### 3. Compile the macro

Run:

```text
SC BOOK.S
```

On installations that use the 32-bit SAL compiler command, use the corresponding compiler, for example:

```text
SC32 BOOK.S
```

Compilation should create the loadable TSE macro file, normally `BOOK.MAC`.

### 4. Load the compiled macro in TSE

Start TSE and load `BOOK.MAC` as an external macro. In classic TSE versions this can be done with:

```text
Ctrl+F10, then L
```

Alternatively, use TSE's menu command for loading a macro and select `BOOK.MAC`.

### 5. Use the bookmark commands

1. Put the cursor at a position you want to remember.
2. Press `Alt+Backtick` to place the next free bookmark.
3. Press `Alt+Backslash` to open the visual bookmark list.
4. Select a bookmark and press `Enter` to go to it, or press `Esc` to cancel.
5. Press `Ctrl+Backslash` to cycle backward through used bookmarks.
6. Press `Ctrl+8` to select and delete a bookmark.

## Command behavior

### Place a bookmark

`mPlaceBookMark()` assigns the lowest available bookmark letter. If no bookmark exists yet, it starts with `@A`. A message reports which bookmark was placed.

If all 26 bookmarks are in use, a visual list appears. Select a bookmark and press `Enter` to reuse it, or press `Esc` to cancel.

### Go to a bookmark

`mGotoBookMark()` displays the active bookmark list. Select an entry and press `Enter`; TSE goes to its saved file, line, and column. Press `Esc` to remain at the current position.

### Visit the previous bookmark

`mNextBookMark()` remembers the last bookmark used and searches backward for the preceding active bookmark. It wraps around from `A` to `Z`. If no bookmarks exist, it displays `No Bookmarks found`.

### Delete a bookmark

`mDelBookMark()` displays the active bookmark list. Select an entry and press `Enter` to delete it, or press `Esc` to cancel.

## Adding the commands to TSE permanently

The original source suggests moving the desired key assignments into your TSE key-definition file and rebuilding the editor configuration with:

```text
SC -b UI\TSE
```

The exact file names and rebuild command can vary by TSE version. Back up your existing configuration before changing it.

The end of `BOOK.S` also contains commented examples for adding the bookmark commands to a Search submenu.

## Troubleshooting

### The macro does not load

- Confirm that compilation completed without errors.
- Load the compiled `.MAC` file, not the `.S` source file.
- Confirm that the compiled macro is compatible with your TSE version.

### A shortcut does not work

- Check whether another macro or key definition already uses the same shortcut.
- Edit the key assignments at the end of `BOOK.S`, then recompile and reload the macro.
- On keyboards where the backtick or backslash key is inconvenient, assign different keys.

### No bookmarks appear

Place at least one bookmark first. The visual list only contains currently active TSE bookmarks.

### A bookmarked file is no longer open or available

Bookmarks depend on TSE's bookmark handling and the associated editor buffers. Reopen the required file and place the bookmark again if necessary.

## Version history

| README version | Changes |
| --- | --- |
| 1.0.0.0.0 | Initial Markdown documentation for the original Visual Bookmark Macros v3.0 package. |

Future revisions should increase the final component sequentially: `1.0.0.0.1`, `1.0.0.0.2`, and so on.

## Credits

- Author: Sammy Mitchell
- Extensive rewrite: Steve Kraus
- Original idea: Jim Susoy and Howard Kapustein

