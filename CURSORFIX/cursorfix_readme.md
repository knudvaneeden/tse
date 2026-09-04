# TSE Cursor Recovery

**Version:** 1.0.0.0.5  
**Date:** 2026-09-03  
**Purpose:** Restore the blinking text cursor in the Windows GUI version of TSE (`g32.exe`).

## Description

This package uses one TSE SAL program, `cursorfix.s`, which performs two
cursor-recovery steps in order:

1. It first uses TSE's own cursor settings and display refresh.
2. It then calls `cursorfix.dll` as a fallback for a hidden standard Win32 caret.

The native SAL repair restores nonzero insert and overwrite cursor sizes, toggles
TSE's `Cursor` setting off and on, and redraws all editor windows.

The DLL repair obtains the caret owned by the current TSE GUI thread and calls
the Windows `ShowCaret()` function until Windows reports that the caret is
blinking. If Windows caret blinking has been disabled, it restores a normal
530 millisecond blink interval. It does not create or replace TSE's caret.

## Package files

- `cursorfix.s` - the single TSE SAL program for both recovery methods.
- `cursorfix.c` - Borland C++ 5.5-compatible DLL source.
- `cursorfix.def` - exports the undecorated `ForceCursorFix` name.
- `build.bat` - builds the 32-bit DLL.

## Build the DLL

Open a command prompt configured for Borland C++ 5.5 and change to this
package directory. Then run:

```bat
build.bat
```

Expected final message:

```text
Build completed: cursorfix.dll
```

Version 1.0.0.0.1 corrects the ILINK32 argument order. The `.def` file is now
passed in the module-definition position instead of the resource-file position.

## Compile and run the combined SAL program

1. Keep `cursorfix.dll` where Windows can find it. The simplest test is to put
   it next to `g32.exe`; a directory on `PATH` can also be used.
2. Copy `cursorfix.s` to a directory in `TSEPath`, or keep it in your normal
   macro directory.
3. Compile it:

```bat
sc32 cursorfix.s
```

4. Load or execute `cursorfix.mac`.
5. When the blinking cursor disappears, run `cursorfix` again or press
   **Ctrl+Alt+C** while the macro is loaded.

The SAL program always performs both steps because SAL cannot inspect the
screen pixels to prove that the first step made the cursor visible. The DLL is
safe to call afterward: it stops immediately if Windows already reports a
blinking caret.

## DLL result codes

| Result | Meaning |
|---:|---|
| `0` | Windows already considered the caret visible; repaint requested. |
| `1` through `16` | Number of `ShowCaret()` calls needed. |
| `-1` | No focused TSE window was found. |
| `-2` | No standard Win32 caret was found; TSE may be painting its own cursor. |
| `-3` | Windows rejected `ShowCaret()`. |
| `-4` | Windows could not restore the caret blink interval. |

## Important notes

- Run either repair only while the main TSE editing window has focus. Do not
  invoke it while a menu, prompt, or pop-up window is open.
- If the DLL returns `-2`, the missing cursor is probably controlled internally
  by TSE. The first, native part of `cursorfix.s` is then the relevant method.
- TSE keeps loaded DLLs in memory. After rebuilding `cursorfix.dll`, completely
  restart TSE before testing the new DLL.
- The DLL is deliberately 32-bit for use with `g32.exe`.

## Version history

### 1.0.0.0.5 - 2026-09-04

- Added explicit recovery of cursor blinking.
- If Windows reports that caret blinking is disabled, the DLL restores a
  530 millisecond caret blink interval.
- Clarified that the native TSE cursor reset restores both visibility and
  blinking state.

### 1.0.0.0.4 - 2026-09-03

- Changed the DEF export to Borland's public `ForceCursorFix` symbol without
  an underscore alias.
- Removed explicit `exit /b` commands from `build.bat` to avoid extraneous
  `exit: exit: quits the CMD.EXE program` messages in some command environments.

### 1.0.0.0.3 - 2026-09-03

- Standardized every source, definition, DLL, README, function, and archive
  name on `cursorfix`.

### 1.0.0.0.2 - 2026-09-03

- Renamed the release archive to `cursorfix_1.0.0.0.2.zip`.
- Corrected the Borland C++ 5.5 export alias to the Borland public-symbol form.
- Eliminated the linker warning about attempting to export a non-public symbol.

### 1.0.0.0.1 - 2026-09-03

- Combined both recovery methods into one `cursorfix.s` program.
- Corrected the ILINK32 comma placement that caused RLINK32 to interpret
  `cursorfix.def` as a 16-bit resource file.
- Removed `cursorfix_dll.s`.

### 1.0.0.0.0 - 2026-09-03

- Initial release.
- Added native TSE SAL cursor recovery.
- Added optional Win32 caret recovery DLL.
- Added Borland C++ 5.5 build files and SAL test front end.
