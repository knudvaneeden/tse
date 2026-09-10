# HSK Read-Only Macros 1.0 for TSE 2.0

**README version:** 1.0.0.0.1  
**Updated:** 2026-09-10 23:15:00 UTC  
**Original macro version:** 1.0  
**Original release date:** 1995-02-22  
**Author:** Howard Kapustein

## Description

HSK Read-Only Macros is a freeware macro package originally written for The SemWare Editor (TSE) 2.0. This Win32 port removes the unsupported `WP.BIN`, `Binary`, `FindFirst`, and `ffblk` dependencies so the source can be built for TSE 4.50 on 32-bit Windows.

The package adds the following features:

- A message, warning, or audible alert when a read-only file is opened.
- An enhanced list of open files that marks read-only and modified buffers.
- A configurable status-line display showing a shortened pathname, file attributes, and information about the character under the cursor.
- Menus for enabling, disabling, and configuring the supplied features.
- An internal tracking buffer that caches file attributes and reduces unnecessary disk access.

The status line can display these DOS file attributes:

- `R` — read-only
- `A` — archive
- `S` — system
- `H` — hidden

It can also display the decimal and hexadecimal value of the character under the cursor. If the cursor is past the end of the line, it displays `<EOL>`.

## Archive contents

| File | Purpose |
| --- | --- |
| `readonly.s` | Main TSE SAL source file and the only `.S` file that must be compiled. |
| `readhlpr.inc` | Win32 DLL declarations and shared helper procedures. |
| `readlist.inc` | Enhanced open-file list. |
| `readmenu.inc` | Main configuration menu. |
| `readmsg.inc` | Read-only file notification support. |
| `readstat.inc` | Status-line and file-attribute tracking support. |
| `hskro100.c` | Borland C++ 5.5-compatible DLL source. |
| `hskro100.def` | DLL export-definition file. |
| `build.bat` | Builds `hskro100.dll` and compiles `readonly.s`. |
| `READONLY.MAP` | Historical compiler-generated map file from the original archive. |
| `READ.ME` | Original documentation. |
| `FILE_ID.DIZ` | Short archive description. |

## Installation

1. Extract the Win32 package into one directory.
2. Build the DLL and macro with `build.bat`.
3. Keep `readonly.mac` and `hskro100.dll` together.
4. Restart TSE if an older copy of `hskro100.dll` was already loaded.
5. Load and execute `readonly.mac`.

The Win32 port targets TSE Pro 4.50 and 32-bit Windows. TSE loads DLLs into memory, so restarting TSE is necessary after rebuilding the DLL.

## How to run

After loading `READONLY.MAC`, the package activates its read-only notification and status-line features automatically.

The supplied key assignments are:

| Key | Action |
| --- | --- |
| `<CenterCursor>` | Open the enhanced list of open files. |
| `<CtrlShift R>` | Open the HSK ReadOnly configuration menu. |

To use the enhanced file list:

1. Press `<CenterCursor>`.
2. Select an open file from the list.
3. Press `<Enter>` to switch to that file.

To configure the package:

1. Press `<CtrlShift R>`.
2. Choose **Buffer List**, **Message If Read-Only**, or **Status Line**.
3. Change the desired option.
4. Press `<Esc>` when finished.

## Configuration help

### Buffer List

The read-only and modified indicators can be displayed in one of three forms:

- `*filename`
- `R*filename`
- `*filename (RO)`

Here, `R` or `(RO)` identifies a read-only file and `*` identifies a modified buffer.

### Message If Read-Only

The notification display cycles through:

- **Nothing** — no read-only notification.
- **Message** — show `File is READONLY` as a normal message.
- **Warning** — display a warning that requires acknowledgement.

The **Alarm** option controls whether TSE also sounds an alert.

### Status Line

The Status Line menu provides these commands and options:

- Enable or disable the enhanced status line.
- Refresh information for the current file.
- Refresh information for all open files.
- Enable or disable shortened pathnames.
- Enable or disable file-attribute indicators.
- Enable or disable character-at-cursor information.
- View the internal file-information tracking buffer.

## Building the Win32 version

Run this command from the package directory after placing the Borland C++ 5.5/5.5.1 and TSE compiler directories on `PATH`:

```text
build.bat
```

The batch file performs these steps:

1. Compiles `hskro100.c` with `bcc32`.
2. Links `hskro100.dll` with `ilink32` and `hskro100.def`.
3. Compiles only `readonly.s` with `sc32`.
4. Produces `hskro100.dll` and `readonly.mac`.

Do not use `sc32 *.s` for the original package. `READHLPR.S`, `READLIST.S`, `READMENU.S`, `READMSG.S`, and `READSTAT.S` were include modules, not independent macros. In this port they use the `.inc` extension, so a wildcard `.S` build compiles only `readonly.s`.

### Removed binary dependency

The original `..\UI\WP.BIN` dependency has been removed. The replacement DLL exports Pascal-calling-convention functions that use the Win32 `GetFileAttributesA` API. The SAL source uses those functions instead of the unsupported DOS `FindFirst` and `ffblk` interface.

## Unloading the macro

Purge or unload `READONLY.MAC` through TSE's normal macro-management command. Its cleanup procedure removes the installed hooks and shuts down status-line tracking.

## Troubleshooting

### No read-only warning appears

- Open the HSK ReadOnly menu with `<CtrlShift R>`.
- Choose **Message If Read-Only**.
- Change **Display** to **Message** or **Warning**.
- Confirm that the file has the operating-system read-only attribute.

### The enhanced status information is missing

- Open **Status Line** from the configuration menu.
- Set **Status Line** to **On**.
- Enable the desired pathname, attribute, and character options.
- Use **Refresh Current Info** or **Refresh All Info**.

### A supplied shortcut conflicts with another macro

Edit the key definitions near the ends of `READONLY.S` and `READMENU.S`, choose unused keys, and recompile the macro. Existing TSE key assignments can override or be overridden by macro key definitions depending on load order.

### TSE reports that it cannot load `hskro100.dll`

- Confirm that `hskro100.dll` is in the same directory as `readonly.mac`.
- Run TSE from an environment in which that directory is accessible.
- Confirm that the DLL was built as a 32-bit DLL.
- Restart TSE after replacing an already-loaded DLL.

## License and historical note

The original package states that the macros are Copyright (C) 1995 by Howard Kapustein and may be used under the usual freeware terms. The author retains the rights, and the package may not be sold. Consult `READ.ME` in the archive for the complete original notice, credits, and historical contact information.

This README documents the original archive without changing its programs or source files.

## Version history

| README version | Date and time | Changes |
| --- | --- | --- |
| 1.0.0.0.0 | 2026-09-10 22:52:18 UTC | Initial Markdown documentation created from the archive contents, original documentation, and SAL source files. |
| 1.0.0.0.1 | 2026-09-10 23:15:00 UTC | Replaced the DOS `WP.BIN` interface with `hskro100.dll`, converted component sources to `.inc`, added Borland C++ 5.5 build files, and documented the TSE 4.50 build procedure. |
