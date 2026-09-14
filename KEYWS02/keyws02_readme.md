# KEYWS02

**Session:** Create KEYWS02 MarkDown Readme
**README filename:** `keyws02_readme.md`
**README version:** 1.0.0.0.1
**Last updated:** 2026-09-14 17:00 UTC
**Documentation created with:** OpenAI Codex

## Description

KEYWS02 is a TSE SAL macro for adding, changing, deleting, and automatically assigning keywords to recipe files.

The original macro was written for The SemWare Editor 2.0 and recipes formatted for import into the QBook recipe database. Because the QBook `Keyword:` field resembles the Meal-Master `Categories:` field, the macro can also be adapted for Meal-Master recipes by changing the format definitions in `keyws.dat`.

KEYWS02 can:

- Display and edit the keywords belonging to the current recipe.
- Suggest keywords whose text occurs in the recipe.
- Add keywords manually.
- Add a country from `country.key`.
- Add a main category from `maincat.key`.
- move to the next recipe.
- Automatically scan all recipes and add matching keywords.
- Add selected keywords to every recipe.
- Change a keyword in all recipes.
- Delete a keyword from all recipes.
- Avoid adding duplicate keywords.
- Perform case-insensitive searches.

Because the macro changes recipe data, make a backup of every recipe file before using it.

## Package contents

The supplied package contains the following files:

| File | Purpose |
|---|---|
| `keyws.s` | TSE SAL source code for the macro |
| `keyws.mac` | Compiled TSE macro |
| `keyws.dat` | Constants, variables, menus, and recipe-format definitions used by `keyws.s` |
| `keyws.doc` | Original preliminary documentation |
| `keyws.key` | Main keyword list used by the manual keyword function |
| `autoscan.key` | Keywords searched for by the automatic scanning function |
| `country.key` | List of countries that can be selected as keywords |
| `maincat.key` | List of main recipe categories |
| `file_id.diz` | Short package description |
| `keyws02.zip` | Original distribution archive |
| `keyws02_readme.md` | This README |

## Requirements

- The SemWare Editor for DOS or a compatible TSE version.
- The TSE SAL compiler if `keyws.s` must be recompiled.
- A QBook-compatible recipe file.
- All required KEYWS02 support files in the appropriate directories.

The source was originally written for TSE 2.0. Modern TSE versions may report obsolete syntax, renamed functions, or compatibility errors when compiling the source.

The supplied `keyws.mac` can be tested before attempting to modernize or recompile `keyws.s`.

## Important backup warning

KEYWS02 can automatically modify every recipe in the current file.

Before running the macro:

1. Save the current recipe file.
2. Create a separate backup copy.
3. Test the macro first on a copy of the recipe file.
4. Confirm that the recipe delimiters and keyword-field format match the definitions in `keyws.dat`.

Do not initially test the AutoScan, Global Change, or Global Delete functions on the only copy of a recipe collection.

## Installation

### Using the supplied compiled macro

1. Extract all files from the KEYWS02 archive.
2. Keep these files together in the macro directory:

   - `keyws.mac`
   - `keyws.key`
   - `autoscan.key`
   - `country.key`
   - `maincat.key`

3. Copy or place `keyws.mac` in a directory from which TSE can load macros.
4. Start TSE.
5. Load `keyws.mac` using TSE's macro-loading command.
6. Open a compatible recipe file.
7. Press `Ctrl+F3` to open KEYWS02.

The macro can also be executed by its macro name if supported by the installed TSE version.

### Compiling from source

Keep at least the following files in the same directory:

- `keyws.s`
- `keyws.dat`

The source begins with:

```sal
#include ["keyws.dat"]

Therefore, the compiler must be able to find `keyws.dat` while compiling `keyws.s`.

Compile the source from a command prompt:

```text
sc32 keyws.s
```

A successful compilation should create:

```text
keyws.mac
```

Copy the resulting `keyws.mac` and its `.key` support files to the intended macro directory.

## Starting KEYWS02

The source assigns the following hotkey:

```text
Ctrl+F3
```

The hotkey calls:

```sal
FixKeywords()
```

The macro's `Main()` procedure also calls `FixKeywords()`, so directly executing the macro should open the same keyword-management menu.

To start it:

1. Open a compatible recipe file in TSE.
2. Position the cursor inside or near a recipe.
3. Press `Ctrl+F3`.

## Main functions

### Add Keywords

The Add Keywords function displays a list containing:

1. Keywords already present in the current recipe.
2. Keywords from `keyws.key` whose text matches text in the recipe.

The list can then be used to add, edit, delete, or select keywords.

The macro checks for duplicate keywords before saving the revised list.

Press `F1` while the keyword list is displayed to obtain context-sensitive help.

### Go to next recipe

This function advances the display to the next recipe in the current file.

If there is no following recipe, KEYWS02 reports that the current recipe is the last recipe.

### AutoScan

AutoScan processes all recipes in the current file.

It searches the recipe text for words stored in `autoscan.key`. When a match is found, the corresponding word is added as a keyword.

Before scanning, the macro asks:

```text
Match whole word only?
```

Choose:

- **Yes** for safer, exact whole-word matching.
- **No** to permit broader matches and word variations.
- **Escape/Cancel** to stop without starting the scan.

For example, a non-whole-word scan may allow a keyword such as `Game hen` to match recipe text containing `Game hens`.

Because AutoScan can alter every recipe in the file, use it only after creating a backup.

### Global Delete

Global Delete asks for a keyword and removes an exact occurrence of that keyword from all recipes in the current file.

The comparison is case-insensitive, but the complete keyword must otherwise match.

For example, deleting `Main` should not delete a longer keyword such as `Main course`.

### Global Change

Global Change asks for:

1. The keyword to change.
2. The replacement keyword.

It then changes exact occurrences throughout all recipes in the current file.

The comparison is case-insensitive. A keyword contained within a longer keyword should not be changed accidentally.

For example, changing `main` to `Main dish` should not change `Main course`.

## Keyword-list controls

While the Add Keywords list is displayed, the source implements the following controls:

| Key | Function |
|---|---|
| `F1` | Display help for the keyword list |
| `Enter` | Modify or select the highlighted keyword |
| `Ctrl+Enter` | Correct or change the capitalization of a keyword |
| `Insert` | Add a new keyword |
| `Delete` | Remove the highlighted keyword |
| `F2` | Open and maintain the `keyws.key` list |
| `F7` | Select a country from `country.key` |
| `F8` | Select a main category from `maincat.key` |
| `F9` | Save the current recipe without advancing |
| `F10` | Save and continue with the next recipe |
| `Escape` | Close or cancel the current list |

The exact behavior can depend on the TSE version and the currently active list window.

## KEY files

A `.key` file is a plain-text file containing one keyword per line.

Example:

```text
Beef
Breakfast
Dessert
Game hen
Raspberry
Vegetarian
```

Rules:

- Start every keyword in column 1.
- Store only one keyword per line.
- A keyword may contain more than one word.
- Do not add headers or explanatory text.
- Keyword comparisons are generally case-insensitive.
- Keep individual keywords within the maximum length configured in `keyws.dat`.

### `keyws.key`

`keyws.key` is the main list used by the Add Keywords function.

It must be located in the same directory as `keyws.mac`.

If the file does not exist, the macro may create a small initial keyword file.

While viewing the keyword list, press `F2` to open the `keyws.key` list. From there, keywords can be added, deleted, or selected. Changes are saved automatically by the macro.

### `autoscan.key`

`autoscan.key` contains words that AutoScan searches for inside each recipe.

When a listed word is found in a recipe, that word is added to the recipe's keyword field.

This file should be in the same directory as `keyws.mac`.

### `country.key`

`country.key` contains country names or regional classifications that can be added manually as keywords.

Press `F7` from the Add Keywords list to display the countries.

This file must be in the same directory as `keyws.mac`.

Although the supplied file contains countries, it may be customized with other suitable geographical keywords.

### `maincat.key`

`maincat.key` contains the main recipe categories.

Press `F8` from the Add Keywords list to select a main category.

This file must be in the same directory as `keyws.mac`.

The supplied categories can be replaced or extended with categories appropriate for the user's recipe collection.

### `allrec.key`

This optional file is not necessarily included in the supplied package.

If present in the macro directory, its keywords are added to every recipe processed by AutoScan.

This can be useful for a keyword that must be assigned to all recipes, such as the name of a collection or BBS.

### `alldir.key`

This optional file is not necessarily included in the supplied package.

If present in the current recipe directory, its keywords are added to all recipes processed in that directory.

### Recipe-specific KEY file

KEYWS02 can also use a `.key` file whose base filename matches the recipe filename.

For example:

```text
SWEDISH.QBF
SWEDISH.KEY
```

When AutoScan processes `SWEDISH.QBF`, keywords from `SWEDISH.KEY` are added to recipes in that file.

## Keyword matching

All keyword searches are case-insensitive.

KEYWS02 uses special matching behavior to recognize some singular and plural word variations. For longer keywords, the search can omit the final character.

For example, searching with part of `Raspberry` may permit matching both:

```text
Raspberry
Raspberries
```

This broader matching can also produce unwanted matches. Use the tilde suffix when an exact whole-word match is required.

## Forcing an exact match with `~`

Place a tilde character at the end of a keyword to force whole-word matching:

```text
Ham~
Pie~
Rice~
```

The tilde is used as a matching instruction and is removed before the keyword is added to the recipe.

This convention can be used in:

- `keyws.key`
- `autoscan.key`

It is especially useful for short words or words that would otherwise match part of a longer word.

## Duplicate handling

The following functions check for duplicate keywords before adding new ones:

- Add Keywords
- AutoScan
- Global Add operations

However, if a recipe already contains duplicate keywords before KEYWS02 processes it, the macro might not automatically remove those existing duplicates.

Review recipe output after processing.

## QBook recipe format

The default constants and strings in `keyws.dat` are intended for QBook recipe files.

Important definitions include:

```text
Maximum keyword length: 32 characters
Maximum keyword-line length: 78 characters
```

The actual recipe markers, title field, keyword field, separator, and end marker are defined in `keyws.dat`.

Do not run the macro on an unrelated text file. If the expected recipe markers cannot be found, the macro reports:

```text
Recipe not found
```

## Meal-Master adaptation

The original documentation states that KEYWS02 can potentially be adapted to Meal-Master because QBook's `Keyword:` field has a structure similar to Meal-Master's `Categories:` field.

To investigate this adaptation:

1. Open `keyws.dat`.
2. Locate the first string declarations for the QBook format.
3. Comment out the QBook declarations.
4. Uncomment the declarations below the comment:

   ```text
   variables for Meal-Master format
   ```

5. Check the maximum keyword and line-length constants.
6. Compile `keyws.s` again.
7. Test only on a copy of a Meal-Master recipe file.

The original author indicated that Meal-Master support had not been tested. Confirm every change carefully before processing a collection.

## Recommended first test

1. Create a copy of a small QBook recipe file.
2. Open the copied file in TSE.
3. Position the cursor in the first recipe.
4. Press `Ctrl+F3`.
5. Choose Add Keywords.
6. Review the suggested keywords.
7. Add or delete one test keyword.
8. Save the current recipe.
9. Close KEYWS02.
10. Inspect the recipe's keyword lines.
11. Save and reopen the file to confirm its structure remains valid.
12. Test AutoScan only after manual editing works correctly.

## Example workflow

1. Add the following lines to `autoscan.key`:

   ```text
   Beef
   Chicken
   Dessert
   Raspberry
   Vegetarian
   ```

2. Open a backed-up recipe file.
3. Press `Ctrl+F3`.
4. Select AutoScan.
5. Choose whole-word matching for the first test.
6. Allow the macro to process the recipes.
7. Review the resulting keyword fields.
8. Undo the changes or restore the backup if the results are not suitable.
9. Adjust `autoscan.key` before scanning the original collection.

## Troubleshooting

### The macro does not start

Confirm that:

- `keyws.mac` has been loaded.
- The hotkey `Ctrl+F3` is not assigned to another macro or editor function.
- The compiled macro is compatible with the installed TSE version.

Try executing the macro directly by name instead of using the hotkey.

### `keyws.dat` cannot be found during compilation

Keep `keyws.dat` in the same directory as `keyws.s`, or configure the compiler's include path so it can locate the file.

### No recipe is found

The current file probably does not contain the recipe markers expected by `keyws.dat`.

Check:

- The recipe file format.
- The beginning-of-recipe marker.
- The end-of-recipe marker.
- The title-line definition.
- The keyword-line definition.

### No keywords are suggested

Confirm that:

- `keyws.key` exists.
- `keyws.key` is in the same directory as `keyws.mac`.
- Each keyword starts in column 1.
- The recipe actually contains matching text.
- The keyword spelling is correct.
- Exact-match keywords use the `~` suffix correctly.

### AutoScan does not add keywords

Confirm that:

- `autoscan.key` exists in the macro directory.
- It contains one keyword per line.
- The recipe contains matching words.
- Whole-word matching is not preventing the intended match.
- The recipe format agrees with `keyws.dat`.

### Too many incorrect matches are added

Use one or more of these methods:

- Select whole-word matching when starting AutoScan.
- Add `~` to keywords that require exact matching.
- Remove overly general words from `autoscan.key`.
- Test with a smaller keyword list.
- Review the results using a copied recipe file.

### Country or main-category lists do not appear

Confirm that these files are present beside `keyws.mac`:

```text
country.key
maincat.key
```

Also confirm that they contain one entry per line.

### Compilation errors occur in a modern TSE version

KEYWS02 is legacy TSE 2.0 source code. Newer TSE SAL compilers may require source changes.

Possible compatibility areas include:

- Old procedure syntax.
- Deprecated editor functions.
- List-window constants and hooks.
- Include-file syntax.
- Global-variable definitions.
- Older `CreateBuffer()` or `CreateTempBuffer()` usage.
- Obsolete block and buffer functions.
- Reserved identifiers introduced in later TSE releases.

The supplied `keyws.mac` may only work with compatible TSE versions.

## Limitations

- The original macro was designed for TSE 2.0.
- QBook is the default recipe format.
- Meal-Master support is described as an untested adaptation.
- AutoScan modifies all recipes in the current file.
- Incorrect recipe-format definitions can damage file formatting.
- Broader searches can produce false matches.
- Existing duplicate keywords might remain.
- Keyword files normally require manual maintenance.
- Compatibility with current 32-bit TSE releases has not yet been confirmed.

## Safety recommendations

- Always work on backup copies.
- Test manual keyword editing before AutoScan.
- Begin with whole-word matching enabled.
- Use `~` for keywords prone to false matches.
- Review the recipe file after each test.
- Keep the original unmodified package.
- Do not overwrite the only copy of a recipe database.

## Version history

### Version 1.0.0.0.0 - 2026-09-14 17:00 UTC

- Created the initial Markdown documentation.
- Added a description of KEYWS02.
- Documented the package contents.
- Added installation and compilation instructions.
- Added steps for starting the macro.
- Documented the `Ctrl+F3` hotkey.
- Described the Add Keywords, AutoScan, Global Change, and Global Delete functions.
- Documented the supplied `.key` files.
- Added keyword-matching and exact-match information.
- Added backup and testing warnings.

### Version 1.0.0.0.1 - 2026-09-14 17:00 UTC

- Expanded the help for keyword-list controls.
- Added the `F1`, `F2`, `F7`, `F8`, `F9`, and `F10` functions.
- Added documentation for optional `allrec.key`, `alldir.key`, and recipe-specific keyword files.
- Added QBook format information.
- Added Meal-Master adaptation guidance.
- Added a recommended first-test procedure.
- Added an example AutoScan workflow.
- Expanded troubleshooting and compatibility notes.
- Added safety recommendations for automatic and global changes.

## Credits

KEYWS02 is based on the original KEYWS TSE 2.0 macro and its supplied documentation.

This README describes the behavior found in the supplied `keyws.s`, `keyws.dat`, `keyws.doc`, and associated keyword files.
