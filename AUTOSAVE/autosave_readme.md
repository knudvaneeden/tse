# AutoSave for The SemWare Editor

## Description

`autosave.s` is a resident TSE SAL macro that periodically creates temporary backup copies of changed files. It was written by Bruce Riggins for TSE 1.51a.

The macro does **not** overwrite the original file during an automatic save. Instead, it writes a recovery file either beside the original or in a directory specified by the `AUTOSAVE` environment variable.

The backup extension consists of `$` followed by the first two characters of the original extension. Examples:

| Original file | Automatic backup |
| --- | --- |
| `autosave.s` | `autosave.$s` |
| `autosave.inc` | `autosave.$in` |
| `notes.txt` | `notes.$tx` |

This naming scheme allows files with the same base name but different extensions to have separate backups.

## Main features

- Automatically saves all changed normal file buffers after a configurable idle interval.
- Uses a default interval of 10 minutes.
- Preserves the original file by writing to a separate recovery file.
- Can store backups in the original files' directories or in one directory selected through the `AUTOSAVE` environment variable.
- Detects an existing backup when its original file is first edited.
- Offers to load the backup so that it can be inspected or compared with the original.
- Deletes the backup after the corresponding original file is saved or quit normally.
- Can retain a changed interval in `autosave.ini` for later TSE sessions.

## Requirements

- The SemWare Editor (TSE).
- The TSE SAL compiler appropriate for the installed TSE version, normally `sc32.exe` for 32-bit TSE.
- Permission to write backup files to the original file directory or to the directory specified by `AUTOSAVE`.

The source was created for TSE 1.51a. A newer SAL compiler may report compatibility errors if older language constructs or hook names are no longer supported.

## Installation

1. Copy `autosave.s` to the TSE macro source directory, commonly:

   ```text
   <TSE directory>\mac
   ```

2. Open a command prompt in that directory.

3. Compile the macro:

   ```bat
   sc32 autosave.s
   ```

   If `sc32.exe` is not on `PATH`, specify its full path, for example:

   ```bat
   C:\TSE\sc32.exe autosave.s
   ```

4. Confirm that compilation creates the loadable macro file used by your TSE installation.

5. Load `autosave` as a resident macro in TSE. This can be done from TSE's macro loading facility or by adding it to the normal startup macro list used by your installation.

Once loaded, `WhenLoaded()` installs the idle, save, quit, first-edit, and editor-exit hooks. No separate command is needed to start timed saving.

## How to run and use it

1. Start TSE and make sure the compiled `autosave` macro is loaded.
2. Open and modify one or more files.
3. Leave TSE idle until the configured interval has elapsed. The status line briefly shows:

   ```text
   AutoSaving changed files...
   ```

4. The macro creates a backup for every changed normal buffer.
5. Continue editing normally. Saving or quitting a file through TSE removes its temporary backup.

## Changing the save interval

The default interval is 10 minutes. Run the public macro procedure:

```text
Set_Save_Interval
```

Depending on the TSE version and macro launcher, select the loaded `autosave` macro and invoke its public `Set_Save_Interval` procedure. Enter the interval in whole minutes.

When the macro is unloaded or the editor exits, it asks whether the changed interval should be saved. If confirmed, it writes the number of minutes to:

```text
<TSE LoadDir>\mac\autosave.ini
```

The saved value is loaded automatically the next time the macro starts.

Entering `0` disables timed saving for the current session. Use a positive value to enable it again.

## Optional separate backup directory

By default, every backup is written in the same directory as its original file. To place all backups in a separate directory, define the Windows environment variable `AUTOSAVE` before starting TSE.

Example for the current Command Prompt session:

```bat
set AUTOSAVE=C:\TEMP\TSE_AUTOSAVE
```

Create that directory first and ensure it is writable. The macro accepts the value with or without a final backslash.

To return to backups beside the original files, remove the variable before starting TSE:

```bat
set AUTOSAVE=
```

## Recovering work after an abnormal exit

If TSE or Windows closes abnormally, the temporary backup remains on disk.

1. Restart TSE with the `autosave` macro loaded.
2. Open the original file and begin editing it.
3. If a matching backup exists, the macro asks:

   ```text
   AutoSave backup exists for this file. Do you wish to load it?
   ```

4. Choose **Yes** to load the backup as another buffer.
5. Compare it with the original and copy any wanted changes, or close the original and save the recovered buffer under the original filename.

Loading the backup does not automatically overwrite the original file.

## Important notes

- Automatic backups are temporary recovery files, not a substitute for normal saves or version control.
- A normal save or quit deletes the corresponding backup.
- Only changed buffers of type `_NORMAL_` are processed.
- Untitled buffers or files in read-only directories may not be suitable for this macro.
- When a shared `AUTOSAVE` directory is used, files with the same name and extension from different source directories can map to the same backup filename. Avoid editing such files simultaneously, or keep backups beside their originals.
- The macro calculates elapsed time from the time of day. An interval that crosses midnight may not trigger until the internal time comparison becomes valid again; this is a limitation of the original implementation.

## Troubleshooting

### `Invalid AUTOSAVE path!`

The directory named by the `AUTOSAVE` environment variable does not exist or cannot be recognized. Create the directory, correct the variable, and restart the macro or TSE.

### No backup appears

Check that:

- `autosave` is loaded as a resident macro;
- the current file has unsaved changes;
- the buffer is a normal file buffer;
- the interval is greater than zero;
- the destination directory exists and is writable; and
- TSE has been idle long enough for its `_IDLE_` hook to run.

### The interval is not retained

Confirm the prompt to save the changed interval when exiting or unloading the macro. Also verify that TSE can create or update `autosave.ini` in `<TSE LoadDir>\mac`.

### A backup disappears

This is expected after the original file is saved or quit normally. The macro treats the backup as temporary recovery data and deletes it through its file-save and file-quit hooks.

## Files used

| File | Purpose |
| --- | --- |
| `autosave.s` | TSE SAL source code |
| Compiled `autosave` macro | Resident macro loaded by TSE |
| `autosave.ini` | Optional saved interval in minutes |
| `name.$xx` | Temporary recovery copy of an edited file |

