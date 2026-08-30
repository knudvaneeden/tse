# bfindr

**README version:** 1.0.0.0.0  
**Program source:** `B_FINDR.S`  
**Original author:** Brian Abbott  
**Original submission date:** April 5, 1994

## Description

`bfindr` is a TSE (The SemWare Editor) SAL macro that performs a series of find-and-replace operations from an ASCII word-list file.

The macro searches for `.FAR` files in a `FINDR` subdirectory on the TSE path. After you choose a `.FAR` file, every active entry in that file is applied to the current editor file.

- If the cursor is inside a marked block, replacements are restricted to that block.
- Otherwise, replacements are performed throughout the current file.
- Blank lines and lines beginning with `/` are ignored.
- Search options can be changed anywhere in the `.FAR` file with a `FINDOPTS = ...` line.

## Requirements

- The SemWare Editor (TSE)
- A compatible SAL compiler, such as `sc32.exe`
- The supplied source file `B_FINDR.S`
- At least one plain-text word list with the `.FAR` extension

## Installing the macro

1. Copy `B_FINDR.S` to your TSE macro source directory.
2. Compile it with the SAL compiler. For example:

   ```text
   sc32 B_FINDR.S
   ```

3. Copy or leave the resulting compiled macro in a directory from which TSE can load it.
4. Create a directory named `FINDR` beneath one of the directories included in TSE's path.
5. Put one or more `.FAR` word-list files in that `FINDR` directory.

The macro locates the lists using the equivalent of:

```text
SearchPath("*.far", Query(TSEPATH), "FINDR\\")
```

## Creating a `.FAR` word list

Each active line has one of these forms:

```text
search text ; replacement text
search text
FINDOPTS = options
```

### Search and replacement

When a line contains a semicolon, the text before it is the search expression and the text after it is the replacement expression:

```text
do while ; while
endif    ; end
append blank ; dbappend()
```

When no semicolon is present, the same text is used for both the search and replacement expressions. This can be useful with search options that alter matching or capitalization behavior.

### Find options

The default options are:

```text
iwn
```

Use `FINDOPTS = ...` to change them for all entries that follow. The setting may be changed any number of times in one list:

```text
FINDOPTS = inw
if
do while ; while
endif    ; end

FINDOPTS = in
set(
ascan(
```

The letters are TSE find/replace option flags. Their precise meaning depends on the TSE version; consult TSE Help for the supported Find/Replace options. When operating on a marked block, the macro automatically adds the `l` option to restrict the operation to that block.

### Comments and blank lines

Blank lines are ignored. To add a comment, begin the line with `/`:

```text
/ Convert older commands to their newer equivalents
append blank ; dbappend()
```

## Running `bfindr`

1. Open the file that you want to modify in TSE.
2. To limit the operation, mark a block and leave the cursor inside that block. Otherwise, the complete file will be processed.
3. Load or execute the compiled `B_FINDR` macro using your normal TSE macro command or key assignment.
4. Select the required `.FAR` file from the displayed file list.
5. Wait until TSE displays `Done.......`.
6. Review the changes and save the edited file if they are correct.

## Important notes

- Back up important files before running a large replacement list.
- The macro performs replacements directly in the current buffer; review the result before saving.
- The original source converts every active `.FAR` line to lowercase before interpreting it. Consequently, search expressions, replacement expressions, and option lines are all processed in lowercase.
- Search and replacement strings in the source are limited to 30 characters; word-list lines are read up to 80 characters.
- A semicolon is treated as the separator between search and replacement text.
- If no `.FAR` files are found, the macro displays `I couldn't find *.FAR files`.
- Pressing Escape in the file-selection dialog cancels the operation without processing a list.

## Troubleshooting

### No `.FAR` files are listed

Confirm that:

- The files have the `.FAR` extension.
- They are stored in a directory named `FINDR`.
- The parent directory of `FINDR` is included in TSE's path.

### Text is not found

Check the current `FINDOPTS` setting and remember that the macro lowercases entries read from the `.FAR` file. Also verify whether whole-word matching is enabled by the `w` option.

### Only part of the file is changed

The cursor was probably inside a marked block when the macro started. Unmark the block, or move the cursor outside it, and run the macro again to process the complete file.

### A replacement is truncated or does not behave as expected

Keep each search and replacement expression within the source program's 30-character string limit, and keep each `.FAR` line within 80 characters.

## Version numbering

This README starts at version `1.0.0.0.0`. Future revisions should increment the final component sequentially:

```text
1.0.0.0.0
1.0.0.0.1
1.0.0.0.2
1.0.0.0.3
...
```

## Version history

### 1.0.0.0.0

- Initial README.
- Added a program description, requirements, `.FAR` format, installation instructions, running steps, troubleshooting information, and the version-number convention.
