# FORSYN - Fortran Syntax Highlighting for TSE Pro/32

## Description

FORSYN is a collection of three SyntaxHilite mapping files for displaying Fortran source code with syntax highlighting in The SemWare Editor Professional (TSE Pro/32).

The archive contains:

| File | Fortran version | Typical extensions | Minimum TSE version |
| --- | --- | --- | --- |
| `FOR.SYN` | FORTRAN 77 and FORTRAN 66 | `.for`, `.f` | TSE Pro/32 3.0 |
| `F90.SYN` | Fortran 90, free-format source | `.f90` | TSE Pro/32 2.8 |
| `F95.SYN` | Fortran 95, free-format source | `.f95` | TSE Pro/32 2.8 |

`FOR.SYN` requires TSE Pro/32 3.0 or later because it uses column-dependent comment highlighting. `F95.SYN` is based on the Fortran 90 mapping and adds the Fortran 95 keywords `ELEMENTAL`, `FORALL`, and `PURE`.

The `.SYN` files are ready-to-use SyntaxHilite mapping files; they are not SAL source files and do not need to be compiled with `sc32`.

## Requirements

- The SemWare Editor Professional for Windows (TSE Pro/32).
- TSE Pro/32 3.0 or later for `FOR.SYN`.
- TSE Pro/32 2.8 or later for `F90.SYN` and `F95.SYN`.
- TSE's SyntaxHilite feature installed and enabled.

## Installation

1. Extract `forsyn.zip` into a temporary directory.
2. Locate the SyntaxHilite directory used by your TSE installation. A typical older installation uses `C:\TSE32\SYNHI`.
3. Copy `FOR.SYN`, `F90.SYN`, and `F95.SYN` into that directory.
4. Start TSE Pro/32.
5. Open the **Options** menu.
6. Select **Full Configuration**.
7. Select **Display/Color Options**.
8. Select **Configure SyntaxHilite Mapping Sets**.
9. Select **Other...** and choose the required `.SYN` file.
10. Select **Associated File Extensions...** and enter the extensions that should use that mapping.
11. Save the configuration when prompted.

The exact menu wording or SyntaxHilite directory can differ between TSE releases and installations.

## Recommended file associations

- Associate `FOR.SYN` with `*.for` and `*.f`.
- Associate `F90.SYN` with `*.f90`.
- Associate `F95.SYN` with `*.f95`.

If an extension is already assigned to another mapping set, remove or change the existing association before assigning it to FORSYN.

## How to run it

FORSYN does not run as a separate macro. After installation and association:

1. Open a Fortran source file in TSE.
2. TSE identifies the file by its extension.
3. SyntaxHilite automatically applies the associated FORSYN mapping.
4. Confirm that comments, keywords, strings, numbers, and operators appear in the configured SyntaxHilite colors.

## Help and troubleshooting

### No syntax highlighting appears

- Confirm that the appropriate `.SYN` file is present in TSE's active SyntaxHilite directory.
- Confirm that the source file extension is associated with the correct mapping set.
- Confirm that SyntaxHilite is enabled in TSE.
- Close and reopen the source file after changing an association. Restart TSE if necessary.

### The wrong highlighting rules are used

Check the file extension and its association. Fixed-format FORTRAN 66/77 source normally uses `FOR.SYN`; free-format Fortran 90 and 95 source normally uses `F90.SYN` or `F95.SYN`.

### FORTRAN 77 comments are not recognized correctly

Use TSE Pro/32 3.0 or later. `FOR.SYN` depends on the column-dependent comment feature used by fixed-format Fortran source.

### Custom colors are required

Use TSE's SyntaxHilite color configuration. The mapping files identify language elements; the editor configuration determines how those elements are displayed.

## Original author

David G. Simpson  
Original package date: 2001-12-03

## Version history

### 1.0.0.0.1 - 2026-09-10 00:52:39 CEST

- Expanded the documentation with requirements, installation instructions, recommended associations, usage steps, and troubleshooting help.
- Clarified that the `.SYN` files are ready to use and do not require SAL compilation.

### 1.0.0.0.0 - 2001-12-03

- Original FORSYN package containing syntax mappings for FORTRAN 77, Fortran 90, and Fortran 95.

