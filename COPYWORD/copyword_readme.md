# COPYWORD — Copy the Current Word in TSE

**README version:** 1.0.0.0.0  
**Created:** 2026-09-03 21:27:09 UTC  
**Original source date:** 1993-04-21  
**Target:** The SemWare Editor (TSE), SAL macro

## Description

`COPYWORD.S` is a small TSE SAL macro that copies the word at the current cursor position to the clipboard. You do not need to mark the word manually.

The macro temporarily saves the existing block selection, marks the current word, copies it, and then restores the previous block selection.

The supplied key assignment is:

```text
Ctrl+numeric-keypad *
```

In the SAL source this key is written as:

```sal
<Ctrl Grey*> mCopyWord()
```

`Grey*` means the multiplication (`*`) key on the numeric keypad, not the regular `*` key.

## Included file

- `COPYWORD.S` — SAL source code containing the `mCopyWord()` procedure and its key assignment.

## How it works

The procedure performs these operations:

1. `PushBlock()` saves the current block-selection state.
2. `MarkWord()` marks the word at the cursor.
3. `Copy()` copies the marked word to the TSE clipboard.
4. `PopBlock()` restores the previous block-selection state.

## Requirements

- The SemWare Editor (TSE) for Windows.
- The TSE SAL compiler, such as `SC32.EXE`.
- A keyboard with a numeric keypad, or a replacement key assignment if the keypad key is unavailable.

## Installation and compilation

1. Extract `copyword.zip` to a working directory.
2. Open a command prompt in that directory.
3. Compile the source:

   ```bat
   sc32 COPYWORD.S
   ```

4. Confirm that compilation finishes without errors. The compiler creates the executable TSE macro file, normally `COPYWORD.MAC`.
5. Copy or move `COPYWORD.MAC` to the directory from which your TSE installation loads macros, if necessary.

If `SC32.EXE` is not in `PATH`, invoke it with its complete path instead.

## How to run it

1. Start TSE or restart it after installing the compiled macro.
2. Load `COPYWORD` as a TSE macro if it is not already loaded.
3. Open a text file and place the cursor anywhere on the word you want to copy.
4. Press **Ctrl+numeric-keypad `*`**.
5. Paste the copied word at the required location by using TSE's normal paste command.

The word is copied to TSE's internal clipboard. The macro does not explicitly copy it to the Microsoft Windows clipboard.

## Loading the macro automatically

If you want the key assignment to be available whenever TSE starts, add the compiled macro to your normal TSE startup or autoload configuration. The exact configuration location depends on your TSE installation and setup.

## Changing the key assignment

Edit the last line of `COPYWORD.S` and replace `<Ctrl Grey*>` with another valid TSE SAL key definition. Then compile the source again.

For example, the original definition is:

```sal
<Ctrl Grey*> mCopyWord()
```

Choose a key that does not conflict with another loaded macro or existing editor command.

## Troubleshooting

### The key does nothing

- Verify that `COPYWORD.S` compiled successfully.
- Verify that the resulting `COPYWORD.MAC` is loaded in TSE.
- Make sure you pressed the `*` key on the numeric keypad while holding Ctrl.
- Check whether another macro uses the same key assignment.

### No word is copied

- Place the cursor on a word rather than on whitespace or punctuation.
- Test with a simple word made from letters or digits.
- The exact word boundaries are determined by TSE's `MarkWord()` behavior and configuration.

### The copied text is not in the Windows clipboard

This macro calls TSE's `Copy()` command and is intended for the TSE clipboard. It contains no explicit Windows-clipboard operation.

## Source overview

```sal
proc mCopyWord()
    PushBlock()
    MarkWord()
    Copy()
    PopBlock()
end

<Ctrl Grey*> mCopyWord()
```

## Version history

| Version | Date and time (UTC) | Changes |
|---|---|---|
| 1.0.0.0.0 | 2026-09-03 21:27:09 | Initial Markdown documentation for `COPYWORD.S`. |

Future documentation revisions should increment the final component, for example:

- `1.0.0.0.1` — first revision
- `1.0.0.0.2` — second revision
- `1.0.0.0.3` — third revision

## Notes

- The archive contains one 112-byte ASCII source file named `COPYWORD.S`.
- The original source file is dated 1993-04-21.
- Keep the `.S` source file so the macro can be recompiled after changing its key assignment.
