# FNEXP105 — Filename Expansion for TSE

**README version:** 1.0.0.0.0  
**FNEXP version:** 1.05  
**Date:** 2026-09-09  
**Time:** 23:22 CEST  
**Session:** Create FNEXP105 MarkDown Readme

## Description

FNEXP105 provides 4DOS-style filename completion in The SemWare Editor (TSE) prompt boxes. It works in all TSE prompts, including prompts that do not normally expect a filename, such as the **DOS command:** prompt.

Instead of immediately opening TSE's normal filename list, FNEXP can cycle through matching files and directories directly in the prompt. Files that have default extensions are offered first; the remaining matches follow in alphabetical order.

The package was written by Chris Antos and contains FNEXP version 1.05.

## Package contents

| File | Purpose |
| --- | --- |
| `FNEXP.S` | FNEXP TSE SAL source code |
| `FNEXP.MAC` | Precompiled FNEXP macro |
| `FNEXP.TXT` | Original FNEXP documentation |
| `INI.S` | Source for the supporting INI macro used by older, non-Win32 TSE versions |
| `INI.MAC` | Precompiled INI support macro |
| `INI.SI` | Include file for INI support |
| `INI.TXT` | Original INI documentation |
| `file_id.diz` | Short package description |

## Filename-completion keys

These keys are active while a TSE prompt box is open:

| Key | Action |
| --- | --- |
| `Tab` | Insert the next matching filename. FNEXP appends a wildcard when needed. |
| `Shift+Tab` | Insert the previous matching filename. Use `Tab` first to create the list of matches. |
| `Ctrl+Tab` | Open a picklist of matching filenames. |
| `Ctrl+Spacebar` | Open the same filename picklist as `Ctrl+Tab`. |

When a picklist opens, the first matching file or directory is highlighted. You can continue typing to narrow the match.

## Installation

### Use the supplied compiled macro

1. Extract `fnexp105.zip` into a directory of your choice.
2. Make `FNEXP.MAC` available to TSE, normally by copying it to your TSE macro directory or to another directory in TSE's macro search path.
3. Start TSE.
4. Load `FNEXP.MAC` using TSE's macro-loading facility.
5. Open any TSE prompt and test completion by entering part of a filename and pressing `Tab`.

To have FNEXP available in every editing session, add it to your normal TSE macro startup or autoload configuration.

### Compile from the SAL source

1. Keep `FNEXP.S` with the supplied support files.
2. Open a command prompt in that directory.
3. Compile the source with the TSE SAL compiler:

```text
sc32 FNEXP.S
```

4. Confirm that the compiler creates `FNEXP.MAC` without errors.
5. Load the resulting `FNEXP.MAC` in TSE.

TSE/32 provides the profile functions used by FNEXP natively. The supplied `INI.S`, `INI.MAC`, and `INI.SI` files support older, non-Win32 TSE installations. The `INI.S` source explicitly states that it must not be compiled for Win32.

## How to run FNEXP

FNEXP is a resident prompt-enhancement macro. After loading it, open a prompt such as **File → Open**, **Macro → Execute**, or the **DOS command:** prompt. Type a partial path or filename and use the FNEXP keys listed above.

Examples:

1. Open TSE's file-open prompt.
2. Type part of a filename, such as `doc`.
3. Press `Tab` repeatedly to cycle forward through matches.
4. Press `Shift+Tab` to move backward.
5. Press `Ctrl+Tab` or `Ctrl+Spacebar` to choose from a picklist.

## Options

To open the FNEXP options menu:

1. Choose **Macro → Execute...** from TSE's main menu.
2. Enter:

```text
FNEXP -o
```

The options are:

- **AutoEnter** — When enabled, selecting a filename from the picklist accepts the prompt and continues the command. When disabled, the selected filename is inserted but the prompt stays open for further editing.
- **Picklist Always** — When enabled, `Tab` always opens the traditional TSE picklist. When disabled, `Tab` cycles through filenames and `Ctrl+Tab` opens the picklist.

FNEXP stores these choices in the `[FNEXP]` profile section as `AutoEnter` and `PicklistAlways`.

## Macro command-line switches

| Switch | Function |
| --- | --- |
| `-o` | Open the options menu. |
| `-next` | Insert the next matching filename. |
| `-prev` | Insert the previous matching filename; `-next` must be used first. |
| `-pick` | Use the picklist to select a filename. |

Running `FNEXP` without a switch displays its built-in help.

## EDITFILE compatibility

FNEXP is compatible with the `EDITFILE` macro supplied with TSE. With **AutoEnter** enabled, pressing `Ctrl+Tab` while using EDITFILE passes the action through as its normal `Tab` operation, allowing multiple files to be tagged for loading, deletion, or another supported action.

## Troubleshooting

- If the FNEXP keys do nothing, verify that `FNEXP.MAC` is loaded and that the cursor is currently inside a TSE prompt box.
- If `Tab` always opens a picklist, run `FNEXP -o` and turn **Picklist Always** off.
- If selecting a picklist entry closes the prompt unexpectedly, run `FNEXP -o` and turn **AutoEnter** off.
- If compilation cannot find `INI.SI` on an older non-Win32 installation, keep `INI.SI` in the source directory or place it in the compiler's include path.
- Do not compile `INI.S` for TSE/32; TSE/32 already has the required profile support.

## Version history

### README 1.0.0.0.0 — 2026-09-09

- Created the FNEXP105 Markdown description and help file.
- Documented installation, compilation, keys, options, command-line switches, EDITFILE compatibility, and troubleshooting.

Future revisions can continue as `1.0.0.0.1`, `1.0.0.0.2`, and so on.

## Original FNEXP history

- **1.00 — 1996-04-10:** Original version.
- **1.01 — 1996-07-02:** Sorted filenames by name.
- **1.02 — 1996-07-24:** Added the `-uniq` option.
- **1.03 — 1996-08-07:** Sorted filenames by name in ascending, case-insensitive order.
- **1.04 — 1996-10-01:** Removed `-uniq`, added `Ctrl+Spacebar`, and improved picklist completion.
- **1.05 — 1996-11-20:** Sorted filenames by name and listed filenames with default extensions first.

## Author and disclaimer

FNEXP was written by Chris Antos. This README describes the supplied historical package. Test the macro with your particular TSE version and keep backups of your existing macro and configuration files before replacing them.
