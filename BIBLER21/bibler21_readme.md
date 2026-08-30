# BibleRes 2.1 — Bible Research for The SemWare Editor

**README version:** 1.0.0.0.0  
**Program version:** 2.1  
**Original author:** Ed Marsh  
**Last original program update:** 2011-12-20

## Description

BibleRes is a TSE SAL macro package for researching the King James Version (KJV) Bible inside The SemWare Editor (TSE). It can search the supplied Bible text for words, phrases, or regular expressions, open a specified verse, and extract a range of verses into a separate file.

Search results are placed in `Hits.txt`. Each matching verse is included with its location, and the matching text is marked so that you can navigate between the result list and the corresponding passage in `KJV.txt`. Extracted passages are placed in `Verses.txt`.

The package also contains:

- `Bullets.s` and `Bullets.mac` — navigation and display operations based on the `*` and `~` markers in the Bible file.
- `ReWrap.s` and `ReWrap.mac` — rewraps verse text to the margins currently configured in TSE while preserving verse-reference lines.
- `Install.txt` — the original installation and customization notes.
- `KJV.txt` — the supplied King James Version Bible text.

## Requirements

- The SemWare Editor (TSE) for Windows.
- A TSE SAL compiler if you want to recompile the supplied `.s` source files.
- Write access to the directory containing `KJV.txt`, because `Hits.txt` and `Verses.txt` are created there.

The included `.mac` files were originally compiled with TSE 4.4 on Windows XP. If they do not run with your TSE version, compile the corresponding `.s` files with your installed SAL compiler.

## Files in the archive

| File | Purpose |
| --- | --- |
| `BibleRes.s` | Main BibleRes SAL source code |
| `BibleRes.mac` | Compiled main macro |
| `Bullets.s` | Bullet-navigation SAL source code |
| `Bullets.mac` | Compiled bullet-navigation macro |
| `ReWrap.s` | Verse-rewrapping SAL source code |
| `ReWrap.mac` | Compiled verse-rewrapping macro |
| `KJV.txt` | King James Version Bible text used by the macro |
| `Install.txt` | Original installation/customization instructions |
| `file_id.diz` | Original short package description |

## Installation

1. Extract all files from `bibler21.zip`.
2. Copy `BibleRes.s` and/or `BibleRes.mac` to your TSE macro directory.
3. Copy `Bullets.s` and/or `Bullets.mac` to the same macro directory if you want to use the Bullet Operations menu.
4. Optionally copy `ReWrap.s` and/or `ReWrap.mac` there if you want to reformat the Bible text.
5. Create `C:\Bible` and copy `KJV.txt` into it. This is the default location expected by `BibleRes.s`.
6. If you put `KJV.txt` elsewhere, edit this line near the top of `BibleRes.s`:

   ```sal
   string Source[80] = "C:\Bible\Kjv.txt"
   ```

   Change it to the full path of your `KJV.txt`, and then compile `BibleRes.s` again.
7. If necessary, compile the source macros with the TSE SAL compiler:

   ```text
   sc32 BibleRes.s
   sc32 Bullets.s
   sc32 ReWrap.s
   ```

   Use the compiler command appropriate for your TSE installation if it differs from `sc32`.

## How to run BibleRes

1. Start TSE.
2. Open the configured `KJV.txt` file. With the original setting, open:

   ```text
   C:\Bible\KJV.txt
   ```

3. Execute the `BibleRes` macro using your normal TSE macro-execution command.
4. The **Bible Research Menu** appears.
5. Select an operation from the menu, or use one of the keyboard shortcuts below.
6. Press `Alt+Q` when you want to unload and quit the BibleRes macro.

If the macro reports that you must be in `C:\Bible\KJV.txt`, either open that file or update the `Source` path in `BibleRes.s` and recompile it as described above.

## Main operations and shortcuts

| Shortcut | Operation |
| --- | --- |
| `Alt+1` | Search for words or phrases |
| `Alt+2` | View a specified Bible verse |
| `Alt+3` | Extract one verse or a range of verses |
| `Alt+4` | Display the three-character Bible book abbreviations |
| `Alt+5` | Move to the first hit for any target in `Hits.txt` |
| `Alt+6` | Jump from a result in `Hits.txt` to the corresponding KJV text |
| `Alt+7` | Return from the KJV text to `Hits.txt` |
| `Alt+8` | Go to the next hit |
| `Alt+9` | Open the Bullet Operations menu |
| `Alt+0` | Restart/refocus the program on the Bible text |
| `Alt+M` | Display the Bible Research Menu |
| `Alt+H` | Display BibleRes help |
| `Alt+Q` | Quit and unload BibleRes |

## Searching the Bible

1. Press `Alt+1` or choose **Search for Words**.
2. Enter a word, phrase, or supported regular expression.
3. Select or confirm the requested search options.
4. Wait for the search to complete.
5. Review the results in `Hits.txt`.
6. Use `Alt+6` to inspect the selected verse in `KJV.txt`.
7. Use `Alt+7` to return to the result list and `Alt+8` to advance to the next hit.

`Hits.txt` reports the number of matches and verses found. If you want to retain a report, save it under another filename before running another search.

## Viewing a specific verse

1. Press `Alt+2` or choose **View Bible Verse**.
2. Enter the reference using the expected three-character book abbreviation.
3. Press `Alt+4` if you need the list of valid abbreviations.

Examples of abbreviations include `GEN`, `PSA`, `MAT`, `JOH`, `ROM`, and `REV`. Numbered books use forms such as `1SA`, `2KI`, `1CO`, and `2TH`.

## Extracting verses

1. Press `Alt+3` or choose **Xtract Verses**.
2. Enter the starting verse reference.
3. Enter the ending verse reference.
4. To extract only the starting verse, accept the same reference shown as the default ending verse.
5. The selected passage is opened in `Verses.txt`, which you can edit, save under another name, or discard.

## Bullet Operations

Press `Alt+9` to open the included Bullet Operations menu. It can:

- Show major `*` headings.
- Show minor `~` headings within the current book.
- Insert or move between major and minor bullets.
- Show all bullet headings in the file.
- Move to the next chapter.
- Display a pick list of chapters in the current book.

The `*` and `~` markers are part of the navigation structure. Do not remove them from `KJV.txt`. If you replace the marker characters, make the same replacement everywhere in `KJV.txt`, `BibleRes.s`, and `Bullets.s`, and then recompile the macros.

The separator `-=<>=-` used in `Hits.txt` is also required by the navigation functions associated with `Alt+6`, `Alt+7`, and `Alt+8`.

## Rewrapping the Bible text

The supplied `KJV.txt` is wrapped to approximately 60 characters. To use another width:

1. Make a backup copy of `KJV.txt`.
2. Open `KJV.txt` in TSE.
3. Set TSE's left and right margins to the desired values.
4. Execute the `ReWrap` macro.
5. Review the result before saving it.

`ReWrap` preserves the verse-address lines and rewraps the verse text to the configured margins.

## Generated files

| File | Contents |
| --- | --- |
| `Hits.txt` | Results from a word, phrase, or regular-expression search |
| `Verses.txt` | Verses copied by the extraction operation |

These files are created in the same directory as `KJV.txt`. Existing work should be saved under another name when you want to preserve it.

## Troubleshooting

### The macro cannot find `KJV.txt`

Open `C:\Bible\KJV.txt`, or change the `Source` variable in `BibleRes.s` to the actual full path and recompile the macro.

### A supplied `.mac` file does not work

Compile its matching `.s` source with the SAL compiler supplied with your TSE version.

### A book name is not recognized

Press `Alt+4` and use one of the listed three-character abbreviations.

### Navigation between `Hits.txt` and `KJV.txt` fails

Confirm that the bullet markers in `KJV.txt`, `BibleRes.s`, and `Bullets.s` still agree and that the `-=<>=-` result separator has not been removed or changed in only one place.

### The Bullet Operations menu does not open

Ensure `Bullets.mac` is installed in a directory where TSE can execute macros. If necessary, compile `Bullets.s` with your TSE SAL compiler.

## Version numbering for this README

This document starts at version `1.0.0.0.0`. For each future revision, increment the final component:

- `1.0.0.0.0` — initial README
- `1.0.0.0.1` — first update
- `1.0.0.0.2` — second update
- and so on

The README version is separate from the original BibleRes program version 2.1.

## Version history

### 1.0.0.0.0 — 2026-08-30

- Created the first Markdown README for the BibleRes 2.1 archive.
- Documented the program purpose, archive contents, installation, compilation, execution, keyboard shortcuts, helper macros, generated files, and troubleshooting.
