# CmdLine Version 3 for TSE

**README version:** 1.0.0.0.1  
**Created:** 2026-09-02 21:43:30 CEST  
**Original package date:** 1993-09-13  
**Original author:** David Marcus

## Description

CmdLine Version 3 is a set of helper routines for The SemWare Editor (TSE) and its SAL macro language. It allows a TSE configuration to recognize custom command-line options, retrieve their arguments, remove handled options from TSE's remaining command line, and separately collect filenames supplied on the command line.

The package is useful when you want to:

- add a new TSE command-line option;
- reinterpret a standard TSE option;
- pass an option argument to another macro;
- process command-line filenames yourself;
- perform an action after TSE starts, such as jumping to a line and column or printing files.

## Package contents

| File | Purpose |
| --- | --- |
| `CMDLINE.S` | The two reusable command-line helper routines. |
| `CMDLINE.DOC` | Original documentation and usage notes. |
| `CMDEXAM.S` | Examples for line/column navigation, printing files, and calling an external loader macro. |
| `FILE_ID.DIZ` | Short archive description. |

## Main routines

### `CmdLineOptionUsed(STRING option)`

Tests whether an option occurs on the TSE command line. Pass only the option name, without its leading hyphen.

```sal
if CmdLineOptionUsed('X')
    // The -X option was supplied.
endif
```

The routine:

1. returns `TRUE` when the option is found, otherwise `FALSE`;
2. removes the handled option and its argument from `DOSCmdLine`;
3. stores the option argument in a global string named:

```text
CmdLineArgFor<option>
```

For option `-X`, retrieve the argument with:

```sal
GetGlobalStr('CmdLineArgForX')
```

For example, the command line option `-Xreport.txt` makes `report.txt` available through `CmdLineArgForX`.

> **Important:** Option matching is case-sensitive. If both lowercase and uppercase variants must work, test both variants and retrieve the corresponding global argument carefully.

### `CmdLineFiles()`

Returns the filenames found on the command line and removes them from `DOSCmdLine`. Options beginning with `-` remain available for normal TSE processing.

```sal
string files[128]

files = CmdLineFiles()
if Length(files)
    EditFile(files)
endif
```

## Installation

1. Extract `cmdline3.zip` into a working directory.
2. Copy `CMDLINE.S` to the directory containing your main TSE SAL configuration source.
3. Add the following before your `WhenLoaded()` procedure:

```sal
#INCLUDE [ "cmdline.s" ]
```

4. Add your option-handling code to `WhenLoaded()`.
5. Compile your main configuration source with the SAL compiler appropriate for your TSE installation.
6. Load or install the resulting compiled configuration or macro as you normally do in TSE.

## Minimal example

This example implements `-X` with a required argument:

```sal
#INCLUDE [ "cmdline.s" ]

proc WhenLoaded()
    string xArg[64] = ''

    if CmdLineOptionUsed('X')
        xArg = GetGlobalStr('CmdLineArgForX')
        if Length(xArg)
            Warn('Argument for -X: ' + xArg)
        else
            Warn('-X requires an argument')
        endif
    endif
end
```

Example invocation:

```text
e32.exe -Xreport.txt
```

Use the actual TSE executable name and path installed on your system.

## Running the supplied example

`CMDEXAM.S` demonstrates two command-line features:

- `-Nline,column` opens the supplied file and moves to a line and column;
- `-P` loads and prints the files specified on the command line.

Before compiling it:

1. Open `CMDEXAM.S`.
2. Replace its historical hard-coded include:

```sal
#INCLUDE [ "q:\cmdline.s" ]
```

with a valid, preferably portable include such as:

```sal
#INCLUDE [ "cmdline.s" ]
```

3. Keep `CMDLINE.S` in the same source directory, or specify another valid include location.
4. Compile `CMDEXAM.S` with your SAL compiler.
5. Install or invoke the compiled macro/configuration according to your TSE setup.

Example commands from the original package are:

```text
e32.exe example.txt -N12,34
e32.exe file1.txt file2.txt -P
```

The first opens `example.txt` and goes to line 12, column 34. The second loads the listed files and starts the example's print workflow.

## Creating your own option

1. Choose an option name, for example `ABC`.
2. Include `CMDLINE.S` in the main configuration source.
3. Create a procedure that performs the desired action.
4. In `WhenLoaded()`, call `CmdLineOptionUsed('ABC')`.
5. If an argument is expected, read `GetGlobalStr('CmdLineArgForABC')`.
6. Validate the argument before using it.
7. Compile and test the configuration with a command such as `e32.exe -ABCvalue`.

## Notes and limitations

- This is historical SAL source from 1993 and may require adaptation for a modern TSE SAL compiler.
- The original code uses fixed-size strings, including a 128-character command-line buffer. Very long command lines may be truncated.
- An option argument is attached directly to the option, for example `-N12,34`; a space terminates the token.
- Filenames or arguments containing spaces are not handled as modern quoted command-line values.
- The helper recognizes options by a leading hyphen (`-`).
- Avoid option names that are prefixes of other option names, because matching can become ambiguous.
- The order of operations in `WhenLoaded()` matters. If an option acts on a file, load the file before performing the action.
- `CMDEXAM.S` references an external `loadfile` macro in a commented example, but that macro is not included in this archive.
- The correct global-string prefix used by `CMDLINE.S` is `CmdLineArgFor`. One passage in the original documentation says `CommandLineArgFor`; that longer spelling is a documentation typo.
- The original copyright and distribution conditions remain applicable. Preserve author credit and identify changes not made by the original author.

## Troubleshooting

### The compiler cannot find `CMDLINE.S`

Place it beside the source that includes it or change the `#INCLUDE` path to a valid location. Use TSE SAL's required bracket notation, for example `#INCLUDE [ "cmdline.s" ]`. Remove the original `q:\cmdline.s` example path if it does not exist on your system.

### An option is not detected

Pass the option without `-` to `CmdLineOptionUsed()`. For `-Xvalue`, use `CmdLineOptionUsed('X')`. Also verify letter case.

### The option is detected but its argument is empty

Attach the argument directly to the option, as expected by the original parser:

```text
-Xvalue
```

rather than:

```text
-X value
```

### TSE processes an option that the macro should intercept

Make sure `CmdLineOptionUsed()` is called early enough in `WhenLoaded()`. When it finds an option, it removes that option from the remaining `DOSCmdLine` value.

### Files are not available when the action runs

Call `CmdLineFiles()`, load the returned files with `EditFile()`, check whether loading succeeded, and only then perform the requested action.

## README version history

| Version | Date and time | Changes |
| --- | --- | --- |
| 1.0.0.0.1 | 2026-09-02 22:14:57 CEST | Corrected all include examples to use the working TSE SAL notation: `#INCLUDE [ "cmdline.s" ]`. |
| 1.0.0.0.0 | 2026-09-02 21:43:30 CEST | Initial Markdown README based on all files in `cmdline3.zip`. |

Future revisions can continue sequentially as `1.0.0.0.2`, `1.0.0.0.3`, `1.0.0.0.4`, and so on.
