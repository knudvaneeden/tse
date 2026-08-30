# BLOCKS.S for The SemWare Editor

**README version:** 1.0.0.0.0  
**Source archive:** `blk_1.zip`  
**Included source file:** `BLOCKS.S`

## Description

`BLOCKS.S` is a TSE SAL macro written by "Buddy" E. Ray Asbury, Jr. It provides prompted alternatives for five standard editing operations in The SemWare Editor (TSE):

- Copy text to the clipboard
- Cut text to the clipboard
- Paste text from the clipboard
- Copy a marked block
- Move a marked block

The macro reduces the number of separate key bindings needed for the alternative forms of these commands. When appropriate, it displays a small menu so that you can choose the required behavior.

## What the commands do

| Macro command | Behavior |
|---|---|
| `mCopy()` | Prompts whether clipboard text should be overwritten or appended to. |
| `mCut()` | Prompts whether clipboard text should be overwritten or appended to. |
| `mPaste()` | If the clipboard contains a column block, prompts whether to overwrite existing text or insert the block. Other block types are inserted normally. |
| `mCopyBlock()` | For a marked column block, prompts whether to overwrite existing text or insert the copied block. Other marked block types are copied normally. If no block is marked, it duplicates the preceding character when possible. |
| `mMoveBlock()` | For a marked column block, prompts whether to overwrite existing text or insert the moved block. Other marked block types are moved normally. |

Press the highlighted letter or select a menu entry and press **Enter**. Pressing **Escape** cancels the prompted macro by executing SAL's `Halt` command.

## Included sample key bindings

The bottom of `BLOCKS.S` defines these bindings:

| Key | Command |
|---|---|
| **Ctrl+F1** | `mCopy()` |
| **Ctrl+F2** | `mCut()` |
| **Ctrl+F4** | `mPaste()` |
| **Alt+C** | `mCopyBlock()` |
| **Alt+M** | `mMoveBlock()` |

These are sample bindings. Edit them before compiling if they conflict with keys already used in your TSE configuration.

## Requirements

- The SemWare Editor with a compatible SAL compiler
- The extracted `BLOCKS.S` source file

The source uses older SAL spelling and style, including `CONSTANT`, `IIF`, `isBlockMarked`, and menu declarations. If a current SAL compiler reports compatibility errors, the source may need minor modernization for that TSE release.

## Installation and compilation

1. Extract `blk_1.zip` to your TSE SAL working directory.
2. Optionally open `BLOCKS.S` and change the five sample key bindings at the bottom of the file.
3. Open a command prompt in that directory.
4. Compile the source with the TSE SAL compiler. For a 32-bit TSE installation, a typical command is:

   ```text
   sc32 BLOCKS.S
   ```

5. Confirm that compilation creates the corresponding loadable macro file, normally `BLOCKS.MAC`.
6. Copy the compiled macro to the directory from which your TSE installation loads macros, if necessary.
7. Start TSE and load the macro. Depending on your setup, use TSE's **Load Macro** command or add the macro to your normal startup/loading configuration.

If your compiler is not on `PATH`, invoke it with its complete path.

## How to use it

### Copy or cut with overwrite/append selection

1. Mark the text to copy or cut.
2. Press **Ctrl+F1** to copy or **Ctrl+F2** to cut.
3. Choose **OverWrite** to replace the existing clipboard contents, or **Append** to add the selected text to them.

### Paste a column block

1. Place the cursor at the destination.
2. Press **Ctrl+F4**.
3. If the clipboard contains a column block, choose **OverWrite** or **Insert**.

For a non-column clipboard block, the macro pastes without showing this menu.

### Copy or move a marked block

1. Mark a block and place the cursor at the destination as required by TSE's normal block commands.
2. Press **Alt+C** to copy the block or **Alt+M** to move it.
3. For a column block, choose **OverWrite** or **Insert**.

For inclusive, noninclusive, and line blocks, TSE performs its normal copy or move operation without displaying the choice menu.

## Notes

- The macro temporarily uses a buffer to determine whether clipboard data is a column block.
- `mPaste()` removes an existing block mark before pasting, while preserving the user's `UnMarkAfterPaste` setting.
- The source was released into the public domain by its author according to its header comment.
- Keep the original ZIP as a backup before modifying the source or its bindings.

## README version history

| Version | Changes |
|---|---|
| 1.0.0.0.0 | Initial description, command reference, installation instructions, usage steps, and key-binding table for `blk_1.zip`. |

Future revisions can use `1.0.0.0.1`, `1.0.0.0.2`, and so on.
