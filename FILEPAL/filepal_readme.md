# FilePal for TSE Pro

**README version:** 1.0.0.0.0  
**Date and time:** 2026-09-08 17:36:06 CEST (UTC+02:00)  
**Original FilePal release date:** 2002-06-19  
**Original author:** Jean Heroux  
**Additional changes:** Michael Graham

## Description

FilePal is a macro for The SemWare Editor Professional (TSE Pro) that remembers file-specific editing information and restores it when a file is opened again.

For an individual file, FilePal can save:

- The current line position and window row.
- Bookmarks.
- Insert mode.
- AutoIndent.
- WordWrap.
- Left and right margins.
- Tab type and tab width.
- ExpandTabs.
- End-of-line type (EOLType).
- End-of-file type (EOFType).

Default editing parameters can also be associated with:

- File extensions.
- Directories.
- Drives.

FilePal supports **AutoTrack**, which automatically saves the current file's position, bookmarks, and editing parameters whenever the file is quit. The saved information is restored when the file is loaded again.

FilePal can also link a macro to a filename, extension, directory, or drive. The linked macro is executed automatically when a matching file becomes active.

## Package contents

| File | Purpose |
| --- | --- |
| `FILEPAL.S` | FilePal TSE SAL source code and original documentation. |
| `FILEPAL.DAT` | Persistent data file containing saved settings, positions, bookmarks, AutoTrack flags, and macro links. |
| `FILE_ID.DIZ` | Short description of the original distribution. |

## Requirements

- TSE Pro 2.5, TSE Pro/32 2.8, or a compatible 3.x/4.x release.
- The TSE SAL compiler appropriate for the installed TSE version.
- Write permission for `FILEPAL.DAT`, so FilePal can save changes when TSE is closed.

The optional `CurrExt` macro can be used to associate related file extensions. FilePal continues to work without it and then uses TSE's built-in `CurrExt()` behavior.

## Installation

1. Extract `filepal.zip`.
2. Copy `FILEPAL.S` and `FILEPAL.DAT` to the TSE macro directory, commonly `C:\TSE\MAC`.
3. Open `FILEPAL.S` in TSE.
4. If desired, change the key assignment at the end of the source. The supplied assignment is:

   ```text
   <Ctrl F11>      mInvokeMenu()
   ```

5. Compile `FILEPAL.S` with the TSE SAL compiler.
6. Load the compiled FilePal macro in TSE.
7. For automatic operation in every editing session, add FilePal to TSE's AutoLoad list.

Keep `FILEPAL.DAT` available in the current directory, the editor load directory, or its `MAC` subdirectory. FilePal searches those locations when it starts.

## How to run FilePal

1. Start TSE Pro and load the compiled FilePal macro if it is not loaded automatically.
2. Open the file whose settings you want to manage.
3. Press **Ctrl+F11** to open the FilePal menu.
4. Select the required category or command.
5. Quit TSE normally when finished so modified FilePal data can be written to `FILEPAL.DAT`.

## Main menu commands

### AutoTrack

Turns automatic tracking on or off for the current filename.

When AutoTrack is on, FilePal saves the current position, bookmarks, and editing parameters whenever the file is quit. These values are restored when the file is loaded again. Turning AutoTrack off does not erase already saved values; use **Clear parms** if they should be removed.

### File Name

Manages settings belonging to the full name of the current file. Filename settings can include position and bookmarks as well as editing parameters.

### Extension

Manages defaults and macro links belonging to the current file extension. Bookmarks are not stored at this level.

### Directory

Manages defaults and macro links belonging to the directory of the current file. This is the file's directory, which may differ from TSE's active working directory. Bookmarks are not stored at this level.

### Drive

Manages defaults and macro links belonging to the drive of the current file. This is useful when a mapped drive or remote system requires particular line-ending settings. Bookmarks are not stored at this level.

### View buffer

Displays FilePal's internal parameter buffer. Press **Escape** to leave it. The displayed buffer cannot be edited directly through this view.

### Reload

Reloads the current file's settings from FilePal's parameter buffer and reapplies the normal cascade from drive to extension to directory to filename.

### Cleanup

Removes saved filenames and paths that no longer exist.

## Category submenu commands

The File Name, Extension, Directory, and Drive menus provide the following commands where applicable:

- **Write parms** — saves the current editing parameters for the selected category. For a filename, it also saves the position and bookmarks.
- **Clear parms** — removes the saved parameters for the selected category. Clearing filename parameters also cancels AutoTrack for that file.
- **Load parms** — immediately loads the saved parameters for the selected category.
- **Link macro** — associates one macro with the selected filename, extension, directory, or drive.
- **Unlink macro** — removes an existing macro association.
- **Show link** — displays the macro currently associated with the selected category.

## Cascading settings

When a file is activated, FilePal applies matching settings from general to specific:

1. TSE editor defaults.
2. Drive settings.
3. Extension settings.
4. Directory settings.
5. Exact filename settings.

Later, more specific matches override earlier, more general matches. For example, a drive can default to LF line endings, `.ini` files can override that with CRLF, and one exact `.ini` filename can override it again with LF.

## Automatic macro links

FilePal checks for linked macros when a file is first edited and when the active file changes. Macro links let you load file-specific key definitions or perform other automatic setup.

Only one macro can be linked to each filename, extension, directory, or drive, although that macro may call other macros. When FilePal switches to a different linked macro, it purges the previously invoked linked macro before running the new one. It does not execute the same linked macro twice consecutively.

## Bookmark limitations

- FilePal stores bookmark line numbers and window rows, but not cursor columns. Restored bookmarks therefore point to column 1.
- Adding or deleting lines can make old bookmark positions inaccurate. Save the file parameters again after editing; AutoTrack does this automatically when the file is quit.
- Restoring bookmarks can replace bookmarks with the same letter in other loaded files.

## FILEPAL.DAT

`FILEPAL.DAT` is FilePal's persistent database. It is loaded into a temporary internal buffer when the macro starts and is saved when TSE is abandoned if the data has changed.

Normally, manage this data through the FilePal menu. If manual editing is necessary, open `FILEPAL.DAT` as a regular file. Do not alter its category title lines: `FILES`, `EXTENSIONS`, `DIRECTORIES`, and `DRIVES`.

Back up `FILEPAL.DAT` periodically if it contains settings or macro associations that would be time-consuming to recreate.

## Restore State interaction

FilePal is inhibited when TSE starts with Restore State enabled. FilePal resembles Restore State but serves a different purpose: it remembers information for any number of files over time, applies settings when files change, supports extension/directory/drive defaults, and can execute linked macros. It does not remember the complete file ring or marked blocks.

## Temporarily disabling FilePal

Another SAL macro can temporarily disable FilePal's automatic hooks with:

```sal
SetGlobalStr('FilePal', 'OFF')
```

Set the global string to `ON` (or any value other than `OFF`) to enable it again. FilePal is also reset when the editor is abandoned.

## Troubleshooting

### Ctrl+F11 does not open the menu

- Confirm that FilePal compiled successfully and that the compiled macro is loaded.
- Check whether Ctrl+F11 is assigned to another macro or command.
- Change the key assignment at the end of `FILEPAL.S`, recompile it, and reload the macro if necessary.

### Settings are not restored

- Confirm that the current file has saved parameters or has AutoTrack enabled.
- Select **Reload** from the FilePal menu.
- Ensure `FILEPAL.DAT` can be found and read.
- Remember that Restore State inhibits FilePal.
- Check whether another macro set the global string `FilePal` to `OFF`.

### Changes are not saved

- Ensure `FILEPAL.DAT` is writable.
- Exit TSE normally so FilePal's editor-abandon hook can save the data.
- Verify that the directory containing `FILEPAL.DAT` permits file updates.

### A linked macro does not run

- Use **Show link** for the filename, extension, directory, or drive.
- Confirm that the linked macro can be found and loaded by TSE.
- Check that FilePal has not been disabled and is not inhibited by Restore State.

## Version history

| README version | Date | Changes |
| --- | --- | --- |
| 1.0.0.0.0 | 2026-09-08 | Initial Markdown README created from the documentation and files in `filepal.zip`. |

Future documentation revisions should increment the final component, for example `1.0.0.0.1`, `1.0.0.0.2`, and so on.

## License

No explicit license file is included in the supplied archive. Retain the original author and contributor notices when redistributing or modifying the package, and obtain permission from the rights holders when required.
