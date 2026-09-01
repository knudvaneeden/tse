# ChAlName

**README version:** 1.0.0.0.0  
**Macro version:** 1.0.0  
**Date and time:** 2026-09-01 23:13:09 CEST (2026-09-01 21:13:09 UTC)  
**Original author:** Carlo Hogeveen  
**Compatibility:** The SemWare Editor Professional (TSE Pro) 2.5e and later

## Description

ChAlName (Change All Filenames) is a TSE SAL macro that changes part of the drive, path, or filename for every file currently loaded in TSE.

With one command, the macro can replace the same text in all loaded filenames. Matching is case-insensitive. It can be useful after moving a group of files, changing a directory name, or correcting a shared part of several loaded file paths.

The macro changes the filenames associated with the loaded buffers. It does not search inside the files and it does not support wildcards or regular expressions.

## Files in the original archive

- `ChAlName.s` - TSE SAL source code.
- `File_id.diz` - Short program description.

## Installation

1. Extract `chalname.zip`.
2. Copy `ChAlName.s` to the TSE `mac` directory.
3. Start TSE.
4. Compile `ChAlName.s` with TSE's SAL macro compiler.
5. Optionally add ChAlName to the Potpourri menu or assign it to a key.

The exact location of the `mac` directory depends on the TSE installation.

## How to run

1. Open or load all files whose buffer filenames should be changed.
2. Run the compiled `ChAlName` macro from TSE, the Potpourri menu, or an assigned key.
3. At the prompt `Replace which part of each loaded drive:\path\filename:`, enter the existing text to replace.
4. At the prompt `Replace this by:`, enter the replacement text.
5. Confirm the second prompt. The macro visits every loaded file and changes each matching filename.

If the first entry is empty, or the second prompt is cancelled, no filenames are changed.

## Example

Suppose these files are loaded:

```text
C:\OLDPROJECT\SOURCE\ONE.C
C:\OLDPROJECT\SOURCE\TWO.C
```

Enter:

```text
Replace which part: C:\OLDPROJECT
Replace this by:    D:\NEWPROJECT
```

The loaded buffer names become:

```text
D:\NEWPROJECT\SOURCE\ONE.C
D:\NEWPROJECT\SOURCE\TWO.C
```

## Important notes

- The replacement applies to all loaded files whose current filename contains the entered text.
- Matching is case-insensitive.
- Only the first matching occurrence in each loaded filename is replaced.
- Wildcards and regular expressions are not supported.
- The macro uses overwrite and no-prompt options when changing a buffer filename. Check the replacement carefully before confirming it.
- If the new name conflicts with an existing file or buffer, data could be overwritten. Back up important files first.
- The macro changes TSE's current filename for each matching loaded buffer. Save the affected buffers if the changed names must be written to disk.

## Troubleshooting

### The macro does nothing

- Make sure the text entered in the first prompt occurs in the loaded filenames.
- Confirm the second prompt instead of cancelling it.
- Verify that the files to be changed are currently loaded in TSE.

### Only some filenames change

The macro changes only loaded filenames containing the specified text. Review the full paths of the files that did not change.

### The macro cannot be found

Confirm that `ChAlName.s` was copied to the correct TSE `mac` directory and compiled successfully.

## Version history

### 1.0.0.0.0 - 2026-09-01 23:13:09 CEST

- Created this Markdown README.
- Added a description, installation instructions, usage steps, example, safety notes, and troubleshooting help.
- Documented original macro version 1.0.0 and TSE Pro compatibility.

Future README revisions can continue as `1.0.0.0.1`, `1.0.0.0.2`, and so on.

## Original program information

- Macro: ChAlName
- Purpose: Change all filenames for all loaded files
- Original date: 2007-06-26
- Original version: 1.0.0
- Original author: Carlo Hogeveen

