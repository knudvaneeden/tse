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
