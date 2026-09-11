# INI.MAC for TSE Pro

**README version:** 1.0.0.0.0  
**Date and time:** 2026-09-11 13:14:47 UTC  
**Session:** Create INI MarkDown Readme

## Description

INI is a TSE Pro SAL support macro by Chris Antos. It lets multiple TSE macros store and retrieve their settings in one readable `tsepro.ini` file. Each client macro uses its own named section, so settings from different macros remain separate.

The archive contains:

| File | Purpose |
| --- | --- |
| `INI.S` | Source code for the central INI settings macro |
| `INI.MAC` | Precompiled macro supplied with the original package |
| `INI.SI` | Include file exposing the INI helper procedures to other SAL macros |
| `INI.TXT` | Original documentation |

The settings file uses a conventional INI layout:

```ini
[AutoSignature]
UserName=Joe Cool
Initials=jc
Signatures=3
```

Section names and key names are matched without regard to letter case. Values are stored as text; integer helper procedures convert between text and SAL integers.

## Requirements

- The SemWare Editor Professional (TSE Pro).
- The TSE SAL compiler when rebuilding `INI.MAC` from `INI.S`.
- `INI.MAC` must be loadable by TSE when a client macro calls its helper procedures.
- `INI.SI` must be accessible to the SAL compiler while compiling a client macro.

## Installation

1. Extract `ini.zip` into a working directory.
2. Copy `INI.SI` to the directory containing the source of the macro that will use it, or to another include directory recognized by your SAL compiler.
3. Copy the supplied `INI.MAC` to a directory from which TSE can load macros.
4. If the supplied compiled macro is incompatible with your TSE version, compile `INI.S` with your TSE SAL compiler and use the newly produced `INI.MAC`.
5. Load `INI.MAC` before running a client macro that uses the INI functions. It may be loaded manually from TSE or by calling `LoadMacro("ini")` from an appropriate startup or client macro.

When loaded, `INI.MAC` keeps the settings in a hidden system buffer. The included source constructs the settings path as `LoadDir() + "tsepro.ini"`. Consequently, `tsepro.ini` is read from and saved in the directory reported by `LoadDir()`.

## Using INI in a SAL macro

Add the include directive near the beginning of the client macro:

```sal
#INCLUDE ["INI.SI"]
```

The current `INI.SI` interface provides the following procedures:

```sal
string proc GetIniStr(string section, string keynm, string default)
integer proc GetIniInt(string section, string keynm, integer default)
proc SetIniStr(string section, string keynm, string value)
proc SetIniInt(string section, string keynm, integer value)
proc SaveIniSettings()
```

Example:

```sal
#INCLUDE ["INI.SI"]

proc Main()
    string userNameS[80]
    integer signatureCountI

    userNameS = GetIniStr("AutoSignature", "UserName", "Unknown")
    signatureCountI = GetIniInt("AutoSignature", "Signatures", 0)

    SetIniStr("AutoSignature", "UserName", userNameS)
    SetIniInt("AutoSignature", "Signatures", signatureCountI)
    SaveIniSettings()
end
```

`GetIniStr()` returns the supplied default string when the requested entry does not exist. `GetIniInt()` does the same for an integer default. Setting a missing key automatically creates it; setting a key in a missing section creates both the section and key.

## How to run it

INI is primarily a support macro and is not intended to be run directly as an interactive utility.

1. Start TSE Pro.
2. Load `INI.MAC`.
3. Compile a client SAL macro containing `#INCLUDE ["INI.SI"]`.
4. Run that compiled client macro.
5. Let the client call `GetIniStr()`, `GetIniInt()`, `SetIniStr()`, or `SetIniInt()` as needed.
6. Call `SaveIniSettings()` when settings should be written immediately. Otherwise, modified settings are saved automatically when `INI.MAC` is purged or TSE closes.

Running `INI.MAC` directly without the internal command arguments displays a warning because its `Main()` procedure is designed to receive commands from the functions in `INI.SI`.

## Settings-file rules

- A section starts with a name enclosed in brackets, such as `[AutoSignature]`.
- A section ends at the next section header or at the end of the file.
- A key consists of a name, an equals sign, and a value.
- Comment lines begin with a semicolon (`;`).
- Section names and key names should contain only letters, digits, spaces, and underscores.
- Values must not contain linefeed, carriage-return, or NUL characters.
- `tsepro.ini` is an ordinary text file and may also be edited manually while INI is not holding unsaved changes.

## Optional integer-helper setting

If a client macro uses only string settings and the compiler warns that `GetIniInt()` or `SetIniInt()` is unused, define `INI_NOINT` before including `INI.SI`:

```sal
#DEFINE INI_NOINT 1
#INCLUDE ["INI.SI"]
```

This omits the integer helper procedures from that client macro.

## Troubleshooting

### TSE reports that it cannot execute INI

Confirm that `INI.MAC` has been compiled for the installed TSE version, is located in a directory searched by TSE, and has been loaded before the client calls an INI helper.

### The SAL compiler cannot find INI.SI

Place `INI.SI` beside the client `.s` source file or in a configured SAL include directory, then compile the client again.

### A value is not found

Check the section and key spelling and inspect `tsepro.ini`. Although matching is case-insensitive, section and key names should use only the supported characters. The getter returns its default value if no matching entry exists.

### Changes are not visible on disk yet

Call `SaveIniSettings()`. Normal writes are deferred until an explicit save, macro purge, or editor shutdown.

### The settings file is in an unexpected directory

The supplied source prefixes `tsepro.ini` with `LoadDir()`. Inspect the directory returned by TSE's `LoadDir()` function and look for the file there.

## Version history

| Version | Date and time | Changes |
| --- | --- | --- |
| 1.0.0.0.0 | 2026-09-11 13:14:47 UTC | Initial Markdown description, help, installation, usage, example, run instructions, and troubleshooting based on the supplied `ini.zip` package. |

Future revisions should increment the final component: `1.0.0.0.1`, `1.0.0.0.2`, and so on.

## Credits

The original `INI.S`, `INI.SI`, and `INI.TXT` identify Chris Antos as the author of the INI macro. The original package states that the macro is used at the user's own risk.
