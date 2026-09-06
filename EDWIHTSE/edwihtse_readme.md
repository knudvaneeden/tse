# EdWihTSE

**README version:** 1.0.0.0.1  
**Date and time:** 2026-09-06 22:28:52 UTC  
**Original macro date:** 2004-08-01  
**Original author:** Carlo Hogeveen  
**Compatibility:** The SemWare Editor (TSE) Pro 4.0 and later on Windows

## Description

`EdWihTSE.s` is a TSE SAL macro that adds or removes an **Edit with TSE** command in the Windows File Explorer right-click menu for all file types.

When the command is installed, right-clicking a file in Windows and selecting **Edit with TSE** opens that file in TSE. The macro changes the Windows Registry under `HKEY_CLASSES_ROOT` and uses the directory of the running TSE executable to construct the command.

The package contains:

- `EdWihTSE.s` — TSE SAL source code.
- `File_Id.diz` — original short package description.

## Features

- Adds **Edit with TSE** to the Windows right-click menu for files.
- Removes the menu entry again when it is no longer wanted.
- Provides an interactive Add/Delete/Cancel menu.
- Supports English messages by default.
- Includes optional Dutch messages through the `DUTCH` compile-time definition.
- Uses the Windows Registry API in `advapi32.dll`; no separate third-party DLL is required.

## Requirements

- Microsoft Windows.
- TSE Pro 4.0 or later.
- The TSE SAL compiler, normally `sc32.exe`, to compile the source.
- Permission to modify the applicable `HKEY_CLASSES_ROOT` Registry keys. On newer Windows versions, running TSE with administrator privileges may be necessary if registry access is denied.

This macro is Windows-specific and is not intended for Linux or macOS.

## Installation and compilation

1. Extract `edwihtse.zip` to a convenient directory.
2. Open a Command Prompt in that directory.
3. Compile the macro:

   ```bat
   sc32 EdWihTSE.s
   ```

4. Confirm that the compiler creates the compiled TSE macro file, normally `EdWihTSE.mac`.
5. Make the compiled macro available to TSE, for example by placing it in a directory from which TSE can load macros.

If `sc32` is not in `PATH`, run it by using its full pathname.

## How to run it

1. Start TSE.
2. Load or execute the compiled `EdWihTSE` macro using your normal TSE macro command.
3. Choose one of the displayed actions:
   - **Add** — asks for confirmation and then installs the Windows right-click command.
   - **Delete** — removes the command.
   - **Cancel** — exits without changing the Registry.
4. After selecting **Add**, right-click a file in Windows File Explorer and choose **Edit with TSE**.

The installed Registry command passes the selected filename to TSE as a quoted argument, so paths containing spaces are supported.

## Enabling Dutch text

English is enabled by default. To compile the macro with Dutch menu text and messages:

1. Open `EdWihTSE.s` in a text editor.
2. Find this commented line near the top:

   ```sal
   // #define DUTCH TRUE
   ```

3. Remove the leading `//` so it becomes:

   ```sal
   #define DUTCH TRUE
   ```

4. Compile the macro again with `sc32 EdWihTSE.s`.

To return to English, comment out that definition and recompile.

## Removing the right-click command

Run the macro again and choose **Delete**. It removes the `command` key and then the `TSE` shell key created by the macro.

## Troubleshooting

### The Registry cannot be changed

Close TSE, start it with **Run as administrator**, and execute the macro again. Registry permissions vary between Windows configurations.

### The menu entry does not appear immediately

Refresh File Explorer, close and reopen its window, or sign out and back in. Windows may cache shell-menu information.

### The menu entry starts the wrong TSE executable

The macro builds the Registry command from `LoadDir(1)` at installation time. Delete the entry, start the intended TSE installation, and run the macro again to add it with the correct path.

### TSE was moved after installation

Run **Delete** before moving TSE if possible. After moving it, run the macro from the new installation and choose **Add** again so the Registry receives the new executable path.

### Microsoft Office Shortcut Bar conflict

The original macro warns that the right-click option may conflict with the Microsoft Office Shortcut Bar. If a conflict occurs, rerun the macro and select **Delete**.

## Safety notes

- The macro writes to the Windows Registry. Back up the relevant Registry keys or create a restore point before use if required by your environment.
- Use **Delete** from the macro to remove only the keys it installed.
- Review the source before deploying it on managed or shared computers.

## Version history

| Version | Date and time (UTC) | Description |
|---|---|---|
| 1.0.0.0.0 | 2004-08-01 | Original `EdWihTSE.s` macro release. |
| 1.0.0.0.1 | 2026-09-06 22:28:52 UTC | Added this Markdown description, help, requirements, run instructions, troubleshooting information, and version history. |

Future documentation updates can continue as `1.0.0.0.2`, `1.0.0.0.3`, and so on.

## License

No explicit license is included in the supplied archive. Contact the original author before redistributing or modifying the macro when permission is required.
