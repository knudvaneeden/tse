# CV2ORG

**Documentation version:** 1.0.0.0.1  
**Created:** 2026-09-04 19:29:15 UTC  
**Original macro date:** 1995-10-15 19:19  
**Original author:** Richard Lassan

## Description

CV2ORG is a macro for The SemWare Editor (TSE) that saves changes made in a numbered compressed view back to the original source file.

The compressed view and original source must be open in two TSE windows. CV2ORG reads the line number before the colon on each changed compressed-view line, moves to that line in the original source window, and optionally replaces the original text with the edited text.

## Archive contents

| File | Description |
|---|---|
| `CV2ORG.S` | SAL source code for the macro. |
| `CV2ORG.MAC` | Precompiled TSE macro supplied with the original package. |

## Requirements

- The SemWare Editor (TSE).
- A compressed-view facility that produces lines beginning with the original line number followed by a colon.
- Two editor windows: the numbered compressed view and its original source file.
- The TSE SAL compiler (`SC32`) only if you want to rebuild the supplied source.

## Important precautions

- Make a backup or commit the original source file before using the macro.
- Do not remove or alter the line number or colon at the beginning of a compressed-view line. CV2ORG uses that number to locate the corresponding original line.
- Keep the compressed view and original source open in the expected two-window arrangement.
- The macro replaces text from the start of the corresponding original line through its end. Review the result before saving the original file.
- This is historical SAL code. A recent TSE SAL compiler may report compatibility issues that require source updates.

## Installation

### Option 1: Use the supplied compiled macro

1. Extract `cv2org.zip`.
2. Copy `CV2ORG.MAC` to a directory from which TSE can load macros.
3. Load or execute `CV2ORG` using your normal TSE macro command or key assignment.

### Option 2: Compile the source

Open a command prompt in the extracted directory and run:

```bat
sc32 CV2ORG.S
```

If compilation succeeds, TSE creates an updated `CV2ORG.MAC`. Load or execute that compiled macro in TSE.

## How to run CV2ORG

1. Open the original source file in TSE.
2. Run the compressed-view command or macro so that TSE displays a numbered compressed view.
3. Use `Alt+E`, as described by the original package, to edit the source represented by the compressed view.
4. Modify the desired text in the compressed view.
5. Leave every leading line number and its colon intact.
6. While the changed compressed view and original source are open in their two windows, execute `CV2ORG`.
7. Answer the prompt for each eligible line.
8. Review the modified original source and save it when satisfied.

## Prompt keys

CV2ORG displays:

```text
Yes/No/Rest/Quit:
```

| Key | Action |
|---|---|
| `Y` | Replace the current corresponding line, then prompt again for the next line. |
| `N` | Leave the current original line unchanged, then continue. |
| `R` | Replace the current line and all remaining eligible lines without further prompts. |
| `Q` | Cancel the replacement operation. |
| `Esc` | Cancel the replacement operation. |

Key input is treated without regard to letter case.

## How it works

For every line processed in the compressed-view window, the macro:

1. Searches for the first colon.
2. Interprets the text before the colon as an original-source line number.
3. Marks the text after the colon.
4. Switches to the original-source window.
5. Goes to the indicated line.
6. Replaces that original line when approved.
7. Returns to the compressed-view window and continues.

## Messages and troubleshooting

### `File contents have not changed.`

The current compressed-view buffer is not marked as changed. Edit the compressed view before running CV2ORG.

### `Cannot open source window.`

CV2ORG could not switch to the expected original-source window. Ensure that both the compressed view and original file are open in two TSE windows.

### `Cannot find line number.`

The macro could not find a colon on the current compressed-view line. Restore the required `line-number:` prefix.

### `Replace cancelled!`

The operation was stopped with `Q` or `Esc`. Lines already accepted before cancellation may already have been changed in the original buffer.

### `Done!`

CV2ORG finished processing the applicable compressed-view lines. Review and save the original source file.

## Version history

| Version | Date and time (UTC) | Changes |
|---|---|---|
| 1.0.0.0.0 | 2026-09-04 19:29:15 | Initial Markdown description, installation notes, and run instructions. |
| 1.0.0.0.1 | 2026-09-04 19:29:15 | Added prompt-key reference, precautions, internal workflow, and troubleshooting help. |

## License

No license information is included in the supplied archive. The original author's rights therefore remain applicable.
