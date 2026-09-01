# CLBLKREP — Safe Find and Replace in Column Blocks

**README version:** 1.0.0.0.0  
**Created:** 2026-09-01 23:29:54 UTC  
**Original source:** `CLBLKREP.S`  
**Original author:** "Buddy" E. Ray Asbury, Jr.  
**Original source date:** 1993-04-05 10:27:06

## Description

CLBLKREP is a TSE SAL macro that provides safer Find, Replace, and Repeat Find operations when the cursor is inside a marked column block.

With an ordinary replacement inside a column block, deleting or shortening text can cause text originally outside the block to move into the marked area and be replaced accidentally. A longer replacement can likewise push text beyond the original column boundary.

CLBLKREP avoids these effects by copying the marked column block to a temporary buffer, performing the replacement there, and copying the result back over the original block. Text outside the marked column block therefore remains untouched.

When the cursor is not inside a column block, the macro calls TSE's normal built-in Find, Replace, and Repeat Find commands.

## Included file

- `CLBLKREP.S` — TSE SAL source code.

## Provided procedures

- `mFind()` — runs the normal Find command and resets the macro's repeat-replace state.
- `mReplace(INTEGER isARepeat)` — performs a normal replacement outside a column block, or an isolated replacement inside a column block.
- `mRepeatFind()` — repeats the column-block replacement when appropriate; otherwise it calls TSE's normal Repeat Find command.

## Requirements

- The SemWare Editor (TSE) with SAL macro support.
- A TSE version compatible with the SAL functions used by this 1993 source.
- Permission to compile or load macros in the TSE installation.

## Installation and compilation

1. Extract `CLBLKREP.S` from `clblkrep.zip`.
2. Copy `CLBLKREP.S` to your TSE macro source directory.
3. Open a command prompt in that directory, or use TSE's macro compiler command.
4. Compile the source with the compiler supplied with your TSE version. A typical command is:

   ```text
   sc32 CLBLKREP.S
   ```

5. Confirm that compilation completes without errors.
6. Load the compiled macro from TSE, or configure TSE to load it during startup.

The exact compiler name and generated file type can differ between TSE releases. Use the macro-compilation procedure documented for your installed TSE version if `sc32` is not available.

## Key binding setup

The source is intended to replace the procedures normally assigned to Find, Replace, and Repeat Find. Bind these procedures to the keys you currently use for those commands:

```text
mFind()
mReplace(FALSE)
mRepeatFind()
```

The precise key-binding syntax depends on the TSE version and the user's existing macro configuration. Preserve a copy of the current key assignments before changing them.

## How to run it

### Replace text safely inside a column block

1. Open a text file in TSE.
2. Mark a column block using TSE's column-block marking command.
3. Place the cursor inside the marked block.
4. Invoke the key bound to `mReplace(FALSE)`.
5. Enter the text to find in the **Search for** prompt.
6. Enter the replacement text in the **Replace with** prompt.
7. Enter any required options at the options prompt:

   - `B` — search backward.
   - `G` — replace globally.
   - `I` — ignore case.
   - `W` — match words.
   - `X` — use a regular expression.

8. Confirm the result. Only text belonging to the marked column block should be affected.
9. Invoke the key bound to `mRepeatFind()` when another repeat operation is required.

### Find text

Invoke the key bound to `mFind()`. This uses TSE's built-in Find command and resets the column-replacement repeat state.

### Work outside a column block

When the cursor is not inside a marked column block, the wrapper procedures behave like TSE's built-in Find, Replace, and Repeat Find commands.

## Example

Given a column block containing:

```text
ABC-123 remaining text
DEF-456 remaining text
GHI-789 remaining text
```

mark only the first column area and replace lowercase letters, digits, or separators as needed. The macro carries out the operation in a temporary buffer and writes the processed block back using overwrite mode. The `remaining text` outside the column block is protected from being pulled into or displaced by the replacement.

## Important notes

- The cursor must be inside a marked column block for the protected temporary-buffer method to be used.
- The macro temporarily turns marking off while it processes the copied block.
- Search and replacement strings are limited by the original declarations to 69 characters.
- The options string is limited to 11 characters.
- The source removes `L` from the entered options before passing them to `Replace()`.
- The temporary buffer is abandoned after its contents have been copied back.
- Test the macro on a copy of important data before adopting new key bindings.
- This is historical SAL source; minor compatibility changes may be necessary with a substantially newer TSE release.

## Troubleshooting

### The protected replacement is not used

Verify that a column block is marked and that the cursor is actually inside it. Otherwise, `mReplace()` deliberately calls the normal built-in Replace command.

### The original Replace command still runs

Check that the desired key is bound to `mReplace(FALSE)` rather than directly to TSE's built-in `Replace()` command.

### Repeat Find does not repeat the replacement

Start the replacement through `mReplace(FALSE)`. The macro records that a column replacement was the last operation and then allows `mRepeatFind()` to repeat it.

### Compilation fails

Confirm that the source is being compiled with the SAL compiler belonging to the installed TSE version. If an identifier is unavailable, consult that version's SAL documentation for its equivalent.

## Version history

| Version | Date and time (UTC) | Changes |
|---|---|---|
| 1.0.0.0.0 | 2026-09-01 23:29:54 | Initial README created from the supplied `clblkrep.zip` archive and `CLBLKREP.S` source. |

Future documentation updates can increment the final component sequentially, for example `1.0.0.0.1`, `1.0.0.0.2`, and so on.
