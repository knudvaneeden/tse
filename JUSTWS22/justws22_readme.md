# JUSTWS22 - WordStar-style full justification for TSE

**Session:** Create JUSTWS22 MarkDown Readme  
**README version:** 1.0.0.0.5  
**Date:** 2026-09-12  
**Time:** 14:47:32 UTC  
**Original macro version:** JustiWS 2.2 (1995-09-09)

## Description

`JUSTWS22.S` is a TSE SAL macro that reformats and fully justifies text in a style similar to the WordStar `Ctrl-B` command.

Starting at the paragraph containing the cursor, the macro:

1. Removes repeated spaces.
2. Joins short source lines until the text reaches the configured right margin.
3. Wraps text that extends beyond the right margin.
4. Offers interactive hyphenation when the final word is too long.
5. Adds spaces between words and after punctuation to align text with the right margin.
6. Continues with following paragraphs until it reaches the end of the file.

The last line of a paragraph is cleaned and wrapped but is not expanded to the right margin.

## Important paragraph requirement

Paragraphs must be separated by blank lines. JUSTWS22 deliberately does not use TSE's `ParaEndStyle` setting, so a blank line is how it recognizes the end of a paragraph.

Before testing the macro, save a backup copy of the document. Reformatting changes the text by joining lines, inserting spaces, and possibly removing line-end hyphens.

## Requirements

- The SemWare Editor (TSE) with its SAL compiler.
- `JUSTWS22.S` from `justws22.zip`.
- Suitable TSE left- and right-margin settings.

The updated archive contains source code only. Compile it to create `JUSTWS22.MAC`.

## Configuration switches

The switches are near the beginning of `JUSTWS22.S` and must be changed before compilation.

| Switch | Supplied value | Purpose |
| --- | ---: | --- |
| `GERMAN` | `TRUE` | Uses German messages during interactive hyphenation. |
| `ENGLISH` | `FALSE` | Uses English messages during interactive hyphenation. |
| `TWO_SPACE` | `FALSE` | If enabled, keeps two spaces after `.`, `!`, `?`, `:`, and `;`. |
| `DELHYPHEN` | `TRUE` | Removes probable old line-end hyphens before joining lines. |
| `NOJUSTIFY` | `FALSE` | If enabled, wraps the text without expanding it to full justification. |

For English prompts, set `GERMAN` to `FALSE` and `ENGLISH` to `TRUE`, then recompile the source.

Be careful with `DELHYPHEN`: the original author notes that it can remove a meaningful hyphen where a hyphenated word has been split across two source lines.

## How to compile

1. Extract `JUSTWS22.S` from `justws22.zip`.
2. If necessary, edit the configuration switches described above.
3. Open a command prompt in the directory containing the source file.
4. Compile it with the TSE SAL compiler:

   ```text
   sc32 JUSTWS22.S
   ```

5. Confirm that the compiler creates `JUSTWS22.MAC` without errors.
6. Put the compiled macro where your TSE installation or macro configuration can load it.

## How to install and invoke it

Updated version `1.0.0.0.5` contains a `Main()` entry point, so it can be compiled and run as a stand-alone TSE macro on the current active file. It does not ask for or open another filename. A block must be marked in the current file before the macro is run.

When the macro starts, `Main()` displays this confirmation before calling `JustiWS()`:

```text
Run JUSTWS22 on the current file? First save and back up all your work before continuing.
```

Choose **Yes** to continue. `Main()` then verifies that a block is marked in the current file. If not, it displays `Please mark a block` and returns without formatting. If a block exists, the cursor moves to its beginning and `JustiWS()` runs from that position. Choose **No** or press **Escape** at the first prompt to cancel.

## Steps to justify text

1. Open a text document in TSE.
2. Ensure that every paragraph is separated from the next paragraph by at least one blank line.
3. Set TSE's left and right margins to the desired text width.
4. Mark a block whose beginning is the position where formatting should start.
5. Save the current document and make a backup copy of all important work.
6. Run `JUSTWS22.MAC` through TSE's Execute Macro command.
7. Read the save-and-backup confirmation displayed by `Main()`.
8. Choose **Yes**. The macro verifies the block, moves the cursor to `GotoBlockBegin()`, and calls `JustiWS()`.
9. Review the reformatted text and save it when satisfied.

The block determines the starting position. The original `JustiWS()` routine does not use the end of the marked block as a stopping boundary; it continues through subsequent paragraphs. To limit its effect, work on a copy of the text or place only the paragraphs to be processed in a temporary buffer.

## Interactive hyphenation

When a word cannot fit within the right margin, JUSTWS22 displays a proposed hyphen position.

- Press **Left Arrow** or **Right Arrow** to move the proposed hyphen.
- Press the normal hyphen key to accept the displayed hyphenation.
- Press another key to continue without accepting that hyphen position.
- Press **Escape** to stop the JUSTWS22 operation.

## What to expect

Normal paragraph source:

```text
This is a short paragraph whose lines
have uneven lengths and need to be
reformatted.
```

After running JUSTWS22, intermediate lines are wrapped and padded with spaces so that their right edges reach the configured right margin. The final line remains ragged-right.

The exact result depends on the current TSE left and right margins, the selected switches, punctuation, and the words in the paragraph.

## Troubleshooting

### The compiled macro appears to do nothing

Confirm that you compiled the updated `JUSTWS22.S` version `1.0.0.0.5`, which contains `Main()`. Also verify that a block is marked in the current file and begins on non-empty text.

### `Please mark a block` appears

Mark a block in the current file and run the macro again. `Main()` requires a block so it can move to the intended starting position with `GotoBlockBegin()`.

### Several paragraphs are merged

Insert a blank line between every paragraph. JUSTWS22 requires blank lines as paragraph separators.

### The result uses the wrong width

Check TSE's current left- and right-margin settings before running the macro. JUSTWS22 uses those editor settings; it does not ask for a width.

### Prompts are in German

Set `GERMAN` to `FALSE` and `ENGLISH` to `TRUE` in the source, then compile it again.

### Meaningful hyphens disappear

Set `DELHYPHEN` to `FALSE` and recompile. The supplied `TRUE` setting tries to remove old hyphens introduced by earlier line wrapping.

### Text wraps but is not fully justified

Check that `NOJUSTIFY` is `FALSE`, then recompile the source.

## Version history

### 1.0.0.0.5 - 2026-09-12 14:47:32 UTC

- Added a check in `Main()` requiring a marked block in the current file.
- Added the `Please mark a block` warning and immediate `RETURN()` when no block exists.
- Added `GotoBlockBegin()` before `JustiWS()` so formatting starts at the beginning of the marked block.
- Clarified that the block supplies the starting position but does not limit processing at its end.

### 1.0.0.0.4 - 2026-09-12 14:40:54 UTC

- Restored the original unconditional `PushBlock()` and `PopBlock()` calls.
- Removed the incorrect conclusion that those calls caused the blank `File not found:` warning.
- Recorded that the warning was related to the `g32.exe` session/version being run.
- Retained the working `YesNo()` entry point that operates on the current file.

### 1.0.0.0.3 - 2026-09-12 14:17:27 UTC

- Changed `Main()` to use the same `YesNo()` startup pattern as the working `justify.s` macro by the same author.
- Confirmed that `JustiWS()` acts directly on the current active file and does not open another file.
- Choosing **No** or pressing **Escape** now cancels before formatting starts.
- Retained the save-and-backup warning in the confirmation text.

### 1.0.0.0.2 - 2026-09-12 14:10:12 UTC

- Fixed the blank `File not found:` warning shown when no block was marked.
- Added conditional block preservation using `isBlockInCurrFile()`.
- Retained the stand-alone `Main()` entry point and save-and-backup warning.

### 1.0.0.0.1 - 2026-09-12 14:03:35 UTC

- Added `Main()` to `JUSTWS22.S` so the compiled macro can be run directly.
- Added a startup warning telling the user to save and back up all work before formatting begins.
- Updated the compilation, execution, usage, and troubleshooting instructions.

### 1.0.0.0.0 - 2026-09-12 13:57:09 UTC

- Created `justws22_readme.md`.
- Documented the JustiWS 2.2 formatting behavior and paragraph requirements.
- Added compilation, configuration, installation, invocation, and usage instructions.
- Documented the absence of a built-in `Main()` entry point and provided an optional stand-alone wrapper.
- Added interactive-hyphenation help and troubleshooting guidance.

## Original authorship

The source identifies Paul Lenz as the original author and records an original macro date of 1993-07-31. The included source is JustiWS version 2.2 dated 1995-09-09. Consult the header in `JUSTWS22.S` for the complete historical change log and the original English and German documentation.
