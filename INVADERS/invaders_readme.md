# INVADERS

## Version information

- README version: 1.0.0.0.5
- Date: 2026-09-11
- Time: 17:47:18 UTC
- Created with: OpenAI Codex (GPT-5)

Future revisions can use version numbers `1.0.0.0.1`, `1.0.0.0.2`, and so on.

## Description

INVADERS is a classic Space Invaders-style game written in SAL for The SemWare Editor (TSE). It runs inside the editor, draws a movable gun at the bottom of the screen, and sends rows of colored invaders downward from the top.

The player moves the gun, fires at individual invaders, and can use a limited supply of bombs to clear the current wave. The status line displays the number of bombs, the score, and the current level.

## Files in the archive

| File | Purpose |
| --- | --- |
| `INVADERS.S` | Main SAL source code for the game. |
| `SS32.H` | SAL declarations for the 32-bit Windows DLL. |
| `invaders32.c` | Borland C++ 5.5.1-compatible DLL source code. |
| `invaders32.def` | Exports undecorated function names for SAL. |
| `build.bat` | Builds the DLL and compiles the SAL macro. |

The original 16-bit `SS.BIN` module has been replaced by `INVADERS32.DLL`. Keep the DLL beside the compiled macro when running the game.

## Controls

| Key | Action |
| --- | --- |
| Left Arrow | Move the gun one position to the left. |
| Right Arrow | Move the gun one position to the right. |
| F | Fire a shot. |
| Spacebar | Use one bomb and clear the current wave. |
| Escape | Exit the game. |

The game starts with two bombs. An additional bomb is awarded after every fifth level.

To shoot, press `F`. Shooting is handled directly by TSE and no longer polls either Windows Shift key.

## Scoring and game play

- Shooting an invader adds `level x 10` points to the score.
- Using a bomb adds `10 x the number of remaining invaders` to the score.
- A new wave appears after all invaders in the current wave have been destroyed.
- Each new wave advances the level and increases the invaders' speed.
- The game ends if the invaders reach the gun area.

## How to compile

1. Extract all files into the same directory.
2. Open a Borland C++ 5.5.1 command prompt in that directory.
3. Ensure the Borland tools and TSE's `sc32.exe` are on `PATH`.
4. Run:

   ```text
   build.bat
   ```

5. Confirm that `INVADERS32.DLL` and `INVADERS.MAC` were created.

This is a 32-bit Windows build. The DLL returns the same keyboard-state bit flags used by the original DOS binary.

## How to run

1. Start TSE.
2. Keep `INVADERS32.DLL` in the same directory as `INVADERS.MAC`.
3. Load or execute `INVADERS.MAC` using TSE's normal macro execution command.
3. Use the Left and Right Arrow keys to position the gun.
4. Hold or press either Shift key to fire.
5. Press Spacebar when you want to use a bomb.
6. Press Escape to leave the game.

Because `INVADERS.S` contains a `Main()` procedure, no separate launcher macro is required.

## Display notes

Version 1.0.0.0.3 replaces the original DOS extended graphics characters with plain ASCII characters. This prevents modern TSE Pro for Windows from displaying the separator, ground, gun, bullet, and invaders as accented letters.

The portable symbols are `=`, `^`, `/`, `_`, `\`, `|`, `W`, and `*`.

## Troubleshooting

### The compiler cannot find `SS32.H`

Keep `INVADERS.S` and `SS32.H` in the same directory, then compile again.

### TSE cannot load `INVADERS32.DLL`

Keep the DLL beside `INVADERS.MAC`. Restart TSE after rebuilding because TSE can retain a loaded DLL in memory.

### The graphics appear as incorrect characters

Confirm that you compiled the `INVADERS.S` supplied in version 1.0.0.0.3. It contains only ASCII display characters and does not require an OEM code page.

### Shift does not fire

The game reads the Windows keyboard state through `INVADERS32.DLL`. Confirm that the 32-bit DLL is present and restart TSE after rebuilding it.

### The game runs too quickly or too slowly

INVADERS performs a short timing calibration when it starts. Performance can still vary on modern systems, emulators, virtual machines, or compatibility layers.

## Original file dates

The files in the supplied archive date from 1992 and 1993. They should be preserved together if the original source package is archived or redistributed.

## Version history

### 1.0.0.0.5 - 2026-09-11

- Changed the shooting key from Shift to `F`.
- Removed continuous Windows Shift-state polling from the game loop.
- Prevented conflicts with Windows Shift-key accessibility features.

### 1.0.0.0.4 - 2026-09-11

- Increased the initial invader descent speed from about 2.05 seconds to about 0.50 seconds per step.
- Made the descent gradually faster as the level increases.
- Added a minimum delay of 0.10 seconds so high levels remain controlled.
- Clarified that either Shift key fires the gun.

### 1.0.0.0.3 - 2026-09-11

- Replaced all DOS extended display characters with portable ASCII graphics.
- Changed the invader to `W` and the bullet to `|`.
- Changed the gun, ground, separator, and explosion to ASCII-safe symbols.
- Corrected the invisible or incorrectly rendered invaders seen in modern TSE Pro for Windows.

### 1.0.0.0.2 - 2026-09-11

- Corrected the Borland DLL export definition to use the public undecorated names.
- Removed the unused `Fire_It` label from `INVADERS.S`.
- Eliminated the three linker warnings and the SAL compiler note reported with version 1.0.0.0.1.

### 1.0.0.0.1 - 2026-09-11

- Replaced the original 16-bit `SS.BIN` routine with `INVADERS32.DLL`.
- Added Borland C++ 5.5.1 source, an export definition, and a build script.
- Updated the SAL declarations and build instructions.

### 1.0.0.0.0 - 2026-09-11

- Created the initial Markdown documentation.
- Added a description of the game and archive contents.
- Documented compilation, execution, controls, scoring, levels, and bombs.
- Added compatibility notes and troubleshooting information.
