# 1LINER Macro for TSE - Help & Instructions

## Overview
**1LINER** is a TSE (The SemWare Editor) SAL macro designed to prepare ASCII text files for importing into word processors[cite: 1]. It accomplishes this by converting multi-line paragraphs into single, long lines terminated by standard EOL characters[cite: 1].

## Key Features
- **Paragraph Flattening:** Automatically wraps multi-line paragraphs into a single continuous line[cite: 1].
- **Smart Spacing Adjustment:** Ensures that sentence-ending punctuation (periods `.`, question marks `?`, and exclamation points `!`) followed by spaces are padded with at least **two spaces**[cite: 1].
- **Whitespace Cleanup:** Converts tabs to spaces and trims excess inner-paragraph whitespace before enforcing sentence-spacing rules[cite: 1].
- **Selective Processing:** Can process an entire file or strictly within a marked text block[cite: 1].

## Compatibility
- TSE for Microsoft Windows version 4.50 RC24[cite: 1]
- TSE for Linux version 4.50.14 in Linux WSL (Ubuntu)[cite: 1]
- TSE for Linux version 4.50.19 in Linux non-WSL (Ubuntu)[cite: 1]
- *(Originally authored for TSE v2.00)*[cite: 1]

## Usage Instructions

1. **Running the Macro:**
   Execute the macro from the Potpourri menu or run it directly in your TSE environment[cite: 1].

2. **Processing a Specific Block:**
   - Mark a standard block of text over the paragraphs you wish to convert[cite: 1].
   - Run the macro.
   - *Note:* If only part of a paragraph is marked, processing starts at the beginning of the line where the mark begins and continues to the end of the paragraph, even if it extends slightly beyond the marked area[cite: 1].

3. **Processing the Entire File:**
   - Ensure that **no text block is marked**[cite: 1].
   - Run the macro. It will scan and convert paragraphs starting from the top of the file to the bottom[cite: 1].

4. **Monitoring Progress:**
   - While processing, a `Working... [count]` counter will appear in the status bar to indicate that the macro is actively running[cite: 1].

## Important Limitations
- **Column Blocks Not Allowed:** You cannot use `_COLUMN_` blocks[cite: 1]. Attempting to do so will abort the macro and trigger the warning: *"The Machine does NOT process column blocks."*[cite: 1]
- **Line Length Limits:** The resulting single line cannot exceed TSE's internal `MAXLINELEN` limit (up to 32,000 characters)[cite: 1].
- **Data Safety:** Do not accidentally run this on structured text like source code, as it will scramble the formatting[cite: 1]. Always save your file before execution[cite: 1].

## Authorship & History
- **Original Author:** Jack Hazlehurst (Written: 01/20/94)[cite: 1]
- **Modifications & Updates:** Knud van Eeden (12-02-2026)[cite: 1]
- **Current Version:** 1.0.0.0[cite: 1]
