# JUSTIWS

**README version:** 1.0.0.0.4  
**Date:** 2026-09-12  
**Time:** 07:48:14 UTC  
**Session:** Create JUSTIWS MarkDown Readme  
**Prepared with:** OpenAI Codex (GPT-5)

## Description

JUSTIWS is a TSE SAL paragraph-justification macro written by Paul Lenz. The archive contains the source file `JUSTIFY.S`.

The macro reformats the paragraph at the cursor in a way similar to WordStar's **Ctrl+B** command. It uses TSE's current left and right margin settings to:

- remove repeated spaces and previously inserted hyphen-space combinations;
- join short lines until the text reaches the right margin;
- split lines at a suitable space, hyphen, or possible hyphenation point;
- optionally let the user adjust or reject an automatically proposed hyphen;
- add spaces so completed lines extend to the right margin;
- give extra spacing after punctuation before widening ordinary word gaps;
- distribute added spaces alternately from the left and right sides.

The final line of a paragraph is cleaned up but is not expanded to the right margin.

## Requirements

- The SemWare Editor (TSE) with a compatible SAL compiler.
- The supplied `JUSTIFY.S` source file.
- Paragraphs separated by at least one completely blank line.
- Suitable TSE **Left Margin** and **Right Margin** settings before the macro is run.

JUSTIWS does not use TSE's `ParaEndStyle` setting. A blank line is therefore required between paragraphs so that the macro can recognize where each paragraph ends.

## Files in the archive

| File | Purpose |
| --- | --- |
| `JUSTIFY.S` | TSE SAL source code for the JUSTIWS macro |

After compilation, the SAL compiler normally creates `JUSTIFY.MAC`.

## Installation

1. Extract `JUSTIFY.S` from `justiws.zip`.
2. Place `JUSTIFY.S` in your TSE SAL working directory or another convenient directory.
3. Open a command prompt in that directory.
4. Compile the source with the TSE SAL compiler:

   ```text
   sc32 JUSTIFY.S
   ```

5. Confirm that `JUSTIFY.MAC` was created without compiler errors.
6. In the successful-compilation menu, choose **Load Macro**. Do not choose **Execute Macro** while `JUSTIFY.S` is the current buffer, because JUSTIWS operates on the currently displayed text.
7. Alternatively, place `JUSTIFY.MAC` where TSE can load it and load it later using TSE's normal macro-loading command.

Do not select `JUSTIFY.S` when TSE asks for the macro to execute. The `.S` file is source code; the compiled `.MAC` file is the runnable macro.

## How to run JUSTIWS

1. Open the text file that you want to reformat in TSE.
2. Ensure that every paragraph is followed by a blank line. The end of the file also counts as the end of a paragraph.
3. Set TSE's left and right margins to the desired paragraph width.
4. Put the cursor on the **first non-empty line** of the paragraph to be reformatted.
5. Execute the loaded `JUSTIFY.MAC` macro. If TSE asks for a macro name, use `JUSTIFY`.
6. If the macro proposes a hyphenation point, use the keys described below.
7. Review the reformatted paragraph and save the file when satisfied.

The macro processes the paragraph containing the cursor and then positions the cursor at the beginning of the following paragraph, when one exists. Run the macro again to format that next paragraph.

## Confirmed test procedure

The following test demonstrates the effect clearly:

1. Load the compiled `JUSTIFY.MAC` macro.
2. Open a separate text file. Do not perform this test in the `JUSTIFY.S` source buffer.
3. Set TSE's right margin to approximately column 40.
4. Enter these three lines and include the completely blank fourth line:

   ```text
   This is the first short line of a paragraph
   and this is the second line of the paragraph
   followed by a third line for testing purposes.

   ```

5. Put the cursor on the first line, beginning with `This is`.
6. Execute the loaded macro named `JUSTIFY`.

JUSTIWS should join the input lines, wrap the words to the configured margin, and expand the completed lines by inserting spaces. The final line of the paragraph is not expanded to the right margin.

## Hyphenation controls

When a word near the right margin cannot be wrapped normally, JUSTIWS may display a temporary hyphen and the following prompt:

```text
HYPHEN: left  right  - hyphen  ESC break  other key: wrap
```

| Key | Action |
| --- | --- |
| **Left Arrow** | Move the proposed hyphen one character to the left |
| **Right Arrow** | Move the proposed hyphen one character to the right, up to the right margin |
| **Hyphen (`-`)** | Accept the displayed hyphenation point |
| **Esc** | Stop the macro at the current hyphenation prompt |
| **Any other key** | Reject hyphenation and wrap the complete word instead |

## Important behavior

- Do not run the macro on a blank line; no paragraph will be processed.
- Start on the first line of the paragraph. Starting on its final line may produce little or no visible change.
- A one-line paragraph that already fits between the margins normally remains unchanged.
- If all paragraph text already fits on one output line, the only visible effect may be joining the original input lines.
- Blank lines are paragraph separators and must not contain spaces or other characters.
- The macro changes the document text directly. Consider saving the original file first or use TSE's Undo command if the result is not wanted.
- Existing multiple spaces inside the paragraph are reduced before justification.
- Existing `- ` sequences may be removed while the paragraph is reflowed.
- A single word longer than the right margin is not forcibly split unless the macro can use its wrapping or interactive hyphenation logic.
- Hyphenation is heuristic. Always proofread accepted word breaks.
- The macro temporarily enables insert mode and changes the cursor display during hyphenation, then restores those settings when it finishes.
- Any block marking that existed before execution is restored when the macro ends.

## Troubleshooting

### The paragraph is not processed

- Make sure the cursor is on the first non-empty line of a multi-line paragraph.
- Confirm that the macro was compiled and loaded successfully.
- Check that the paragraph has a blank line after it, unless it is the final paragraph in the file.
- Temporarily set the right margin to approximately column 40 and use the confirmed test procedure above.

### A blank `File not found:` warning appears

Use version `1.0.0.0.3` or later. Earlier versions always attempted to restore a saved block, even when no block was marked in the current file. Version `1.0.0.0.3` saves and restores the block only when `isBlockInCurrFile()` reports an active block.

After compiling from the `JUSTIFY.S` source buffer, choose **Load Macro** rather than **Execute Macro**. Then open the text document to be justified and run `JUSTIFY` there.

### More than one paragraph is joined

Insert a completely blank line between the paragraphs. JUSTIWS depends on blank lines rather than `ParaEndStyle` to detect paragraph endings.

### Lines use an unexpected width

Check TSE's current left and right margin values before executing the macro. JUSTIWS reads those settings and does not ask for a width of its own.

### A word is hyphenated incorrectly

At the hyphenation prompt, move the proposed hyphen with the arrow keys, press `-` to accept it, or press another key to wrap the whole word without hyphenation.

### The source does not compile in a modern TSE version

`JUSTIFY.S` is historical SAL source dated 1993. SAL syntax and character encoding can differ between TSE releases. Keep the source in the single-byte encoding expected by TSE and review any compiler-reported line before changing the original logic.

## Version history

| Version | Date and time | Changes |
| --- | --- | --- |
| 1.0.0.0.4 | 2026-09-12 07:48:14 UTC | Added the confirmed three-line test procedure, the right-margin setup, the required first-line cursor position, and explanations for cases where the macro correctly produces little or no visible change. |
| 1.0.0.0.3 | 2026-09-12 07:40:00 UTC | Made block preservation conditional to prevent a blank `File not found:` warning when no block is marked. Corrected the workflow: load the macro after compilation, open the target text, and run `JUSTIFY` there. |
| 1.0.0.0.2 | 2026-09-12 07:33:59 UTC | Added a modern `Main()` entry point that calls `JustiWS()`. Clarified that TSE must execute the compiled `JUSTIFY.MAC`, not the `JUSTIFY.S` source file. |
| 1.0.0.0.1 | 2026-09-12 07:31:00 UTC | Documented the repaired ASCII-safe source. The incomplete German-vowel string at source line 271 was removed to fix compiler error 2330, "String not terminated." |
| 1.0.0.0.0 | 2026-09-12 07:25:42 UTC | Initial Markdown description, help, installation instructions, usage steps, hyphenation controls, and troubleshooting information for the supplied JUSTIWS archive. |

Future revisions should increment the final component sequentially: `1.0.0.0.5`, `1.0.0.0.6`, `1.0.0.0.7`, and so on.

## Original author information

The source header identifies the macro as written by **Paul Lenz** on **1993-07-31**.
