# BLOCKCNT for The SemWare Editor

**README version:** 1.0.0.0.0  
**Original macro author:** Dan Farmer  
**Original source date:** July 28, 1995

## Description

BLOCKCNT is a small TSE SAL macro for The SemWare Editor (TSE). It counts the size of the block marked in the current file and displays the result in TSE's message/header area.

- For a **line block**, it reports the number of blocked lines.
- For a **column block**, it reports the number of blocked columns.
- If no supported block is marked in the current file, it displays no count.

The supplied hotkey is:

```text
Ctrl+Alt+C
```

## Files in `blockcnt.zip`

| File | Purpose |
|---|---|
| `BLOCKCNT.S` | TSE SAL source code |
| `BLOCKCNT.MAC` | Precompiled TSE macro, ready to load |

## Requirements

- The SemWare Editor (TSE) for DOS or a compatible TSE version capable of loading the included `.MAC` file.
- The TSE SAL compiler is required only if you want to recompile `BLOCKCNT.S`.

Because the supplied files date from 1995, the precompiled macro may not load in every newer TSE edition. If that happens, compile the source with the SAL compiler belonging to your installed TSE version.

## Installation

1. Extract `blockcnt.zip`.
2. Copy `BLOCKCNT.MAC` to your TSE macro directory, or leave it in another directory from which TSE can load macros.
3. Start TSE.
4. Load `BLOCKCNT.MAC` using TSE's macro-loading facility.

If your TSE installation automatically loads macros listed in an autoload or startup configuration, you may add BLOCKCNT there instead.

## How to run it

1. Open a text file in TSE.
2. Mark either a line block or a column block.
3. Make sure the marked block belongs to the current file.
4. Press `Ctrl+Alt+C`.
5. Read the result in TSE's message/header area, for example:

```text
5 blocked lines
```

or:

```text
12 blocked columns
```

You can also execute the loaded macro by its macro name through TSE's macro execution command, if supported by your TSE version.

## Compiling the source

To rebuild the macro, open a command prompt in the directory containing `BLOCKCNT.S` and run the SAL compiler supplied with your TSE installation. For example, with the 32-bit compiler:

```bat
sc32 BLOCKCNT.S
```

This should create a new `BLOCKCNT.MAC`. Load that compiled file in TSE as described above.

Compiler commands and output formats can differ between TSE editions. Use the compiler that matches the TSE version in which the macro will run.

## Changing the hotkey

The hotkey assignment is the final line of `BLOCKCNT.S`:

```text
<CtrlAlt C> mCountBlocked()
```

Change this line if `Ctrl+Alt+C` conflicts with another macro, then recompile the source.

## Limitations

- The macro explicitly handles line blocks and column blocks.
- Character/stream blocks are not counted.
- A block marked in another file is ignored.
- The displayed value is a width or line count; the macro does not count all characters contained inside a rectangular block.

## Version history

| Version | Changes |
|---|---|
| 1.0.0.0.0 | Initial README with description, installation, compilation, usage, hotkey, and limitations. |

Future README revisions can use sequential versions such as `1.0.0.0.1`, `1.0.0.0.2`, and so on.
