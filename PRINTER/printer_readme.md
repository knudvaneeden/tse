# PRINTER

Version: 1.0.0.0.0  
Date and time: 2026-09-27 18:26 CEST (Europe/Amsterdam)

## Description

PRINTER provides wrappers around TSE's built-in print operations. `PRINTER.S` is the modern source; it has no external DLL or BIOS dependency. Its `Main()` displays usage help when you run the compiled macro directly. It does not print until a calling macro invokes one of the printing functions.

The original 1993 DOS implementation is retained as `PRINTER_DOS.S`, with `CHKPRN.ASM` and `CHKPRN.BIN` for reference. The DOS version uses BIOS interrupt 17h and is not suitable for TSE/32 on Windows or TSE on Linux.

## Functions

| Function | Action |
| --- | --- |
| `PrinterReady()` | Compatibility function; returns TRUE because modern print queue status cannot be determined by the old port check. |
| `PrinterWarning()` | Displays a failed print operation warning. |
| `mPrintBlock()` | Calls `PrintBlock()` and warns if it fails. |
| `mPrintChar(s)` | Calls `PrintChar(s)` and warns if it fails. |
| `mPrintFile()` | Calls `PrintFile()` and warns if it fails. |
| `PrintString(s)` | Sends characters without an initial status check; retains the original procedure interface. |
| `SendPrintString(s)` | Sends characters and returns FALSE on the first failed `PrintChar()`. |

The wrappers observe the result TSE reports when printing. `PrinterReady()` is retained for source compatibility but is not a reliable test of a printer's actual physical state. A successfully queued print job may still fail later.

## Steps to run

1. Extract the files into one directory. Set TSE's print device to your destination.
2. Compile `PRINTER.S` with your installed TSE SAL compiler (for example, `sc32 PRINTER.S` on Windows). No Borland compiler or DLL is needed for this version.
3. Run the compiled PRINTER macro in TSE to display its help message.
4. To use its printing functions, include `PRINTER.INC` immediately after your UI's `config`/`endconfig` block, as described by that file, and compile/link `PRINTER.S` into your UI application. Invoke `mPrintFile()`, `mPrintBlock()`, `mPrintChar(s)`, or `SendPrintString(s)` from your own code. If your UI already defines `Main()`, integrate these routines without a second `Main()` definition.

Compilation and runtime behavior require testing in your TSE installation; no TSE compiler is available in the creation environment.

## Configuration

The included `printer.ini` has:

```ini
[Settings]
silent=false
```

Keep it in the current working directory when running the macro. `silent=false` displays the startup `Warn()` box; `silent=true` suppresses that box. Print failure warnings remain active. If the INI file is missing, the startup box appears.

## Legacy files

`PRINTER_DOS.S`, `CHKPRN.ASM`, and `CHKPRN.BIN` are historical material. Use `PRINTER.S` for current TSE/32. The legacy binary cannot perform a valid Windows printer queue status check.
