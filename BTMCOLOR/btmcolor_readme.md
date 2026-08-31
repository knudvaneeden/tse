# BTMCOLOR for TSE

**Version:** 1.0.0.0.0  
**Package:** `btmcolor.zip`

## Description

BTMCOLOR is a syntax-coloring definition for The SemWare Editor (TSE). It adds color highlighting for 4DOS and NDOS batch-to-memory files with the `.BTM` filename extension.

4DOS is a replacement command processor for MS-DOS. NDOS is the version of 4DOS that was distributed with Norton Utilities. A `.BTM` file is a batch file that is loaded into memory before execution, which can improve batch-file processing speed.

The supplied `BTMCOLOR.TSE` file was designed for the command sets of:

- 4DOS 5.5
- NDOS 7.0
- MS-DOS 6.2

Because this is a historical color-definition file, newer commands and newer JP Software Take Command/TCC syntax may not be included.

## Files in the archive

- `BTMCOLOR.TSE` — TSE syntax-coloring definition containing commands, variables, functions, operators, and their assigned color groups.
- `BTMCOLOR.TXT` — original description and installation notes by Tom Bowden.

## Color assignments

The template uses the following general color scheme:

| Color | Highlighted items |
|---|---|
| White | Most internal 4DOS/NDOS commands |
| Yellow | `IF`, `THEN`, and `ELSE` constructs; comparison operators; labels |
| Red | Most symbols and transfer-of-control commands such as `FOR`, `DO`, `UNTIL`, `WHILE`, `GOTO`, `GOSUB`, `RETURN`, and `CALL` |
| Green | External MS-DOS commands and utilities; numbers |
| Magenta | 4DOS/NDOS internal variables and variable functions; paired commands such as `PUSHD`/`POPD` and `TEXT`/`ENDTEXT` |
| Grey | Remarks and comments |

The actual displayed colors can depend on the color-group configuration in your TSE installation.

## Installation

1. Extract `btmcolor.zip` to a temporary directory.
2. Locate `BTMCOLOR.TSE` in the extracted files.
3. Copy `BTMCOLOR.TSE` to the directory in which your TSE color-definition or syntax-coloring files are stored.
4. Make a backup copy of your existing TSE color configuration before changing it.
5. Ensure that TSE's color configuration associates the `.BTM` extension with the `.btm` color group/template.
6. Reload the color configuration, restart TSE, or recompile the relevant color macro if required by your particular TSE installation.

> The exact installation command varies among TSE versions and customized `COLORS.S` setups. `BTMCOLOR.TSE` is a color-definition data file; it is not a standalone SAL macro that you run directly.

## How to use it

1. Start TSE.
2. Open a 4DOS or NDOS batch-to-memory file whose name ends in `.BTM`.
3. TSE should select the `.btm` color definition automatically.
4. Commands, variables, functions, numbers, symbols, labels, and comments should appear in their assigned colors.

If the file remains uncolored, see the troubleshooting section below.

## Optional `.BAT` file highlighting

The original instructions state that the template can also colorize ordinary `.BAT` files. Add or adapt the following association in the `mResolveGroupExtensions` procedure of your `COLORS.S` file:

```text
when ".btm", ".bat"
    s = ".btm"
```

After saving the change, compile or reload `COLORS.S` according to your normal TSE color-macro procedure. Back up `COLORS.S` before editing it.

## Help and troubleshooting

### No syntax colors appear

- Confirm that the edited file has a `.BTM` extension.
- Confirm that `BTMCOLOR.TSE` is in the directory used by your TSE color system.
- Check that `.btm` is mapped to the BTMCOLOR definition in `COLORS.S` or the equivalent configuration used by your TSE version.
- Reload or recompile the color macro and restart TSE if necessary.

### `.BTM` works, but `.BAT` does not

Add `.bat` to the `.btm` mapping as shown in **Optional `.BAT` file highlighting**, and then reload or recompile the color configuration.

### Some commands are not highlighted

The supplied definition dates from 1994 and targets 4DOS 5.5, NDOS 7.0, and MS-DOS 6.2. Add missing modern commands, variables, or functions to a working copy of `BTMCOLOR.TSE`, following the format of the existing entries.

### The colors differ from the descriptions

The letter codes in `BTMCOLOR.TSE` refer to TSE color groups. If those groups were customized in your installation, their on-screen colors may differ from the original white, yellow, red, green, magenta, and grey scheme.

## Version history

### 1.0.0.0.0

- Initial README release.
- Documented the supplied BTMCOLOR files, purpose, color assignments, installation, use, optional `.BAT` support, and troubleshooting.

Future documentation revisions can continue as `1.0.0.0.1`, `1.0.0.0.2`, and so on.

## Original credit

The BTMCOLOR template and its original documentation identify **Tom Bowden** as the author.
