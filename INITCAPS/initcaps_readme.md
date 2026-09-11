# INITCAPS — Initial Capitals for TSE

**Session:** Create INITCAPS MarkDown Readme  
**Readme version:** 1.0.0.0.0  
**Readme date and time:** 2026-09-11 15:22:19 UTC  
**Original macro version:** Version 2, dated 1993-05-07  
**Original author:** David Marcus  
**Assistance/enhancement:** Ray Asbury

## Description

INITCAPS is a TSE SAL include file that adds an **Initial Caps** operation to The SemWare Editor (TSE). It converts a marked block to lowercase and then changes the first character of every word to uppercase.

For example:

```text
THIS IS a SAMPLE sentence.
```

becomes:

```text
This Is A Sample Sentence.
```

The archive contains:

- `INITCAPS.INC` — the SAL include file containing `InitialCaps()` and the `INIT_CAPS` constant.

`INITCAPS.INC` is not a standalone macro and has no `Main()` procedure. It must be included in and connected to the standard TSE interface source, normally `TSE.S`, and then the interface must be rebuilt.

## Requirements

- The SemWare Editor (TSE) with its SAL compiler.
- The editable interface source, normally `TSE.S`.
- A marked text block before running Initial Caps.

Keep a backup of the interface source and compiled interface before making changes.

## Installation

1. Extract `INITCAPS.INC` from `initcaps.zip`.
2. Copy `INITCAPS.INC` to the directory containing the TSE interface source files.
3. Open `TSE.S`, or the configuration source used to build your interface.
4. Add the following include before the existing `ChangeCase()` procedure:

   ```sal
   #include ['initcaps.inc']
   ```

5. Locate this procedure:

   ```sal
   proc ChangeCase(integer type)
   ```

6. Inside its `case casetype` statement, add the Initial Caps case before `when UPPER_CASE`:

   ```sal
   when INIT_CAPS
        InitialCaps()
   ```

7. Locate the existing `mUpper()` procedure and add this procedure before it:

   ```sal
   proc mInitCaps()
        casetype = INIT_CAPS
        CaseMenu("Initial Caps")
   end
   ```

8. Locate `menu BlockMenu()` and add an Initial Caps entry after the existing Flip entry. The original package supplies this menu definition:

   ```sal
   "Ini&tCaps"                ,   mInitCaps()         , DontClose
   ```

   The unusual control character before the closing quote is part of the original TSE menu formatting. Copy the entry from `INITCAPS.INC` if it is not preserved correctly by another editor.

9. Optionally bind a key in `TSE.KEY`. The original suggested binding is:

   ```sal
   <Ctrl F4>               mInitCaps()
   ```

10. Optionally update the interface help text to describe the new menu command or key.
11. Rebuild/rebind the TSE interface with the SAL compiler appropriate for your TSE installation. The original instructions specify using the compiler's `-b` switch.
12. Restart or reload the rebuilt interface as required by your TSE setup.

## How to run INITCAPS

1. Open a text file in TSE.
2. Mark the text that must be converted.
3. Keep the cursor inside the marked block. This is required, just as it is for TSE's standard Upper and Lower block commands.
4. Run the command in either of these ways:

   - Open the Block menu and select **InitCaps**.
   - Press **Ctrl+F4** if the optional key binding was installed.

5. The marked text is changed to lowercase, after which the first character of every word is changed to uppercase.

## Help and behavior

- The operation only runs when a block is marked.
- The cursor must be within the marked block.
- The original cursor position is restored when the operation finishes.
- The command changes the entire marked block; it does not preserve deliberate uppercase letters inside words.
- Word boundaries are determined by TSE's `WordRight()` behavior and the editor's current word-character configuration.
- If no block is marked, the procedure makes no change and displays no warning.

## Quick test

1. Enter this line in a test file:

   ```text
the QUICK brown FOX jumps OVER the lazy DOG.
   ```

2. Mark the complete line and leave the cursor inside the block.
3. Select **Block > InitCaps** or press **Ctrl+F4**.
4. Confirm that the result is:

   ```text
The Quick Brown Fox Jumps Over The Lazy Dog.
   ```

Also test an unmarked line. INITCAPS should leave it unchanged.

## Troubleshooting

### The command does not appear in the Block menu

Confirm that `mInitCaps()` and the menu entry were added to the interface source and that the interface was successfully rebuilt and loaded.

### The compiler cannot find `INITCAPS.INC`

Place the include file in the same directory as the interface source, or adjust the include reference so it points to the actual location.

### Nothing happens

Make sure a block is marked and that the cursor is inside that block before invoking the command.

### Existing capitalization is lost

This is expected. The procedure first calls `Lower()` on the marked block and then capitalizes each word's initial character.

### The menu line contains a strange character

The original menu entry contains a TSE menu-formatting control character. Copy the line directly from the supplied `INITCAPS.INC`, using an editor and file encoding that preserve the original byte.

## Version history

### 1.0.0.0.0 — 2026-09-11 15:22:19 UTC

- Created the initial Markdown description and help file.
- Documented installation in the TSE interface source.
- Documented the Block menu command and optional Ctrl+F4 binding.
- Added usage, testing, behavior, and troubleshooting guidance.

Future readme revisions should increment the final component sequentially: `1.0.0.0.1`, `1.0.0.0.2`, and so on.

## Original license notice

The source states that non-commercial distribution is permitted when credit is given to the author and changes by others are attributed. It also grants SemWare permission for commercial distribution under the same attribution conditions. Consult the notice in `INITCAPS.INC` for the authoritative wording.
