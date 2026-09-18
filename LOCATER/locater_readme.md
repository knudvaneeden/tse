# LOCATER

## Version information

- Package version: `1.0.0.0.0`
- Package date: `2026-09-18`
- Package time: `22:37:42 UTC`
- Original macro author: Ed Marsh
- Original source date: 2002-05-22
- Documentation prepared by: OpenAI Codex (GPT-5)

## Description

LOCATER is a package containing two TSE SAL macros for finding two words or phrases inside marked text, even when the original line endings would normally prevent a single search from matching them.

The macros copy the marked block to a temporary buffer, temporarily re-wrap its paragraphs into long lines, perform the search, and append every matching paragraph to `Found.txt` in the current directory. The original file is not modified by this search process.

## Included macros

### `locnear.s` — LocateNear

`LocateNear` finds paragraphs in which the first target is followed later by the second target. Any quantity of text, punctuation, spaces, or original line breaks may occur between the targets, provided both targets occur in the same paragraph and in the requested order.

Example targets:

- First target: `new`
- Second target: `year`

This can match a paragraph containing:

```text
The new policy goes into effect next year.
```

### `locnxtto.s` — LocateNextTo

`LocateNextTo` finds paragraphs in which the first target is immediately followed by a space and the second target. Because the macro first joins each paragraph into a long line, it can find adjacent words that were originally split across two lines.

Example source text:

```text
We wish everyone a happy new
year and good health.
```

Using `new` as the first target and `year` as the second target finds this paragraph.

## Requirements

- The SemWare Editor (TSE) with its SAL compiler.
- A TSE version supporting the SAL commands used by these sources.
- A marked block in the current file before running either macro.
- Write permission in the current directory for `Found.txt`.

The original package states that the macros were tested with TSE 2.5 using a 2,032-column line limit and TSE 4.0 using a 16,000-column line limit. The supplied sources currently set the temporary right margin to `16000`.

## Files in this package

| File | Purpose |
| --- | --- |
| `locnear.s` | SAL source for the LocateNear macro. |
| `locnxtto.s` | SAL source for the LocateNextTo macro. |
| `locater.ini` | Initial settings and reference values. |
| `locater_readme.md` | This documentation. |
| `read_me.txt` | Original documentation by Ed Marsh. |
| `file_id.diz` | Original short package description. |

## Installation

1. Extract all files from `locater1.0.0.0.0.zip` into a working directory.
2. Compile `locnear.s` with the TSE SAL compiler to create `locnear.mac`.
3. Compile `locnxtto.s` with the TSE SAL compiler to create `locnxtto.mac`.
4. Put the compiled `.mac` files in a directory from which TSE can load or execute macros.
5. Optionally assign either macro to a key, add it to a menu, or run it by name from TSE's macro menu.

Example compilation commands:

```text
sc32 locnear.s
sc32 locnxtto.s
```

If `sc32.exe` is not on the command search path, run it by its full path or compile the sources by using your normal TSE SAL compilation procedure.

## How to run LocateNear

1. Open the text file to search in TSE.
2. Mark the block of text that must be searched.
3. Run `locnear.mac`.
4. At `First target to find?`, enter the first word or phrase.
5. At `Second target to find?`, enter the word or phrase that must occur later in the same paragraph.
6. Wait while the marked text is processed.
7. Review the matching paragraphs in `Found.txt`.

## How to run LocateNextTo

1. Open the text file to search in TSE.
2. Mark the block of text that must be searched.
3. Run `locnxtto.mac`.
4. At `First target to find?`, enter the first word or phrase.
5. At `Second target to find?`, enter the immediately following word or phrase.
6. Wait while the marked text is processed.
7. Review the matching paragraphs in `Found.txt`.

## Search behavior

- Both searches are case-insensitive.
- Both macros search only the marked block.
- The first target must occur before the second target.
- The targets can each contain more than one word.
- Each target is currently limited to 40 characters by the SAL source declaration.
- The macros append results to `Found.txt`; they do not automatically erase earlier results.
- Repeated runs can therefore add duplicate or previously found paragraphs to `Found.txt`.
- The original document remains unchanged because the macros perform their work in a temporary buffer.

## Important notes

Before starting a new independent search, rename, move, or delete an existing `Found.txt` if its earlier contents should not be retained.

The macro search expressions use TSE regular-expression search mode. Therefore, characters that have a special meaning in TSE regular expressions can affect the interpretation of a target. The supplied sources do not escape such characters automatically.

The current source files use a fixed temporary right margin of 16,000 columns. If the installed TSE version supports a smaller maximum line length, edit that value in both source files before compiling.

## `locater.ini`

`locater.ini` records the initial package defaults in a convenient editable form. The original `locnear.s` and `locnxtto.s` sources do not read an INI file, so changing the INI values alone does not currently change macro behavior. Corresponding SAL support must be added before these values can control the macros.

## Troubleshooting

### “Only works in a marked block”

Mark the text to search, ensure that the block belongs to the current file, and run the macro again.

### “You must enter a target to locate!”

The first prompt was cancelled or left empty. Run the macro again and enter a first target.

### “You must enter a second target target to locate!”

The second prompt was cancelled or left empty. Run the macro again and enter a second target.

### “Failed to create new buffer”

TSE could not create the temporary working buffer. Close unneeded files or buffers, check available memory, and try again.

### Old results appear in `Found.txt`

This is expected because results are appended. Close and remove or rename the old `Found.txt`, then repeat the search.

### Expected text is not found

Confirm that:

- the relevant text is inside the marked block;
- both targets occur in the same paragraph;
- the targets occur in the requested order;
- `LocateNextTo` has only a space between its two targets after paragraph re-wrapping; and
- neither target contains an unintended regular-expression operator.

## Original author information

Ed Marsh  
`edmarsh@mountain.net`

The original documentation permits users to alter and improve the sources.

## Version history

### 1.0.0.0.0 — 2026-09-18 22:37:42 UTC

- Created `locater_readme.md`.
- Added complete descriptions and operating instructions for both macros.
- Added compilation, usage, output, limitations, and troubleshooting information.
- Added the initial `locater.ini` reference file.
- Repackaged the original files without changing their contents.
