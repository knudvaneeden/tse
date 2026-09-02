# CNTWRP — Continuous Paragraph Wrapping for TSE

**README version:** 1.0.0.0.0  
**Created:** 2026-09-02 22:07:00 UTC  
**Original macro date:** 1993-04-26  
**Original author:** Peter J. Farley III  
**Language:** SAL (SemWare Application Language)  
**Target:** The SemWare Editor (TSE)

## Description

CNTWRP adds continuous paragraph wrapping to TSE. When continuous wrapping is enabled, common cursor movement, scrolling, editing, clipboard, and save commands automatically call TSE's `WrapPara()` functionality.

This gives TSE behavior similar to a word processor: as text is edited or the cursor moves through paragraphs, the affected text is reformatted to remain within the configured margins. It is particularly useful when preparing e-mail or other plain-text documents that must not exceed a specified line width.

## Archive contents

| File | Purpose |
| --- | --- |
| `CONTWRAP.S` | Main continuous paragraph-wrapping source code |
| `CONTWRAP.KEY` | Replacement key definitions used while continuous wrapping is active |
| `ABSPOS.S` | Implements `PushAbsPos()` and `PopAbsPos()` for saving and restoring the absolute cursor position |
| `MOVEPARA.S` | Implements `NextPara()`, `PrevPara()`, `BeginPara()`, and `EndPara()` |
| `CONTWRAP.DOC` | Original documentation dated April 26, 1993 |

## How it works

The main command is:

```text
ToggleContWrap()
```

When enabled, the macro:

- enables TSE word wrapping;
- temporarily disables automatic indentation;
- activates the `ContWrapKeys` key definition set;
- wraps the current paragraph before or after supported movement and editing operations;
- wraps all paragraphs crossed by multi-line movement commands such as Page Up and Page Down;
- restores the previous automatic-indent setting when continuous wrapping is disabled.

Pressing the assigned toggle key again disables continuous wrapping.

## Important requirements

`CONTWRAP.S` depends on:

- `MOVEPARA.S`;
- `ABSPOS.S`;
- `CONTWRAP.KEY`;
- the `mWrapPara()` macro in the main TSE source configuration.

All supplied files should remain together in the directory from which the TSE source is compiled, or otherwise be placed where the SAL compiler can resolve the include files.

## Installation

The archive was written for the classic TSE source-and-burn installation model.

1. Extract all files from `cntwrp.zip`.

2. Copy these files to the directory containing the TSE user-interface source files, historically the `TSE\UI` directory:

   ```text
   CONTWRAP.S
   CONTWRAP.KEY
   ABSPOS.S
   MOVEPARA.S
   ```

3. Open `TSE.S`, or your customized equivalent, and add the following include after the definition of `mWrapPara()`:

   ```text
   #include ["contwrap.s"]
   ```

   The multi-line movement wrappers depend on `mWrapPara()`. A forward declaration may be used instead if required by the source layout.

4. In the existing `mWrapPara()` implementation, the original documentation instructs you to replace:

   ```text
   until (not WrapPara()) or (not isCursorInBlock())
   ```

   with:

   ```text
   until (CurrLine() >= Query(BlockEndLine) or not WrapPara())
   ```

   This prevents the paragraph following a marked block from being wrapped accidentally.

5. In `TSE.KEY`, or your customized key-definition file, assign an available key to `ToggleContWrap()`. The original suggested assignment is:

   ```text
   <Alt w>    ToggleContWrap()
   ```

6. Recompile or rebuild the customized TSE configuration. The original documentation specifies:

   ```text
   sc -b
   ```

   Use the equivalent command required by your installed TSE/SAL compiler and configuration.

## How to run

1. Start the rebuilt or customized TSE.
2. Open a plain-text document.
3. Set the desired left and right margins in TSE.
4. Press the key assigned to `ToggleContWrap()`—for example, **Alt+W**.
5. Type or edit paragraph text. Pressing Space or using supported cursor, scrolling, block, paste, or save commands causes the affected paragraph text to be wrapped.
6. Press the toggle key again when continuous wrapping is no longer wanted.

## Supported operations

While `ContWrapKeys` is active, wrapper macros are provided for operations including:

- cursor movement: Up, Down, Left, Right, Home, End, Word Left, and Word Right;
- larger movements: Page Up, Page Down, beginning/end of window, and beginning/end of file;
- scrolling and rolling;
- Tab and Shift+Tab;
- Space insertion;
- cut, copy, and paste;
- saving files, blocks, or all files.

The exact active key assignments are defined in `CONTWRAP.KEY`.

## Paragraph definition

The macro treats a paragraph as one or more nonblank lines separated from other paragraphs by at least one blank line. `MOVEPARA.S` and TSE's built-in `WrapPara()` behavior depend on this definition.

## Warnings and limitations

### All encountered text can be reformatted

When continuous wrapping is active, moving through text can reformat it. This can produce unwanted changes in:

- e-mail header lines;
- source code;
- tables;
- lists whose items are not separated by blank lines;
- preformatted or column-aligned text.

Disable continuous wrapping before moving through content that must retain its exact layout.

### E-mail headers

Moving to the beginning of a file can cause header lines to be wrapped. The original author recommends adapting `MarkWrapUp()` in `CONTWRAP.S` for the local mail format. For example, this line:

```text
when zBegFile   BegFile()
```

could be changed to move down past a fixed number of header lines after `BegFile()`. The correct number is specific to the e-mail system and document format.

### Lists

Adjacent list items without blank lines may be treated as one paragraph and joined or reflowed. Separate items with blank lines or turn continuous wrapping off while editing the list.

### Historical source compatibility

This package dates from 1993 and targets an older TSE/SAL environment. Modern TSE SAL compilers may report deprecated syntax, reserved-name conflicts, or other compatibility errors. Review and test the source against a copy of your current configuration before using it on important files.

## Testing checklist

Before regular use, test the macro on a disposable document:

1. Create several paragraphs separated by blank lines.
2. Configure narrow margins so wrapping is easy to observe.
3. Enable continuous wrapping.
4. Add and remove words in the middle of a paragraph.
5. Move with the arrow, Home, End, Page Up, and Page Down keys.
6. Test cut, copy, and paste.
7. Disable continuous wrapping and confirm that the previous AutoIndent setting is restored.
8. Verify that lists, headers, and other specially formatted text are not edited while the feature is active.

## Troubleshooting

### Include file not found

Confirm that `CONTWRAP.S`, `CONTWRAP.KEY`, `ABSPOS.S`, and `MOVEPARA.S` are available in the compiler's include search location and that their names match the include statements.

### `mWrapPara()` is unknown

Place the `CONTWRAP.S` include after the existing definition of `mWrapPara()`, or add an appropriate forward declaration.

### Alt+W does nothing

Confirm that the key assignment was added to the active TSE key-definition source and that the customized configuration was successfully rebuilt and loaded.

### Text wraps unexpectedly

Toggle continuous wrapping off before entering headers, source code, lists, tables, or preformatted text. Blank lines must separate independent paragraphs.

### AutoIndent behaves differently

The macro disables AutoIndent while continuous wrapping is enabled and restores the saved setting when it is disabled normally. If execution is interrupted or the macro terminates abnormally, inspect and restore the AutoIndent setting manually.

## Version history

| Version | Date and time (UTC) | Changes |
| --- | --- | --- |
| 1.0.0.0.0 | 2026-09-02 22:07:00 | Initial README created from `cntwrp.zip`, its source files, and the original documentation |

For later README revisions, increment the final component sequentially:

```text
1.0.0.0.0
1.0.0.0.1
1.0.0.0.2
1.0.0.0.3
```

## License

No explicit license is included in the supplied archive. Preserve the original author information and documentation, and obtain permission from the appropriate rights holder before redistributing or modifying the package where required.
