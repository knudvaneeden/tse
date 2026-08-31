# BULLET for The SemWare Editor (TSE)

**README version:** 1.0.0.0.0  
**Package:** `bullet.zip`  
**Original author:** Chris Antos  
**Target:** The SemWare Editor (TSE)

## Description

`BULLET` is a TSE SAL macro that adds support for creating and wrapping bulleted lists. It provides a bullet-selection menu, can automatically continue a bulleted list when Enter is pressed, and helps TSE's word-wrap commands preserve the layout and hanging indentation of bullet points.

The package also contains `AUTOWRAP`, an optional companion macro that uses `BULLET` while automatically wrapping text as it is typed.

## Package contents

| File | Description |
|---|---|
| `BULLET.S` | TSE SAL source code for the main bullet-list macro. |
| `BULLET.MAC` | Precompiled BULLET macro supplied in the archive. |
| `BULLET.TXT` | Original documentation. |
| `AUTOWRAP.S` | TSE SAL source for the optional automatic word-wrap companion. |
| `AUTOWRAP.MAC` | Precompiled AUTOWRAP macro supplied in the archive. |

## Main features

- Opens a menu from which a bullet character can be inserted.
- Automatically inserts the same bullet on the next line when Enter is pressed and word wrap is enabled.
- Wraps only the relevant bullet point instead of reformatting the entire surrounding list.
- Maintains a hanging indent for wrapped bullet text.
- Can act as a wrapper around `WrapPara()`, `WrapLine()`, or another word-wrap macro.
- Includes the optional `AUTOWRAP` macro for wrapping and indenting bullet lists while typing.

## Installation

### Using the supplied compiled macros

1. Extract `bullet.zip` to a temporary directory.
2. Copy `BULLET.MAC` to the directory from which your TSE installation loads macros.
3. If automatic wrapping is wanted, also copy `AUTOWRAP.MAC` to that directory.
4. Load `BULLET` from TSE, or add it to your normal TSE macro-loading configuration.
5. Load `AUTOWRAP` only if you want its automatic wrapping behavior.

The included `.MAC` files are old precompiled versions. If they are incompatible with your TSE release, compile the supplied `.S` source files as described below.

### Compiling from source

From a command prompt in the extracted directory, run the TSE SAL compiler:

```text
sc32 BULLET.S
sc32 AUTOWRAP.S
```

This should create updated `.MAC` files. Copy the resulting macros to your TSE macro directory and load them in TSE. `AUTOWRAP` calls `BULLET`, so `BULLET.MAC` must be available when `AUTOWRAP` is used.

## How to run and use BULLET

1. Start TSE and load `BULLET.MAC`.
2. Press **Ctrl+B** to open the bullet menu.
3. Select a bullet character. BULLET inserts the selected character followed by a space.
4. Type the first list item.
5. With TSE WordWrap set to **ON** or **AUTO**, press **Enter** to begin the next item with the same bullet.
6. Press Enter a second time when you want a blank line, then remove the unwanted automatically inserted bullet.

### Calling BULLET from another SAL macro

Use BULLET as a wrapper for TSE's wrapping commands:

```sal
ExecMacro("bullet -p")
```

This replaces:

```sal
WrapPara()
```

For line wrapping, use:

```sal
ExecMacro("bullet -l")
```

This replaces:

```sal
WrapLine()
```

To wrap another macro command, pass that command after `bullet`:

```sal
ExecMacro("bullet foo -x")
```

BULLET temporarily identifies the current bullet point, runs the requested wrapping operation, restores its indentation, and removes its temporary paragraph delimiters.

## Using AUTOWRAP

`AUTOWRAP` provides automatic wrapping while text is entered or deleted. It uses `BULLET` so wrapped list items retain their bullet and hanging indent.

1. Make sure `BULLET.MAC` is installed and available to TSE.
2. Load `AUTOWRAP.MAC`.
3. Press **Ctrl+Shift+W** to cycle through TSE's word-wrap modes: OFF, ON, and AUTO.
4. Type normally. When wrapping is required, AUTOWRAP invokes `bullet -l` or `bullet -p`.

Do not load AUTOWRAP together with another macro or `.UI` configuration that hooks the same automatic-wrap behavior unless the definitions have first been reconciled. Conflicting hooks can cause unexpected wrapping.

## Configuration

At the top of `BULLET.S`, these settings control the default key bindings:

```sal
#define BULLET_MENU 1
#define BULLET_CRETURN 1
```

- Set `BULLET_MENU` to `0` to disable the **Ctrl+B** menu binding.
- Set `BULLET_CRETURN` to `0` to disable automatic bullet continuation on **Enter**.

BULLET stores its recognized bullet characters in the TSE global string named `Bullets`. If that value is empty, the macro installs its built-in default set. Advanced users can set this global string in their `.UI` file and can edit `BulletMenu()` in `BULLET.S` to change the displayed menu choices.

After changing the source, recompile `BULLET.S` and reload the resulting macro.

## Keys

| Key | Action |
|---|---|
| **Ctrl+B** | Open the bullet-selection menu. |
| **Enter** | Continue the current bullet when WordWrap is ON or AUTO. |
| **Ctrl+Shift+W** | With AUTOWRAP loaded, cycle through word-wrap modes. |

If these keys are already used by your TSE configuration, change the key assignments near the end of the corresponding `.S` file and recompile it.

## Known limitations

- To insert a blank line after a bullet, press Enter twice and then remove the extra bullet.
- Increasing or decreasing a bullet's indentation is not automatic.
- In rare cases, wrapping may stop early when a recognized bullet character such as `-` or `*` appears as the first character of an ordinary wrapped line.
- The source and compiled macros date from 1995, so current TSE releases may require source-level compatibility adjustments and recompilation.
- Some original extended bullet characters may display differently when the archive is opened with a different legacy code page.

## Troubleshooting

### Ctrl+B does not open the menu

- Confirm that `BULLET.MAC` is loaded.
- Check that `BULLET_MENU` is set to `1` in the source used to compile the macro.
- Check whether another macro or `.UI` assignment overrides Ctrl+B.

### Enter does not continue the bullet

- Set TSE WordWrap to ON or AUTO.
- Confirm that `BULLET_CRETURN` is set to `1`.
- Make sure the first nonblank character is one of the characters in the global `Bullets` string.
- Check whether another loaded macro replaces the Enter key handler.

### Wrapped bullets lose their indentation

- Invoke wrapping through `ExecMacro("bullet -p")` or `ExecMacro("bullet -l")` instead of calling `WrapPara()` or `WrapLine()` directly.
- Verify that the bullet character is present in the global `Bullets` string.

### AUTOWRAP causes unexpected behavior

- Remove or disable other automatic-wrap macros and overlapping `.UI` hooks.
- Test `BULLET` by itself before loading `AUTOWRAP`.
- Recompile both source files with the compiler supplied for your current TSE installation.

## Version history

| Version | Changes |
|---|---|
| 1.0.0.0.0 | Initial Markdown README created from the contents and original documentation of `bullet.zip`. |

Future README revisions should increment the final component sequentially: `1.0.0.0.1`, `1.0.0.0.2`, `1.0.0.0.3`, and so on.

## Credits

The BULLET and AUTOWRAP macros and their original documentation were written by Chris Antos. This README reorganizes the supplied information into installation, usage, configuration, and troubleshooting sections.
