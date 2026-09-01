# CJJSTFY3 - Improved Paragraph Justification for TSE

**README version:** 1.0.0.0.0  
**Created:** 2026-09-02 01:06:55 CEST (UTC+02:00)  
**Original macro copyright:** 1994 Jack Hazlehurst

## Description

CJJSTFY3 contains **Crazy Jack's Version of JUSTIFY**, a TSE SAL macro for The SemWare Editor (TSE) 2.00. Its main routine, `mJustifyPara()`, is designed as an improved substitute for TSE's `WrapPara()` function.

Unlike the original justification macro, `mJustifyPara()` removes excess spaces left by earlier justification passes before wrapping the paragraph again. This prevents spaces from accumulating when a paragraph is edited and repeatedly rejustified.

The macro:

- Converts tabs in the paragraph to spaces.
- Removes redundant spaces.
- Restores two spaces after sentence-ending punctuation where applicable.
- Rewraps the paragraph using the current TSE right margin.
- Optionally expands spaces to fully justify each line.
- Alternates the direction in which spaces are added, helping distribute them more evenly.
- Saves and restores the `RemoveTrailingWhite` setting.
- Returns the same TRUE or FALSE result expected from `WrapPara()`.

## Archive contents

| File | Description |
| --- | --- |
| `CJJSTFY.S` | TSE SAL source code, documentation, and a self-running `Main()` procedure. |
| `FILE_ID.DIZ` | Original short package description. |

## Requirements

- The SemWare Editor (TSE), version 2.00 or a compatible version.
- A TSE installation capable of compiling and running SAL source files.
- The source relies on TSE 2.00 block-limited find-and-replace features.

## How to run the supplied standalone macro

1. Extract `cjjstfy3.zip` to a working directory.
2. Open `CJJSTFY.S` in TSE.
3. Compile the SAL source with TSE's macro compiler.
4. Place the cursor in, or at the beginning of, the paragraph to process.
5. Execute the compiled `CJJSTFY` macro.
6. At the prompt:
   - Press **Enter** to wrap and fully justify the paragraph.
   - Press **Esc** to normalize and wrap the paragraph with a ragged-right margin.

The macro uses TSE's current `RightMargin` setting. Set the right margin to the desired column before running it.

## Installing it in a TSE user-interface source file

The supplied file includes a `Main()` procedure so it can be tested independently. To use the routine as part of a custom TSE user interface:

1. Copy the global `Justify` variable, the `mjss1` through `mjss5` strings, and the complete `mJustifyPara()` procedure into the user-interface SAL source.
2. Remove or omit the standalone `Main()` procedure from `CJJSTFY.S`.
3. Replace suitable calls to `WrapPara()` with calls to `mJustifyPara()`.
4. Leave existing calls to `mWrapPara()` unchanged, but update the implementation of `mWrapPara()` as described below.
5. Optionally assign a key or menu command that toggles the global `Justify` variable:
   - `TRUE` enables full justification.
   - `FALSE` performs normal paragraph wrapping with a ragged-right margin.
6. Recompile the modified user interface and load it in TSE.

## Important `mWrapPara()` compatibility change

The original comments warn that the macro may hang in a `_SYSTEM_` buffer because `RemoveTrailingWhite` has no effect there. This can occur when `mWrapPara()` moves a marked column block into a temporary system buffer for justification.

In the user-interface implementation of `mWrapPara()`, locate:

```sal
CreateTempBuffer()
```

and replace it with a hidden ordinary buffer, following the original source's guidance:

```sal
CreateBuffer("", _HIDDEN_)
```

This change is especially relevant when full-justifying a marked column block.

## Usage notes

- Run the macro with the cursor in the paragraph that should be reformatted.
- Blank lines are used to locate paragraph boundaries.
- The final line of a paragraph is wrapped but is not padded like the preceding lines.
- Re-running the macro is safe for normal text because existing excess justification spaces are removed first.
- Keep a backup of a custom TSE user-interface source before integrating the procedure.

## Troubleshooting

### The paragraph uses the wrong width

Set TSE's `RightMargin` value to the required output column, then run the macro again.

### The macro only wraps and does not fully justify

When using the standalone version, press **Enter** at the prompt. When integrated into a user interface, make sure the global `Justify` variable is `TRUE`.

### TSE appears to hang while processing a column block

Check the `mWrapPara()` implementation and replace its `CreateTempBuffer()` call with `CreateBuffer("", _HIDDEN_)`, as described in the compatibility section.

### Compilation fails after integration

Ensure that the global integer `Justify` and all five shared strings (`mjss1` through `mjss5`) were copied along with `mJustifyPara()`. Also verify that no conflicting declarations already exist in the user-interface source.

## Version history

| Version | Date and time | Changes |
| --- | --- | --- |
| 1.0.0.0.0 | 2026-09-02 01:06:55 CEST | Initial Markdown documentation created from `CJJSTFY.S` and `FILE_ID.DIZ`. |

Future documentation updates can continue as `1.0.0.0.1`, `1.0.0.0.2`, and so on.

## Original archive

The original package is distributed as `cjjstfy3.zip`. This README documents the supplied files without modifying the original SAL source.
