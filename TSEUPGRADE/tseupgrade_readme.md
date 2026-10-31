# TSEUPGRADE

Version: 1.0.0.0.53  
Updated: 2026-10-31 18:43:55

Upgrade Windows TSE into a separate installation, using an INI for all personal
paths. The old installation, old UI, and old CFG are read as sources. Personal
files may live outside either installation, in your working directory.

## Included files

`tseupgrade.s`, `tseupgrade.ini`, `tseupgrade.ps1`, and this readme.
Compile the SAL launcher yourself; no executable or compiled macro is included.
All supplied text is ASCII. The ZIP is the sole download deliverable.

## Your configured locations

| Purpose | INI setting | Configured path |
| --- | --- | --- |
| Old installation | old_directory | F:\WORDPROC\tse32_v45024\ |
| New installation | new_directory | F:\WORDPROC\tse32_v45032\ |
| Personal working directory | working_directory | F:\BBC\TAAL\ |
| Old UI input, read only | ui_file | F:\BBC\TAAL\qed32v45024.ui |
| New UI output | ui_destination | F:\BBC\TAAL\qed32v45032.ui |
| Old CFG input, read only | cfg_file | F:\BBC\TAAL\tse45024knu.cfg |
| New CFG output | cfg_destination | F:\BBC\TAAL\tse45032knu.cfg |

The INI is based on your supplied configuration. `powershell_exe` was corrected
to blank for automatic detection. The new UI filename follows your naming pattern;
change it if you want a different name. Check every path before running.

## Steps to run

1. Extract the ZIP into a writable directory. Keep all six files together.
2. Review `tseupgrade.ini`. Keep the actual filename `tseupgrade.ini`.
3. Confirm the downloaded archive is complete. Back up any existing NEW target.
4. Compile using your current TSE SAL compiler:

   ```bat
   sc32.exe tseupgrade.s
   ```

5. In TSE, use Macro > Execute to run the resulting `tseupgrade.mac`.
6. Read the initial message, then answer console prompts in order. Only `y` or `n` answers a step (case-insensitive); any other input repeats it. Each command finishes before the next.
7. The helper offers to copy the old installation and extract the ZIP. If the
   archive contains a vendor installer rather than ready-to-use editor binaries,
   the helper runs the extracted installer and waits. Select the NEW installation
   directory in its dialog. Confirm completion before compilation proceeds.
8. Optionally compile distributed macros, copied personal macros, the new UI,
   and the staged CFG. Inspect the transcript if a compiler step fails.
9. Optionally set search paths and startup directory, then start the new editor.
10. Test the new editor before changing shortcuts or daily use. The console
    remains at a Press Enter prompt until you dismiss it.

Requirements: Windows TSE and its SAL compiler, Windows PowerShell 5.1 with
Expand-Archive (normally present on Windows 10/11), and write access to the target
and personal output directory. No TCC-specific commands or third-party ZIP utility
are needed. Keep package paths short because SAL strings are limited to 255 bytes.

## INI settings

Use `[tseupgrade]` and unquoted `key=value` lines. Full-line comments may begin
with `;` or `#`. Inline comments are not supported. Environment variables in paths
are expanded by the helper; use a literal full path for powershell_exe.

| Parameter | Behavior |
| --- | --- |
| silent | false shows the initial SAL Warn; true hides only that introductory message. |
| powershell_exe | Blank discovers Windows PowerShell through SystemRoot. Otherwise a full executable path, never an INI path. |
| old_version / new_version | Version labels, asked if blank; no directory or URL is guessed from them. |
| old_directory / new_directory | Required, separate non-nested installation directories. Asked if blank. |
| archive_file | Downloaded ZIP, optional. A configured file must exist before migration starts. |
| download_url | Optional HTTP/HTTPS page opened in your default browser after confirmation; no automatic download or verification. |
| installer_exe | Installer extracted from the ZIP; default tse.exe, relative to new_directory. Run with a visible dialog and wait for completion. |
| ui_file | Existing personal UI source, read only. |
| ui_destination | NEW personal UI filename. Relative to working_directory, falling back to new_directory. Blank uses new_directory\new_ plus the old UI basename. |
| cfg_file | Existing exported ASCII CFG source, read only. Not a binary DAT file. |
| cfg_destination | NEW personal CFG filename. Relative to working_directory, falling back to new_directory. |
| cfg_data_file | Compiled settings destination, relative to new_directory. Default tsecfg.dat; must stay within the new installation. |
| custom_macro_directory | Personal source directory; copied recursively into NEW custom_macros, then all .s and .si copies, including every subdirectory, are compiled there. |
| cuamark_file | Optional personal source copied into NEW mac\cuamark.s. |
| editor_exe / compiler_exe | g32.exe / sc32.exe by default, relative to new_directory. Must point inside the new installation. |
| tse_path / kbd_path | Optional literal search-path strings, maximum 220 characters and no quotes; semicolon lists allowed. Blank leaves copied settings unchanged. |
| working_directory | Startup directory for the new editor; also the base for relative personal UI/CFG destinations. |
| log_file | Blank generates a unique transcript beside the helper. Explicit path must not exist and its parent must exist. Cannot be within old_directory. |
| old_compile_data | Old compiler data for automatic merge; blank uses old_directory\compile.dat. |

Other relative input paths resolve beside the INI. Answers to blank required
settings are not automatically saved. Changing working_directory does not change
TSEPath or KbdPath. For example, to use the newly compiled personal copies, review
whether your new editor should use F:\WORDPROC\tse32_v45032\custom_macros in its
macro search path. Blank search paths may retain references to the old installation.

## Personal UI and CFG handling

The old UI is copied to ui_destination and that NEW file is compiled with the
new compiler's -b option targeting the new editor. It runs from the destination
folder, so relative includes in F:\BBC\TAAL remain accessible. The whole personal
folder is no longer copied a second time merely to compile the UI. If you put the
new UI in a different folder, arrange its relative include files there yourself.
The helper also checks that the new UI's possible same-name .mac output is unused.

The old ASCII CFG is staged inside NEW and burned with -b targeting NEW g32.exe.
The separate automatic export step then queries the running NEW editor and writes
a fresh CFG to cfg_destination. The old ASCII source is not copied as that export.

External UI/CFG outputs must have different names from OLD sources. Existing
NEW UI/CFG outputs and the UI compiler output are preserved in uniquely named
.before_upgrade_<id>.bak files before replacement, after step confirmation. No output may be inside the old installation. Linked entries encountered inside source trees are reported and skipped without
following them. A linked source root or linked output path is still rejected to
avoid redirected writes. All source/output paths remain
configurable; no source code edits are needed for another Windows computer.

Personal macro compilation still copies the entire custom_macro_directory tree
into NEW custom_macros, so a large F:\BBC\TAAL can take time and disk space.
All personal .s and .si files are compiled recursively, including nested subdirectories.
.s and .si files are compiled using directory wildcard runs in each selected batch. The original personal macros and compiled files there are not rebuilt.

## Settings and final checks

Optional search-path changes generate a uniquely named SAL source and macro in
the new installation. Execute that generated macro only in the NEW editor; it
sets the configured paths and calls SaveSettings. If launch is declined, the
helper prints the macro path to execute later. Generated files remain for review.
Startup working_directory is written only to the NEW tse.ini. The launch also
uses the configured working directory if provided.

Merge compiler rules manually in the new editor: Shift+F9 > Advanced Setup >
Merge Data File, selecting old_compile_data. Existing NEW installation files may
be overwritten after confirmation. Batch .s errors do not stop later steps; UI/CFG compiler errors stop their dependent steps; completed
steps remain and there is no automatic rollback. Verify the actual executable
version before compiling settings; the helper checks presence, not release identity.

The helper itself does not update old source files. Compilers, your own include
files, and startup/autoload macros can contain their own paths or executable code;
review such custom behavior if it writes files outside the new installation.

## Validation and troubleshooting

ASCII encoding, INI parameter coverage, distinct configured old/new personal
filenames, and ZIP integrity were checked. Windows TSE and Windows PowerShell
execution were unavailable here and require local testing.

Missing companion: keep INI and PS1 beside the compiled macro. Missing editor or
compiler: install the new release first or correct its executable paths. Existing
personal output: select an unused NEW filename. Compiler error: inspect console
and transcript, fix the source, then rerun. Access denied: select writable paths.

## Copy progress in version 1.0.0.0.53

Installation and personal-source copies print their source, destination and totals.
Scanning, directory preparation and copying report progress about once per second
while entries complete. Normal copy filenames and directory names are suppressed.
Copy updates show completed files / total, percentage, copied MB and elapsed time.
The final summary always reports totals, including an empty source. Copy errors
include the source/destination paths; skipped links are still individually reported.
Progress summaries, errors and skips are recorded in the transcript.

A large individual file may take longer than one second to copy; progress updates
occur between completed operations, not while a single Copy-Item is blocked.
A failed copy stops the upgrade and does not print a success summary.
The old installation and source files remain read-only inputs to the copy step.

Replace all package files with this version, retaining any later personal INI
changes you made. Copy progress is part of the helper and is always enabled;
`silent=true` still suppresses only the introductory SAL message.

## Linked source folders in version 1.0.0.0.53

A junction or symbolic link such as F:\BBC\TAAL\tse no longer stops a source
scan. The console and transcript show `SKIP linked file/directory: full-path`.
The link and everything reachable only through it are omitted. Ordinary files
and ordinary subdirectories continue to be copied and compiled recursively.
Each scan ends with a count of inspected entries and skipped links.

The traversal lists one directory at a time, checks each entry for the reparse
attribute, and only adds ordinary directories to its work list. It never follows
linked entries. Reparse points such as junctions, symbolic links and certain
special Windows filesystem entries are all treated as links for this purpose.
If a skipped folder contains macros you need, copy their actual source files to
an ordinary folder first; the skipped link itself is not a migrated macro folder.
A configured source root that is itself a link, and links in output paths, are
still rejected. Existing links already in the new installation are also rejected.

For a retry after the reported error, installation copying, archive extraction,
and distributed macro compilation can be declined if those steps already finished
correctly. Then accept personal-source copying/compilation to resume that work.
The error occurred during source scanning, before that personal copy began.
Keep any later edits you made to your INI when replacing the package files.

Validation: reviewed the explicit traversal to ensure links are skipped before
being queued or yielded; checked version stamps, ASCII encoding and ZIP integrity.
Windows execution still requires testing on your computer.

## Compiler warnings in version 1.0.0.0.53

Exit code 1 is accepted with explicit success even when there are no warnings.
The reported UI compile showed duplicate-key warnings and unused-declaration
notes, then `Installation successful! Interface burned into editor.`, but returned
exit code 1. The helper now accepts exit 1 only when the same compiler invocation
contains an explicit successful-installation or output-file message,
and no compiler error diagnostics. It prints a successful completion message
and continues. Other nonzero results still stop the upgrade. Error diagnostics mark the source as failed even if the return code is zero.
Batch .s compilation continues; standalone UI/CFG compilation still stops on failure. Full compiler output remains visible
and is recorded in the transcript.

Duplicate-key warnings indicate that duplicate definitions were ignored; review
them separately if that differs from your intended bindings. They are not treated
as failed UI installation when the compiler explicitly reports success.

If resuming after this stop, the UI may already have been burned into the NEW
editor, as reported. You can skip that UI step and continue with CFG and settings.
Personal UI output from the prior attempt may exist; rerunning its copy step
requires a fresh output name or moving that NEW copy aside. Do not delete the old UI.

Checks covered warning-only success, actual errors, missing success confirmation,
and other nonzero results using representative diagnostic text, plus ZIP integrity
and ASCII/version checks. Windows execution still requires local testing.

## Target confirmations in version 1.0.0.0.53

Both the continue confirmation and the existing-directory confirmation now include
the full NEW installation directory, taken from new_directory in the INI. This
makes the destination explicit at the point where you answer Yes or No.

## Installer execution in version 1.0.0.0.53

The sequence is now: copy OLD installation to NEW (optional), extract the ZIP
into NEW, run the extracted installer, wait for it to finish, confirm its target,
and only then compile macros/UI/CFG. `installer_exe=tse.exe` resolves to the NEW
installation's tse.exe, not the older external DDD directory from your first INI.
Update that parameter if keeping your own INI.

For your settings the installer is:

```text
F:\WORDPROC\tse32_v45032\tse.exe
```

In its destination dialog select:

```text
F:\WORDPROC\tse32_v45032\
```

The helper prints both paths before asking to run it. No undocumented silent
installer switches are used, so select the new directory yourself in its dialog.
The helper does not change the old directory; the installer's destination choice
must also be the NEW directory to preserve the old version.

If the ZIP contains a top-level folder, set installer_exe to the corresponding
relative path, such as subfolder\tse.exe. Extraction may be skipped on a retry if
the extracted installer already exists. Missing installer, a nonzero installer
exit, declining to run it, or not confirming completion prevents compilation from
continuing with copied old binaries. Installer exit codes are handled separately
from SAL compiler results; a nonzero installer exit requires inspection.

After confirmation the helper checks the configured NEW editor and compiler
files and prints their file/product version metadata when available. Check the
new editor's About/version display as well; version labels in the INI do not
verify the installed binary release automatically.

All earlier copy progress, link skipping, recursive batch compilation, and
continue-after-batch-errors behavior is retained. No separate download files are
provided. Windows installer execution could not be tested in this environment;
sequence, paths, ASCII/version consistency and ZIP integrity were checked.

## Explicit confirmation details in version 1.0.0.0.53

Every confirmation displays the old and new version labels. Each operation also
shows the actual relevant paths or values: download URL, archive, source tree,
copy destination, compiler, UI input/output, CFG input/output, compiled settings,
new editor, search paths, startup INI, working directory, or startup macro.
The Yes/No line follows these details and requires an explicit y or n.
Installer execution introduced in 1.0.0.0.9 is included: extract the ZIP, run its
tse.exe, wait, and confirm installation before compilation. Use installer_exe=tse.exe
for an installer extracted directly into the NEW directory.

Validation checked every confirmation site for context, output preview resolution,
ASCII/version consistency and ZIP integrity. Windows execution remains to be tested.

## Less copy output and installer clipboard in version 1.0.0.0.53

Per-file copy logging is optional to reduce console/transcript overhead.
The default is copydisplay=none; an omitted or blank key also defaults to none.
Compiler filenames and diagnostics remain visible, including batch failures.
The actual speed improvement depends on the disk and workload; no Windows timing
benchmark was available here.

After you agree to run the installer, immediately before launching tse.exe, the
helper copies the NEW installation directory to the Microsoft Windows clipboard
and tells you exactly what was copied and where to paste it. Clipboard failure
is reported and the destination is printed for manual entry; installation can
still proceed. The clipboard is not restored afterward, leaving the path ready
for pasting while installation is running.

Validation checked throttling structure, error-path messages, clipboard placement
before installer launch, consistent ASCII/version stamps and ZIP integrity.
Windows copy/clipboard/installer execution still requires local testing.

## Copy display parameter

Set this in [tseupgrade] in tseupgrade.ini:

```ini
copydisplay=none
```

| Value | Display |
| --- | --- |
| all | Every copied filename and prepared directory, with start/end totals. |
| summary | Periodic counts, percentage and elapsed time, about once per second. |
| none | Default: one start message; no filenames or periodic copy progress. |

Copy errors remain visible and stop the copy in every mode. This option controls
copy-related progress, not confirmation prompts, installer messages or compiler
diagnostics. Linked-entry skips are individually shown in all/summary and silent
in none. Invalid values produce a configuration error before migration begins.
In none mode, the single start message and any copy errors are still recorded
in the transcript; filenames and periodic progress are suppressed.
Existing INIs without this parameter use none automatically.

Version 1.0.0.0.53 changes the copydisplay default and missing/blank-key fallback
to none. Explicit all or summary settings remain supported. Copy errors remain visible.

## Copy start notice in version 1.0.0.0.53

Each directory-copy operation prints one line before scanning or copying begins:
`Copying has started. Please be patient...`
This is also displayed with copydisplay=none. No periodic progress or filenames
are added in that mode. Copy errors remain visible.

## Console focus in version 1.0.0.0.53

The helper remembers the window that receives each Yes/No answer. It requests
that window's focus again after the answer, before the next confirmation, and
before copying. When opening the download URL it requests a minimized browser
launch and immediately restores the console, so the next question stays in the
console. Browser reuse behavior may ignore the minimized request.

The installer still receives focus for its own dialogs. When it exits the helper
restores the console for the remaining steps. The code supports the actual input
window (including Windows Terminal), rather than relying on a hidden console
window handle. It does not repeatedly force focus during lengthy copying, so
you can deliberately switch to other applications. Windows foreground-window
restrictions or browser-specific behavior may still require Alt+Tab.

Validation checked focus-call placement after answers, after browser launch,
before copying and after installer exit; version/ASCII and ZIP checks passed.
Windows foreground behavior requires local testing.

## Delayed browser activation in version 1.0.0.0.53

Opening the download URL can activate a browser after Start-Process has already
returned. The helper now announces focus recovery and retries for five seconds
before presenting the next prompt. Focus restoration also temporarily attaches
the calling and foreground input threads, detaching them in a finally block.
This targets the console saved when you answered, including Windows Terminal.
It reports if Windows still refuses focus. There is no ongoing focus lock after
this short recovery interval; the installer can still receive focus normally.

Changes affect download-URL launch, not ZIP extraction. Focus behavior requires
Windows testing; source sequencing, balanced thread attachment cleanup, ASCII
version stamps and ZIP integrity were checked locally.

## One early copy-time estimate in version 1.0.0.0.53

`copyeta=true` in the INI enables one early estimate per directory-copy operation.
It also defaults to true if omitted. With copydisplay=none, the start notice is
followed by a single approximate remaining time in hours:minutes:seconds, then
copying continues silently. No ETA bar or repeated ETA messages are displayed.
Set copyeta=false to disable the estimate. The all/summary display modes still
provide their separately requested copy output.

The helper first scans the source and prepares destination folders, then measures
a short sample of actual copying. After at least three seconds and five completed
files it prints the estimate once, if files remain. A copy that finishes before
that sample threshold needs no estimate. No reliable estimate is available before
measuring the drive's copy speed; scanning itself is not included in the estimate.
Both completed-file and copied-byte rates are considered, using the longer
estimate. This is approximate and is deliberately not updated afterward.

Arithmetic cases and one-shot output guards were checked, along with ASCII/version
consistency and ZIP integrity. Windows execution and timing accuracy need testing.

## Prepare the copied editor before the installer

Version 1.0.0.0.53 replaces the ineffective Windows TSEPATH environment-variable
workaround. TSEPath is an internal editor setting.

After copying/extraction and before launching tse.exe, the helper:

1. Checks that the NEW editor and copied tsecfg.dat exist.
2. Announces the editor, compiler, configuration, backup and new TSEPath in a confirmation.
3. Copies the NEW directory's tsecfg.dat to a unique
   `tsecfg.dat.before_prepare_<id>.bak` file beside it, without overwriting a backup.
4. Writes a unique preparation source in the NEW directory and compiles it with
   the matching compiler in NEW. Set `preparation_compiler_exe` to override it.
5. Runs the compiled macro using the NEW directory's copied g32.exe with `-e`,
   with the NEW directory as its process working directory.
6. The macro sets TSEPath to the NEW installation directory, calls SaveSettings(),
   writes a success marker only after SaveSettings succeeds, then calls Exit().
7. Waits for that editor to close and checks the marker. Missing confirmation or
   preparation compilation errors stop the upgrade before the installer starts.
8. Runs tse.exe and waits for it to finish. Personal sources are copied to
   custom_macros and compiled there only afterward.

If SaveSettings fails, the macro warns and leaves the editor open. Close that
preparation editor; the helper will stop without launching the installer.
Generated source, compiled macro, success marker and backup remain in the NEW
installation for inspection. Do not restore the backup before running the
installer, because that would undo the preparation. Restoration is a manual
recovery action with the NEW editor closed, not an automatic post-install step.
The original OLD tsecfg.dat is only read during the installation copy.

The preparation uses the copied old editor before the installer replaces it;
it does not require cross-version configuration compatibility for that step.
Whether the installer reads these saved settings is still a hypothesis requiring
Windows testing. Watch its macro compilation stage: this change is intended to
prevent compilation in the original working directory, but has not yet proved
that behavior. tse.ini is retained for macro settings; it is not deleted.
Existing startup macros in the copied editor can still run during preparation.

Validation: checked preparation/backup/compile/run/marker/installer ordering,
removed environment-variable manipulation, and verified ASCII/CRLF files and ZIP
integrity. Neither Windows TSE execution nor installer behavior was testable here.

## Strict Yes/No input in version 1.0.0.0.53

Every Yes/No confirmation displays [Y/n]. Press Enter for the default Yes,
or enter y/Y for Yes or n/N for No, followed by Enter. Other input (t, yes, no,
spaces or unrelated text) is rejected and the same question, with versions and
paths, is repeated. Whitespace is not silently trimmed into a default answer.
This applies to every Confirm-Step call, including overwrite/install questions.
Normal path entry and the final Press Enter to close prompt are unchanged.
No INI parameter is needed.

Validation checked empty/default input, both letter cases, invalid text and
whitespace, plus the retry loop, ASCII/CRLF and ZIP integrity. Windows runtime
testing remains required.

## Preparation diagnostics in version 1.0.0.0.53

The existing console transcript now records the exact preparation command, working
directory, generated source and compiled macro, configuration backup and expected
confirmation filename. It records the editor process ID, exit code and elapsed
time, then the confirmation file's presence, size, modification time and contents,
and whether saved=true was accepted. Launch/wait exceptions are logged explicitly.

If confirmation is missing, the log gives a direct command using the macro name
and identifies the exact file to inspect afterward. Missing confirmation does not
prove SaveSettings failed. A success marker reports SaveSettings success during
that macro run; it does not prove the installer reads that setting.

Version 20 added diagnostics without changing the preparation command or upgrade
sequence. Static checks and ZIP validation passed. Windows execution still needs
local testing.

## Preparation command correction in version 1.0.0.0.53

The preparation editor is now launched with a plain macro name, without a full
path, quotes or .mac extension in the -e argument. For example:

```bat
g32.exe -etseupgrade_prepare_<id>
```

The helper still selects the NEW directory's editor by its full executable path
and sets its process working directory to NEW. Compilation and generated files
remain there. The log records the exact command and confirmation result.

The supplied version 20 log showed exit 0 after about one second but no marker
with the full-path argument. A previous manual run produced a success marker.
This change tests that argument difference; it does not yet prove the underlying
TSE parsing cause or the installer's use of saved TSEPath. Windows testing is
still required. The installer remains blocked unless the fresh marker confirms
saved=true. Backup and post-install personal compilation ordering are unchanged.

## Launch strategy from chanfitn.s in version 1.0.0.0.53

Preparation now follows the original macro's launch pattern: Windows START, a
full compiled macro path and an existing text file to open. IConfig is omitted.
The helper generates a unique .txt file and .cmd launcher in NEW, and explicitly
uses Windows cmd.exe with AutoRun and delayed expansion disabled. START /WAIT
and the helper's process wait keep the installer from starting prematurely.

Example of the command recorded in the log:

```bat
start "" /wait "NEW\g32.exe" -e"NEW\tseupgrade_prepare_ID.mac" "NEW\tseupgrade_prepare_ID.txt"
```

The empty quoted argument is START's window title. Actual paths come from the
INI and generated NEW-directory filenames. Percent signs in paths are escaped
in the batch source. The launcher's working directory is NEW. Its .cmd and .txt
files remain beside the generated macro for diagnosis. Logged PID/exit status
now belong to the waiting launcher; the success marker remains the required
evidence that the preparation macro reported SaveSettings success.

This supersedes the version 21 plain-macro-name launch. Backup, compilation with
the old compiler, SaveSettings check, marker validation and installer ordering
remain in place. No success is inferred merely from exit code 0. The installer
TSEPath hypothesis remains unverified until the Windows installation test.
Static ordering, ASCII/CRLF and ZIP integrity checks passed; no Windows runtime
test was available here.

## Version 1.0.0.0.53: recursive wildcard compilation

After the installer finishes, each selected compilation tree is scanned for .s
and .si files, including ordinary subdirectories and hidden sources. In each
directory containing sources, the helper runs the NEW compiler with these
literal wildcard arguments, skipping patterns with no matching source:

```text
sc32.exe *.s
sc32.exe *.si
```

There is at most one invocation per extension per directory, rather than one per
source. Both extensions are mandatory for selected batches. No INI change is
needed. The working directory is the source directory, preserving relative
includes and compiler output locations. SC32 performs wildcard expansion.
The helper does not use *.s?, combine both patterns in one invocation, or
fall back to individual invocations. These choices avoid untested wildcard
semantics and retain two explicit source types.

This applies to NEW mac and NEW custom_macros. Personal originals are only
read/copied; they are never compiled in place. Recursive traversal skips links; a wildcard run is rejected if its pattern
could include a linked source. Staged-path checks remain. UI, CFG and preparation compile separately as before.

Compiler errors are visible and retained in the transcript. A failed wildcard
run does not stop later patterns or directories. SC32 controls continuation
within its own wildcard run: verify this during the first Windows test. There
is no automatic per-file retry. A run can produce both successful outputs and
errors; the summary counts failed RUNS, not failed sources. Source counts mean
selected files, not proof that SC32 processed each one. Previously copied .mac
files may remain after errors. Some .si files are fragments and may fail alone;
shared basenames can share output names, as controlled by SC32.

## Compiler timing and diagnostics

Each compiler invocation logs SC32 START and END, the exact command, working
directory, invocation ID, start/end timestamps, elapsed seconds, exit code and
SUCCESS/FAILED. Runs lasting at least 10 seconds also log SC32 SLOW on completion.
The existing ASCII .log.sc32.tsv sidecar records START before launch and END
in finally, appending and closing on each event. Its columns remain:
timestamp_local, invocation_id, event, elapsed_seconds, exit_code, result,
compiler, working_directory, arguments_json, detail.

Wildcard runs now have one timing pair per directory/extension rather than per
source. All compiler output remains in the main transcript. Output is streamed
without retaining a full batch-sized copy in memory. A START without END can
mean a running invocation or an interrupted upgrade. Timing does not establish
the cause of a delay. No timeout, deliberate pause or antivirus change is added.
Actual speed depends on compilation and system activity; no speedup is promised.

Automatic cleanup is still pending. Fresh CFG export is implemented below. Static validation
covered exact extension grouping, absent-pattern skipping, error continuation,
version markers, ASCII/CRLF and ZIP integrity. Windows SC32 runtime validation
is still required, especially continuation after an error within a wildcard run.

## Total installation timer

The timer starts when the PowerShell upgrade helper begins and ends when its
upgrade steps finish or an error stops them. The console and main transcript
record INSTALLATION START, INSTALLATION END, result (COMPLETED or STOPPED), failed
wildcard run count, and INSTALLATION TOTAL TIME in days/hours/minutes/seconds/
milliseconds and total seconds. COMPLETED can include compilation errors that
the batch policy allows; the failure count remains visible.

Elapsed time includes confirmations, copying, extraction, installer execution,
compilation and waiting for the user during installation. It excludes the final
Press Enter to close this console wait, time before the helper starts, and time
spent using the new editor after its final launch. A monotonic Stopwatch measures
elapsed time independently of wall-clock changes; timestamps include UTC offsets.

Timing is written before Stop-Transcript, on both normal completion and caught
errors. If an error occurs before transcript creation, timing can only appear
in the console. Forced termination or power loss cannot guarantee a final entry.
No INI setting is required. Static checks verified timer start/end placement,
logging before transcript closure, ASCII/CRLF and ZIP integrity. Windows runtime
testing remains required.

## Version 1.0.0.0.53: integrated configuration operations

One upgrade package and ONE tseupgrade.ini. Two independent internal SAL modules,
tseupgrade_writecfg.s and tseupgrade_mergedat.s, are included alongside the four
usual files. Keep all six together. The helper stages unique copies inside NEW,
compiles them using NEW sc32.exe, and automatically launches NEW g32.exe with
-e"<full-drive-and-path-to-unique-macro>.mac" (no intervening space), from the NEW directory. Each worker
writes its own unique confirmation marker, then exits. No separate module INI
files, manual menu navigation or manual worker execution are required.

Both actions remain separate steps within the upgrade; each existing-style
confirmation shows its paths/version. With Yes, execution is automatic. Both
are enabled by default: export_cfg=true and merge_compile_data=true. False skips
that operation. Parameters are in the shared [tseupgrade] section:

| Parameter | Meaning |
| --- | --- |
| cfg_destination | Fresh ASCII CFG from running NEW editor; existing NEW file is backed up. |
| old_compile_data | Previous compiler DAT to read; blank uses OLD/compile.dat. |
| new_compile_data | Destination compiler DAT inside NEW; default compile.dat. |
| export_cfg | Enable automatic fresh CFG export; default true. |
| merge_compile_data | Enable automatic compiler DAT merge; default true. |

The worker paths are resolved by the helper; module Main routines also read the
same tseupgrade.ini for direct testing with full absolute paths. Status markers
are runtime evidence, not additional user configuration files. A matching
saved=true marker is required; missing confirmation stops the upgrade. Process
command, PID, duration, exit and confirmation are logged. Compiler calls use the
existing SC32 timing logs, and the total installation timer includes both actions.

CFG export uses WriteCfg, SettingsData and the export helpers extracted from the
supplied rc24 iconfig.si. It reads CURRENT settings of the NEW running editor, after
UI/CFG burning and (if selected) applying the generated search-path macro. It
checks SaveAs success. It refuses an existing/open output. It does not merely
copy the old CFG. The supplied rc24 iconfig.si itself also supports the macro command
iconfig writecfg "filename"; this extraction avoids a runtime iconfig dependency.

DAT merge uses isSetupSame and RemoveDuplicateSetups extracted from the supplied
rc24 compile(10).s, retaining its 20-line record comparison. It preserves the current
header/debugger configuration, removes incoming records identical to current,
and appends remaining incoming records. Different setups for the same extension
are retained. It does not replace setups by extension or remove duplicates found
only within the incoming file. Both files must have the expected Semware compiler
data header. The current DAT is updated; previous DAT is read only.

Before writing a changed current DAT, the original on-disk file is saved as
<current_dat>.before_merge.bak. An existing backup causes refusal: retain/move
it before rerunning. If already up to date, no write is needed. Use actual
canonical distinct paths, not aliases for the same file. Do not leave compiler
setup edits unsaved in another editor. The final NEW editor launch reads merged
on-disk data. Full editor settings and compiler setup data are independent.

Modules preserve the caller's position/block and applicable TabWidth,
EntabOnSave/EOLType settings. Byte-valued compressed CFG template markers are
represented with Chr(n) to keep distributed sources ASCII; decorative comments
are simplified. The provided SemWare sources are the provenance for these routines.
Automatic cleanup is not added. Generated workers/markers/backups remain for
inspection. First test with a disposable NEW directory and retain the log.

Validation: static extraction/dependency checks, shared-INI references, action
ordering, unique marker verification, ASCII/CRLF and ZIP integrity. No Windows
SAL compiler/runtime is available here; both modules and integration need local
compilation/runtime testing. No claim of a successful Windows test is made.

## Version 1.0.0.0.53: rc24 sources and named configuration queries

Both operation modules now derive from the supplied default TSE 4.50.rc24
sources: iconfig(1).si and compile(10).s. tse(1).ui confirms their menu launchers.
The uploaded common(2).h does not define QueryInt, QueryStr, CfgInt, CfgStr or
CfgRange; including that header would not resolve the reported undefined symbol.
The prior assumption that a newer compiler alone resolves QueryInt was unverified.

The exporter now uses explicit named Query(option) calls. Private template IDs
select these calls; they are not internal editor configuration IDs. The export
format and active settings list come from rc24 iconfig.si. Boolean formatting
follows the source template's B tags, without internal CfgRange checks. No common.h
or other include is needed. Both operation modules should now be suitable for
ordinary SC32 compilation; this still requires confirmation on Windows.

The exporter retains the ORIGINAL EntabOnSave value in its output while temporarily
disabling entabbing for the save. TabWidth likewise uses the source's saved value.
The two settings introduced in the supplied newer exporter, ShowLineNumberBorder
and LineNumberBorderColor, are not exported by the rc24 template. The new editor's
other settings outside the rc24 template are likewise outside this export's scope.
The DAT comparison/removal routines are identical in both supplied versions.

The shared INI, automatic NEW-compiler worker compilation, unique confirmation
markers, backups, recursive .s/.si wildcard compilation and total elapsed timer
remain. OLD compiler output must not be assumed runnable by the NEW editor; the
upgrade still recompiles its workers using the installed NEW compiler.

Static checks verify every active rc24 template entry maps to a typed named Query,
no internal configuration API calls remain, extraction matches rc24 merge routines,
control-block balance, ASCII/CRLF and ZIP integrity. No Windows compilation or
runtime test was possible here. Please test compilation first, before a full run.

## Version 1.0.0.0.53: delay before generated macro execution

The supplied failed-run log showed preparation sc32.exe finishing at
15:38:16.162, followed immediately by g32.exe startup. That process exited after
about 0.329 seconds without either preparation marker. The existing 30-second
preparation_wait_seconds occurred AFTER the editor exited; it was only a marker
polling period. Manual recompile and later launch produced started=true and
saved=true. This establishes a difference in outcomes, not the cause.

New shared INI setting:

```ini
generated_macro_launch_delay_seconds=30
```

Accepted range: 0 through 300 seconds; missing/blank defaults to 30. After each
generated preparation, CFG export or DAT merge macro compiles, the helper verifies
its .mac, waits this interval, verifies it again, then launches g32.exe. The wait
has timestamped START/END entries, actual elapsed time, exact macro path, file
size and pre-wait last-write timestamp in the main log. Existing confirmation
polling still follows editor exit and is controlled separately by
preparation_wait_seconds. Only saved=true in the unique marker confirms success.

No delay is added to each .s/.si source, wildcard run or directory. There are at
most three such launch delays when all generated workers run, adding about 90
seconds with the default. SC32 invocation timing excludes this delay; total
installation timing includes it. All executable commands use sc32.exe/g32.exe
or full executable paths, so TCC aliases for extensionless names are avoided.
The automatic g32.exe launch remains CreateProcess with UseShellExecute=False.

This is a controlled timing experiment, not a confirmed diagnosis. If it still
fails, retain the log, generated .s/.mac and exact result marker for comparison.
No antivirus changes, automatic retries or manual bypass of confirmation are
introduced. Static checks verified compile-before-delay-before-launch ordering,
absence of batch delays, INI default/range handling, ASCII/CRLF and ZIP integrity.
Windows execution remains to be tested.

## Version 1.0.0.0.53: absolute macro paths after -e

Every generated worker is now launched with its quoted full drive and path
immediately after -e. Preparation, CFG export and DAT merge use this form:

```text
"F:\WORDPROC\tse32_v45032\g32.exe" -e"F:\WORDPROC\tse32_v45032\tseupgrade_prepare_ID.mac"
```

Paths come from configuration/generated filenames; the example is not hardcoded.
The NEW installation remains the process working directory. The exact command is
logged. Direct Process.Start, UseShellExecute=False, the 30-second configurable
pre-launch delay and unique saved=true checks remain. Final optional startup
macro execution already used a quoted full path. No shell aliases are involved.

Static checks verified both worker argument constructions, quoted paths with
spaces, no basename-only construction, ASCII/CRLF and ZIP integrity. The change
still needs a Windows runtime test; it is not a confirmed explanation of the
previous missing marker.

## Version 1.0.0.0.53: suspend copied autoload for helper editor runs

The manual test identified an autoload failure (KeepBlinking) before the
preparation macro could create its marker. Renaming NEW/tseload.dat allowed the
helper to run. The upgrade now temporarily moves NEW/tseload.dat to a unique
.upgrade_autoload_<id>.bak immediately before each preparation, CFG-export or
DAT-merge editor launch. This behavior is always active; no INI setting is needed.
The OLD installation's tseload.dat is never modified.

A finally block restores that exact original file after the child exits, or
if launching/waiting throws. If the helper recreated tseload.dat, that file is
preserved under a unique .helper_generated_<id>.bak before restoration. No
existing backup is overwritten or deleted. Suspension and restoration paths
are logged. If NEW had no tseload.dat, no suspension/restoration is needed.

Restoration happens before marker polling and before the next upgrade stage.
The installer and final normal NEW editor launch use the restored autoload file.
Existing marker checks, full-path -e arguments, pre-launch delays, wildcard
compilation and installation timing remain. The launch delay can still be set
to zero using generated_macro_launch_delay_seconds; its default is now 5 seconds.

If restoration fails, the upgrade stops and logs the original backup's path.
Restore it to NEW/tseload.dat before normal use. A forced process kill, power loss
or system crash cannot run finally: use the logged backup path for recovery.
This suppresses the tseload.dat list for helper runs; it does not bypass other
startup code in a custom UI. A normal final editor can still report an unresolved
personal autoload problem; this change does not repair KeepBlinking itself.

Static checks verified that all helper launches suspend inside try, restore in
finally, never target OLD, and retain the normal final launch; ASCII/CRLF and
ZIP integrity passed. Scratch filesystem scenarios checked original absent/present and
helper-created replacement; static inspection covered finally on failure. Windows runtime remains to test.

Version 36 also reduces both generated_macro_launch_delay_seconds and
preparation_wait_seconds defaults/fallbacks to 5 seconds. Both remain configurable
from 0 through 300. Earlier timing examples describe previous versions. The
confirmation wait is a maximum polling interval and returns early on success.

## Version 1.0.0.0.53: START launches and separate TSE instances

Helper editor launches now run through the Windows cmd.exe START command, as
requested, following the launch strategy in chanfitn.s. The generated command is:

```text
start "" /wait /d "F:\WORDPROC\tse32_v45032" "F:\WORDPROC\tse32_v45032\g32.exe" -1- -e"F:\WORDPROC\tse32_v45032\tseupgrade_prepare_ID.mac"
```

All paths are generated/configurable. The empty quoted argument is START's window
title, not the executable. /wait keeps the upgrade waiting for the helper; /d
sets its startup directory. The -1- switch requests a separate non-shared TSE
instance. START creates a process; it does not itself prevent TSE forwarding the
request to an existing single-instance editor. The switch is supported by the
user's published TSE command-line reference:
https://groups.google.com/g/semware/c/T9SMIBw_quA

The helper calls SystemRoot/System32/cmd.exe explicitly with /d (skip shell
AutoRun), /v:off (disable delayed expansion), /s /c and the START command. It does
not use a TCC alias or COMSPEC. Quoted paths containing spaces are supported;
percent signs are refused to prevent CMD environment-variable expansion.

The change covers preparation, CFG export and DAT merge. The logged PID and exit
code now belong to the waiting cmd.exe START shell; a successful shell exit alone
is not success. Each unique saved=true marker is still mandatory. NEW tseload.dat
is suspended for the launch/wait and restored in finally afterward. Both default
waits remain 5 seconds. Final normal interactive editor launch is unchanged.

This replaces the prior direct g32.exe Process.Start strategy. The old process
exited quickly and markers were missing; forwarding to the already-running editor
is the user's observed explanation. Only a successful isolated run will confirm
the fix. Static command/quoting tests and launch coverage checks, ASCII/CRLF and
ZIP integrity passed. Windows runtime testing is still required.

## Version 1.0.0.0.53: refresh installer clipboard after preparation

The NEW installation path is now copied to the Microsoft Windows clipboard AFTER
the preparation editor has exited and its saved=true marker has been confirmed,
immediately before tse.exe is launched. Previously the copy occurred before that
editor ran, allowing the clipboard to be cleared in between.

The helper reads the clipboard back and logs the verified path, then launches
the installer without another TSE helper launch in between. If copy/read-back
fails, it reports that and prints the destination for manual entry. It does not
claim success without a matching read-back. The installer or another application
could still subsequently change the clipboard; this check verifies the value
at the time of launch. The existing START/-1-, autoload restoration, 5-second
waits, compilation and total timer are unchanged. No new INI parameter is needed.
Static checks verified copy placement after preparation, before installer launch,
ASCII/CRLF and ZIP integrity. Windows runtime testing remains required.

## Version 1.0.0.0.53: Yes is the confirmation default

All upgrade confirmations now show [Y/n] and accept Enter as Yes. Explicit n/N
still declines. Invalid text repeats the prompt. Source/destination/version
details remain visible before confirmation. This includes questions authorizing
writes to the NEW installation. No additional INI option is required.

## Version 1.0.0.0.53: TSE settings interface

The SAL launcher now offers Run upgrade, Settings and Cancel. The Settings menus
follow the supplied latex.s pattern: current values beside each item, prefilled
Ask prompts for text, immediate in-memory boolean toggles and an explicit save.
There is no dependency on latex.s, setwiyde or any other personal macro.

All 32 current [tseupgrade] parameters are exposed in four short groups:
Installation/versions, Personal paths, Executables/data, and Behavior/logging/waits.
Long values show their last 35 characters with an ellipsis; selecting the item
opens its full value. Text prompts accept blank values. Copy display accepts only
all/summary/none; numeric waits accept 0..300. Paths retain their existing resolution
rules and need no surrounding quotes. The PowerShell helper retains final path
and file validation when Run upgrade is selected.

Choose Save settings to save and keep editing, Save and return to save/close, or
Discard changes and return to abandon unsaved edits. Escape leaves a group. At
the settings root, Escape returns if unchanged; with unsaved edits it explains
how to save/discard and stays in Settings. Saving uses WriteProfileStr for each
known key and reads it back. Unrelated sections and unknown keys are not explicitly
removed. A save failure may leave some earlier keys written; it reports the failed
key and keeps the unsaved state. Already saved edits cannot be undone by Discard.

The single INI remains beside tseupgrade.mac, located with CurrMacroFilename().
The editor does not write to installation directories or launch the upgrade just
because settings are edited. All existing upgrade behavior is retained.

From TSE's Execute Macro command, use:

```text
tseupgrade
tseupgrade settings
tseupgrade run
```

The first opens the startup menu; settings opens configuration only; run bypasses
the startup menu and starts the existing console workflow. These are macro-command
parameters, not a change to Windows -p syntax. Compile the updated launcher with:

```text
sc32.exe tseupgrade.s
```

Settings menus have at most nine editable items per group to fit ordinary TSE
screens without depending on scrolling. Values are limited to SAL's 255-character
strings, as before. No new INI parameter is introduced. Static checks verified
all INI keys are covered, defaults, menu sizes, source structure, ASCII/CRLF and
ZIP integrity. Windows SAL compilation and menu testing remain required.

## Version 1.0.0.0.53: automatic Yes for upgrade steps

Set in the shared [tseupgrade] INI section, or toggle under Settings > Behavior:

```ini
unattended=true
```

Default is false. When true, all upgrade-script confirmations are automatically
answered Yes, with full version/path details and AUTO YES recorded in the log.
The launcher skips its startup menu and introductory message; the console skips
its final Enter-to-close pause. Explicit tseupgrade settings still opens the
settings editor, allowing this option to be switched off. The existing silent
parameter retains its introductory-message role for interactive runs.

The tse.exe INSTALLER REMAINS INTERACTIVE. Complete its destination/options dialogs
normally. The helper waits for it, then continues with automatic Yes answers.
This is not a fully unattended vendor installation. Other configured operations
proceed as if Yes was entered, including browser opening if a URL is configured,
existing-target reuse, copying, compilation and final editor launch. Clear an
optional input or disable its existing switch when that operation is unwanted.

All required values must already be configured: missing required values produce
an error instead of a prompt. Path validation, backup rules, installer exit-code
checks, helper saved=true checks and batch error continuation remain active.
Automatic Yes to the post-installer question does not replace those checks.
Missing confirmation still stops the upgrade. Logs and installation/SC32 timing
remain. Pre-transcript validation failures can only appear in the console, as
before. Keep log_file blank for the usual uniquely named log, or set its path.

Static checks covered the unattended branch before Read-Host, guarded required
input/final pause, shared-INI/menu coverage, default false, ASCII/CRLF and ZIP
integrity. Windows compilation and full-run testing remain required.

## Version 1.0.0.0.53: reuse expected personal output filenames

F:\BBC\TAAL\qed32v45032.ui is a valid NEW UI destination outside the installation
directory. An existing file there no longer stops the upgrade. (This .ui is the
UI source; the separate CFG destination still uses cfg_destination.)

After the UI step is accepted, the helper preserves an existing NEW UI file and
any same-basename UI compiler output (.mac) with unique
.before_upgrade_<id>.bak suffixes, then copies/burns the NEW UI normally. Before
fresh CFG export, it similarly preserves an existing cfg_destination and lets
the NEW editor write a fresh file there. Backups are logged and never overwritten.
No extra prompt or INI parameter is introduced. unattended also uses this policy.

Destination validation alone does not move files; backups happen only after the
corresponding operation is accepted. Old-source equality/protected-source checks,
OLD installation protection and link checks remain. Different old/new filenames
are still required. If copying, compilation or export fails, backups remain for
inspection/recovery; failed outputs are not silently accepted. In settings-only
mode there are no file moves. Previously documented unused-NEW-output restrictions
are superseded for the integrated upgrade; direct module tests still refuse
existing outputs unless the helper has backed them up first.

Static tests checked validation has no move, backups precede approved UI/CFG
writes, protected-source checks remain, ASCII/CRLF and ZIP integrity. Scratch
filesystem checks verified preserving an existing output and writing its new
replacement. Windows runtime testing remains required.


## Version 1.0.0.0.53: optional tsecfg.dat and restoration

An absent cfg_data_file (normally NEW/tsecfg.dat) no longer stops installation.
When absent, copied-configuration preparation is skipped and the interactive
installer runs normally. No backup is invented and no previous-run backup is
restored. A directory or unreadable existing file remains an error.

When present, the original DAT is backed up before the temporary TSEPath
preparation. After tse.exe exits, that exact backup is restored, including on
installer failure. Any post-installer DAT is preserved under a unique
.after_installer_*.bak filename first. The original .before_prepare_*.bak is
retained, and SHA256 verifies the restored bytes. Paths and results are logged.
Later approved settings steps may change settings again as before.

Version 1.0.0.0.42 backed up the original DAT but omitted post-installer
restoration. A missing DAT stopped that version before tse.exe was launched.

Validation: reviewed both missing/present branches and installer finally order;
checked all six packaged files carry 1.0.0.0.53 and are ASCII with CRLF.
Windows PowerShell, the interactive installer, and SAL compilation were not
available for an end-to-end execution here.


## Version 1.0.0.0.53: continue after skipping tse.exe

Answering No to Run installer now means the NEW installation was installed
earlier. Skip copied-editor preparation and the installer, then continue the
remaining upgrade steps. Validate the installed editor and compiler normally.
The installer executable is required only when it is selected to run.
All previous fixes for absent tsecfg.dat and post-installer restoration remain.


## Version 1.0.0.0.53: final launch from custom_macros

Final g32.exe launch uses NEW/custom_macros as its working directory so the
newly compiled personal macros can be found. It no longer uses the personal
working_directory setting for this final launch. That setting still controls
personal UI/CFG destinations and the optional tse.ini startup-directory step.

Set startup_macro=knudstar in [tseupgrade] to run knudstar.mac with -e.
Leave startup_macro empty to disable the personal startup macro. This setting
is also editable in the TSE settings menu. Existing INI files without this key
have no personal startup macro until it is configured/saved in that menu.
The generated settings macro, when needed, runs first; the personal macro
runs second. No -p parameters are used. The final confirmation and log show
the executable, launch directory and both macros. The launch directory must
already exist; missing macro files are left for TSE to report normally.

Example equivalent command, issued while in NEW/custom_macros:

    ..\g32.exe -eknudstar

Validated version consistency, ASCII/CRLF, settings load/save/menu wiring and
launch argument order. Windows execution and SAL compilation remain to test.


## Version 1.0.0.0.53: startup menu dividers

Added a menu divider between Run upgrade and Settings, and between Settings
and Cancel. unattended mode continues to bypass the startup menu.


## Version 1.0.0.0.53: warning before startup menu

The introductory Warn dialog now appears when the macro starts, before the
three-option startup menu. It is shown once per invocation, rather than after
selecting Run upgrade. silent=true or unattended=true suppresses this
informational dialog as before. Errors still report normally.


## Version 1.0.0.0.53: initial INI validation and compilation estimates

Before download/copy/extraction/installer actions, PowerShell now prints one
aggregate INI validation report. It also saves a uniquely named
`*.validation.log` beside the package, including when validation stops the run.
Report saving failure is reported visibly and does not hide validation results.
The TSE launcher still checks the INI and PowerShell executable before launch.

Checks include required values; Boolean/display/wait values; malformed lines;
unknown sections/keys; duplicate keys (last value wins); source file/directory
existence and type; output paths; OLD/NEW directory separation; path links;
unresolved environment variables for checked path settings; URL format; and
basic startup-macro/search-path syntax. Unknown or duplicate keys are warnings.

ERROR entries block upgrade actions until corrected. WARNING entries describe
optional/conditional inputs: you can skip their steps; selecting those steps
still requires valid inputs and can stop the upgrade. Blank required settings
are warnings in interactive mode because they are prompted for, and errors in
unattended/validation-only mode. Blank optional inputs are listed as skipped
or defaulted. Missing tsecfg.dat remains informational, never an installation
blocker. Installed/generated files may not exist yet; the report marks these
as deferred and the original checks still run when those files are used.
This is an initial check, not a guarantee of write permissions, successful
compilation, a valid ZIP, available disk space, or the behavior of tse.exe.

A configured missing ZIP is now reported before the steps, and is required
only if its extraction step is selected. This allows reusing an already
installed target while skipping extraction.

For a validation-only run without installation:

    powershell.exe -NoProfile -ExecutionPolicy Bypass -File tseupgrade.ps1 -ValidateOnly

The report includes all detected problems instead of stopping at the first
invalid Boolean or missing required setting. Normal per-step checks remain.

### SC32 compilation time estimate

`compileeta=true` (default when absent) shows rough compilation estimates for
both NEW/mac and NEW/custom_macros. It is editable in the TSE settings menu.
Set it to false to hide estimates; actual elapsed times are still recorded.

Before compiling, a previous successful run with the same compiler path and
directory supplies seconds per selected source. This is scaled by the current
.s/.si source count. The console shows an approximate duration and a broad
0.5x to 2x range; this is a heuristic, not a statistical confidence interval.
Compiler version/content changes at the same path can make history inaccurate.

Without usable history, the console says no estimate is available yet. After
the first successful wildcard batch, it estimates remaining time from the
successful batches' average time per source, if sources remain. A single large
wildcard batch cannot provide an estimate until it completes. No arbitrary
seconds-per-macro default is invented and macros are not compiled twice.

Each directory's actual elapsed compilation time (excluding the initial scan)
is displayed and appended to `tseupgrade_compile_history.tsv` beside the
package. Failed runs are recorded but excluded from future estimates. Keep
this file across reruns to retain history; deleting it resets estimates.
Copy time and interactive installer waits are not part of this estimate.

Validation performed here: PowerShell syntax-tree comparison against .47,
including a clean parse after normalizing two pre-existing grammar limitations
for PowerShell's valid `1MB` numeric suffix; INI key coverage; preflight ordering
before modifying upgrade actions; startup-menu dividers preserved; and all six
ZIP entries verified for version, ASCII and CRLF. Windows PowerShell runtime,
SAL compilation, and end-to-end installer tests remain to be run on Windows.


### Unattended setting name

The INI key is now `unattended=true|false`. The settings menu and console use
this name. `unattended=true` automatically answers Yes to upgrade confirmations,
skips the launcher menu/intro and the final close prompt, but tse.exe itself
still requires interaction if launched. Default: false.

Only unattended is recognized. If absent or blank, unattended mode is off.
The supplied INI contains unattended=false.

## Version 1.0.0.0.53: built-in help

Choose Help in the startup menu or settings menu. The topic menu covers
getting started, directories/personal files, confirmations/unattended mode,
validation, compilation estimates, installer/DAT restoration and final startup
and logs. Selecting a topic displays a TSE Warn dialog and returns to Help.
Choose Return or Escape to return to the previous menu. Settings edits remain
in memory while viewing Help.

Run `tseupgrade help` (or `tseupgrade /?`) to open help directly, including
when unattended=true or when tseupgrade.ini is missing. Help does not launch
PowerShell or execute upgrade steps. The standard startup menu now has four
options: Run upgrade, Settings, Help and Cancel, separated by dividers.


While the TSEUPGRADE macro is active, press <CtrlAltShift F1> to open its
built-in Help menu. Both Help menu labels display the shortcut. The key is
enabled on macro entry and disabled on return, including early-return paths;
it does not install a permanent editor-wide binding.


## Version 1.0.0.0.53: one unattended parameter

unattended is the only accepted setting for automatic Yes confirmations.
No compatibility alias or fallback is supported. Use unattended=true or
unattended=false. Unknown INI keys produce the usual validation warning and
have no effect. Review existing INIs and retain only the documented settings.


## Version 1.0.0.0.53: structured main log includes INI errors

Every main-log message uses:

    YYYY-MM-DD HH:MM:SS ERROR|WARN|INFO [type] message

Examples:

    2026-10-31 20:05:00 ERROR [INI] old_directory: directory not found
    2026-10-31 20:05:01 WARN [INI] unknown_key: Unknown setting; ignored.
    2026-10-31 20:05:02 INFO [UPGRADE] Upgrade steps finished.

The main log starts before INI reading/validation, so missing/invalid INI data,
all aggregated validation entries, caught failures and the final status are
saved even if validation prevents installation. The console uses the same
records. Compiler output uses [SC32]; validation uses [INI]. Multiline messages
are split and every line gets a timestamp, level and type.

The default unique main log is beside the package; TEMP is used if that folder
cannot be written. A valid configured log_file receives the early records and
becomes the main log before validation. Existing log files are never overwritten.
If log_file cannot be used, the error is recorded in the early main log and
validation stops with its path shown. A logging write failure is shown visibly.
The separate validation report uses the same line format. The main log no
longer uses PowerShell transcript headers. Compiler timing/history TSV files
remain tabular data and retain their existing format.

Checked PowerShell syntax, logging initialization order and packaged file
versions. Windows PowerShell runtime and SAL compilation remain to be tested.


## Version 1.0.0.0.53: startup menu hotkey notation

Startup labels now use R: Run upgrade, S: Settings, H: Help and C: Cancel.
The corresponding letter is the menu hotkey. Dividers and the Help shortcut
<CtrlAltShift F1> are retained.


## Version 1.0.0.0.53: separate personal-copy and compile confirmations

Personal files now have two independent [Y/n] confirmations:

1. Copy custom_macro_directory into NEW/custom_macros.
2. Recursively compile .s and .si sources already in NEW/custom_macros.

You may copy without compiling, or skip copying and compile an existing copy.
If the source setting is blank, copying is skipped but compilation is still
offered. If compilation is accepted, its destination must exist; the usual
error is logged if absent. Copy failure stops the upgrade before compilation.
Both choices and skipped steps are recorded in the main log.
With unattended=true, each confirmation is automatically answered Yes as before.
