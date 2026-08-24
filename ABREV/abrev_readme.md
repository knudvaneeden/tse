# abrev.s - TSE SAL Macro Documentation

## Description
`abrev.s` is a text expansion macro written in SemWare Application Language (SAL) for The SemWare Editor (TSE). It allows users to type short, predefined abbreviations and expand them into full code snippets or text blocks using a designated hotkey (`<F12>`). The macro intelligently maintains the indentation level of the expanded text and automatically places the cursor at a specified location within the snippet, accelerating the coding or writing process.

## Help

### Usage
1. Type an abbreviation in the editor (e.g., `b`, `c`, `ie`).
2. Place your cursor immediately after the typed abbreviation.
3. Press the `<F12>` key to trigger the expansion.

*Example:*
Typing `c` and pressing `<F12>` will expand to:
```sal
case
    when
    otherwise
endcase
```
(The cursor will be placed right after `case `).

### Adding New Abbreviations
Abbreviations are stored in the `datadef abbreviations` section within the source file. To add your own:
1. Define the abbreviation surrounded by dollar signs (e.g., `"$my_abbrev$"`).
2. Write the replacement text on the subsequent lines, enclosing each line in double quotes.
3. Insert a tilde (`~`) exactly where you want the cursor to appear after expansion. **Note: Each entry must have a `~` character.**
4. Ensure the very last entry in the `datadef` block is a single `"$"` to correctly terminate the list.

## History
* **v1.0 (Initial Release):** Implemented core abbreviation functionality triggered by `<F12>`.
  * Added `datadef` structure for mapping `$abbreviation$` to text blocks.
  * Integrated auto-indentation to match the current line's leading spaces.
  * Added smart cursor positioning using the `~` placeholder.
