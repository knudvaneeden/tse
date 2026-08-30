# BLOCK1 — TSE Block Procedures

**README version:** 1.0.0.0.0
**Original macro date:** 1994-03-12
**Original author:** D. Marcus
**Archive:** `block1.zip`

## Description

BLOCK1 is a collection of block-handling procedures and key assignments for The SemWare Editor (TSE). The supplied `BLOCK.INC` file extends TSE's marked-block operations so that an existing block can be resized from the cursor and its block type can be changed.

The macro supports character, line, and column blocks.

## Files in the archive

| File | Description |
| --- | --- |
| `BLOCK.INC` | TSE SAL source containing the block procedures and key assignments. |
| `FILE_ID.DIZ` | Short archive description. |

## Features

- Starts character, line, or column blocks.
- Ends block marking or resizes an already marked block.
- Expands a marked block when the cursor is outside it.
- Shrinks a marked block toward the cursor when the cursor is inside it.
- Cycles a marked block between character, line, and column types.
- Restores the previously saved block.
- Moves the cursor to the beginning or end of the marked block.

## Default keys

| Key | Action |
| --- | --- |
| `F3` | Save the current block, clear it, and start a character block. |
| `Shift+F3` | Save the current block, clear it, and start a line block. |
| `Ctrl+F3` | Save the current block, clear it, and start a column block. |
| `Alt+F3` | Change the marked block type: character → line → column → character. |
| `F4` | End block marking, or resize/extend an existing marked block to the cursor. |
| `Shift+F4` | Unmark the current block. |
| `Alt+F4` | Restore the block previously saved with `PushBlock()`. |
| `F5` | Move to the beginning of the marked block. |
| `F6` | Move to the end of the marked block. |

> **Important:** These assignments replace any existing TSE commands on the same keys while the macro is loaded. In particular, `Alt+F4` is commonly associated with closing a Windows application. Change the assignments in `BLOCK.INC` before compiling if you want to retain your current keys.

## Installation and compilation

1. Extract `block1.zip` to a working directory.
2. Make a backup copy of `BLOCK.INC` before changing it.
3. If necessary, edit the key assignments at the bottom of `BLOCK.INC`.
4. Compile the source with the SAL compiler supplied with your TSE installation. Although its extension is `.INC`, the supplied file contains complete procedures and key assignments and can be used as the macro source. Depending on the compiler version, either compile it directly or copy/rename it to `BLOCK.S` first.

Example from a command prompt when direct `.INC` compilation is accepted:

```bat
sc32 BLOCK.INC
```

Alternative:

```bat
copy BLOCK.INC BLOCK.S
sc32 BLOCK.S
```

5. If your TSE compiler does not automatically place the compiled macro where TSE can load it, copy the resulting compiled macro to your normal TSE macro directory.
6. Load or execute the compiled macro using your usual TSE macro-loading method.

The exact compiler command and compiled filename can vary between TSE releases. Use the compiler that belongs to your installed TSE version.

## How to use it

### Create and finish a block

1. Put the cursor at the desired starting position.
2. Press `F3` for a character block, `Shift+F3` for a line block, or `Ctrl+F3` for a column block.
3. Move the cursor to the desired ending position.
4. Press `F4` to finish marking the block.

### Resize an existing block

1. Leave the block marked.
2. Move the cursor to the new boundary position.
3. Press `F4`.

If the cursor is inside the block, the macro moves the nearest end, edge, or corner toward the cursor. If the cursor is outside the block, it extends the block to the cursor.

### Change the block type

1. Mark a block.
2. Press `Alt+F3` repeatedly.

With the supplied active assignment, the order is:

```text
character → line → column → character
```

The source also contains a commented alternative assignment using `change_block_type(1)`. If enabled instead, the order is:

```text
character → column → line → character
```

### Restore the previous block

The `F3` block-start commands call `PushBlock()` before clearing the current block. Press `Alt+F4` to restore that saved block.

## Compatibility notes

- `BLOCK.INC` is legacy SAL source dated 1994. Modern TSE/SAL releases may report renamed constants, changed syntax, or key conflicts.
- The source uses global variables and helper names such as `max` and `gotoposxy`; check for name conflicts if you include it inside a larger macro.
- Test the macro with non-critical text first, especially after changing its keys or adapting it for a newer compiler.

## Version history

| Version | Changes |
| --- | --- |
| 1.0.0.0.0 | Initial README with description, installation instructions, key reference, usage examples, and compatibility notes. |

Future README revisions should increment the final component sequentially: `1.0.0.0.1`, `1.0.0.0.2`, and so on.
