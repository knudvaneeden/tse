# getfidso

## Description

`getfidso` is a portable TSE SAL macro that returns the size of a file in bytes. Version `1.0.0.0.10` supports TSE for Windows, the 32-bit TSE for Linux running under WSL, and the 32-bit TSE running on native Linux distributions such as Ubuntu.

The earlier Windows-only `#IFDEF WIN32` restriction has been removed. The macro now uses TSE's `FindThisFile()` and `FFSize()` functions on Windows, WSL, and native Linux.

## Package contents

| File | Description |
| --- | --- |
| `getfidso.s` | Portable SAL source for Windows, Linux/WSL, and native Linux. |
| `getfidso.zip_readme.md` | This documentation. |

The package does not contain a newly compiled `.mac` file. Compile `getfidso.s` with the SAL compiler belonging to the TSE platform on which it will run.

## Compile

From the directory containing `getfidso.s`, run:

```text
sc32 getfidso.s
```

This creates `getfidso.mac` for the current TSE platform.

## Run

1. Load `getfidso.mac` in TSE.
2. Press **F12**.
3. Enter a filename or full path.
4. Press **Enter**.
5. The file size is displayed in bytes with `Warn()`.

Press **Escape** or submit an empty filename to stop without checking a file.

## Path examples

Windows:

```text
C:\temp\ddd.txt
```

Linux/WSL path to the same file on drive C:

```text
/mnt/c/temp/ddd.txt
```

Linux file in the current directory:

```text
ddd.txt
```

Native Linux or WSL file in the user's home directory:

```text
/home/username/ddd.txt
```

Native Ubuntu system file:

```text
/etc/hosts
```

Use Linux path syntax when running the Linux edition of TSE. On native Ubuntu, use paths such as `/home/username/file.txt`. Under WSL, Windows drives are normally mounted below `/mnt`, for example `/mnt/c/temp/ddd.txt`. A Windows path such as `C:\temp\ddd.txt` is not automatically translated by the macro.

## Behavior

- Existing hidden, system, and read-only files are included in the search.
- A missing file produces a warning and the function returns `0`.
- An empty file also has size `0`; use the warning to distinguish it from a missing file.
- The result is a signed 32-bit SAL `INTEGER`. Files larger than the supported integer range may not be represented correctly.
- `FFSize()` reports the file length in bytes. It does not necessarily report the filesystem allocation size or number of disk blocks occupied.

## Reusable function

```text
INTEGER PROC FNFileGetSizeDiskI( STRING filenameS )
```

Pass a Windows path when running TSE for Windows, or a normal Linux path when running TSE under WSL or on native Linux. The function returns the file length in bytes, or `0` if the file cannot be found.

## Version information

- Version: **1.0.0.0.10**
- Date: **2026-09-06**
- Time: **19:23 CEST**
- LLM: **OpenAI Codex**

## Version history

| Version | Date | Change |
| --- | --- | --- |
| `1.0.0.0.8` | 2026-09-05 | Windows-only implementation. |
| `1.0.0.0.9` | 2026-09-06 | Added Linux/WSL support by using the same TSE file-search and size functions on both platforms; added clean cancellation and an empty-input check. |
| `1.0.0.0.10` | 2026-09-06 | Explicitly documented and supported native Linux distributions such as Ubuntu in addition to Windows and WSL. |
