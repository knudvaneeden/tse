# ATOE — ASCII/EBCDIC File Converter for TSE Pro

## Description

ATOE is a TSE Pro macro that lets TSE edit fixed-record-length EBCDIC files.

When a file with the configured EBCDIC filename extension is opened, the macro:

1. Opens the file in binary mode using the configured record length.
2. Converts its contents from EBCDIC to ASCII for editing in TSE.
3. Offers to save the edited file as either EBCDIC or ASCII.

The conversion is performed by the included 32-bit Windows helper library, `ascii_ebcdic.dll`.

ATOE was written by Sammy Mitchell of SemWare for TSE Pro 4.0 for Windows. It is described by its author as experimental, so keep a backup of important files before using it.

## Files in `atoe.zip`

| File | Description |
| --- | --- |
| `atoe.mac` | Compiled TSE macro, ready to install |
| `atoe.s` | TSE SAL source code for the macro |
| `ascii_ebcdic.dll` | 32-bit ASCII/EBCDIC conversion library required by the macro |
| `atoe.txt` | Original installation instructions |
| `file_id.diz` | Original archive description |

> Note: The original `atoe.txt` refers to `atoe.dll`. The DLL actually included in the archive, and referenced by `atoe.s`, is `ascii_ebcdic.dll`.

## Requirements

- TSE Pro for Windows (32-bit)
- The TSE executable `g32.exe`
- Write access to the TSE installation and macro directories
- The record length and filename extension used by your EBCDIC files

## Installation

1. Make a backup of any files you plan to convert or edit.
2. Extract `atoe.zip` into the directory containing `g32.exe`.
3. Keep `ascii_ebcdic.dll` in the same directory as `g32.exe`, so the macro can load it.
4. Move these two files into TSE's `mac` subdirectory:

   - `atoe.mac`
   - `atoe.s`

5. Open a Command Prompt and change to the TSE installation directory. For example:

   ```bat
   cd /d C:\TSE
   ```

6. Start TSE and load the macro:

   ```bat
   g32.exe -eatoe
   ```

7. When prompted, enter the extension used by your EBCDIC files, for example:

   ```text
   .ebc
   ```

   If the leading period is omitted, the macro adds it automatically.

8. Enter the fixed EBCDIC record length when prompted, for example:

   ```text
   80
   ```

9. Exit TSE after answering both questions. The macro adds itself to TSE's autoload configuration, so it will load automatically in later sessions.

## How to Use It

1. Start TSE normally.
2. Open an EBCDIC file whose extension matches the extension configured during installation.
3. The macro opens the file using the configured fixed record length and converts the displayed contents to ASCII.
4. Edit the text normally.
5. Save the file. A **Save As** dialog offers three choices:

   - **EBCDIC** — converts the edited text back to EBCDIC before saving.
   - **ASCII** — saves the edited text as ASCII instead.
   - **Cancel** — cancels the save operation.

## Configuration

The macro stores the EBCDIC filename extension and logical record length in TSE's profile data under the `EBCDIC` section. These questions normally appear only the first time the macro is loaded.

To use a different extension or record length, remove or change the following saved profile entries and reload the macro:

- `extension`
- `lrecl`

The exact profile-editing method depends on the TSE version and configuration. Alternatively, update the values through TSE's profile facilities and restart TSE.

## Recompiling the Source

The archive already includes the compiled `atoe.mac`, so recompilation is normally unnecessary. To rebuild it after modifying `atoe.s`, use the TSE SAL compiler appropriate for your TSE installation, for example:

```bat
sc32.exe atoe.s
```

Keep the resulting `atoe.mac` in TSE's `mac` directory and keep `ascii_ebcdic.dll` where TSE can load it.

## Troubleshooting

### The macro cannot load the DLL

Confirm that `ascii_ebcdic.dll` is in the same directory as `g32.exe`. It must retain that exact filename. Also confirm that you are using the 32-bit Windows edition of TSE.

### A file is not converted automatically

Confirm that its filename extension exactly matches the configured EBCDIC extension and that the macro is present in TSE's autoload list.

### Records or lines appear incorrectly

The configured logical record length must match the fixed record length of the EBCDIC file. A wrong value causes the binary records to be divided incorrectly.

### Conversion may damage the original file

Work on a copy until you have verified the conversion and save behavior with your EBCDIC data. The original package explicitly labels the macro experimental.

