# MKSAVDIR

Version: 1.0.0.0.0  
Updated: 2026-09-22 14:20:16 CEST  
Original author: Carlo Hogeveen  
Package update: OpenAI Codex (GPT-5)

## Description

MKSAVDIR is a TSE Pro SAL macro that detects missing directories when a file is saved. If the pathname begins with a Windows drive letter and one or more directories in that path do not exist, the macro offers to create them before TSE saves the file.

The prompt provides these choices:

- **Yes** - create the current missing directory.
- **No** - do not create the current missing directory.
- **Never** - do not create missing directories during the current save operation.
- **Always** - create all required directories during the current save operation.

The macro supports TSE Pro 2.5e and later according to the original source. The added INI-controlled startup message uses facilities available in current TSE Pro releases, including TSE Pro 4.50.

## Package contents

- `MkSavDir.s` - TSE SAL source code.
- `mksavdir.ini` - startup-message configuration.
- `mksavdir_readme.md` - this documentation.
- `File_id.diz` - original short package description.

## Installation

1. Extract all files from `mksavdir1.0.0.0.0.zip` into one directory.
2. Keep `MkSavDir.s` and `mksavdir.ini` together.
3. Open a command prompt in that directory.
4. Compile the source with the TSE SAL compiler:

   ```text
   sc32 MkSavDir.s
   ```

5. Confirm that `MkSavDir.mac` is created without compiler errors.
6. Load or execute `MkSavDir.mac` in TSE.
7. Use the configuration menu to enable automatic loading if you want the macro active whenever TSE starts.

Restart TSE after replacing an already loaded copy if necessary.

## How to run it

1. Execute `MkSavDir.mac` in TSE.
2. With the default `silent=false`, read and dismiss the informative startup `Warn()` box.
3. In the **MkSavDir Configuration** menu, select **Offer to create non-existing directories when saving** to toggle automatic loading.
4. Exit the configuration menu.
5. Open or create a file whose full Windows pathname contains a directory that does not yet exist.
6. Save the file.
7. Choose **Yes**, **No**, **Never**, or **Always** when MKSAVDIR asks whether it should create the missing directory.

Example target pathname:

```text
C:\WORK\NEW_FOLDER\example.txt
```

If `C:\WORK` exists but `NEW_FOLDER` does not, MKSAVDIR can create `NEW_FOLDER` during the save operation.

## INI configuration

`mksavdir.ini` must be in the same directory as the running `MkSavDir.mac` file.

```ini
[mksavdir]
silent=false
```

- `silent=false` is the default and shows the informative `Warn()` box when the macro is run directly.
- `silent=true` suppresses that startup `Warn()` box.

The setting controls only the informative startup box. It does not suppress the directory-creation question shown while saving a file, and it does not change whether the macro is automatically loaded.

## Enabling and disabling

Running the macro opens its configuration menu. Toggling the menu item adds or removes MKSAVDIR from TSE's autoload list.

- When enabled, the macro hooks TSE's file-save event and checks destination directories.
- When disabled, it removes itself from the autoload list and unloads after the configuration menu closes.

## Notes and limitations

- The source checks paths beginning with a drive letter, such as `C:\...`.
- The macro creates directories one level at a time when their parent directory exists.
- Save or back up important work before testing a newly compiled macro.
- Keep the INI file beside the compiled macro so `silent` is read from the expected location.
- `silent=true` does not disable MKSAVDIR; it hides only the explanatory startup box.

## Version history

### 1.0.0.0.0 - 2026-09-22

- Added this Markdown description, help, installation, and run guide.
- Added `mksavdir.ini` with `silent=false` as the default.
- Added an informative `Warn()` box to `Main()`.
- Added support for `silent=true` to suppress the startup information box.
- Preserved the original directory-checking and autoload-configuration behavior.
