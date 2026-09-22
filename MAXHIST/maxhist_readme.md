# MAXHIST

**Package version:** 1.0.0.0.0  
**Updated:** 2026-09-22 10:24:59 UTC  
**Original macro:** MaxHist version 2, 1999-02-22  
**Original author:** Carlo Hogeveen  
**README and package update:** OpenAI Codex

## Description

MAXHIST is a TSE SAL macro that protects TSE's persistent command and input histories from crowding each other out.

TSE stores multiple history lists within a total history capacity. If the configured size of each list multiplied by the number of lists is larger than the total capacity, a frequently used list can displace entries from less frequently used lists. MAXHIST prevents this by:

1. Enabling persistent history.
2. Detecting the largest `MaxHistorySize` accepted by the current TSE version.
3. Detecting the largest `MaxHistoryPerList` value accepted by TSE.
4. Counting the history lists currently present.
5. Dividing the available total history capacity among those lists.
6. Saving the changed TSE settings.
7. Purging itself from memory after it has finished.

The calculations are performed automatically, so no fixed history-size values are built into the macro.

## Package contents

- `MAXHIST.S` - TSE SAL source code.
- `maxhist.ini` - reserved configuration file; version 1.0.0.0.0 has no user-configurable values.
- `maxhist_readme.md` - this description and help file.
- `FILE_ID.DIZ` - original short package description.

## Requirements

- The SemWare Editor Professional (TSE).
- A TSE SAL compiler compatible with the original macro.
- Access to TSE's macro directory and macro autoload list.

The original release identifies compatibility with TSE Pro 2.5 and TSE Pro/32 2.8. The source uses standard TSE history settings and is intended to remain useful with later TSE versions, but compile and test it with the TSE version in which it will be used.

## Installation

1. Back up your current TSE settings and important work.
2. Extract all files from `maxhist1.0.0.0.0.zip` into a temporary directory.
3. Copy `MAXHIST.S` to TSE's macro directory.
4. Keep `maxhist.ini`, `maxhist_readme.md`, and `FILE_ID.DIZ` with the source for reference.
5. Open a command prompt configured for the TSE SAL compiler.
6. Change to the directory containing `MAXHIST.S`.
7. Compile the source, for example:

   ```text
   sc32 MAXHIST.S
   ```

8. Confirm that the compiler creates `MAXHIST.MAC` without errors.
9. Add `MAXHIST` to TSE's macro autoload list so it runs during startup.
10. Restart TSE.

## How to run MAXHIST automatically

Automatic startup is the recommended mode.

1. Add `MAXHIST` to TSE's macro autoload list.
2. Start or restart TSE.
3. MAXHIST hooks TSE's idle event.
4. When TSE becomes idle, the macro optimizes the history settings.
5. If either history-size setting changes, MAXHIST displays the old and new values, saves the settings, and refreshes the display.
6. MAXHIST then purges itself from memory.

If the existing settings are already optimal, the startup execution may finish without displaying a change message.

## How to run MAXHIST manually

1. Compile and load `MAXHIST.MAC` in TSE.
2. Execute `MAXHIST` as a macro.
3. An informative message confirms that optimization has been scheduled.
4. Close the message and allow TSE to become idle.
5. MAXHIST then performs the optimization, saves any changed settings, and removes itself from memory.

The message shown by `Main()` does not itself report the calculated values. Those values are displayed after the idle-time calculation, but only when a setting changes.

## Configuration

MAXHIST version 1.0.0.0.0 does not require configuration. The included `maxhist.ini` is a reserved placeholder for possible future settings.

Do not add assumed history-size values to the INI file. MAXHIST deliberately discovers the supported limits at runtime so it can adapt to the active TSE version and current history lists.

## Important notes

- MAXHIST turns `PersistentHistory` on because optimizing history storage is useful only when histories persist between TSE sessions.
- The macro changes `MaxHistorySize` and `MaxHistoryPerList` and calls `SaveSettings()` when either value changes.
- The per-list size is calculated from the total supported size and the number of detected history lists.
- MAXHIST is designed to run briefly during startup and then purge itself, so it does not remain in macro memory.
- The original author reported a runtime of less than 1/18 of a second on the systems available in 1999.

## Troubleshooting

### The macro displays an informative message but no values

The manual `Main()` message only confirms that MAXHIST installed its idle hook. Close the message and let TSE become idle. A values message is shown only if MAXHIST changes one or both history-size settings.

### Nothing appears during startup

This can be normal when the existing history settings are already optimal. Also verify that:

- `MAXHIST.MAC` compiled successfully.
- `MAXHIST` is present in the macro autoload list.
- TSE is allowed to become idle after startup.

### History entries are not retained after restarting TSE

Run MAXHIST once and confirm that TSE can save its settings. MAXHIST enables persistent history, but TSE must also be able to write its settings file.

### Compilation fails

- Compile the unmodified ASCII source with the compiler supplied for your TSE installation.
- Confirm that the compiler can locate TSE's standard SAL definitions.
- Check whether the selected TSE version supports the settings and hooks used by this historical macro.

### The macro cannot be run a second time

MAXHIST intentionally calls `PurgeMacro("maxhist")` after completing its idle-time work. Load or execute the compiled macro again if another run is needed.

## Version history

### 1.0.0.0.0 - 2026-09-22 10:24:59 UTC

- Created `maxhist_readme.md` with a description, installation instructions, usage steps, notes, and troubleshooting help.
- Added the reserved `maxhist.ini` file.
- Added an informative `Warn()` message to `Main()` for manual execution.
- Preserved the original automatic optimization and self-purge behavior.
- Retained the original `FILE_ID.DIZ` package description.

### Original version 2 - 1999-02-22

- Also maximized `MaxHistoryPerList` when only a small number of history lists existed.

