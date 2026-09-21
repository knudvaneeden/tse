# SCROLLWORD

Version: 1.0.0.0.2  
Date: 2026-09-21  
Created with: OpenAI Codex (GPT-5)

## Description

SCROLLWORD is a portable TSE SAL macro that horizontally scrolls the current editing window so that the word at the cursor is displayed in the center of the window.

The macro does not alter the file, move to another line, or change the logical column of the cursor. It changes only the horizontal view offset. The cursor character is used as the reference point for the word.

This is useful when the cursor is close to the far-right edge of a long line and you want to see an equal amount of surrounding text on both sides.

## Package files

- `scrollword.s` - TSE SAL source code.
- `scrollword.ini` - Configuration file.
- `scrollword_readme.md` - Description and instructions.

Keep `scrollword.ini` in the same directory as `scrollword.s` and the compiled `scrollword.mac` file.

## Requirements

- The SemWare Editor Professional 4.50 or a compatible TSE version.
- The TSE SAL compiler `sc32.exe`.
- Windows 11 or another operating system supported by the installed TSE version.

No DLL or other external helper is required.

## Compile

Open a command prompt in the package directory and run:

```text
sc32 scrollword.s
```

This creates `scrollword.mac`.

## Run

1. Open a file containing a line that extends beyond the right edge of the editing window.
2. Put the cursor on the word that you want to bring into view.
3. Press **Ctrl+Alt+Shift+C**.
4. The view scrolls horizontally until the cursor character is at the configured position. With the supplied INI file, that position is the center.

You can also execute `scrollword.mac` from TSE, for example through the Potpourri menu or your preferred macro launcher. Direct execution runs `Main()` and shows an informational message; the keyboard shortcut scrolls immediately without displaying a message.

## Configuration

The supplied `scrollword.ini` contains:

```ini
[scrollword]
target=50
silent=false
```

`target` is the desired horizontal position expressed as a percentage of the current editing-window width:

- `50` centers the cursor and its word.
- `25` places it at the left quarter.
- `75` places it at the right quarter.

Values below 1 are treated as 1. Values above 100 are treated as 100. If the INI file or setting cannot be found, the macro uses 50.

`silent` controls the informative `Warn()` box when the macro is executed normally:

- `silent=true` scrolls without showing a `Warn()` box.
- `silent=false` shows the informative `Warn()` box after scrolling. This is the default.

The value is compared without regard to uppercase or lowercase. The **Ctrl+Alt+Shift+C** shortcut always scrolls silently because it calls the scrolling procedure directly.

The INI path is derived from `CurrMacroFilename()`, so the package is portable and does not depend on the TSE load directory.

## How it works

The macro reads the current logical column with `CurrCol()`, obtains the editing-window width from `Query(WindowCols)`, calculates the required view offset, and applies it with `GotoXoffset()`.

According to the TSE SAL relationship:

```text
screen column = CurrCol() - CurrXoffset()
```

the calculated offset places the cursor at the requested percentage of the visible window while keeping it on the same character.

## Notes

- If the cursor is too close to column 1 for centering to be possible, the horizontal offset becomes zero. TSE cannot display columns before column 1.
- The macro works with split editing windows because it uses the width of the current window.
- Running the macro does not mark, copy, insert, delete, or otherwise modify text.

## Version history

### 1.0.0.0.2 - 2026-09-21

- Changed the supplied `silent` value to `false`.
- Changed the missing-setting fallback to `false`.
- The informative `Warn()` box is now shown by default.

### 1.0.0.0.1 - 2026-09-21

- Added the `silent=true|false` INI setting.
- `silent=true` suppresses the final `Warn()` box.
- `silent=false` retains the informative final message.

### 1.0.0.0.0 - 2026-09-21

- Initial release.
- Horizontally centers the word at the cursor.
- Assigned **Ctrl+Alt+Shift+C** to the scrolling command.
- Added portable INI-file handling.
- Added a final informative message in `Main()`.
