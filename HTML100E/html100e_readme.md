# HTML100E

## Version information

- README version: 1.0.0.0.0
- Date and time: 2026-09-10 23:19:32 UTC
- Original macro: `HTML_E.S`
- Original macro version: 1.00e (English version)
- Original target: The SemWare Editor (TSE) 2.0
- Original author: Peter Weisenstein
- README created by: OpenAI Codex (GPT-5)

Future README revisions can use the sequence `1.0.0.0.1`, `1.0.0.0.2`, `1.0.0.0.3`, and so on.

## Description

HTML100E is an English-language TSE SAL macro for inserting HTML tags and converting special characters in an ASCII text file. It displays an HTML formatting menu when **F11** is pressed.

For tags that surround text, the macro inserts the opening tag at the current cursor position. You then move the cursor to the desired end position and press **Enter**; the corresponding closing tag is inserted there.

The archive contains one source file:

- `HTML_E.S` — TSE SAL source code

## Main features

The HTML formatting menu supports:

- Document title and paragraphs
- Named anchors and hyperlinks
- Unnumbered, ordered, and description lists
- Preformatted text, line breaks, horizontal rules, block quotes, and addresses
- Heading levels 1 through 6
- Inline images with source, alignment, and alternative-text options
- Logical character styles: definition, emphasis, strong emphasis, citation, code, keyboard entry, sample output, and variable
- Physical character styles: bold, italic, and typewriter text
- Conversion from ASCII/special characters to HTML escape sequences
- Conversion from HTML escape sequences back to ASCII text

## Requirements

- The SemWare Editor (TSE)
- A TSE SAL compiler compatible with the source
- An editable ASCII or text file

The macro was written in 1995 for TSE 2.0. Newer TSE versions may require small source changes before it compiles or behaves exactly as intended. Keep a backup of important files before testing the conversion commands.

## Installation

1. Extract `html100e.zip` to a working directory.
2. Locate the extracted source file `HTML_E.S`.
3. Compile it with the TSE SAL compiler. For example:

   ```text
   sc32 HTML_E.S
   ```

4. Confirm that compilation creates `HTML_E.MAC`.
5. Copy `HTML_E.MAC` to a directory searched by TSE for compiled macros, or keep it in the current working directory when loading it.
6. Load the macro in TSE, for example from the TSE command line:

   ```text
   LoadMacro("HTML_E")
   ```

   If your TSE setup automatically loads macros placed in its macro directory, restart TSE after copying the file.

## How to run HTML100E

1. Open the text or HTML file that you want to edit.
2. Place the cursor where the opening HTML tag should be inserted.
3. Press **F11** to open the **HTML-formattings** menu.
4. Choose the required tag or submenu.
5. Supply any requested information, such as an anchor name, hyperlink target, or image filename.
6. For a paired tag, move the cursor to the position where the closing tag should be inserted.
7. Press **Enter** to insert the closing tag.
8. Press **Esc** instead if you want to cancel placement of the closing tag.
9. Review the generated HTML and save the file.

## Cursor keys while placing a closing tag

After an opening tag is inserted, the following keys can be used to select the closing-tag position:

| Key | Action |
| --- | --- |
| **Left / Right / Up / Down** | Move the cursor |
| **Ctrl+Left / Ctrl+Right** | Move by word |
| **Page Up / Page Down** | Move by page |
| **Home / End** | Move to the beginning or end of the line |
| **Ctrl+Page Up / Ctrl+Page Down** | Move to the beginning or end of the file |
| **Alt+F** | Open Find |
| **Alt+J** | Go to a mark, line, relative line, or column |
| **Enter** | Insert the closing tag |
| **Esc** | Cancel closing-tag insertion |

## Examples

### Bold text

1. Put the cursor before the text.
2. Press **F11**.
3. Choose **character formatting**, then **Bold**.
4. Move the cursor to the end of the text.
5. Press **Enter**.

The result is:

```html
<B>text</B>
```

### Hyperlink

1. Put the cursor before the link text.
2. Press **F11** and choose **Anchor HREF**.
3. Enter the document name or `#named_anchor` requested by the macro.
4. Move to the end of the link text and press **Enter**.

Example result:

```html
<A HREF="document.html">link text</A>
```

### Special-character conversion

Open **Escape-Sequences** from the F11 menu and choose one of these commands:

- **ASCII -> HTML** converts supported special characters to HTML entities.
- **HTML -> ASCII** removes HTML tags and converts supported entities back to characters.

This conversion operates on the current file. Save a backup first, especially when the document contains HTML that must be preserved.

## Notes and limitations

- The macro generates classic HTML syntax and uppercase tag names, reflecting common HTML practice at the time it was written.
- Some menu commands create paired tags even for elements that modern HTML treats as void elements, such as `BR`, `HR`, and `IMG`. Review and adjust the output when targeting modern HTML.
- The inline-image dialog initially shows placeholders such as `{TOP|MIDDLE|BOTTOM}` and `(alt_text)`; replace them with the required values.
- The source contains character conversions based on the original DOS/ASCII code page. Characters may need adaptation for a modern Windows encoding or UTF-8 document.
- The **HTML -> ASCII** command removes text matching HTML-tag syntax before decoding the supported entities.
- The macro assigns **F11** globally while loaded. If another macro already uses F11, change the final key assignment in `HTML_E.S`, recompile, and reload the macro.

## Troubleshooting

### F11 does not open the menu

- Confirm that `HTML_E.MAC` compiled successfully.
- Confirm that the macro is loaded in TSE.
- Check whether another loaded macro has reassigned F11.

### The SAL compiler reports errors

The source targets TSE 2.0 and may use syntax or built-in names that differ in a newer TSE release. Compile the unmodified source first and note the exact line, column, and error message before making compatibility changes.

### The wrong characters appear after conversion

The original conversion table expects an older DOS character encoding. Avoid running the conversion on UTF-8 text unless the mapping has been updated for that encoding.

### An unwanted opening tag was inserted

Use TSE's Undo command. Pressing **Esc** during cursor placement cancels only the closing tag; it does not remove the opening tag that was already inserted.

## Version history

| Version | Date and time (UTC) | Changes |
| --- | --- | --- |
| 1.0.0.0.0 | 2026-09-10 23:19:32 | Initial Markdown description, help, installation instructions, usage steps, examples, notes, and troubleshooting information. |
