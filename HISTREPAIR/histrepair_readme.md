# HistRepair

**README version:** 1.0.0.0.0  
**HistRepair source version:** 1.1 (12 September 2026)  
**Last updated:** Saturday 12 September 2026, 15:30:42 CEST  
**Session:** Create HISTREPAIR MarkDown Readme

## Description

HistRepair is a TSE SAL macro by Carlo Hogeveen that checks, repairs, and optimizes The SemWare Editor's history lists. TSE stores these lists between sessions in `tsehist.dat` in the TSE load directory.

The macro can also display the existing history lists and their values. A selected macro-created history list can be deleted manually.

HistRepair performs its automatic repair work only when all of the following conditions are true:

- HistRepair is loaded.
- TSE is closing.
- The closing TSE session is the only TSE session still running.
- A scheduled or one-time check is due.

Therefore, running the macro and opening its menu does not immediately repair `tsehist.dat`. The repair check normally takes place when TSE closes.

## Compatibility

- Windows TSE v4.50 RC19 (9 March 2024) or later.
- Linux TSE v4.50 RC15 (14 December 2023) or later.
- The supplied source is HistRepair v1.1, dated 12 September 2026.

HistRepair v1.1 replaces its former use of the Windows `wmic` command with direct Windows functions. This is required because the September 2026 Windows 11 update removed `wmic`.

## What HistRepair can repair

HistRepair can detect and correct several invalid history conditions, including:

- Empty file lines in the history data.
- Illegal history list number 0.
- Macro-created history lists using numbers above 127.
- Names incorrectly assigned to TSE's built-in history lists.
- Mixed-up lists containing multiple names.
- Macro-created lists having an empty or missing name.
- Severe corruption where history names also occur among their own values.

In the severe corruption case, HistRepair may need to delete all macro-created history lists.

## What HistRepair can optimize

The macro can:

- Delete unused, empty macro-created history lists.
- Sort history-name records into the order expected by TSE.
- Renumber macro-created history lists as low as possible while preserving their order.
- Free high history numbers for later calls to `GetFreeHistory()`.

TSE provides only 127 numbers, 1 through 127, for macro-created history lists. The HistRepair menu shows the highest number in use, the total free numbers, and the free high numbers.

## Safety and backup files

Before changing the history data, HistRepair requires successful backups of the relevant `tsehist.dat` and history-buffer states. It also records a description of its changes in:

```text
tsehist_HistRepair.log
```

The log is stored in the TSE load directory. If repairs or optimizations were made, an AutoLoaded HistRepair can offer to open this log during a later TSE session.

For additional safety:

- Close all other TSE sessions before requesting a one-time check.
- Do not remove the backup or log files until the repaired history has been verified.
- Make your own copy of `tsehist.dat` before the first run if you want an additional independent backup.

## Installation

1. Extract `HistRepair.s` from `histrepair.zip`.
2. Copy `HistRepair.s` to TSE's `mac` directory.
3. Open `HistRepair.s` in TSE.
4. Select **Macro -> Compile**.
5. Confirm that TSE creates `HistRepair.mac` without compiler errors.

The source itself recommends compiling the macro in TSE's `mac` directory.

## How to run HistRepair once

1. Close every other running TSE session.
2. Execute the `HistRepair` macro in the remaining TSE session.
3. In the HistRepair menu, change **Check for errors once** from **Off** to **On**.
4. Close the menu.
5. Close TSE normally.
6. HistRepair checks, repairs, and optimizes the histories while TSE is closing.
7. Start TSE again.
8. Inspect `tsehist_HistRepair.log` in the TSE load directory, or execute/load HistRepair again so it can offer a link to the log when changes were recorded.

If another TSE session is running when this session closes, HistRepair deliberately does no repair work.

## Recommended AutoLoad setup

Using HistRepair as an AutoLoaded macro lets it perform periodic optimization and guard against future history errors.

1. Add `HistRepair` to TSE's **Macro AutoLoad List**.
2. Execute `HistRepair` to open its configuration menu.
3. Choose how often TSE histories should be checked:
   - time - at most once per TSE session;
   - hour;
   - day;
   - month;
   - year.
4. Optionally change **Check for errors if N <=**, where `N` is the number of free high history numbers.
5. Close TSE normally while it is the only running TSE session.

An actual check can add approximately one second to TSE's closing time. Selecting a lower check frequency avoids this delay during most sessions.

## HistRepair menu

### View history lists

Displays the known history lists and their values. A macro-created list can be selected and deleted manually. Manually deleting a list automatically enables a one-time repair/optimization check so that high history numbers can be reclaimed when TSE closes.

### Check for errors every

Sets the recurring check period to time, hour, day, month, or year.

### Check for errors once

Toggles a one-time check. When set to **On**, the check is attempted when the current TSE session closes and only if it is the sole remaining TSE session.

### History statistics

- **Highest history number** shows the highest macro-created number currently used.
- **Free numbers** shows how many of the 127 macro-created history slots are unused.
- **Free high numbers (N)** shows how many numbers remain above the highest number currently used.
- **Check for errors if N <=** sets the threshold that can trigger a check even when the normal period has not elapsed. The accepted range is 1 through 127.

### Help

Displays the documentation embedded in `HistRepair.s`.

## Interaction with HistMerge

HistRepair checks its macro load order relative to `HistMerge`. If both macros are used, follow any load-order warning displayed by HistRepair and adjust TSE's Macro AutoLoad List accordingly.

## Troubleshooting

### The menu opened, but nothing was repaired

This is normally expected. HistRepair performs its check when TSE closes, not immediately when its menu opens. Enable **Check for errors once**, ensure this is the only TSE session, and then close TSE normally.

### No log entry appeared

Confirm that:

- **Check for errors once** was set to **On**, or a scheduled/threshold check was due;
- no other TSE session was running;
- TSE was closed normally;
- `tsehist.dat` exists in the TSE load directory.

The log primarily records actual repairs and optimizations, so a clean history may produce no new repair report.

### Unknown history signature

HistRepair refuses to alter `tsehist.dat` when its signature is unknown. Note the complete error message and keep the original file and backups for investigation.

### HistRepair repeatedly deletes the same empty lists

Update TSE and the responsible macro where possible. Some macros may repeatedly create empty history lists. The source specifically exempts known debugger and Function List histories to avoid unnecessary repeated reports.

### TSE closes slowly

A history check can add about one second to the closing time. Change the recurring frequency from **time** to hour, day, month, or year if checking every session is unnecessary.

## Files

| File | Purpose |
| --- | --- |
| `HistRepair.s` | TSE SAL source code. |
| `HistRepair.mac` | Compiled macro created by TSE. |
| `tsehist.dat` | TSE's persistent history data in the load directory. |
| `tsehist_HistRepair.log` | Cumulative HistRepair report in the load directory. |
| HistRepair backup files | Safety copies created before applicable changes. |

## Version history

### README 1.0.0.0.0 - 12 September 2026, 15:30:42 CEST

- Created the initial Markdown description and help file.
- Documented HistRepair v1.1 compatibility and purpose.
- Added installation, one-time use, AutoLoad setup, menu help, safety information, and troubleshooting.
- Clarified that repairs occur while the only TSE session is closing.

Future README revisions should continue as `1.0.0.0.1`, `1.0.0.0.2`, and so on.

## Credits

HistRepair was written by Carlo Hogeveen. The source lists the project website as `eCarlo.nl/tse`.
