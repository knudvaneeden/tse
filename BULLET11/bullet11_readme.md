# BULLET 1.1 for TSE

**README version:** 1.0.0.0.1  
**Package:** `bullet11.zip`

## Description

BULLET is a TSE (The SemWare Editor) SAL macro that adds support for bulleted lists and numbered outlines. It can insert bullet characters, continue a list when you press **Enter**, indent or outdent complete list items with **Tab** and **Shift+Tab**, renumber outlines, and protect list formatting while paragraphs are word-wrapped.

The package also contains:

- **AUTOWRAP** — automatically wraps text while you type and uses BULLET to preserve hanging indents in bulleted lists.
- **INI** — lets BULLET and other macros store settings in a common `TSEPRO.INI` file.
- Original help files for BULLET and INI.

## Package contents

| File | Purpose |
|---|---|
| `BULLET.S` | BULLET SAL source code |
| `BULLET.MAC` | Precompiled BULLET macro |
| `BULLET.TXT` | Original BULLET documentation |
| `AUTOWRAP.S` | AUTOWRAP SAL source code |
| `AUTOWRAP.MAC` | Precompiled AUTOWRAP macro |
| `INI.S` | INI support macro source code |
| `INI.SI` | Include file required when compiling BULLET |
| `INI.MAC` | Precompiled INI support macro |
| `INI.TXT` | Original INI documentation |

## Requirements

- The SemWare Editor (TSE) with SAL macro support.
- The SAL compiler, such as `SC32.EXE`, only if you want to rebuild the supplied `.MAC` files.
- A backup of your TSE configuration before changing macro bindings or replacing existing macros.

This is an older TSE macro package. Compatibility with a current TSE release is not guaranteed; if the supplied `.MAC` files cannot be loaded, compile the included `.S` sources with your own TSE SAL compiler.

## Portable package version 1.0.0.0.1

This revision removes the dependency on TSE's `LoadDir()`:

- BULLET resolves `INI.MAC` from the directory containing `BULLET.MAC`.
- INI stores `TSEPRO.INI` beside `INI.MAC`.
- AUTOWRAP resolves `BULLET.MAC` from the directory containing `AUTOWRAP.MAC`.

Keep the newly compiled macros together. The directory can then be moved without copying support files into the directory containing `G32.EXE` or `E32.EXE`.

## Installing the portable revision

1. Extract `bullet11.zip` into a temporary directory.
2. Compile `INI.S`, `BULLET.S`, and optionally `AUTOWRAP.S` as described below. The supplied 1995 `.MAC` files are the original non-portable binaries and are retained only for reference.
3. Keep the newly compiled `INI.MAC`, `BULLET.MAC`, and optional `AUTOWRAP.MAC` in the same directory.
4. Start TSE.
5. Load `BULLET.MAC` by its full path. Do not load or execute `INI.MAC` manually; BULLET invokes it with a private command line.
6. Load `AUTOWRAP.MAC` by its full path only if you want automatic wrapping while typing.

Do not load `AUTOWRAP` together with another macro or UI configuration that implements the same automatic-wrap behavior unless you have checked that their key hooks are compatible.

## Compiling from source

Keep `INI.SI` in the same directory as `BULLET.S`, because BULLET includes that file.

From a command prompt in the extracted directory, compile the support macro first:

```bat
sc32 INI.S
sc32 BULLET.S
sc32 AUTOWRAP.S
```

If `SC32.EXE` is not on `PATH`, specify its full path. After successful compilation, keep the resulting `.MAC` files together and load `BULLET.MAC` by its full path. Do not load `INI.MAC` manually. Load `AUTOWRAP.MAC` by its full path only when required.

## How to use BULLET

### Insert or change a bullet

1. Place the cursor where the list item should begin, or place it in an existing bullet point.
2. Press **Ctrl+B** to open the Bullet Menu.
3. Select the required bullet or outline style.
4. Type the list text.

Using the Bullet Menu while the cursor is already in a bullet point changes that point's bullet style.

### Continue a list

When WordWrap is enabled or set to automatic mode, press **Enter** at a bullet or outline item to create the next item automatically.

### Indent or outdent an item

Place the cursor on the first line of a bullet point and use:

- **Tab** to indent the complete point.
- **Shift+Tab** to outdent the complete point.

### Create and renumber an outline

1. Press **Ctrl+B**.
2. Choose a numbered, alphabetic, or Roman-numeral outline style.
3. Add items with **Enter**.
4. Choose **Renumber** from the Bullet Menu when an existing sequence needs to be recalculated.
5. Use the menu's options to adjust outline behavior.

## Using BULLET from another SAL macro

BULLET can act as a wrapper around TSE's wrapping commands:

```sal
ExecMacro("bullet -p")
```

Use that in place of `WrapPara()`.

```sal
ExecMacro("bullet -l")
```

Use that in place of `WrapLine()`.

To wrap another macro invocation, pass the macro and its arguments after `bullet`:

```sal
ExecMacro("bullet foo -x")
```

To display the Bullet Menu from a macro:

```sal
ExecMacro("bullet -m")
```

## Configuration

BULLET stores its settings through the included INI macro. Portable revision `1.0.0.0.1` places `TSEPRO.INI` beside `INI.MAC` rather than in TSE's load directory.

The source has compile-time switches near the beginning of `BULLET.S`:

- `BULLET_MENU` controls the **Ctrl+B** menu binding.
- `BULLET_CRETURN` controls automatic list continuation with **Enter**.
- `BULLET_INDENT` controls indentation with **Tab** and **Shift+Tab**.

Set a switch to `0` and recompile `BULLET.S` to disable that feature.

## Troubleshooting

### BULLET does not load

- Confirm that the newly compiled `INI.MAC` is beside `BULLET.MAC`. Do not load INI manually.
- Recompile the sources with the SAL compiler belonging to your installed TSE version.
- Confirm that `INI.SI` is available beside `BULLET.S` during compilation.

### Ctrl+B, Enter, or Tab behaves unexpectedly

Another loaded macro or UI file may use the same key. Purge the conflicting macro, change its key assignment, or disable the corresponding BULLET compile-time switch and rebuild BULLET.

### Word wrapping joins two bullet points

Keep at least one space or hard tab between the bullet character and its text. Without that whitespace, BULLET may interpret the line as part of the preceding point.

### A paragraph is only partly reformatted

In rare cases, the first word on a line can resemble a bullet or outline number. Change that text temporarily, reformat the paragraph, and then restore it.

### AUTOWRAP conflicts with existing wrapping

Remove or disable the other automatic-wrap macro. Some TSE configurations may also require changes to the `.UI` file that supplies existing autowrap support.

## Version history

| README version | Changes |
|---|---|
| 1.0.0.0.1 | Portable path resolution using `CurrMacroFilename()`; removed `LoadDir()`; corrected INI loading instructions; preserved TSE-compatible single-byte source encoding. |
| 1.0.0.0.0 | Initial Markdown description, installation instructions, usage help, compilation steps, macro integration examples, and troubleshooting notes for `bullet11.zip`. |

Future revisions can continue as `1.0.0.0.1`, `1.0.0.0.2`, and so on.

## Original package information

The included original documentation identifies the macro as **BULLET.S v1.1** and credits Chris Antos. The README version above tracks this Markdown documentation independently of the original macro version.
