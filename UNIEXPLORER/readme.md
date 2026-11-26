# UniExplorer compatibility 1.0.0.0.17
26 November 2026 — unofficial adaptation of Carlo Hogeveen's UniExplorer v0.0.0.8 BETA.

**Important — open files one at a time:** After double-clicking a filename in Windows Explorer, wait until that file is fully loaded and visibly displayed in the original TSE editing window before double-clicking the next filename. If the Buffer List, a menu or a dialog is open, close it first (for example, press Escape). This allows the mailbox receiver to finish loading and acknowledging the current request. Opening another file too early may cause a timeout or leave an additional TSE instance open.

## Mandatory installation and Explorer configuration

1. Compile `UniExplorer.s` with the compiler belonging to the intended TSE installation (`sc32 *.s`). Install the resulting `UniExplorer.mac` and `uniexplorer.ini` together.
2. Adding `UniExplorer.mac` to TSE's AutoLoad list is **mandatory and essential**: its `WhenLoaded()` procedure must intercept the original Unicode command line before TSE processes the filename. Do not autoload `UniExplorer_debug.mac`. Save the AutoLoad configuration and restart TSE.
3. Set native TSE Single Instance to OFF, save the configuration and completely restart TSE. UniExplorer supplies its own forwarding mechanism.
4. In Windows Explorer, right-click a test file, choose **Open with** > **Choose another app** (or **Open with TSE** if already correctly configured), then browse to the exact `g32.exe` you want to use. On Windows 11 the browse option may be labelled **Choose an app on your PC**. Confirm the intended executable; repeat for other extensions if necessary. Optionally set it as the default app to enable double-click opening. All participating TSE instances must use the same macro path and version.
5. Wait until each file is fully loaded and visibly displayed in TSE before opening the next file. Close the Buffer List, menus and dialogs first.

### Single Instance command-line options (experimental alternative)

The TSE manual documents `-1` (digit one) for Single Instance ON and `-1-` for OFF. `-i` instead augments the editor load directory. Version 17 explicitly recognizes an unquoted `-1-` or `-1` followed by one quoted filename in the original UTF-16 command line. The previous Explorer parser is retained for ordinary opening. The switch is processed by TSE itself before AutoLoad; UniExplorer cannot force a new process after native forwarding has already occurred.

First verify the ordinary Explorer workflow with native Single Instance OFF. Then, for an independent experiment, close every TSE instance, set native Single Instance ON, save settings and restart using the intended g32.exe. From a console, issue the following command with your actual absolute filename (use a disposable test file):

```bat
"F:\WORDPROC\tse32_v45033\g32.exe" -1- "F:\BBC\taal\UNIEXPLORER\tests\files\only-ă.txt"
```

Wait for the file to be fully displayed. Repeat with a different Unicode file. The expected log includes `Command line Single Instance override: -1- (OFF)`, the primary receiver PID, acknowledgment and WM_CLOSE. Verify that the primary ring contains the correct files and no extra window remains. If the test fails, restore native Single Instance OFF. Use a Unicode-capable command entry method; a console that changes Unicode characters before launching TSE cannot test the original path reliably.

For Explorer integration, the equivalent opening command is `"F:\WORDPROC\tse32_v45033\g32.exe" -1- "%1"`. The ordinary Open with dialog selects an executable, not its arguments, and does not automatically add this switch. Version 17 does not change registry associations or install a launcher. If the chosen g32.exe is already the default application for that file extension, simply double-clicking the filename in Explorer may be sufficient when native Single Instance is OFF (or when its opening command already includes `-1-`). Do not use `-1` for incoming Unicode requests when native forwarding would bypass AutoLoad.

Reference: https://ecarlo.nl/tse/files/TseHelp.html (command-line options).

## Version 17 — experimental Unicode save-back (inherited from version 16)

Version 15 was the tested loading baseline (13 distinct buffers, duplicate detection enabled). Version 17 retains its AutoLoad, mailbox and deduplication logic. On legacy GUI TSE, the normal `_AFTER_FILE_SAVE_` hook attempts to propagate the successfully saved temporary file to the registered original UTF-16 path. Ordinary ASCII files are not handled by this hook. Save As and Save Block do not invoke this event and are not supported for save-back. The mapping is limited to the current session; opening a temporary file manually or restoring a session does not register it for save-back.

```ini
[Save]
saveback=1
backup=0
```

- `saveback=1` enables the experimental hook (default); `0` disables original-file writing.
- `backup=0` is the default: no separate original-file backup is created. `1` creates a uniquely named adjacent `.ue-<PID>-<tick>.bak` copy of the original before replacement. If the backup cannot be created, save-back is refused. TSE's own native backup setting for its temporary buffer remains independent.
- For conflict checking, a private `.uebase` snapshot of the initially loaded bytes is stored alongside the temporary copy in the temporary directory, even when `backup=0`. It is refreshed after a successful save. It is not a user backup, and is retained for diagnostics in this version. The `.ueorig` file retains the original path. Neither is automatically deleted.
- Before replacing the original, compare its raw bytes with the snapshot, copy the edited temporary file to a unique sibling staging path, optionally create a backup, and compare again. Missing, unreadable, or changed originals are refused. `ReplaceFileW` performs the replacement. There is a small race between the final comparison and replacement; do not edit the original concurrently. Windows replacement failures can leave files under different names; inspect the log and retained files. No promise of transactional or crash-proof saving is made. The edited temporary copy is retained; a failure warns the user and attempts to mark the buffer changed again.
- If `deduplicate=0`, multiple buffers can refer to one original; the comparison should refuse stale edits. Use the default `deduplicate=1` for ordinary testing.

### Save tests (disposable copies only)
1. First complete the 13 loading tests without saving. Run the fixture verifier before any save tests.
2. Copy test 06 into a separate disposable directory using Explorer. Double-click the copy, wait until the contents are visible, append a distinctive line, press Ctrl+S. Check the log for `Backup disabled by INI` and `Save-back ReplaceFileW succeeded`. Open the actual original with a Unicode-aware editor to verify the new line, and verify no new `.bak` appeared beside it. Repeat a second save to test snapshot refresh.
3. Close all TSE instances, set `backup=1`, restart and repeat with a fresh disposable test file. Verify the adjacent backup contains the pre-save bytes. Revert `backup=0` when finished.
4. Open a fresh disposable original, change it using another Unicode-aware editor, then edit and save the TSE buffer. Expect a refusal, the external modification to remain, and the edited temporary copy to be retained. Also test an ASCII file (normal TSE save), and the empty and nested Unicode fixtures in separate disposable copies.
5. Upload the log. If any original save fails, do not discard the temporary copy or staging files. Version 17 still requires Windows compilation and runtime tests; do not use valuable files yet.

## Version 15 regression isolation
Version 14 successfully selected duplicate test 06 twice, then stopped receiving requests. The primary may have been displaying the Buffer List or another nonediting menu; this is not established. Version 15 logs pending requests during _NONEDIT_IDLE_ once per sender and never loads files in that state. Close menus before sending the next request. Duplicate selection now uses EditThisFile with the existing temporary path, verifying the existing buffer ID, rather than directly selecting with GotoBufferId. The original atomic mailbox send, retry, acknowledgment and closure logic is unchanged.

Set [UniExplorer] deduplicate=1 (default) or 0 to disable the in-memory duplicate registry and use the version 13 ordinary EditThisFile receiver path, while retaining readable names and .ueorig files. Restart all instances after changing the INI. Version 15 passed the full loading test with duplicate detection enabled. With deduplicate=0 repeated Unicode requests intentionally create separate buffers.

Test A: start test 06, reopen twice, open Buffer List to inspect, press Escape to return to editing, open cafe and tests 04/05. Test B: intentionally leave Buffer List open while opening another file, then press Escape within the configured acknowledgment timeout. Check for nonediting idle warning and editing idle resumed. If no warning appears, the nonediting hook may not run in that state. Test C: if forwarding fails even with all menus closed, repeat A with deduplicate=0. Keep version 15 for rollback. Do not save during loading-only tests.

## Features inherited from version 14
Version 13 passed all 13 loading fixtures in one persistent TSE instance under 4.50.33. Version 14 retains the mailbox retry mechanism and adds exact UTF-16 associations. Each Unicode temporary copy has a `.ueorig` companion containing the original path in UTF-16LE, including its terminating NUL (no BOM). The primary keeps a memory registry of original paths and temporary buffer filenames. Reopening the exact same original path selects the existing open buffer instead of loading another copy; this preserves unsaved edits. Comparison is exact, not ANSI, case-folded, or hash-based. Different spellings, aliases, and case variants can still create separate buffers. A closed buffer can be opened again from a fresh copy. The association survives on disk but the duplicate registry is session-local; it is not restored at startup. A sidecar failure falls back to ordinary content-only loading.

Temporary names use a readable ASCII stem, a unique numeric suffix and the original simple ASCII alphanumeric extension, e.g. `ue-pair-_-1234.txt`. Unsupported or absent extensions use `.txt`. CopyFileW still refuses to overwrite an existing destination. Duplicate requests still create an unused temporary copy and sidecar, deliberately retained because timeout fallback may need them. No automatic deletion or original filename renaming is implemented. Version 17 retains the experimental save-back introduced in version 16, described above.

## Additional tests
With native Single Instance OFF, start from test 06; reopen it twice without closing TSE. Confirm the ring retains one buffer for test 06 and log reports `Duplicate original filename; selected existing buffer`. Repeat test 04, then open test 05 and test 03: all three must remain distinct and contain their respective IDs. Test 12 as well. For extension preservation, make a disposable copy of a fixture with a Unicode name ending in `.s` or `.cpp` and open it through Explorer (use Open with TSE if needed). Verify the temporary filename extension. Inspect the `.ueorig` companions with a Unicode-aware viewer if desired. Perform the separate save-back tests below only on disposable files. Verify that the original TSE window remains open and no other windows remain after successful forwarding. Version 15 passed user testing; version 17 has not been compiled or run under Windows here.

## Mailbox configuration
In uniexplorer.ini, [Mailbox] retryintervalms=100, busytimeoutms=10000, acktimeoutms=10000. Valid retry interval 10–1000 ms; valid timeouts 1000–60000 ms. Out-of-range values revert to defaults. Timeouts count requested sleep intervals (actual elapsed time may be longer). A busy timeout leaves the secondary open with its file; an acknowledgment timeout during a load can leave copies in both rings. No request is intentionally discarded.

## Install and test
1. Close all TSE processes before replacing the macro. Set native Single Instance OFF, save configuration, and restart as necessary.
2. Compile sc32 *.s. Install UniExplorer.mac and uniexplorer.ini together; AutoLoad UniExplorer (not the debug macro). All participating instances must use the same macro path and version.
3. Rotate uniexplorer.log. Double-click only-ă.txt (test 06) from Explorer with no TSE running.
4. Leave that primary editing window open, not in a menu or dialog. Double-click pair-ă.txt (test 04). Expected: correct 04 content in primary, secondary closes normally, focus returns to primary.
5. Repeat with 中文.txt (07), plain.txt (01), and remaining fixtures. Check the TSE ring and Windows taskbar/processes; upload the log if any extra windows remain. Do not save during loading-only tests.
6. Optional stress test only, after the ordinary sequential test passes: open several additional files rapidly (including ASCII files), then check for Mailbox busy; waiting and Mailbox acquired after waiting. A persistent busy timeout is a fallback, not a successful handoff. Look for Mailbox request sender PID, Mailbox receiver PID, Mailbox receiver selected, Mailbox acknowledged successful load, foreground requested/denied, WM_CLOSE posted, and secondary cleanup. A posted message is not proof of closure: verify the window actually disappears.

## Limitations and safety
SAL and native Windows system DLLs only. No external launcher, registry edits, or custom DLL. Optional PowerShell fixture verifier is not used by the runtime. Log format YYYY-MM-DD HH:MM:SS INFO|WARN|ERROR <message>; logging defaults on. Single-slot mailbox with configurable busy and acknowledgment timeouts. If the receiver remains busy, absent or fails, secondary opens locally and stays open. A timeout during loading may leave copies in both rings. Experimental save-back is now available; no automatic temporary cleanup yet. One quoted filename per invocation only; multi-select not supported. Separate manual starts without a file request stay open. Primary idle receiver may not run while a modal dialog is open. If a process dies during a request, close all TSE instances to reset. Upstream path retained for newer TSE builds. Version 17 is uncompiled and untested on Windows here; focus and WM_CLOSE behavior remain best effort. Keep version 15 available for rollback. Test only disposable files.

Reference: https://ecarlo.nl/tse/files/TseHelp.html (GetWinHandle, Hook, _IDLE_, _NONEDIT_IDLE_, UpdateDisplay).
