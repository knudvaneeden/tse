# CTAGS for The SemWare Editor (TSE)

**README version:** 1.0.0.0.1  
**Date:** 2026-09-04  
**Time:** 17:06:25 UTC  
**Original macro author:** Jeff Hawk

## Description

CTAGS is a TSE SAL macro that adds support for a standard `tags` file, allowing you to jump from a symbol in source code to the location where that symbol is defined.

Place the cursor on a function, variable, class, or other tagged identifier and press **Ctrl+Shift+Enter**. The macro reads the word under the cursor, finds the corresponding entry in the `tags` file, opens the referenced source file, and moves the cursor to the definition.

The original package was released for TSE Pro v2.5 and TSE Pro/32 v2.8. Its source says it was tested with Exuberant Ctags 1.5 and 1.6.

## Archive contents

- `CTAGS.S` — TSE SAL source code for the macro.
- `FILE_ID.DIZ` — short description of the original package.

## Features

- Gets the tag name from the word beneath the cursor.
- Searches for a file named `tags` in the captured starting directory and then in parent directories.
- Supports tag entries that contain either a line number or a search pattern.
- Opens the target source file automatically.
- Centers the located definition on the screen.
- Keeps the loaded `tags` file in a hidden TSE buffer.
- Handles tagged C++ member functions and source filenames containing spaces.

## Requirements

- The SemWare Editor (TSE) with its SAL compiler.
- A ctags-compatible program, such as Exuberant Ctags or Universal Ctags, for generating the `tags` file.
- Source files for which tags have been generated.

> Note: The macro is historical software. The original source explicitly documents testing only with Exuberant Ctags 1.5 and 1.6. Newer ctags implementations may work, but their output format should be tested with this macro.

## Installation

1. Extract `ctags.zip` to a working directory.
2. Open a command prompt in that directory.
3. Compile the SAL source:

   ```bat
   sc32 CTAGS.S
   ```

4. Confirm that the compiler creates the compiled macro file, normally `CTAGS.MAC`.
5. Copy or move the compiled macro to the directory from which you load TSE macros.
6. Load `CTAGS.MAC` in TSE using your normal macro-loading method.

If your TSE installation uses a different SAL compiler command or macro directory, adjust these steps accordingly.

## Generate a tags file

Run your ctags program in the root directory of the source tree. A typical command is:

```bat
ctags -R .
```

This should create a lowercase file named:

```text
tags
```

The exact command-line options depend on the installed ctags program. Verify that its output file is named `tags`, because that is the filename configured in `CTAGS.S`.

## How to run

1. Start TSE from the source project directory, or ensure that the directory captured when the macro is loaded belongs to the same source tree as the `tags` file.
2. Open a source file covered by the generated `tags` file.
3. Put the cursor on the identifier whose definition you want to locate.
4. Press:

   ```text
   Ctrl+Shift+Enter
   ```

5. The macro opens the referenced source file and positions the cursor at the tagged definition.

## Keyboard command

| Key | Action |
|---|---|
| `Ctrl+Shift+Enter` | Find the word under the cursor in `tags` and jump to its definition. |

The key assignment is defined at the end of `CTAGS.S`:

```text
<CtrlShift Enter>   main()
```

Edit this line before compiling if you prefer another key combination.

## How the tags-file search works

When the macro is loaded, `WhenLoaded()` saves the current directory in `myRootDir`. Each lookup then:

1. Checks `myRootDir` for a lowercase `tags` file.
2. If it is not found, walks upward through the parent directories.
3. Stops when it finds `tags` or reaches the drive root.
4. Restores the original current directory after the search.

Because the starting directory is captured when the macro loads, reload the macro from the appropriate project tree if it cannot locate the expected `tags` file.

## Help and troubleshooting

### Nothing happens

- Make sure the cursor is on a word consisting of letters, digits, or an underscore.
- Confirm that `CTAGS.MAC` is loaded.
- Check whether another macro already uses `Ctrl+Shift+Enter`.

### The tag file cannot be found

- Confirm that the filename is exactly `tags` in lowercase.
- Place it in the directory captured when the macro was loaded or in one of that directory's parents.
- Reload the macro while TSE's current directory is inside the correct project tree.

The original macro displays `Can't file Tag File`; this historical message means that it could not find the `tags` file.

### The tag is not found

- Regenerate the `tags` file after changing the source code.
- Verify that the identifier is present in `tags`.
- Make sure the cursor is on the correct identifier.
- Check whether your ctags program writes a format compatible with the macro.

### A referenced source file cannot be opened

- Check the filename stored in the matching `tags` entry.
- Generate the `tags` file from the source-tree root so that relative paths resolve correctly.
- Confirm that the source files have not been moved since `tags` was generated.

### A search-pattern entry goes to the wrong place

The macro translates and progressively shortens ctags search patterns until a matching source line is found. If several source lines are similar, navigation may stop at an earlier match. Regenerating the `tags` file or using line-number entries may improve accuracy.

## Configuration

The default tags filename is defined near the beginning of `CTAGS.S`:

```text
string tagsfile[] = "tags"
```

Change this value and recompile the macro if your tags generator uses another filename.

## Limitations

- The macro searches only the first matching tag entry for the selected word.
- It does not present a selection list when a symbol has multiple definitions.
- The tags-file lookup starts from the directory captured when the macro was loaded, not necessarily the directory of the currently edited file.
- The original source was tested only with older Exuberant Ctags releases.
- Tag paths and search-pattern syntax produced by newer tools may require changes to the SAL source.

## Version history

| Version | Date | Time | Changes |
|---|---|---|---|
| 1.0.0.0.0 | 2026-09-04 | 17:06:25 UTC | Initial README describing the supplied CTAGS archive. |
| 1.0.0.0.1 | 2026-09-04 | 17:06:25 UTC | Expanded installation, tags generation, usage, configuration, and troubleshooting instructions. |

## Original source history

- 1997-01-24 — Original version.
- 1997-01-27 — Kept the `tags` file in a hidden buffer instead of closing it after every search.
- 1997-08-06 — Changed the root of the tags-file search to the saved starting directory because `CurrDir()` caused problems in Win32 versions 2.6 and 2.8.
- 1997-08-29 — Corrected WordSet handling for C++ member functions and fixed filenames containing spaces.

## License and warranty

The supplied source does not state a formal license. It explicitly provides no warranty. Preserve the original author information and source comments when redistributing or modifying the macro, and confirm that you have permission for the intended use.
