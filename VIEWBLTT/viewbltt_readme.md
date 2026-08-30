# `viewbltt.s` — Count ampersand menu lines in a marked block

## Description

`viewbltt.s` is a TSE SAL macro that counts menu-definition lines containing an ampersand (`&`) within the block currently marked in The SemWare Editor (TSE).

An ampersand is commonly used in quoted menu text to designate a keyboard accelerator or hotkey. After scanning the marked block, the macro displays the total in a `Warn` dialog.

- Macro filename: `viewbltt.s`
- Macro version: `1.0.0.0.6`
- Activation key: `Ctrl+F12`
- Result: `Total ampersand lines (&) in this block = <number>`

The macro preserves the current cursor position and marked block while it performs the count.

## Requirements

- The SemWare Editor (TSE) for Windows
- The TSE SAL compiler, normally `sc32.exe`
- The source file `viewbltt.s`

The macro attempts to load the optional helper macro `setwiyde` before displaying warnings. If that helper is available, it controls the position of the warning dialog.

## Compile the macro

1. Copy `viewbltt.s` to your TSE SAL working directory.
2. Open a Command Prompt in that directory.
3. Compile the source file:

   ```bat
   sc32 viewbltt.s
   ```

4. Confirm that the compiler completes without errors. It should create the compiled TSE macro file used by your TSE installation.

If `sc32.exe` is not on `PATH`, use its full path, for example:

```bat
"C:\path\to\TSE\sc32.exe" viewbltt.s
```

## Load the macro in TSE

Load the compiled macro using your normal TSE macro-loading method. For example, enter TSE's macro command and specify:

```text
viewbltt
```

The macro can also be added to your normal TSE startup or autoload configuration if you want it available in every editing session.

## How to run it

1. Open the file containing the menu definitions that you want to inspect.
2. Mark a block containing the lines to be checked.
3. Press `Ctrl+F12`.
4. Read the total shown in the warning dialog.

Example result:

```text
Total ampersand lines (&) in this block = 10
```

## Important behavior

- Only lines inside the marked block are examined.
- The search is intended for quoted menu-style lines containing `&`.
- The search is case-insensitive, although letter case does not affect ampersand matching.
- If no block is marked in the current file, the macro reports:

  ```text
  No block is marked in current file. First mark a block
  ```

- The result is a line count, not a count of every individual ampersand. A matching line contributes one to the total.

## Troubleshooting

### Nothing happens when pressing `Ctrl+F12`

Make sure `viewbltt` compiled successfully and that the resulting macro is loaded in TSE. Also check that another macro has not assigned a different command to `Ctrl+F12`.

### The macro says that no block is marked

Mark a block in the current file before running the macro. A block marked in another open file is not used.

### `setwiyde` cannot be loaded

`setwiyde` is a helper macro used to position warning and yes/no windows. Put it where TSE can find macros if you want that positioning behavior. The main counting logic is contained in `viewbltt.s`.

### The count is lower than expected

Check that the relevant lines are inside the marked block and use the quoted menu-line format expected by the macro's TSE regular expression. Lines containing `&` in unrelated or differently formatted text may intentionally not match.

## Source entry point

The keyboard assignment calls `Main()`:

```sal
<Ctrl F12> Main()
```

`Main()` calls `FNBlockViewLineMenuAmpersandTotalTseI()`, which scans the marked block and returns the number of matching lines.
