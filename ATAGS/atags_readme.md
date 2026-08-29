# ATAGS for The SemWare Editor

## Description

ATAGS v1.09 is a TSE SAL macro for navigating from a symbol in source code to the location where that symbol is defined. It provides tag navigation for:

- MASM assembly source files: `.ASM`, `.INC`, and `.EQU`
- C and C++ source files: `.C`, `.H`, and `.CPP`

For assembly projects, ATAGS reads a Phoenix ATags-compatible `TagV3.dat` or older `TagV2.dat` index. It can also create `TagV3.dat` itself by scanning an assembly project recursively.

For C and C++ projects, ATAGS reads a standard ctags file named `Tags`.

ATAGS was written by LeChee Lai and the included version is **v1.09**, dated May 2001. The original documentation states that it was designed for TSE Pro 2.8 and 3.0. On newer TSE releases, source changes may be necessary if compiler errors or runtime incompatibilities occur.

## Files in `atags.zip`

| File | Description |
| --- | --- |
| `ATAGS.S` | TSE SAL source code for the ATAGS macro |
| `ATAGS.TXT` | Original documentation and version history |

## Keyboard commands

| Key | Action |
| --- | --- |
| `Ctrl+F` | Find the definition of the symbol under the cursor |
| `Ctrl+B` | Return to the previous location in the tag-navigation history |
| `Alt+'` | Display ATAGS status, version, configured directory, and key help |
| `Ctrl+Alt+'` | Create an assembly `TagV3.dat` index recursively |

ATAGS assigns these keys globally while the macro is loaded. If one of them is already used by another TSE command or macro, change the key assignments at the end of `ATAGS.S` and recompile it.

## Installation

1. Extract `atags.zip` into a working directory.
2. Open a command prompt in that directory.
3. Compile the SAL source with the TSE SAL compiler:

   ```bat
   sc32 ATAGS.S
   ```

4. Confirm that compilation creates `ATAGS.MAC`.
5. Copy `ATAGS.MAC` to your TSE macro directory, if the working directory is not already on TSE's macro search path.
6. Start TSE and load the macro by entering its macro name through TSE's **Execute Macro** command:

   ```text
   ATAGS
   ```

7. To load ATAGS automatically whenever TSE starts, add `ATAGS` to the TSE AutoLoad macro list using your normal TSE configuration method.

If `sc32` is not on the Windows `PATH`, run it with its full pathname instead.

## Assembly-project setup

### 1. Set the project directory

Before starting TSE, define the `TAGFILE` environment variable as the directory containing the assembly project and its tag index:

```bat
set TAGFILE=G:\MYPROJECT
g32.exe
```

Use your actual project directory. The variable contains a **directory**, not the name of `TagV3.dat`.

For a permanent user-level Windows environment variable, you can use:

```bat
setx TAGFILE "G:\MYPROJECT"
```

After `setx`, close and reopen the command prompt and restart TSE so that it receives the new value.

### 2. Create the assembly tag index

1. Load ATAGS.
2. Press `Ctrl+Alt+'`.
3. Confirm the creation dialog.
4. ATAGS recursively scans the configured project directory for:
   - `*.asm`
   - `*.inc`
   - `*.equ`
   - `*.h`
5. It writes `TagV3.dat` in the directory specified by `TAGFILE`.

The internal index creator recognizes common MASM definitions including `proc`, `dw`, `db`, `equ`, `label`, `macro`, `dd`, and labels ending in a colon. It is MASM-oriented and may not recognize every assembler syntax or every possible symbol declaration.

You may alternatively use a Phoenix ATags-compatible utility to generate `TagV3.dat`. If `TagV3.dat` is absent, the macro tries the older `TagV2.dat` format.

### 3. Navigate to an assembly symbol

1. Open an assembly source file in TSE.
2. Put the cursor on the symbol to locate.
3. Press `Ctrl+F`.
4. If the index contains one match, ATAGS opens the target file and moves to the definition.
5. If several definitions match, select the required entry from the displayed list and press `Enter`.
6. Press `Ctrl+B` to return to the preceding source location.

## C and C++ project setup

ATAGS expects a standard ctags index named `Tags`. Generate it in the root of the C/C++ project with your preferred ctags implementation. For example:

```bat
ctags -R -f Tags *.c *.h *.cpp
```

The exact options supported by `ctags` depend on the installed implementation.

When `Ctrl+F` is used in a `.C`, `.H`, or `.CPP` file, ATAGS looks for `Tags` in the current directory and then searches parent directories. Put the cursor on a symbol and press `Ctrl+F`; use `Ctrl+B` to return.

## Help and troubleshooting

### `TagV3.DAT not found`

- Check that `TAGFILE` points to the correct assembly-project directory.
- Confirm that `TagV3.dat` or `TagV2.dat` exists there.
- Restart TSE after changing the environment variable.
- Press `Alt+'` to see the directory currently used by ATAGS.

### `Can't file Tag File`

This message, which means that the tag file could not be found, normally occurs during C/C++ navigation. Confirm that a file named `Tags` exists in the current project directory or one of its parent directories.

### `Tag <name> not found`

The symbol is missing from the index. Recreate `TagV3.dat` or regenerate the C/C++ `Tags` file after changing source code.

### `Bad Filename in tag file`

The index refers to a source file that ATAGS cannot locate. Regenerate the index from the proper project directory and check whether its stored paths are still valid.

### The definition is indexed but cannot be found

The source may have changed since the index was generated. Rebuild the tag file. Also note that the internal assembly index creator supports a limited set of MASM declaration patterns.

### Compilation fails on a newer TSE version

ATAGS is legacy SAL code originally intended for TSE Pro 2.8/3.0. Review the compiler's reported lines for APIs or syntax that changed in later TSE versions. The original notes specifically mention a historical `CmpiStr()`/`CmpStr()` compatibility difference between TSE versions.

## Typical assembly workflow

```bat
set TAGFILE=G:\SOURCE\MYASM
g32.exe
```

Then, inside TSE:

1. Load `ATAGS` if it is not autoloaded.
2. Press `Ctrl+Alt+'` to build `TagV3.dat` initially.
3. Place the cursor on a symbol and press `Ctrl+F`.
4. Press `Ctrl+B` to return.
5. Rebuild `TagV3.dat` whenever declarations or project files change.

## Limitations

- The internal tag creator is designed for MASM syntax.
- Its assembly file patterns and recognized declaration keywords are fixed in `ATAGS.S`.
- The macro uses global key assignments that may conflict with existing TSE commands.
- Tag indexes are not updated automatically when source files change.
- Because this is older software, current TSE versions may require compatibility edits.

## Version history summary

- **v1.09:** Added Ctags support; selects assembly or Ctags behavior from the source-file extension.
- **v1.08:** Added backward navigation and rearranged key assignments.
- **v1.07:** Improved label and token handling.
- **v1.06:** Corrected duplicate-result handling.
- **v1.05:** Added backward compatibility with `TagV2.dat`.
- **v1.03:** Added a selection list for duplicate matches.
- **v1.02:** Added label support.
- **v1.01:** Added `TAGFILE` environment-variable support.

