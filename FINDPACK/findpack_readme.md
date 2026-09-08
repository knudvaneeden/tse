# FINDPACK — Enhanced Find Package for TSE

**README version:** 1.0.0.0.0  
**Created:** 2026-09-08 23:26:31 (UTC+02:00)  
**Source archive:** `findpack.zip`  
**Program source:** `FINDPACK.S`  
**Original author:** SemWare (Sammy Mitchell)  
**Original program date:** November 1992; revised April 1993

## Description

FINDPACK is a TSE SAL (The SemWare Editor macro language) enhanced search package. It remembers the current search text and find options, supports explicit forward and backward searches, repeats the previous search without prompting, reverses the current search direction, and provides a menu for all included commands.

The supplied source binds the FINDPACK menu to **F12**.

## Included file

| File | Purpose |
|---|---|
| `FINDPACK.S` | TSE SAL source code for the enhanced find commands and menu. |

## Commands

| Command | Description |
|---|---|
| `mFind()` | Prompts for a search string and find options, then searches from the current position. |
| `mFindForward()` | Prompts for a search string and searches forward using the current options. |
| `mFindBackward()` | Prompts for a search string and searches backward using the current options. |
| `mFindReverse()` | Prompts for a search string and searches in the direction opposite to the last `mFind` direction. |
| `mRepeatFindForward()` | Repeats the last search forward without prompting. |
| `mRepeatFindBackward()` | Repeats the last search backward without prompting. |
| `mRepeatFindReverse()` | Repeats the last search in the opposite direction without prompting. |
| `mSetFindOptions()` | Prompts for new find options. |
| `mFindMenu()` | Opens a menu containing all FINDPACK commands. |

## Find options

FINDPACK accepts TSE's standard find-option letters. The prompt displays:

```text
BGLIWX
```

The meaning and availability of individual option letters can depend on the TSE version. Consult the **Find()** or **Find Options** topic in your TSE help for the authoritative definitions. FINDPACK automatically adds or removes the backward-search option (`B`/`b`) when changing direction. It also adds `+` when repeating a forward search so that the search starts after the current match.

## Requirements

- The SemWare Editor (TSE) with SAL macro support.
- The TSE SAL compiler appropriate for the installed TSE version, commonly `SC32.EXE` for 32-bit TSE.
- A writable directory in which to compile or store the macro.

## Installation and compilation

1. Extract `findpack.zip` to a directory of your choice.
2. Open a Command Prompt in that directory.
3. Compile the source with the TSE SAL compiler:

   ```bat
   sc32 FINDPACK.S
   ```

4. Check the compiler output for errors.
5. Keep the generated macro file in a directory from which TSE can load macros, or specify its full path when loading it.

If `SC32.EXE` is not in `PATH`, invoke it by its full path, for example:

```bat
"C:\Path\To\TSE\SC32.EXE" FINDPACK.S
```

The exact output filename can vary with the TSE edition and compiler version.

## How to run it as a separate macro

1. Start TSE.
2. Load the compiled FINDPACK macro using TSE's **Load Macro** command. In classic TSE configurations this can usually be reached with **Ctrl+F10**, followed by **L**, or through **Menu → Macro → Load**.
3. Press **F12** to open the FINDPACK menu.
4. Select a search command.
5. Enter the required search text and, when requested, the find options.

The exact macro-loading keys may differ if your TSE configuration has customized key assignments.

## Typical use

1. Open the file you want to search in TSE.
2. Press **F12**.
3. Choose **Find** to enter both the search string and options.
4. Choose **RepeatFindForward** or **RepeatFindBackward** to locate another occurrence without re-entering the search string.
5. Choose **FindReverse** or **RepeatFindReverse** when you want to switch to the opposite direction.
6. Choose **Set find options** to change the persistent find options.

Press **Escape** in a prompt or menu to cancel the current operation.

## Integrating FINDPACK into a TSE configuration

The original source can also be incorporated into a custom `TSE.S` configuration.

1. Place the global variable declarations before `WhenLoaded()`.
2. Add the FINDPACK procedures and menu to `TSE.S`, or include the source by the method supported by your TSE version.
3. Initialize the saved options inside `WhenLoaded()`:

   ```text
   _findopts = Query(FindOptions)
   ```

4. Add a key assignment, for example:

   ```text
   <F12> mFindMenu()
   ```

5. Remove or avoid any standalone main routine if one is added when adapting the package for `TSE.S`.
6. Recompile/rebind the editor configuration using the procedure required by your TSE version (the original documentation refers to the compiler's `-b` switch).

Back up the existing TSE configuration before changing or rebinding it.

## Built-in key assignment

The supplied `FINDPACK.S` contains this assignment:

```text
<F12> mFindMenu()
```

Change or remove it before compiling if F12 is already used by another macro or editor command.

## Troubleshooting

### F12 does not open the menu

- Confirm that FINDPACK was compiled successfully.
- Confirm that the compiled macro has been loaded into TSE.
- Check whether another macro or configuration entry overrides F12.
- Run the macro-loading command again and select the compiled FINDPACK macro.

### A repeat command asks for search text

This is expected when no previous FINDPACK search string is stored. Perform `mFind()`, `mFindForward()`, or `mFindBackward()` first.

### Search direction is unexpected

Open **Set find options** and review the active options. The `B` option represents backward searching. Direction-specific commands adjust this option automatically.

### The source does not compile on a modern TSE release

FINDPACK is legacy SAL source from 1992–1993. SAL syntax, compiler behavior, configuration names, or macro-loading conventions may differ between releases. Preserve the original archive, work from a copy, and consult the documentation supplied with the installed TSE version.

### An option letter behaves differently than expected

Use the TSE help for the installed editor version. FINDPACK passes the chosen option string to TSE's built-in `Find()` function, so the editor determines the exact behavior.

## Version history

| README version | Date and time | Changes |
|---|---|---|
| 1.0.0.0.0 | 2026-09-08 23:26:31 (UTC+02:00) | Initial Markdown documentation: description, commands, compilation, loading, operation, configuration integration, and troubleshooting. |

Future documentation revisions can increment the final component sequentially: `1.0.0.0.1`, `1.0.0.0.2`, `1.0.0.0.3`, and so on.

## License and attribution

The source identifies **SemWare (Sammy Mitchell)** as its author. No separate license file is present in the supplied archive. Retain the original source header and consult the source owner or applicable distribution terms before redistributing a modified package.
