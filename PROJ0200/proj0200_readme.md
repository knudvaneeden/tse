# PROJ0200 - 1.0.0.0.354

Updated: 2026-10-17 11:09:57

## Installation

1. Close TSE. Back up your existing PROJ0200 folder and personal settings.
2. Extract the complete ZIP into your PROJ0200 folder, keeping its subfolders.
3. Open a command prompt in that folder and compile the complete package:

   ```bat
   build.bat "F:\WORDPROC\tse32_v45024\sc32.exe"
   ```

   Use the compiler path matching your installed TSE. Wait for the build to
   finish successfully before continuing.
4. Start TSE. Choose **Macro > Execute** and enter:

   ```text
   F:\BBC\TAAL\PROJ0200\projstart.mac
   ```

   Adjust this path to your installation folder.
5. Create or open a project from the menu. Execute `projstart.mac` again
   whenever you want to reopen the Project menu.

## Things to know

- Keep the complete package together: macros, DLLs, INI, help files and helpers.
  Rebuild with `build.bat` after an update, then restart TSE.
- Preserve your personal `proj0200.ini` settings and saved project records
  when updating. Do not replace your settings blindly with the supplied defaults.
- A project record describes a collection of files. Keep separate backups of
  the actual source files; saving a project record does not back them up.
- Some archive, backup and other features use Windows PowerShell. Certain
  archive formats also need the configured external archive tools.
- PJL scripts use `.pjl`. Run them through **Run projects > Run scripts**.
  Script error logs are saved as `pjlYYYYMMDDHHMMSS.log` in the package folder.
- **Ctrl+Alt+Shift+G** returns to the latest project-search results.
- **View projects > View timelog** starts tracking on first use. Select it
  again to see updated results. Its logs are saved beside the package macros.
- The Windows clipboard viewer displays text. The named-clipboard viewer
  offers NAMECLIP clipboards and legacy A-Z TSE clipboards separately.

## HISTORY

## prioritize Import and Export

Import projects and Export projects now follow the divider after View projects. Another divider follows Export projects. Their actions and hotkeys are retained. OpenAI Codex (GPT-6). Rebuild and restart TSE.

## reduce resident macro size

Unused file-type section loading/saving and editing routines are excluded from proj.mac. They remain in pjfile.mac, where Project Settings uses them. Mouse actions and Ctrl S saving are retained. This addresses SAL error 2332 (Macro too long). OpenAI Codex (GPT-6). Rebuild with build.bat; corrected Windows compilation remains to be verified.

## source audit of mouse access

Viewer editing now saves with Ctrl S, with a clickable Ctrl-S/Left=Save label.

OpenAI Codex (GPT-6). Shared input prompts now have a right-click Accept/Cancel action menu (9 direct Ask/AskFilename call sites routed). Native Windows filename dialogs retain their own Open/Save/Cancel buttons.

Right-click action menus added to known file types, assigned files/directories, associated extensions, project picklists, autoload lists, README help and session file sorting/help. Native menus and message/confirmation buttons retain editor-provided mouse handling. Paused viewing/editing keeps the explicit status-label click handlers.

This is source-level verification, not full runtime mouse certification. Cross-file search/replace now exposes Yes/No/Only/Rest/Quit via right-click. Legacy contextual help and editor-default prompt behavior still require interactive review. Rebuild all macros and restart TSE; test prompt right-click menus and each custom list on Windows.

## show source before compiling

Run-files actions now activate or open each named source, go to its beginning, notify file-change hooks and refresh the whole display before invoking compile. The same shared routine applies to block source files. Existing buffer contents and unsaved edits are retained. The original document is refreshed after the run loop. OpenAI Codex (GPT-6). Rebuild and restart TSE; source ordering and ZIP checks passed, SAL compilation and interactive testing remain required.

## Enter/Left edit label

The viewing status label is Enter/Left=edit: Enter or left-click on that label enters editing. Its mouse hit target uses the identical text. OpenAI Codex (GPT-6). Rebuild and restart TSE.

## explicit click labels

Viewing displays Enter/Left=edit. Editing displays Alt-S/click=Save and Esc/click=Return to viewing. Each label uses left-click. Direct mouse hit ranges match the displayed labels. OpenAI Codex (GPT-6). Rebuild and restart TSE; mouse runtime testing remains required.

## direct status-line mouse actions

Clicks on Enter/Left=edit and the navigation labels are handled directly using their displayed column ranges on the status row. Editing displays clickable Alt-S/click=Save and Esc/click=Return to viewing labels, refreshed after editor commands. This replaces reliance on footer/internal hotspots for plain status text. OpenAI Codex (GPT-6). Rebuild and restart TSE. Source and archive checks passed; SAL compilation and mouse testing remain required.

## mouse entry into editing

The viewing footer now has clickable Previous, Next, Edit and Stop actions. Click Edit or Ctrl-left-click on the document to enter editing. Ordinary left-click on the page still means previous. Enter also enters editing. Existing editing Save and Return footer controls are retained. OpenAI Codex (GPT-6). Rebuild and restart TSE; source and ZIP checks passed, SAL compilation and clickable-footer testing remain required.

## edit and save while viewing

Viewing: Tab/Left-click previous; Space/Right-click next; Enter edit; Esc/Center-click stop. Editing: normal TSE keys (Enter inserts a newline), Alt S saves, clickable footer Save saves, Escape or Center-click returns to navigation.

Leaving a changed edited file offers Save/Discard/Cancel. Cancel stays on the file. Discard restores the pre-view snapshot and its original changed flag, preserving edits that existed before the viewing step. Viewer-owned files are closed only when unchanged; already-open files remain open. Custom Save/Discard/Cancel uses native TSE buttons in both dialog styles.

OpenAI Codex (GPT-6). Rebuild and restart TSE. Source and archive checks passed; SAL compilation, normal editing and clickable footer behavior remain to be tested.

## Center-click terminology

Navigation labels and menu help now say Esc/Center-click=stop, matching the CenterBtn SAL key name. OpenAI Codex (GPT-6). Rebuild with build.bat and restart TSE.

## middle-button SAL key correction

The paused viewer uses CenterBtn for the middle mouse button, replacing the unrecognized MiddleBtn key name that caused error 2213. Previous/next/stop behavior and named-file viewer cleanup are retained. OpenAI Codex (GPT-6). Rebuild with build.bat and restart TSE; corrected compilation remains to be verified.

## named, non-editing file previews

The viewer uses EditFile rather than EditBuffer. EditBuffer inserted contents into an unnamed normal buffer, causing save prompts for an empty filename and preventing normal extension-based highlighting. Files opened solely by the viewer are closed after viewing (also before stopping). Already-open buffers, their contents and existing unsaved-change status are retained. No viewer save or content-edit commands are issued. Navigation from an earlier release is retained. OpenAI Codex (GPT-6). Rebuild and restart TSE; source checks passed, Windows compilation and runtime tests remain required.

## paused-view navigation and highlighting refresh

Tab/Left-click=previous; Enter/Space/Right-click=next; Esc/Center-click=stop. Previous on the first file stays there. Next on the last finishes. Full filenames (including extensions) are retained and shown after navigation instructions. Buffer switches notify the file-change hooks and request a full display refresh for syntax/header handlers; restoration also refreshes the original document. Rebuild and restart TSE. OpenAI Codex (GPT-6). Source and archive checks passed; SAL compilation and interactive highlighting/navigation checks remain required.

## Import menu hotkeys

Import project uses I; Import all projects uses A. Existing import actions are retained. OpenAI Codex (GPT-6). Rebuild with build.bat and restart TSE.

## View projects menu order and hotkeys

View current active project (V) and View all projects (A) appear first, followed by a divider. Paused file viewing follows: current project (C), all projects (P), TSE ring (R). OpenAI Codex (GPT-6). Rebuild with build.bat and restart TSE. Menu source and archive checks passed; SAL compilation remains required.

## desc= in createproject scripts

createproject accepts optional desc="Project description" after the name. It writes Description= in the project Info section, matching interactive project creation. Omitting desc or supplying an empty value stores an empty description. Duplicate desc parameters are rejected. Examples, PJL documentation and syntax highlighting are updated. The full PJL command line is still limited to 255 characters. OpenAI Codex (GPT-6). Rebuild with build.bat and restart TSE; source checks passed, Windows SAL compilation and runtime testing remain required.

## document both dialog-style values

The INI comments explicitly show dialogstyle=tse (native TSE, default) and dialogstyle=windows (Microsoft Windows). This is a documentation update. OpenAI Codex (GPT-6).

## session-wrapper compilation correction

The renamed session action procedure now ends with end PROCProjectMainActions, matching its declaration. The old end Main caused SAL error 2336. Dialog configuration and save-set-restore behavior are retained. OpenAI Codex (GPT-6). Rebuild the full package with build.bat and restart TSE. Source and archive checks passed; the corrected Windows build remains to be tested.

## scope and restore filename-dialog preference

The same dialogstyle setting now controls filename dialogs. At each package macro entry, Set(UseCommonDialogs, ...) saves the previous value and applies OFF for tse (default) or ON for windows. A wrapper restores the saved value after the actions return, including early returns or cancellation. The resident Project menu has its own wrapper, so reopening it applies and restores the setting while PROJ remains loaded.

Messages and confirmations continue using the shared dialog helper. Normal exit and cancellation restore the editor preference; forced editor termination cannot execute cleanup.

Rebuild with build.bat and restart TSE. OpenAI Codex (GPT-6). Source wrapper and archive checks passed; Windows SAL compilation and interactive checks remain required.

## configurable dialogs, native TSE by default

Set dialogstyle=tse in proj0200.ini for native TSE messages and standard confirmations. This is the default, including when the key is missing, empty or invalid. Set dialogstyle=windows for Windows standard message boxes. The setting is read when each message is shown, without changing global editor preferences.

Warning messages and standard OK/Yes-No/Yes-No-Cancel dialogs in the package's compiled macros share the helper. Return values retain TSE's 0=Cancel, 1=OK/Yes, 2=No convention. Custom-button dialogs, menus, lists and input prompts retain their TSE interface. Messages use SAL's 255-character string limit.

Rebuild the complete package with build.bat and restart TSE. OpenAI Codex (GPT-6). Source routing and archive integrity checked; SAL compilation and native/Windows runtime checks remain required.

## one project-description dialog

The description is displayed in one dialog titled "Project description", with the complete description as its message. The separate label-only dialog has been removed. OpenAI Codex (GPT-6). Rebuild with build.bat and restart TSE; SAL compilation and runtime testing remain required.

## clarify empty assignments

When no directories or filenames are assigned, the clickable action reads "Save assignments (empty list allowed)". With entries it reads "Save assignments". OpenAI Codex (GPT-6). Rebuild with build.bat and restart TSE; SAL compilation and runtime testing remain required.

## explicit Save and Cancel in Project Settings

Project Settings now has Save / Finish <Enter> and Cancel <Escape> rows. Select Save and press Enter, or click Save, to finish. Escape or clicking Cancel cancels. New creation defers disk saving and database registration until Save; cancellation restores the previous active project. Enter continues to activate the selected menu option, so select Save to finish.

Rebuild with build.bat and restart TSE. OpenAI Codex (GPT-6). Source and archive checks passed; SAL compilation and interactive keyboard/mouse checks remain required.

## project name before description

Creation asks for the project name first, then the optional description. Cancelling either prompt stops creation. Copy project offers its inherited description after the new name. Existing-project saves do not prompt again.

Rebuild with build.bat and restart TSE. OpenAI Codex (GPT-6); Windows SAL compilation and runtime testing remain required.

## optional project descriptions

Created by OpenAI Codex (GPT-6).

Create project now asks for an optional description (up to 255 characters). Enter accepts an empty description; Escape cancels creation and restores the previous project. Change projects > Edit project description edits and immediately saves the active project's description; an empty value removes the description. View projects > View current active project displays it.

The description is stored as Description= in the .pj file's [Info] section. Older projects default to an empty description. Save, reopen, switch, rename and copy preserve the description; a new project starts empty. Failed or cancelled switching restores the previous description.

Run build.bat with your matching sc32.exe, then restart TSE. Included .mac files are inherited from the previous package and MUST be rebuilt. Windows SAL compilation and interactive testing could not be run here.

## portable PowerShell lookup restored

SVN, Git, backup and scope helpers again invoke powershell.exe through PATH, without an absolute executable path. Restarting TCC restored executable lookup on the user's system, so the full-path change has been removed. The direct current-file/ring manifest and paused file viewing options are retained.

Rebuild with build.bat and restart TSE. Executable invocation and archive integrity checks passed; Windows SAL compilation and runtime verification remain required.

## direct TSE-ring scope list

Subversion upload of all files in the TSE ring now builds the exact-file manifest directly in SAL. This avoids the failing PowerShell scope-manifest preparation shown in the user screenshot. The change also applies to current-file and ring list-only operations in the transfer and reload workers. Scanned project scopes and archive searches retain the existing archive helper.

The actual SVN upload helper still uses PowerShell and the configured svn executable. Named ring buffers, per-file notes and configured unsaved-content snapshots retain their existing behavior. Unnamed buffers have no repository filename and are excluded from SVN upload.

Rebuild the complete package and restart TSE. Native manifest integration, unchanged F/D record format and archive integrity were checked. Windows SAL compilation and actual upload still need user verification; the screenshot alone does not identify the original PowerShell launch failure.

## Space key syntax correction

The pause handler uses ASCII character code 32 for Space because SAL does not recognize the key name <Space>. Keyboard and mouse actions are retained. This correction requires compilation and interactive testing in TSE.

## SAL reserved-keyword correction

Renamed the view-pause input variable from the reserved SAL keyword keyPressed to inputKey. The user compilation confirmed the preceding build stages succeeded; the corrected transfer worker still needs compilation and interactive keyboard/mouse testing.

## view files with pause

Under Alt+[ > V: View projects, choose:

- P: View all files in the current project - with pause
- F: View all files in all projects - with pause
- T: View all files in the TSE ring - with pause

Enter, Space or left-click advances to the next file. Escape or right-click stops. Arrow keys, Page Up/Page Down and the mouse wheel scroll during each pause; Ctrl+Home/End moves to the start/end. Other keys do not edit documents.

Current/all project scopes use a snapshot of project membership and show duplicate paths only once, in alphabetical order. All projects includes the active in-memory project and registered saved projects. The TSE ring scope follows the initial ring order and includes unnamed buffers and unsaved contents. Already open project files show their current buffer contents. Closed project files are opened and remain in the ring. Missing/unreadable files are skipped and counted in the final message.

Completion or cancellation restores the starting buffer, cursor position and marked block. Scrolling positions in already open files are restored after each pause. Project membership and source contents are retained.

Rebuild the complete package with build.bat and restart TSE. Source integration and archive integrity were checked; Windows SAL compilation and keyboard/mouse execution still require verification on the user's machine.

# PROJ v2.00 for TSE

Prepared: **2026-10-11 22:34**  
Original author: **Chris Antos**  
Package update: **OpenAI Codex (GPT-6)**

## Separate Visustin block and file options

Draw projects now offers `&B: Draw a Visustin flow chart diagram of the current block` and `&V: Draw a Visustin flow chart diagram of the current file`. B requires a marked block in the current buffer. V exports the entire current buffer, including unsaved edits, whether or not a block is marked. Both preserve the original selection and cursor position, retain the source extension, and use the existing Visustin language prompt and temporary-file cleanup.

Rebuild using `build.bat` before testing. Static source checks passed; Windows SAL compilation and Visustin execution require testing on Windows.

## Click to save assignments

Create project path list includes clickable Add files/directories and Save assignments rows. Enter also saves. Neither action row is persisted, editable or removable. Run files is renamed Run block or files, retaining F.

## Run menu hotkeys

Main menu: R = Run projects. Its submenu: F = Run files; R = Run scripts.

## Preserve wildcard paths in assigned-path view

Removed ExpandPath from the assigned-path display so directory entries ending in wildcards remain visible. Drive prefixes are added without resolving wildcards.

## Full assigned paths

The read-only assigned-path view expands paths before adding scan/exclusion labels. Rooted paths without a drive use the saved project drive; UNC paths retain their server/share prefix.

## View assigned project paths

Project settings > V: View assigned directories or files to current project shows a read-only list of explicit assignments, with recursive scans and excluded paths labelled.

## Preserve working directory

Open/Change project no longer schedules an idle-time change to the saved project directory. The PJL runner restores its original directory on cancellation, success or script error.

## PJL parameter highlighting

Moved name, file, dir, scan, yes and no from KeyWords2 to KeyWords3. KeyWords2 is reserved for punctuation.

## Project Language interpreter

Run projects > Run scripts now runs .pjl files. Includes a CASE dispatcher, create/open/change/close/save project commands, project-name export, example.pjl and pjl.txt highlighting. See pjl_readme.md for syntax and limits. Run files retains hotkey R.

## Shorter Run files labels

Removed standalone a/the from all run-action labels.

## Create and Run menus

E = Create project replaces New project. Run projects now contains R = Run files (all existing run actions) and R = Run scripts. The .pjl interpreter and highlighting are the next development step; the Run scripts entry explicitly identifies that planned status.

## Offer to close before deleting

Deleting the active project offers to close it first. Yes uses the normal Close project behavior, then continues to the separate deletion confirmation. No cancels. If closing is cancelled or fails, deletion stops. Source files are kept.

## Change and Get projects hotkeys

Change projects: C = Change project. Get projects: R = Get all project names; N = Get all filenames in the TSE ring.

## Project picker filename cancellation

Escape explicitly cancels the saved-project list. Cancelling its alternate filename prompt now discards the history suggestion, so Copy, Change and Delete do not continue with that unaccepted filename or show a project-file-not-found warning.

## Shared menu cancellation handling

Cancelled named text/filename prompts and project-name/filename lists now request a return to the main project menu. Cancelling a saved-project picker no longer opens the alternate filename prompt. Submenus retain their existing parent-menu navigation. Runtime verification in TSE is still required.

## Cancel Copy project

Escape in the source-project picker or destination filename prompt returns to the main project menu. A cancelled save no longer reports successful creation or opens project settings; the source project name and filename are restored.

## Cancel New project filename

Escape at the new-project filename prompt clears the unaccepted suggested name, stops creation, and returns to the main project menu. No Add files screen or successful creation message follows.

## View projects hotkeys

In View projects, C selects View current active project and A selects View all projects.

## Click to add project files or directories

The New project path list displays a clickable [ Add files or directories... ] row at its end. Click it or press Ins to open the existing add prompt. The action row is never saved as a path.

## Cancel Open project returns to the main menu

Escape in the Open/Change project picker returns to the main project menu. Escape in the main menu still returns to the editor.

## Mouse confirmation for saved lists

In project-name and filename lists, click a list row or press Enter to open the save filename prompt. Scrollbars and the close button retain their normal behavior. The entire list is saved.

## Get projects menu divider

A divider separates Get all project names from the filename-list options.

## All-project name-list scope correction

The project-name menu now requests scope 3 (all registered projects), matching the transfer worker scope used to retrieve its request buffer. The previous scope 0 caused the worker to receive no saved-project records. Imported project names are included, duplicate names are retained, and Enter offers saving the list.

## Project-name worker compiler correction

Replaced the unavailable RemoveQuotes helper with local removal of paired surrounding double quotes. Duplicate names remain preserved and the list can be saved to a file.

## Get all project names

Get projects > N: Get all project names lists all registered saved projects plus the active in-memory project. Names are sorted and duplicate names are retained in both the displayed list and saved file. Press Enter to choose a file and save the list; Escape returns. The save destination has its own named history. Open destination files are protected and existing files require overwrite confirmation. Projects are not switched or saved by this action.

## Calculator error logs and clipboard

Calculator failures retain a .log file and offer to copy its full filename to the Microsoft Windows clipboard. If PowerShell produces no marked result, the log contains the generated expression, Dos return, and script/batch paths as well as captured output. Failed .ps1 and .bat files are retained beside the macros. Two final empty input lines complete PowerShell's multiline stdin block, addressing a possible cause of empty output. Runtime verification remains required.

## Calculate projects hotkey

Press 5 in the Project menu to open Calculate projects. Its submenu still uses C for Floating point calculator.

## Calculator PowerShell integration

The calculator retains the supplied expression parser. Its private batch now invokes PowerShell synchronously using stdin (-Command -), and searches all output for the result marker. Failure messages include the PowerShell error when available and the diagnostic filename. Failed script, batch and output files remain beside the macros for inspection; successful runs clean up their private files. Test 1+sin(2)*cos(3), expecting approximately 0.0998023702644826. Windows runtime verification remains required.

## Browser help menu option

Choose Help > B: Read package help in browser to open the bundled proj0200_readme.html in your default browser. It uses the PROJ0200 installation directory and closes the Project menu before launching. Missing files or browser launch failures produce an explanatory message. Help > R retains the resizable wrapped TSE viewer. Rebuild with build.bat.

## Resizable README window

The README now opens in a window of 100 columns by 30 rows, limited to the available TSE screen. Press F4 to choose width and height; each value has a separate named history and is reused next time. Values are limited to at least 40 columns and 8 rows when the screen permits. Prose is rewrapped from the original file after resizing, while code and table lines retain horizontal scrolling. F4 changes the help window, not the outer Windows application window.

## Wrapped README navigation and display

Help > R opens a temporary wrapped README view using your editor's text and highlight colors. The Help entry now closes the outer Project menu after its submenu returns, allowing the deferred README action to run immediately. UpdateDisplay() refreshes the help buffer after loading/wrapping and before displaying it. The original README is unchanged.

Navigation: Up/Down and PgUp/PgDn scroll; F3 searches; Alt+F3 finds the next match; Enter opens a link on the selected line; F2 lists links; Alt+Left goes back to the previous help document; Escape closes the viewer. The viewer title shows the action keys. Code blocks, tables, headings and links are not wrapped. Margin and menu-color settings are restored.

## README menu handoff correction

Help > R now schedules the README to open after the Project menu loop and cleanup finish. This prevents the menu from immediately reopening over the README. The separate projreadme.mac is compiled and copied by build.bat; if missing, the launcher displays a rebuild message.

## Guided Mermaid steps

Creating a Mermaid prompt now pauses at each manual ChatGPT step. Press OK when ready to continue: paste the prompt, attach the generated source ZIP (its exact location is displayed), send and wait for the reply, copy the Mermaid source, then return to Draw projects > Save returned Mermaid script from Windows clipboard. You can switch between TSE and ChatGPT while a step message is displayed.

The Save action pauses before reading the clipboard, after saving the script and before opening it, and after opening it with instructions to run the configured Mermaid compiler. Close the final message before invoking the compiler. The default output is ddd.mmd beside the PROJ0200 macros; existing filename history can override that default. No machine-specific output path is hardcoded.

## Normal editor for package help

Help > R uses EditFile() to open proj0200_readme.md as a normal file. Your editor colors, keys and Markdown highlighting apply automatically. The custom list viewer and its temporary wrapping are removed. Opening the file does not change its contents. Rebuild with build.bat.

## Mermaid menu descriptions

Both Mermaid creation options now end with `(this needs ChatGPT AI)` to make the manual ChatGPT step explicit.

## Drawing menu grouping

The three Mermaid options are grouped together, followed by a menu divider and the Visustin option. The user confirmed that an earlier release transfers the marked block to Visustin and displays a flowchart.

## Original working Visustin block-save sequence

The supplied `runblclj.s` confirms a direct `SaveBlock(QuotePath(filename))` between `PushBlock()` and `PopBlock()`. PROJ's Visustin worker now uses this sequence rather than copying into another buffer. The temporary filename still retains the current source extension and is removed after Visustin is closed and cleanup is confirmed.

PROJ now preserves the block while its WhenLoaded initialization runs, and preserves both position and block around startup preparation and first-run handling before opening the Project menu. This extends protection to the earlier INI/temp-buffer work that executes before the recorded menu-entry diagnostic. Menu and picker preservation remain in place. Static checks passed; the block-detection fix and native SaveBlock behavior still require Windows testing.

## Preserve selection before the main menu

The user's diagnostic showed the correct source file but `BlockId=0` and block type zero at Visustin entry. The Project menu now saves the block before it opens. Before the deferred Draw action it explicitly returns to the captured source buffer and restores that saved block. When Draw returns, the block is saved again while the Project menu loops, then restored on final menu exit. The Draw picker's own preservation remains in place.

If detection still fails, the warning also reports the block type recorded before the Project menu opened. This distinguishes a selection already absent at menu entry from one lost later. The source is not reopened with EditFile or saved to disk. Static control-flow and ZIP checks passed; Windows testing remains necessary.

## Visustin block-type and picker preservation

The Visustin check now explicitly uses `isBlockInCurrFile() == 0` to reject an absent selection. Nonzero values represent character, line or column block types. The Draw worker wraps its picker in `PushPosition()` / `PushBlock()` and restores the source buffer, then calls `PopBlock()` / `PopPosition()` before dispatching the action. The main Project-menu deferred handoff remains in place.

If detection still fails, the warning reports the current buffer ID, `BlockId` and the result of `isBlockMarked()` so the next test identifies the actual block context. The marked source is still copied without saving its original file. Static routing and package checks passed; this correction requires Windows compilation and runtime testing.

## Visustin marked-block menu handoff

Draw projects now schedules its worker after the main Project menu returns, matching the established Session tools handoff. This avoids checking the source block while the outer menu is still active. The Draw picker also returns before invoking Visustin. Mark the block in the source file, open Draw projects, then choose V. On leaving Draw, the Project menu is shown again; Escape returns to editing.

an earlier release's complete package was successfully compiled by the user. This handoff correction passed static routing and packaging checks; detection and preservation of the marked block still require a Windows test.

## Drawing-menu compiler correction

The diagram-type picker and Draw worker menu now use procedure calls for selection actions instead of inline assignments, with explicit close-after flags. Diagram selection and the Draw menu loop remain the same. an earlier release successfully compiled the main macro, README viewer, Visustin worker, tooltip worker and scoped search/reload worker with SAL Compiler V4.50.rc23. The drawing worker and remainder of the full build still need confirmation.

## README viewer key correction

The Markdown viewer's Back key now uses SAL's `<Alt CursorLeft>` key name rather than the invalid `<Alt Left>`. The physical shortcut remains Alt+Left Arrow. an earlier release's main `proj.mac` compiled successfully with SAL Compiler V4.50.rc23; this confirms the main macro size error has been resolved. The remaining full build and worker execution still require testing.

## Scoped search and reload worker

Scoped search, archive-result handling and disk reload operations now run in the separate `projscope.mac`. Only project/ring request collection, menu entries and the launch bridge remain in `proj.mac`. This provides another substantial size reduction after an earlier release still exceeded the SAL macro limit. The Draw and mouse-tooltip workers remain separate too.

The worker receives the existing scope request buffer; it does not switch projects or invent another directory scope. Search histories and reload confirmation rules are unchanged. Request buffers are cleaned up when prompts are cancelled and when current-buffer searching bypasses archive handling. `build.bat` compiles and copies the new worker. Recompile the full package; SAL compilation and Windows behavior still require testing.

## Additional main-macro size reduction

The complete mouse-hover tooltip implementation now resides in the separately compiled `projtooltip.mac`. It registers its own idle and after-command hooks when PROJ starts and is purged before PROJ releases its DLL state. The tooltip worker reads the same project and CTags state from ProjDLL. F12 navigation remains in the main macro. The Draw menu remains in `projdraw.mac`.

This removes the 300-plus-line tooltip implementation from `proj.mac`, providing a larger reduction after an earlier release still reported compiler error 2332. `build.bat` compiles and copies the new worker. Recompile the entire package before running it. Static dependency and package checks passed; the actual compiled size and Windows tooltip behavior require testing on your machine.

## Main macro size correction

The Draw projects submenu now runs inside `projdraw.mac` instead of being compiled into `proj.mac`. This removes its menu strings and action code from the main macro after compiler error 2332 (Macro too long). Mermaid and Visustin options remain available; after an action the Draw menu remains open until Escape. Missing workers produce an explanatory message.

Recompile the complete package with `build.bat`. Source synchronization, menu routing and ZIP integrity checks passed. The actual SAL macro size and Windows execution still need verification with your compiler.

## Visustin marked-block flowcharts

Mark a block in a named source file, then choose **Draw projects > V: Draw a Visustin flow chart diagram of the current file**. Enter the Visustin language switch, such as `/C`, `/CPP`, `/JAVA` or `/PYTHON`; this input has its own named history. The marked block is copied to a unique temporary file beside the installation, retaining the current extension. The original file, unsaved contents, cursor and block are retained.

Configure `FNStringGetProgramVisustinS` (default `c:\PROGRA~2\Visustin\visustin.exe`), `FNStringGetVisustinTseListS` (default bundled `visustintselist.txt`), and `VisustinParameters` (default `{language} /DRAW {file}`) in `proj0200.ini`. The list is the supplied reference document, not an executable language configuration. Its older SAL tests report failures; SAL flowchart support is not promised. Both executable and temporary source are converted to Windows short filenames. If 8.3 names are unavailable, the helper reports the failure in `proj0200_visustin_log.txt`.

The launch waits for the process. Afterwards TSE additionally asks you to close Visustin before confirming cleanup, covering an existing Visustin instance receiving the file. Confirm only after closing Visustin: the temporary source is then deleted. A crash or forced shutdown can leave the temporary file for manual cleanup. Relative configuration paths resolve from the installation. No clipboard changes or saving of the original source are required.

Recompile with `build.bat`; the separate `projvisustin.mac` keeps the main macro below its size limit. Static packaging checks passed; Windows SAL compilation and Visustin execution remain to be tested.

## Optional source ZIP for Mermaid drawing

Both **Draw projects > Create a Mermaid diagram of the current file** and **Create a Mermaid diagram of the current project** now offer to create an additional ZIP attachment for ChatGPT. Answer **Yes**, then choose its output filename. The archive contains the current file, or the exact current-project file list. It does not scan parent directories or unrelated directories.

The ZIP preserves original directory structure beneath `files/`, using drive prefixes or `UNC/` so equal basenames remain distinct. `PROJ0200_FILES.txt` maps each ZIP entry to its original filename and identifies editor snapshots. Current-file contents and unsaved open project documents are snapshotted without saving the originals; other project files are read from disk. The ZIP includes existing binary project members too, while the prompt's inline source text continues to skip known binary extensions. Missing/unreadable files are reported in the manifest and `proj0200_draw_zip_log.txt`.

The generated prompt explicitly refers to the ZIP when creation succeeds. Attach that ZIP together with the prompt on the ChatGPT website when you are ready; nothing is uploaded automatically. Then use the existing **Save returned Mermaid script from Windows clipboard...** option to save and open the `.mmd` reply.

ZIP creation uses Windows PowerShell and its built-in .NET ZIP support; no separate archiver executable is needed. The destination directory must exist. Existing ZIPs require overwrite confirmation; project source files, the prompt destination, and open TSE files are protected. Temporary editor snapshots and request files are removed after the operation. Cancelling the ZIP option continues with the prompt-only workflow.

The ZIP destination has its own named history (`PROJ0200:projdraw:sourcezip`). Recompile with `build.bat`. Package and archive-request checks passed; Windows PowerShell ZIP creation and TSE execution still need testing.

## Draw projects with Mermaid

Open **D: Draw projects >** and choose **F: Create a Mermaid diagram of the current file** or **P: Create a Mermaid diagram of the current project**. The type picker offers:

- Sequence diagram (initial default)
- Flowchart
- Class diagram
- State diagram
- Gantt chart
- Entity-relationship diagram

Choose where to save the generated ChatGPT prompt. The full prompt is also copied to the Windows clipboard. It includes the selected diagram type and source text: current unsaved buffer contents for open documents, disk contents for closed project files. Known binary types are skipped. Unreadable sources are identified as unavailable. The source files are retained and their existing marks and cursor positions are restored.

When ready, paste the prompt into [ChatGPT](https://chatgpt.com/) and ask it to generate the script. The package waits for this manual handoff; it does not submit source text or run an AI request automatically. For a large project, attach the saved prompt file instead of pasting it if the website's input limit is reached. Review the generated diagram's assumptions and interpretation of the source.

Copy the returned Mermaid code to the Windows clipboard, then choose **Draw projects > S: Save returned Mermaid script from Windows clipboard...**. Select an output filename; its extension is forced to `.mmd`. A surrounding `mermaid` Markdown fence is removed if present. The macro checks the diagram header, saves the script, and opens it in TSE. This header check is not a Mermaid syntax validator.

Run the script through your `.mmd` compiler rule, or **Run projects > Run the current file**. Add the saved `.mmd` file to project membership if desired. Rendering uses your configured Mermaid compiler, not the prompt builder. Sequence, class, state, and entity diagrams describe different aspects of a source; Gantt dates and durations are explicitly illustrative when the source does not contain scheduling information.

The type choice and output filenames use separate named histories. Existing output files require overwrite confirmation, and currently open output destinations are protected. **Session tools** now uses **2**, freeing **D** for drawing. Recompile with `build.bat`. Package checks passed; Windows SAL compilation and the complete handoff/rendering flow still need testing.

## Separate named input histories

The input-prompt audit found that the README search and calculator already used named histories, while other prompts still shared the editor history. Applicable `Ask()` and `AskFilename()` prompts now use **GetFreeHistory()** with a stable name for their input and restore **GetHistoryStr(historyId, 1)** before displaying the prompt.

This covers project names and paths, import/export locations, filename-list loading and saving, clipboard filenames, file-type and associated-extension inputs, search text and options, backup destinations, Subversion/Git directories and change messages, session snapshots, and help inputs. Each input retains its own previous answer. Before an input has history, its existing default remains available. Non-empty INI settings that bypass an input prompt continue to take precedence.

The shared implementation is `SRC/MAC/projhistory.si`. The prompt-to-history audit is included in `proj0200_histories.md`. Editor-owned file-opening history bookkeeping remains separate from these prompt histories. Recompile with `build.bat` and restart TSE. Package and prompt checks passed; Windows compilation and prompt-history behavior still need testing.

## Load filenames from a file

Under **Load projects >**, choose one of the two new options:

- **F: Load all filenames in the file into current project** adds exact file entries to the active project. It retains existing membership and does not open these files. Use **Save projects** to persist the changes; the picklist is rebuilt through the normal project file-list mechanism.
- **O: Load all filenames in the file into the TSE ring** opens the listed files and keeps documents already open, including unsaved changes. Project membership is unchanged.

Both options ask you for the filename of the text file containing the filenames to load. Use one filename per line, including paths if needed. Lists saved by **Get projects >** can be used directly. Blank lines are ignored, surrounding double quotes are accepted, and relative filenames are resolved against the list file's directory.

Only existing files are accepted; directories, missing files, and lines longer than SAL's 255-character limit are skipped and counted in the result message. There is no implicit directory scan, extension filtering, or closing of documents. Duplicate exact project entries and already-open ring files are skipped. The input-file prompt uses edit history.

Recompile with `build.bat`. Package and menu checks passed; compilation and runtime behavior still need testing in Windows TSE.

## Get filename lists

Open **3: Get projects >** and choose:

- **C: Get current filename**
- **P: Get all filenames in current project**
- **A: Get all filenames in all projects**
- **T: Get all filenames in the TSE ring**

The centered list shows one full filename per line. Press **Enter** to choose an arbitrary output filename and save the list as plain text, or **Escape** to return without saving. Existing destinations require overwrite confirmation; destinations already open in TSE are protected. The save prompt uses edit history.

Lists are sorted without changing filename case, and duplicate Windows paths are removed without regard to case. Current-project membership comes from the project picklist; other projects use the filenames stored in their saved `.pj` records. Closed source files are included for projects; unnamed and internal buffers are excluded from the ring list. Documents are never loaded, closed, saved, or reloaded by these options. If the current project list is still being built, wait or reload its file list before retrying.

Recompile using `build.bat` and restart TSE. Menu and package checks passed; Windows SAL compilation and runtime behavior still need testing.

## Floating point calculator

Choose **M: Calculate projects >**, then **C: Floating point calculator ...**. This integrates Knud van Eeden's supplied `getstemk.s` expression parser and evaluates the resulting mathematical expression with Windows PowerShell.

Enter, for example, `1+sin(2)*cos(3)`, `(1+2)*3`, `2^10`, or `sqrt(9)`. Trigonometric functions use radians. The result is displayed and copied to the Windows clipboard. The expression prompt has its own edit history (`getstemk:expression`); Escape cancels and returns to the project menu.

Run `build.bat` with your SAL compiler path to compile the separate `getstemk.mac` calculator. `powershell.exe` must be available through the Windows executable search path. The calculator waits for PowerShell, uses private temporary files beside the installed macro, and removes them afterward. Your documents are retained. The calculator no longer offers the original optional WolframAlpha browser launch.

Package structure and menu wiring were checked; SAL compilation and numerical behavior still need testing in TSE on Windows.

## Named search histories and Alt+F3

In the README help viewer, F3 starts Search and Alt+F3 finds the next match (replacing Shift+F3). The viewer shows both keys in its title. The prompts use separate histories allocated by GetFreeHistory("projreadme:searchtext") and GetFreeHistory("projreadme:searchoptions"). At viewer startup, GetHistoryStr(history, 1) restores each prompt's most recent value. Empty options default to i (ignore case). These dedicated histories replace the shared edit history for these two prompts, preventing the search text and options from mixing. Cancel returns to help without exiting TSE.

Rebuild and restart TSE. Viewer-specific keys are active only in the README help list. Source and ZIP checks passed; SAL compilation and interactive history behavior still need testing.


## Search in README help

The Markdown help viewer now offers F3: Search and Shift+F3: Search next. Search asks for text and options with edit history; i ignores case and x enables TSE regular expressions. F3 begins at the start of the displayed help document. Search next continues from the selected line/cursor and wraps to the beginning when necessary. Matching lines are selected in the read-only help list. A missing match shows a message and keeps the previous position. This searches the currently displayed help document only; link navigation and Escape behavior are retained.

Rebuild and restart TSE. Source structure and ZIP checks passed; SAL compilation and interactive search require testing on Windows.


## Help submenu and Markdown navigation

Help / F1 now opens a submenu: H keeps the existing project help, and R displays proj0200_readme.md in a read-only text list. Enter on a line offers its links; F2 offers links throughout the displayed document. Select a link and press Enter to open it. Alt+Left goes back through local document/heading navigation; Escape returns to the original editing file. Viewer keys are enabled only during the help list. Horizontal scrolling exposes long lines.

Supported links are inline Markdown `[label](target)` and bare/angle-bracket HTTP/HTTPS URLs. Web/mail links open in the associated Windows application. Local paths resolve relative to the current help document; .md/.txt files remain inside the viewer, other local files use their associated application. Heading anchors use lowercase headings with spaces changed to hyphens. Reference-style links, nested parentheses, percent-encoded paths and duplicate-heading anchors are not currently supported. This is text navigation, not an HTML renderer or mouse-clickable browser. Only the first 255 characters of each line can be parsed because of SAL's string limit.

The separately compiled projreadme.s worker is built and copied by build.bat. Rebuild and restart TSE. Source structure and ZIP integrity are checked; Windows SAL compilation and interactive navigation need testing.


## Reload projects under Load projects

Reload projects now appears inside Load projects, retaining hotkey P and the submenu indicator. Its reload-file-list and file-reload actions are unchanged. Open the main project menu, choose L: Load projects, then P: Reload projects. The former top-level Reload projects entry has been removed.

Menu placement, unique submenu hotkeys and ZIP integrity were checked. Rebuild and restart TSE to test this version.


## Display the loaded example immediately

All six example-loading options now call UpdateDisplay() immediately after EditFile() succeeds, so the newly loaded example is drawn immediately. Failed loads retain their explanatory warning. The user confirmed successful compilation of version ; this display change still needs testing in TSE.


## Built-in QuotePath fix

Removed the example worker's duplicate QuotePath procedure declaration. The worker now uses TSE SAL's built-in QuotePath. The user confirmed successful compilation of proj.mac and projbuffersearch.mac with SAL V4.50.rc23 in the preceding release, resolving the main macro size error. Compilation stopped at the example worker's reserved-keyword error; rebuild this version to verify the remaining workers and complete copying.


## Startup code moved out of the main macro

Startup-message settings and initial menu selection now run in the existing projexamples worker. The main macro receives the initial menu selection and keeps its project initialization and menu loop. The silent/showbeginmessage and New/Open Project settings retain their behavior. This removes another complete section of code from proj.mac after the compiler reached line 700 but still exceeded its size limit. No additional build target is needed.

Rebuild with build.bat and restart TSE. Source linkage and ZIP integrity were checked; SAL compilation remains to be confirmed in Windows.


## Directory-loader macro split

The directory enumeration and non-binary-file loader now run in projexamples.mac, alongside the example-file loader. The main project macro keeps only a small launcher. The worker reads the existing binary-extension exclusions beside the macros, asks for a directory with edit history, and retains the existing non-recursive loading behavior. This further reduces proj.mac after compiler error 2332 persisted in the previous release. The existing build script already compiles and copies the worker.

Rebuild all macros and restart TSE. ZIP and source structure checks passed. The Windows SAL compiler must still confirm that the main macro is now within its limit.


## Further main-macro size reduction

Current-buffer and TSE-ring searches now compile in projbuffersearch.s, alongside the separately compiled example loader. The main project macro calls these workers through small launchers. build.bat compiles and copies both workers. The search behavior and menu options remain the same. This removes additional search implementation code from proj.mac after the previous split still exceeded the older SAL compiler limit. The unused ringIndex declaration has also been removed from the moved function.

Rebuild all macros and restart TSE. Static structure and ZIP checks passed; compilation with the Windows SAL compiler still needs confirmation.


## Example-loader macro size fix

The example lookup and file-loading code now compiles separately as projexamples.s. The project menu invokes projexamples.mac through a small launcher, reducing the size of proj.mac. build.bat compiles and copies the new worker automatically. Rebuild all macros and restart TSE. This addresses the reported Macro too long error; SAL compilation remains to be confirmed on Windows.

COMASP.BAT locates its PowerShell helper beside itself through %~dp0COMASP.ps1; the helper is supplied in PROJ0200COMPILERS. The example loader uses its own macro directory for all supplied examples and does not depend on the working directory.


## Language example files

**Load projects >** now offers six example loaders: helloworld, compiler, compiler rule, error test, syntax highlight, and CTags. Select an option while editing a source file; its extension determines the matching example. For example, `.md` loads `helloworld.md`, `COMMARKDOWN.BAT`, `commarkdownbatcompilersetting_md.txt`, `errorstest.md`, `markdown.txt`, or `ddd.md`, respectively. Compiler BAT files and compiler-rule files also resolve through their associated source extension (for example COMMARKDOWN.BAT resolves as Markdown).

The five uploaded archives are unpacked beside CTAGSEXAMPLES into PROJ0200HELLOWORLD, PROJ0200COMPILERS, PROJ0200COMPILERSETTINGS, PROJ0200ERRORSMULTIPLE, and PROJ0200SYNTAXHIGHLIGHTS. Archive path prefixes are removed. Supplied files are included, including helper files, compiled syntax files, and nested archives. Machine-specific example paths in comments/documentation use an illustrative installation root; the BBC BASIC launcher now uses its own BAT directory via %~dp0. Their independent tool versions are retained. Loading an example opens it for editing; it does not install rules/highlights, run a compiler, generate CTags, or alter project membership. Existing documents remain open.

`proj0200_examples.txt` contains one extension/type/path mapping per line: `extension|type|relative filename`. Types 1 through 6 correspond to the menu order. Compiler mappings come from the supplied compiler-rule filenames; syntax files use explicit language mappings. Missing examples report a message and do not create an empty file. Source example extensions match exactly; for example an absent helloworld.sql is not silently replaced by helloworld.sqlmysql. The supplied COMTSE compiler rule has no corresponding COMTSE.BAT in the uploaded compiler archive.

Rebuild using `build.bat "path\to\sc32.exe"` and restart TSE. Package contents, mapping targets, menu hotkeys and ZIP integrity have been checked. SAL compilation and interactive behavior still need testing in TSE on Windows.


## Change projects hotkey

**Change projects** now uses **C** in the main menu. **Copy project...** uses **G** to avoid a duplicate C hotkey.


## Run projects and Change projects

**R: Run projects** contains ten options: marked block, current file, current project files, all projects, and TSE ring files, each with or without pause. Each invokes `compile "filename"`; your installed compile macro, extension rule and COM...BAT command determine compilation and execution. No language-specific compiler commands are duplicated. Install/configure those rules before using Run projects.

Block runs adapt `compblcb.s`: a block must be marked in the current file. The block is copied without changing the clipboard to a uniquely named source file beside the macros, preserving the current language extension, then passed to compile. The generated file stays on disk for diagnostics and can be removed later. The block must be independently compilable; it does not automatically include surrounding declarations. The original file and block are retained.

File runs pass existing on-disk filenames. Save changes before running if the compiler needs the latest content; any saving, prompts or editor changes performed by your compile macro remain that macro's behavior. Project scopes use project membership and known file types; ring scope uses open named normal documents only. Source files are not closed by the runner. Each compile invocation owns its diagnostics; this version does not combine diagnostics from separate runs.

With pause asks Continue after each compile call; No stops further calls. Without pause adds no such prompt. PAUSE commands inside COM...BAT files or prompts inside compile are still controlled by those external tools. Compile macros that launch asynchronous commands may return before those commands finish.

**C: Change projects** now contains **Change project...** and **Rename project...**. Their existing actions and help text are retained.


## Delete projects hotkey

**Delete projects** now uses **J** in the main menu. **Session tools** uses **D** to keep main menu hotkeys unique. Submenu actions are unchanged.


## Automatic Subversion ring-upload hotkey

**Upload all files in the TSE ring to Subversion - automatic** now uses **S** in the Subversion submenu. Its upload behavior is unchanged. The automatic Git ring upload still uses U.


## File version control hotkey

**File Version Control of projects** now uses **F** in the main menu. Subversion and Git submenu actions are unchanged.


## Git ring upload options

**File Version Control of projects > Git options** now includes **N: Upload all files in the TSE ring to Git - with notes...** and **U: Upload all files in the TSE ring to Git - automatic**. With notes confirms each named open document and asks for its change notes. Automatic uses one shared configured change message without per-file questions; if empty, Ask requests the message once. Both use the existing Git executable, working directory, push and unsaved-content settings. Temporary and unnamed buffers are excluded, and project directories are not scanned. Current-file automatic upload now uses **F** to keep submenu hotkeys unique.


## Subversion ring upload options

Both ring uploads now appear under **File Version Control of projects > Subversion options**: **N: Upload all files in the TSE ring to Subversion - with notes...** and **U: Upload all files in the TSE ring to Subversion - automatic**. With notes retains per-file confirmation and notes. Automatic uploads the collected named open documents without per-file questions, using the configured shared change message; if that message is empty, Ask requests it once. Current-file automatic upload now uses **F** to avoid a duplicate N hotkey. Both options use the existing Subversion settings and unsaved-content snapshot policy.


## Search the TSE ring

**Search projects > A: Search in all files in the TSE ring** searches the current contents of normal open buffers, including unsaved edits and unnamed documents. Temporary buffers are excluded. Search text and i/x options use edit history. Results show filename, line, column and matching text. It does not scan project directories, extract archive files or load/close source documents. Existing cursor positions and marked blocks are restored. The all-projects archive search now uses **G** to avoid a duplicate A hotkey.


## Backup hotkey

**Backup projects** now uses **B** in the main menu. **Clipboards** uses **K** to keep the main menu hotkeys unique.


## Backup the TSE ring

**Backup projects > R: Backup all files in the TSE ring** backs up normal named documents already open in TSE, independent of project membership. Temporary and unnamed buffers are excluded. It uses the existing destination list, ordinary-copy/ZIP mode, ZIP executable and command settings. Unsaved-content handling follows `backupsnapshotunsaved`; original documents remain open and are not saved or closed by this action. No additional project directories are scanned.


## Load directory files into the ring

**Load projects > N: Load all non-binary files from a given directory into the TSE ring** adapts `loadfifa.s`. Ask offers the current directory and edit history. Only that directory is scanned, without subdirectories. Files with extensions listed in `proj0200_binarytypes.txt` are excluded; all other extensions, including those outside Known file types, are eligible. This is an extension-based filter, not a binary-content detector. Existing documents and unsaved edits remain open, and project membership does not change. No files are deleted or saved. The operation stops without loading files if the binary exclusion list cannot be read.


## Delete projects submenu

**D: Delete projects** contains **D: Delete project...** and **N: Delete all saved files in the TSE ring without asking**. Delete project retains its existing confirmation and removes a project record without deleting source files. The ring option adapts the supplied `remofibc.s`: it unloads saved documents from the editor ring without per-file questions, while retaining the current document, modified/unsaved documents and unnamed buffers. Disk files and project membership remain unchanged. A completion summary reports the files closed. It uses the package implementation and does not require an external unload macro or add the attachment's F12 binding.


## Subversion upload of the editor ring

**File Version Control of projects > N: Upload all files in the TSE ring to Subversion - with notes...** uses the ring-walking approach from the supplied `savefifa.s`. It collects named normal documents already open in TSE, independent of project membership, without scanning project directories or loading other files. Temporary and unnamed buffers are excluded. For each collected file, YesNo asks whether to upload it; accepted files prompt for change notes with edit history. The existing Subversion executable, working directory and unsaved-content snapshot settings in `proj0200.ini` apply. Original documents remain open and their contents are not saved or closed by this action. This integrated option does not require the external updafisc macro.


## Load and reload menu order

**P: Reload projects** now appears directly below **L: Load projects** in the main menu. Their hotkeys and submenu actions are unchanged.


## Change project

**G: Change project...** switches the active project to one selected project at a time. Open documents and unsaved edits are retained. The singular label replaces Change projects.


## Reload file list

**F: Reload file list** is now inside **P: Reload projects**, above the file reload operations. Its existing file-list action and active-project requirement are retained. The main menu now displays **C: Copy project...**.


## Load projects submenu

The main menu contains **L: Load projects**, with **Load all files in current project** inside its submenu. Its existing action is unchanged. The other main menu labels now read **View projects**, **Import projects**, **Export projects**, and **Close projects**.


## Main menu order

**Close Projects** now appears directly below **Rename project**. Its Z hotkey and submenu actions are unchanged.


## Project menu labels

**Reload projects** uses **P**. **Project settings** uses **Y** to keep the hotkeys unique. The submenu entries use plural **View Projects**, **Import Projects**, and **Export Projects**.


## Main menu labels and hotkeys

The main menu now shows **Reload projects**, **S: Search projects**, **Z: Close projects**, and **C: Copy project**. **Save projects** uses **A** to avoid a duplicate S hotkey. Reload projects retains the existing refresh actions.


## Project submenus

The main menu groups project operations under **View Project**, **Close Project**, **Import Project**, and **Export Project**. Each entry shows the submenu arrow. Their existing actions and help descriptions are retained. Import all projects uses **I** inside the Import Project submenu; import one project uses **M**. Closing saved files keeps unsaved files and project membership. Export copies project records, not source files.


## Known file types initialization — version 

New projects first read the editable `proj0200_filetypes.txt` beside the installed macros. If that read fails, they now load the complete bundled default extension list directly into the types buffer, rather than issuing the misleading “defaults not found” warning and leaving an empty list. The external defaults file remains included and can still be customized. A failed read uses built-in defaults, not unread customizations.

Static checks confirm that the fallback contains every extension from the supplied defaults file. Rebuild and restart TSE; Windows runtime verification remains required.

## Reject nonexistent project paths — version 

Adding a scan directory or exact filename with Insert now checks that it exists before inserting it. A nonexistent path produces a warning and leaves the project path list unchanged. Editing an entry uses the same check and preserves the original entry when the replacement does not exist. Existing saved paths are not automatically removed; remove unwanted entries explicitly in project settings.

Rebuild with `build.bat` and restart TSE. Static checks confirm validation precedes insertion or deletion; Windows compilation/runtime testing remain necessary. Test by inserting a nonexistent directory, then saving/exporting the project and verifying it is absent from `[Paths]`.

## Browser output-file correction — version 

Fixed the reported Subversion browser startup warning: an unnamed temporary buffer was incorrectly saved using its empty current filename. Both Subversion and Git browsers now save to their explicit output filenames. Rebuild the complete package and restart TSE. Static checks confirm both initialization routines use the explicit path; Windows runtime verification remains necessary.

## Bundled Git browser — version 

The supplied **git.s** by **Knud van Eeden**, adapted from Carlo Hogeveen's SVN browser, is now bundled in `SRC/MAC`. `build.bat` compiles it as the ninth entry macro and copies `git.s` and `git.mac` to the installation directory. **Git options > R: Browse Git repository** now defaults to `gitbrowsermacro=git.mac`; a configured external macro is still supported.

The bundled browser reads `gitexe`, `gitbash` (empty locates Bash beside Git), `gitworkingdirectory`, `gitbrowserlocation` (empty uses the working directory), and `gitcompareexe` from `proj0200.ini`. It asks for the working directory using `_EDIT_HISTORY_`; Windows drive paths are converted to Cygwin /cygdrive paths.

Enter browses directories/reads files; Enter from a read view opens an editable copy. F5 shows file history; selecting a commit opens that historical content. F8 shows information, F9 Git status/attributes information, F1 help. F10 marks the first version, then compares it with a second selection through the configured comparison executable. Escape returns from details or leaves the browser without exiting TSE. It does not bind F12. Temporary comparison extracts are kept for the comparison tool.

The browser retains its historical filename-case lookup logic. Repository browsing does not commit or push; the existing upload options handle those operations separately. Rebuild and restart TSE. Static build/configuration checks passed; Windows SAL compilation and Cygwin/Beyond Compare runtime testing remain required. Very long commands remain subject to SAL's 255-character string limit.

## Git browser launcher — version 

Open **Alt+[ > File Version Control of projects > Git options > R: Browse Git repository**. This implements the load-and-execute functionality of the supplied **runprcgj.s**, keeping the launched macro loaded for reuse. Existing Git upload options remain available.

Set `gitbrowsermacro=git\git` in `proj0200.ini`, or supply a full filename for your installed Git browser `.mac`. The package installation directory is checked first, followed by TSE's macro lookup. The supplied file is only a launcher: the browser implementation was supplied later and is bundled starting with an earlier release. If it cannot be loaded, PROJ0200 displays an explanatory warning. The external browser controls its own interface, Git executable configuration, and operations; PROJ0200's existing `gitexe` setting applies to its upload workflow.

The original launcher's F12 binding is omitted so CTags keeps F12. No additional build target is needed. Rebuild with `build.bat` and restart TSE. Static launcher/menu checks passed; compilation and testing with your external Git macro remain necessary.

## Subversion repository browser — version 

Adapted the supplied `svn.s` by **Carlo Hogeveen** into the separately compiled **projsvnbrowse.s**. Open **Alt+[ > File Version Control of projects > Subversion options > R: Browse Subversion repository**. Existing upload options remain available. `build.bat` now compiles eight entry macros.

The browser asks for a repository URL or checkout location, initially `svnbrowserlocation` or, when empty, `svnworkingdirectory`. It uses `svnexe`. Windows checkout paths are converted to /cygdrive paths for the Cygwin client. Credentials must already be available to Subversion; this browser does not implement a login dialog.

- Arrow keys / PageUp / PageDown / Home / End: select an entry.
- Enter: enter a directory or read a file; Enter again opens an editable extracted copy, without saving or committing it to the repository.
- F5: history; select a revision and press Enter to read it.
- F8: information. F9: properties. F1: browser help.
- F10: extract the first selected file/revision; choose another and press F10 to compare using `svncompareexe`. Extraction files remain in the temporary directory so the asynchronous comparison tool can read them.
- Escape: return from a detail view, or leave the browser and return to the editor/project menu. It never exits TSE.

Repository queries are read operations. Explicit editing opens a new copy; existing document contents are retained. The original macro's editor-exit action was removed and its file-node detection corrected. Static integration checks passed; Windows SAL compilation and Cygwin/Beyond Compare runtime testing are still required. SAL's 255-character strings limit very long repository URLs and commands.

## Active project menu label — version 

Renamed the main menu option to **A: View current active project**. Its hotkey and behavior remain unchanged: it displays the active project name and saved project filename. Rebuild with `build.bat`, then restart TSE.

## Import hotkeys — version 

The main project menu now uses **I: Import All projects** and **M: Import project**. Rebuild with `build.bat`, then restart TSE to activate the revised menu.

## Close all projects — version 

Open **Alt+[**, then **3: Close all projects**. Only one project can be active at a time, so this closes its runtime state using the same project-metadata autosave setting as **Close project**. Saved projects remain registered and can be reopened. Open documents, unsaved document edits, source files, and project membership are retained. The option is disabled when no project is active; the project menu remains available until Escape.

Recompile with `build.bat "path\to\sc32.exe"`, restart TSE, and run `projstart`. Static menu, dispatcher, and source checks passed; the new option still needs compilation and runtime testing on Windows.

Ordinary-copy and PKZIP backups of PROJ0200 were verified by the user in an earlier release: 26 files, one destination, zero failures in each mode, with a readable ZIP archive.

## Backing up the PROJ0200 installation

Backup now skips its own generated request/settings/status/log files, batch wrappers, temporary snapshots, and scope manifests/wrappers **when they are beside the installed helper**. These files can change or be removed during the backup operation. This fixes the reported missing `proj0200_backup_status.txt` failure when backing up the PROJ0200 project itself, and avoids copying the actively written log.

Skipped control files are listed in `proj0200_backup_log.txt`. Package source files, INI settings, project membership, and ordinary user files remain eligible under the existing membership rules. A same-named file outside the installation directory is not excluded. Actual missing user files still produce an error; they are not silently skipped.

an earlier release compiled successfully on the user's Windows SAL compiler. The ZIP backup correction was verified by the user. Keep your own `backupdirectories` value and `backupzip=true` when testing ZIP mode after rebuilding.

## SAL macro size correction

Uploads and backups now execute in the separately compiled **projtransfer.s / projtransfer.mac** worker. The main project macro retains the menu entries and passes the selected project membership to the worker without switching or saving projects. This reduces the compiled size of `proj.si`, addressing compiler error **2332: Macro too long** reported in an earlier release.

`build.bat` now compiles seven entry files, including `projtransfer.s`, and copies its macro into the installation directory. Rebuild the **complete package**, restart TSE, and run `projstart`. Upload/backup menu choices, INI settings, filenames, and logs are unchanged. The standalone worker is intended to run through the project menu.

Static include/dispatch/build checks passed; compilation with your Windows SAL compiler still needs confirmation.

## Backup projects

Open **Alt+[**, then **2: Backup projects**. The label has the ASCII decimal 16 submenu indicator.

- **C: Backup current file**
- **P: Backup all files in current project**
- **A: Backup all files in all projects**

Ordinary file copies are the default. Configure one or more destination directories in `proj0200.ini`, separated by semicolons. The default is empty, which requests destinations through `Ask()` with `_EDIT_HISTORY_`. Spaces around separators are ignored. A configured list is used directly. For example:

```ini
backupdirectories=D:\; H:\; E:\; Z:\
backupzip=false
backupsnapshotunsaved=true
backupzipexe=G:\UTILS\ZIP\PKWARE\pkzipc.exe
backupzipcommand=cd /d "{source}" && "{exe}" -add -dir "{archive}" "*"
```

The delivered package leaves `backupdirectories=` empty. Change it to your own destination list. Each destination receives the complete selected set of files; duplicate destination paths are processed once. Relative destination paths resolve beside the package; environment variables are expanded.

Each run gets a unique dated name such as `PROJ0200_current_project_20261005_130400_ab12cd34`. Copy mode creates that subdirectory at every destination. Source drive/directory names are retained inside it, so `F:\BBC\TAAL\COMADA.BAT` becomes `D:\PROJ0200_current_project_...\F\BBC\TAAL\COMADA.BAT`. UNC sources use an `UNC` prefix. Earlier backups are not overwritten. Set `backupzip=true` to create an identically named `.zip` file instead, with the same source-path layout inside it.

| Parameter | Purpose |
|---|---|
| `backupdirectories` | Semicolon-separated destinations; empty asks where |
| `backupzip` | `false`: ordinary copies; `true`: ZIP archives |
| `backupsnapshotunsaved` | `true`: include unsaved contents of named open buffers through temporary snapshots. `false`: disk contents |
| `backupzipexe` | ZIP executable path or command on PATH; default `G:\UTILS\ZIP\PKWARE\pkzipc.exe`. Only required for ZIP mode |
| `backupzipcommand` | Full command template; default is your PKZIP `-add -dir` command |

The command template must contain **`{exe}`**, **`{archive}`**, and **`{source}`**. They become the resolved executable, a temporary ZIP output filename, and the staged source directory. Quote the placeholders as shown. The default changes into the staged directory before running PKZIP, keeping archive paths relative. `%1` through `%9` from your batch wrapper are replaced here by the named placeholders and the staged-file wildcard. The tool must return exit code zero and create the requested ZIP, storing the **contents** of `{source}` at the archive root. The archive is checked for the requested file entries before distribution. Set `backupzipexe` to your full `pkzipc.exe` path or adapt both values for a different ZIP tool. Copy mode does not invoke the ZIP executable.

Project files need not be loaded in the ring. Closed files are read from disk; named open buffers with unsaved edits can be snapshotted. Source files are not saved, renamed, closed, or marked unchanged. No project switch or membership change occurs. The same filename/directory and Known file types membership rules used by project uploads apply to project backups; explicit filenames remain exact. All-project scope combines current membership with registered saved project records and processes duplicate sources once.

The helper first stages the selected files once, then copies that set to each destination. Missing source files stop the backup before destination writes. An unavailable destination is reported while the others are still attempted. A failed destination may contain an incomplete backup folder/file; check the log before relying on it. No incomplete destination is silently reported as successful.

Windows PowerShell is required. `proj0200_backup_log.txt` records the exact completed backup paths and failures; `proj0200_backup_status.txt` reports completion counts. Both are beside the installation. Temporary source snapshots and staging files are removed afterwards. Request/settings files and the batch wrapper remain for troubleshooting.

Recompile using `build.bat`, restart TSE, then run `projstart`. Package checks passed; SAL compilation, Windows copying, and execution of your configured ZIP tool still need testing on your machine.

## Git uploads

Open **Alt+[**, then **1: File Version Control of projects**, then **G: Git uploads**. **S: Subversion uploads** retains the existing SVN choices.

Git offers the same three scopes and two modes:

| Scope | With notes | Automatic |
|---|---|---|
| Current file | C | N |
| All files in current project | P | Q |
| All files in all projects | A | B |

**With notes** asks for each file's message and commits each selected destination separately. **Automatic** uses non-empty `gitmessage` directly for one combined commit; if empty, one `Ask()` requests the shared message. All prompts use `_EDIT_HISTORY_`. Cancelling a prompt cancels before the upload helper starts.

Files do not need to be loaded in the editor ring. Closed files use disk contents. With `gitsnapshotunsaved=true`, unsaved named open buffers upload temporary snapshots without saving, renaming, closing, or marking the originals unchanged. Project membership remains intact. Current-project membership follows the project's filename/directory and Known file types settings; all-project scope also reads registered saved projects.

| INI parameter | Default / purpose |
|---|---|
| `gitexe` | `G:\CYGWIN\bin\git.exe` |
| `gitworkingdirectory` | `G:\VERSIONCONTROL\GIT\DDD01\`; existing Git working tree |
| `gitcygpath` | Empty; detect `cygpath.exe` beside Cygwin Git |
| `gitbash` | Empty; detect `bash.exe` beside Cygwin Git |
| `gitlayout` | `flat`; copies basenames directly into the working directory. `paths` preserves source drive/directory names beneath it |
| `gitmessage` | `recompiled`; empty means ask once in automatic mode |
| `gitsnapshotunsaved` | `true`; false uploads disk contents |
| `gitpush` | `false`; true pushes after successful local commits |
| `gitremote` | `origin`; existing configured remote name |
| `gitbranch` | Empty; current branch is the remote destination. A value chooses a destination branch |

Matching basenames share a destination; the last selected source wins. Originals retain their locations. For example, `F:\BBC\TAAL\COMADA.BAT` is copied to `G:\VERSIONCONTROL\GIT\DDD01\COMADA.BAT` in flat mode.

The integration adapts the supplied **updaficd.s** copy/add/commit/optional-push workflow in `SRC/MAC/projgit.si`. Cygwin Git runs through **Bash --login**, with filenames passed as arguments and messages passed through a file. Windows paths are converted using that installation's `cygpath.exe`. The original macro is not loaded, so its F12 binding does not replace CTags navigation.

Only selected files are staged and committed; unrelated staged files are excluded using Git's `commit --only`. Unchanged selected files create no new commit. Git must support `add`/`commit --pathspec-from-file` and `--pathspec-file-nul`; unsupported clients are reported before destination copies. An existing repository and configured Git author/committer identity are required. The helper does not initialize repositories, rename branches, rewrite remotes, or force-push.

For remote upload, set `gitpush=true` and use the repository's existing credential setup. No password or token is stored in the package, generated script, or INI. The configured remote branch receives the current local branch history, including earlier unpushed commits. If pushing fails, completed local commits remain. With-notes mode can leave earlier files committed if a later operation fails; copied/staged changes can remain after an error.

Logs and status are saved beside the installation as `proj0200_git_log.txt` and `proj0200_git_status.txt`. Generated request/settings/target/message files and batch/Bash wrappers remain available for troubleshooting.

Local Git tests passed for selected-only commits, retaining unrelated staged changes, new files, names containing spaces or `@`, and unchanged-file detection. SAL compilation and the Windows/Cygwin wrapper still require testing on your machine. Recompile using `build.bat "path\to\sc32.exe"`, restart TSE, then run `projstart`.

**Subversion verification:** the automatic current-project upload in an earlier release succeeded with revision **8083**. A binary comparison confirmed `COMADA.BAT` matched its uploaded copy; unchanged files did not require another revision.

## Cygwin Subversion path correction

The SVN helper now supports the existing Cygwin client. Defaults are `svnexe=G:\CYGWIN\bin\svn.exe` and `svnworkingdirectory=G:\VERSIONCONTROL\SUBVERSION\W1\`.

The helper detects `cygwin1.dll` beside the resolved SVN executable and uses that installation's `cygpath.exe`. Windows paths are converted for `svn info`, `add`, `status`, the commit target-list entries, and the target-list/message-file arguments. Actual copying continues to use Windows paths. Optional repository verification converts the returned repository path back to Windows form. Native Windows SVN remains supported without conversion.

This corrects the reported failure where Cygwin interpreted `G:\VERSIONCONTROL\SUBVERSION\W1` as a relative pathname beneath `/cygdrive/f/BBC/TAAL/`. The log now records the resolved executable, converter, converted paths, and SVN commands. Keep `svnmessage=recompiled` to upload automatically without a message prompt; empty requests one shared message using `_EDIT_HISTORY_`.

`svncygpath=` can explicitly select a converter if automatic detection is unsuitable. See the [Cygwin cygpath documentation](https://cygwin.org/cygwin-ug-net/cygpath.html). Recompile with `build.bat`, restart TSE, and repeat the current-project automatic upload test. Windows/Cygwin execution remains to be verified on your machine.

## Local Subversion uploads

Open **Alt+[**, then **1: File Version Control of projects**. Choose the current file, all files in the current project, or all files in all projects. Each scope offers **with notes** and **automatic**.

- **With notes:** an `Ask()` requests a change message for each file. Each destination is committed separately.
- **Automatic:** a non-empty `svnmessage` from the INI (default `recompiled`) is used directly for every uploaded file in one commit. If it is empty, one `Ask()` requests the shared message. There are no individual message prompts.

All these prompts use `_EDIT_HISTORY_`. Escape or an empty message cancels before upload starts.

Configure `proj0200.ini`:

| Parameter | Default / purpose |
|---|---|
| `svnexe` | `G:\CYGWIN\bin\svn.exe`; executable path or command on PATH |
| `svncygpath` | Empty; detect `cygpath.exe` beside the Cygwin SVN client. Optional explicit converter path |
| `svnworkingdirectory` | `G:\VERSIONCONTROL\SUBVERSION\W1\`; existing checkout of a local Subversion repository |
| `svnrepository` | Empty; optionally specify the repository disk directory to verify |
| `svnlayout` | `flat`; upload basenames into the working directory. `paths` preserves drive/directory names beneath it |
| `svnmessage` | `recompiled`; used directly in automatic mode; empty means Ask once |
| `svnsnapshotunsaved` | `true`; upload temporary snapshots of unsaved named buffers. `false` uploads disk contents |

Matching basenames share the same destination, as requested. If several different sources in one operation have the same basename, **the last source in the scope wins**, and this is logged. Project membership and original filenames remain unchanged.

The implementation adapts the supplied **updafisc.s** copy/add/commit workflow in `SRC/MAC/projsvn.si`. It uses a portable PowerShell helper instead of the original personal command aliases, global configuration, and browser macros. It does not load the original macro or replace the CTags F12 binding. Source buffers are not saved, renamed, closed, or marked unchanged. Only the selected destination files and newly added parent directories are committed.

Install the Subversion command-line client and configure an existing local working copy before using this feature. The helper checks that the checkout repository uses `file://`; it does not create a repository or checkout. Windows PowerShell is required. Upload reports are written beside the package to `proj0200_svn_log.txt` and `proj0200_svn_status.txt`. If a commit fails, copied or added working-copy files can remain; earlier per-file commits in with-notes mode remain committed.

Recompile using `build.bat "path\to\sc32.exe"`, restart TSE, and run `projstart`. SAL compilation and Subversion execution still need testing on your Windows installation.

## Search and refresh

Open the project menu with **Alt+[**. Two entries near the top open submenus: **Z: Search projects** and **0: Refresh projects**. Each label ends with **ASCII decimal 16** as the submenu indicator. The same indicator is used on other submenu labels throughout the package.

The Search submenu offers **C** current file, **P** current project, and **A** all projects, each including archives.

Enter the expression and options (`i` for ignore case, `x` for TSE regular expressions). Results show source, line, column, and matching text. Nested members use `archive::member` names. The results list is a viewer: Escape returns to the original file. Search does not activate other projects or open their files in the editor ring. Already-open ordinary files are searched using their current buffer contents, including unsaved edits; other files are read from disk. Archive members are read from disk.

The archive engine reuses GREPZIP . Supported containers: ZIP, JAR, TAR, TGZ/TAR.GZ, GZ/GZIP, 7z, RAR, BZ2, and XZ, including nested archives up to 32 levels. ZIP/JAR and standalone GZIP use PowerShell/.NET. TAR/TGZ uses Windows `tar.exe` (or 7-Zip as fallback); 7z/BZ2/XZ needs `7z.exe`; RAR uses `rar.exe` or 7-Zip. Set optional `SevenZipExecutable=` and `RarExecutable=` paths in `proj0200.ini`, or leave empty for automatic detection. Extraction failures and missing paths are reported in the search results. A path exceeding 254 characters (SAL's 255-character limit minus the record prefix) is reported rather than searched under a truncated path.

Directory membership follows the project's Known file types and subdirectory/exclusion settings. Archive containers in included directories are also inspected for search, without adding their binary extensions to Known file types. Explicit filenames remain exact. All-project operations use registered saved project records and the current project's in-memory membership, with duplicate physical files processed once. Save changes to other projects before using this scope. No active project switch occurs.

The Refresh submenu offers **C** current file without asking, **Q** current file with asking, **P** current project with asking, **N** current project without asking, **A** all projects without asking, and **Y** all projects with asking.

| Scope | With asking | Without asking |
|---|---|---|
| Current file | Confirm the file before reload | Reload directly, subject to the unsaved-edits warning below |
| Current project | Confirm each matching open file | Reload matching open files, subject to the warning |
| All projects | Confirm each matching open file | Reload matching open files, subject to the warning |

**Refresh replaces buffer contents with disk contents, discarding unsaved edits.** For âwithout askingâ, if any targeted open buffer has unsaved edits, a **YesNo() warning appears once before any buffer is changed**. No cancels the whole operation; Yes proceeds without individual questions. âWith askingâ confirms each file separately; No skips that file.

Refresh only affects files already open in the TSE ring. It does not open closed project files, close buffers, change membership, save source files, or refresh the project picklist. Unnamed and missing disk files are not overwritten. Each disk file is read into a temporary staging buffer before replacing its open buffer, so a failed read leaves the original contents intact. Archive refresh reloads the container file itself if open; it does not rewrite archive members. The original file/cursor is restored after the operation and a final count is displayed.

Ordinary current-buffer search also works for unnamed buffers and needs no PowerShell. PowerShell is required for project scope enumeration and archive preparation. Generated `proj0200_scope_request.txt` and batch wrappers remain beside the package for troubleshooting; extracted temporary archive members and the manifest are cleaned after the operation.

Suggested refresh test: open two project files, change one without saving, then choose refresh without asking. Choose **No** at the initial warning and verify both buffers are unchanged. Repeat and choose **Yes** to confirm that disk contents replace the edits. Repeat with asking to confirm that **No** skips only the selected file. Verify that a closed third project file stays closed throughout.

Recompile using `build.bat "C:\path\to\sc32.exe"`. This release has source/static checks; SAL compilation and Windows runtime testing remain pending.

## Supported CTags languages

The user has verified F12 navigation for every listed language, including Emacs Lisp and Markdown. This records the packaged example tests, not complete parser coverage.

This package covers **61 language entries**: the **41 built-in parsers** reported by your Exuberant CTags 5.8 plus **19 package-defined regex parsers**, with Emacs Lisp shown separately from Lisp although both use the same parser. The latter provide basic definition indexing, not full language parsing. TSE SAL takes priority for `.s` and `.si`; `.pl` retains Perl priority. This table lists the packaged example extension for each language; your executable's `--list-maps` and the package configuration determine all accepted extensions. Examples are in `CTAGSEXAMPLES/`.

| Language | Example extension | Parser | Navigation test |
|---|---|---|---|
| ABAP | `.abap` | Custom regex | F12 verified |
| ActionScript | `.as` | Custom regex | F12 verified |
| Ada | `.adb` | Custom regex | F12 verified |
| Ant | `.build.xml` | Built-in | F12 verified |
| ASP | `.asp` | Built-in | F12 verified |
| Assembly | `.asm` | Built-in | F12 verified |
| AWK | `.awk` | Built-in | F12 verified |
| Basic | `.bas` | Built-in | F12 verified |
| BETA | `.bet` | Built-in | F12 verified |
| C | `.c` | Built-in | F12 verified |
| C# | `.cs` | Built-in | F12 verified |
| C++ | `.cpp` | Built-in | F12 verified |
| Cobol | `.cob` | Built-in | F12 verified |
| Dart | `.dart` | Custom regex | F12 verified |
| DosBatch | `.bat` | Built-in | F12 verified |
| Emacs Lisp | `.el` | Built-in Lisp | F12 verified |
| Eiffel | `.e` | Built-in | F12 verified |
| Erlang | `.erl` | Built-in | F12 verified |
| Flex (MXML) | `.mxml` | Built-in | F12 verified |
| Fortran | `.f90` | Built-in | F12 verified |
| Go | `.go` | Custom regex | F12 verified |
| Haskell | `.hs` | Custom regex | F12 verified |
| HTML | `.html` | Built-in | F12 verified |
| Java | `.java` | Built-in | F12 verified |
| JavaScript | `.js` | Built-in | F12 verified |
| Kotlin | `.kt` | Custom regex | F12 verified |
| Lisp | `.lisp` | Built-in | F12 verified |
| Lua | `.lua` | Built-in | F12 verified |
| Make | `.mak` | Built-in | F12 verified |
| Markdown | `.md` | Custom regex | F12 verified |
| Maple | `.mpl` | Custom regex | F12 verified |
| Mathematica | `.wl` | Custom regex | F12 verified |
| MatLab | `.m` | Built-in | F12 verified |
| OCaml | `.ml` | Built-in | F12 verified |
| Pascal | `.pas` | Built-in | F12 verified |
| Perl | `.pl` | Built-in | F12 verified |
| PHP | `.php` | Built-in | F12 verified |
| PowerShell | `.ps1` | Custom regex | F12 verified |
| Prolog | `.pro` | Custom regex | F12 verified |
| Python | `.py` | Built-in | F12 verified |
| R | `.r` | Custom regex | F12 verified |
| REXX | `.rx` | Built-in | F12 verified |
| Ruby | `.rb` | Built-in | F12 verified |
| Rust | `.rs` | Custom regex | F12 verified |
| SAS | `.sas` | Custom regex | F12 verified |
| Scala | `.scala` | Custom regex | F12 verified |
| Scheme | `.scm` | Built-in | F12 verified |
| Sh | `.sh` | Built-in | F12 verified |
| SLang | `.sl` | Built-in | F12 verified |
| SML | `.sml` | Built-in | F12 verified |
| SQL | `.sql` | Built-in | F12 verified |
| Swift | `.swift` | Custom regex | F12 verified |
| Tcl | `.tcl` | Built-in | F12 verified |
| Tex | `.tex` | Built-in | F12 verified |
| TSE SAL | `.s`, `.si` | Custom regex | F12 verified |
| TypeScript | `.ts` | Custom regex | F12 verified |
| Vera | `.vr` | Built-in | F12 verified |
| Verilog | `.v` | Built-in | F12 verified |
| VHDL | `.vhd` | Built-in | F12 verified |
| VimScript | `.vim` | Built-in | F12 verified |
| YACC | `.y` | Built-in | F12 verified |

## Description

PROJ manages TSE projects containing many files. It remembers open files and editor state, offers a project file list in the Edit File prompt, associates directories with projects, and can navigate to related files and tags. The included original release is v2.00 (2002). Its original `README.txt` and `SRC/MAC/proj.hlp` provide further details; portions of the original help remain unfinished.

This package adds an optional startup message to `SRC/MAC/proj.si` and supplies `proj0200.ini`. Running `proj` directly can show an informative `Warn()` box that points to the Projects menu; the supplied INI now suppresses it by default. First-run setup still runs, then the Project menu opens automatically. Later direct runs open the Project menu immediately. The message does not appear when PROJ is invoked with an internal command such as `-m`, or when it is autoloaded. `silent=true` hides only the added startup message; existing error warnings and setup dialogs retain their behavior.

## Requirements

- TSE for Windows with a compatible **32-bit** `ProjDLL.dll`. The original documentation describes TSE Pro 2.8, 3.0, and 4.0; the user has compiled all five entry files using SAL 4.50.rc23 and confirmed that PROJ starts, help opens, and a new project can be created.
- A SAL compiler compatible with your installed TSE. The bundled `.mac` files are from the original release and can report âmacro compiled with wrong versionâ; recompile from the supplied sources for your TSE version.
- Optional: `CTAGS.EXE` for tag generation. Download the official [Exuberant Ctags 5.8 Windows ZIP (`ctags58.zip`)](https://sourceforge.net/projects/ctags/files/ctags/5.8/ctags58.zip/download), extract `ctags.exe`, and set its full path in `proj0200.ini` using `ctags=C:\path\to\ctags.exe`. Check `ctags.exe --version` for `+regex`, which the package-defined language rules require. BSC navigation uses the supplied `msbsc60.dll`.


## Tags and ctags.exe

**Alt+[ -> CTags -> Generate CTags file** runs the executable named by `ctags=` in `proj0200.ini`. It scans the project source file list and writes a `.tag` index beside the project's `.pj` file, for example `PJ\FOOBAR01.tag`. The index contains symbol definitions such as C functions, types, and variables; it is not a list of every textual occurrence or call. Generate tags again after adding files or changing definitions.

Place the cursor on a symbol use and press **F12** (Goto CTags definition at cursor), or use **Alt+[ -> CTags -> Goto CTags definition** and enter its name. PROJ reads the existing `.tag` file via `ProjDLL.dll` and jumps to the matching definition. F12 does not run `ctags.exe`; when already on a definition, the jump may appear to do nothing because the destination is the current line. For every occurrence, including comments or string literals, search project files as text instead. Exuberant Ctags 5.8 headers are normalized automatically for the bundled DLL.

## Language support

The configured Exuberant Ctags 5.8 program supports 41 built-in languages, including C, C++, C#, Java, JavaScript, Python, Perl, PHP, Ruby, Lua, HTML, shell scripts, and many others. The authoritative list is [Exuberant Ctags supported languages](https://ctags.sourceforge.net/languages.html); on your machine run `"g:\utils\ctags.exe" --list-languages` to see the actual languages of your executable. TSE SAL (`.s` and `.si`) takes priority over the built-in Assembly mapping of `.s`: the included `proj0200_ctags_languages.conf` defines a TSESal parser for procedures, menu declarations, and defines, and the first variable declared on a line. Keep that file beside `proj.mac`. It requires a CTags executable built with regular-expression support (`+regex` in `ctags.exe --version`). Other languages retain the executableâs own mappings. The pasted 41-language extension table is not necessarily the mapping in your particular executable; check `ctags.exe --list-maps` as well as `--list-languages`.

PROJ now passes **all files already in the project** to ctags; the earlier C/C++-only filter is gone. Ctags chooses its parser by file extension and ignores files whose language it does not recognize. New project defaults include several common extensions, such as `java`, `py`, `js`, `cs`, `php`, and `rb`. For other languages or an existing project, add the extension to **Project Settings -> Known file types** when scanning a directory, then refresh the file list and generate CTags again. You can also add a specific full filename under **Add files to project**; exact file entries are passed to ctags regardless of the known types list. PROJ does not change the languages built into your `ctags.exe`. With no project open, generation indexes the current file only.

## TSE clipboard commands

Under **Alt+[ -> Clipboards**, the commands are:

- **Load TSE clipboard content from a file**: choose a file and replace TSE's internal clipboard with its saved content. PROJ restores its own `.clp` format including block shape; another text file is loaded as a line block.
- **Save TSE current clipboard content to a file**: choose a filename and write the current internal clipboard, including the block information needed for later loading.
- **View the current TSE clipboard content**: display the internal clipboard in a temporary list without inserting it into the edited file.

When saving a project, PROJ can also save this internal clipboard as a `.clp` file beside the `.pj` file and restore it when that project opens. These commands manage TSE's clipboard, separate from Windows clipboard diagnostics used by `ctagsdebug=true`.

## Configuration

Edit `proj0200.ini` beside `proj.mac`:

```ini
silent=true
ctags=g:\utils\ctags.exe
ctagsdebug=true
```

- `silent=false`: show the added informative `Warn()` box when `proj` runs directly.
- `silent=true` (packaged default): suppress that box.
- `ctags=`: path to a compatible `ctags.exe` for **CTags â Generate CTags file**. The default is `g:\utils\ctags.exe`; an empty setting also uses this default. An absolute path is used as written; a relative path is resolved from the package directory. Paths containing spaces may be enclosed in double quotes.

If the INI file is absent, PROJ behaves as `silent=false`. The `ctags` setting controls the external tag generator; PROJ's project database, paths, and other options use its existing setup and TSE profile settings.

## Notes

The SAL sources no longer call `LoadDir()`. The running macro directory is the installation directory: `Proj.DB`, the default `PJ` project folder, `proj0200.ini`, `proj.hlp`, `gethelp.dat`, are resolved there; `ctags.exe` uses the INI path. Keep `proj.mac`, `pjfile.mac`, and `gethelp.mac` together. The project directory setting and last-project setting still use TSE profile entries, and existing project records can contain absolute file paths; review these after moving the installation.

**DLLs:** The supplied `msbsc60.dll` is 32-bit and exports the `openBrowser` symbol imported by the original `ProjDLL.dll`. Keep both DLLs together beside the compiled macros. `msbsc60.dll` also imports the Windows `MSVCRT.dll` runtime. No new DLL was built; subsequent changes in  still require user compilation and verification. The original `README.txt` documents original integration commands and history.

## Compiler fix in 

The Windows `CreateDirectoryA` declaration was named `MkDir`, which is a reserved word in SAL 4.50. It is now declared as `PROCCreateDirectory` in both `proj.si` and `pjfile.si`; its call in `pjfile.si` was updated. `gethelp.si` and `helphelp.s` already compiled successfully with SAL Compiler V4.50.rc23 in user testing. The user later compiled and ran both successfully with SAL 4.50.rc23.

## Runtime path fix in 

When TSE loads `proj.mac` from an arbitrary directory, PROJ now loads and invokes the neighboring `pjfile.mac` using its full path. Its help call similarly uses the neighboring `gethelp.mac`; `helphelp.mac` calls that file by full path. Recompile all four macros for this release. Put both DLLs, `proj.hlp`, and `proj0200.ini` beside the macros. A screenshot from the earlier version showed a download directory containing only the four macros and sources; the required DLLs, help, and INI still need copying there.

## DLL loading in 

TSE resolves `dll "projdll.dll"` through its macro search path. After TSE finds the full path, Windows separately resolves DLL imports such as `msbsc60.dll`. On a machine where TSE runs with another working directory, the Windows dependency search can fail even when both DLLs sit together. Run **`projstart.mac`**: it uses the Windows `SetDllDirectoryA` API to add its own directory to this TSE process's DLL search path, then runs `proj.mac` by full path. The DLL search directory stays set for the life of the TSE process. Compile `projstart.s` alongside the four existing entry files.

## Help path fix in 

`gethelp.si` now accepts an existing full path to `proj.hlp` directly before searching for a relative help filename. The previous lookup appended that full path to another directory and displayed "Topic Welcome to PROJ not found" even when `proj.hlp` sat beside the macros. Recompile `gethelp.si`; the other four macros from  can be reused.

## Project folder fix in 

When saving a new project, `pjfile.si` now creates the configured project folder (by default `PJ` beside `pjfile.mac`) before prompting for the `.PJ` name. It reports a clear error if a file occupies that path or Windows cannot create the directory. Recompile `pjfile.si`; the other compiled macros from  can be reused.

## Portability and settings fix in 

`pjfile.si` now invokes the adjacent `proj.mac` by full path for internal stop, tags, and file-list operations. After Project Settings closes, it saves the project so edited include paths persist in the `.PJ` file. Compile `pjfile.si` again and copy the resulting `pjfile.mac` beside `projstart.mac`; the other entry macros may be reused from your successful compilation. In the include-path list use **Ins** to add a path, **Enter** to accept it, then leave Project Settings. Confirm the path is still present after reopening the project. When moving an existing installation, old `.PJ` entries and TSE profile paths can still point to the old location; update them as needed.

## Batch build in 

`build.bat` follows the same build workflow using `cd` for relative directory changes from the package root, supported by `cmd.exe` and JPSoft TCC. It runs from the extracted package root, compiles in `SRC\MAC`, then returns to the package root before the `copy SRC\MAC\...` commands. Pass the compiler path as the first argument (quote it if it contains spaces). It stops copying if compilation fails.

## Compiler argument in 

The root-level `build.bat` now takes its compiler path as the first argument: `build.bat "F:\WORDPROC\tse32_v45024\sc32.exe"`. Quoted paths with spaces are accepted. It prints usage when the argument is missing. Run it from the extracted package root.

## Windows batch portability in 

The batch file uses `cd /d` for directory changes, so it can run from Windows `cmd.exe` as well as shells that support this command. It requires a Windows TSE `sc32.exe`; classic MS-DOS does not provide `cd /d` or this compiler.

## Compiler and batch correction in 

`pjfile.si` includes `common.si` before `stubs2.si`, so `GetInstallationDir()` is declared when the latter uses it. This fixes SAL error 2335 on `stubs2.si` line 33 reported with V4.50.rc23. `build.bat` uses plain `cd` for its same-drive relative directory changes; TCC had printed directory messages for `cd /d`. Re-run the batch from the extracted root. This revision has not yet been compiled on the user machine.

## Project reopening and Add Files in 

A `.PJ` project stores **directories** in `[Paths]`. `FOOBAR01.pj` showed `c:\temp\ddd.s` and `c:\temp\ddd.txt` under `[Paths]`, while `[FilesInProject]` remained empty. Enter `C:\TEMP\` in **Project Settings â Add files to project**, then add `txt` under **Known file types** (the default already contains `s`). The file list is generated from those directory paths and known extensions. To restore specific open buffers and cursor positions, open the files in TSE and save the project; `[Buffers]` and `[Windows]` are separate from `[Paths]`. In , `pjfile.si` rejected individual files in that prompt; version  accepts them and converts them automatically.

`proj.si` now tries to reopen the last project when TSE starts with a single unnamed buffer, as well as when it starts with no files. PROJ previously skipped this step when `NumFiles()` was one. Verify this with **Options â Open last project** enabled. At TSE's `File(s) to edit` prompt, **Escape** asks for confirmation before exiting. **No** keeps the prompt open; **Yes** exits. **Alt+[** opens the project menu there.

## Automatic directory and file type in 

converted a full filename to its parent directory and scanned all matching files there. This caused unintended entries when `C:\TEMP\ddd.txt` and `C:\TEMP\ddd.s` were entered. Version  restores exact filename behavior.

**Clean extraction:** If you delete the entire installation directory (`D`) before extracting a new ZIP, this also deletes `D\PJ\*.pj` and `D\Proj.DB`. To retain projects between package versions, copy the `PJ` directory and `Proj.DB` somewhere else before deleting `D`, then restore them after extraction. The compiled `.mac` files still need to be regenerated with `build.bat`.

## Exact filenames in 

In **Project Settings â Add files to project**, enter `C:\TEMP\ddd.txt` and `C:\TEMP\ddd.s` as two separate entries. Full filenames stay exact in `[Paths]` and contribute only those two files to the generated project file list. A directory entry such as `C:\TEMP\` still scans that directory using **Known file types**. Exact filenames work regardless of Known file types and may be mixed with directory entries. Duplicate file entries are removed during the sorted merge. A changed path list invalidates the old `[FilesInProject]` cache, allowing the next rebuild to reflect the new selection. No DLL rebuild is required; compile `pjfile.si` and `proj.si` via `build.bat`.

## Exact-file sort fix in 

The exact-file merge now saves the existing block selection, marks the temporary file list explicitly, sorts it, and restores the previous selection. This addresses the TSE warning "Block not in current file" reported after creating a project in version . Recompile using `build.bat` and retry adding two full filenames. The change still needs verification in TSE.

## Last-file close confirmation

While PROJ is loaded, closing the only file in TSE's ring shows a Yes/No confirmation. **No** or **Escape** keeps the file open. **Yes** closes it and goes to TSE's **File(s) to edit** prompt; pressing Escape at that prompt asks whether to exit TSE; **No** returns to the prompt. This uses TSE's `_ON_FILE_QUIT_` hook and temporarily enables `QuitToPrompt`, which is required for the hook to run when the ring contains one file. PROJ restores your prior `QuitToPrompt` setting when its macro is purged. Rebuild `proj.mac` using `build.bat` before testing; this change has not yet been compiled or run under TSE here.

## Project file picker keys

At the **File(s) to edit** prompt, PROJ now selects the first listed project file when the prompt is empty. Use **Down/Up** to choose a row and **Enter** to open it. Previously an empty prompt left no row selected, so Down opened TSE's History instead. Recompile via `build.bat`; the new behavior still needs testing in TSE.

## Selected filename in the Edit prompt

PROJ now writes the highlighted project file's full path into TSE's **File(s) to edit** field. The field updates when Up/Down moves the project list selection, and Enter opens that path. The picker retains its current filter while updating the displayed field. Rebuild with `build.bat`; verify the field and navigation in TSE.

## Reopen the project picker while editing

With a project open, choose **File â Open** to show TSE's **File to edit:** prompt. PROJ now also attaches its project file list to this singular prompt, in addition to the startup **File(s) to edit:** prompt. Use the arrow keys to choose a file, then Enter to open it. The previously edited file remains in TSE's ring. Rebuild with `build.bat`; test this menu path in TSE.

## Prompt repaint

After returning from the project picker to an editing window, PROJ requests one further full window refresh. This addresses repeated line numbers and `[ End` fragments left at the top of the display by the popup's cleanup timing. These are screen artifacts, not additional open files. Recompile with `build.bat`; the fix needs verification in TSE.

## Project transition repaint

Closing and reopening a project could leave repeated `1` and `[ End` fragments in the editing area. PROJ now schedules a full display refresh after the project menu returns to the editor. The earlier picker cleanup also called `UpdateDisplay()` while the prompt was still active; TSE documents that this is unsupported, so that premature call was removed. Recompile with `build.bat`, then repeat **Close project â Open project** several times to verify the screen. This change has not been run under TSE here.

## Single-window project reopen

The preceding redraw did not resolve repeated line-number columns after **Close project â Open project**. For a project with one saved edit window, PROJ now uses TSE's current single window instead of reconstructing its saved geometry. It still reopens project buffers and restores their recorded positions. Projects with multiple saved windows keep the original restoration path. Recompile `pjfile.si` using `build.bat`; check repeated close/open of a one-window project in TSE. The behavior has not been run under TSE here.

## CTags path

Set `ctags=C:\Tools\ctags.exe` in `proj0200.ini` if the executable is elsewhere. The tag generator reads the setting when **Generate tags file** runs, quotes the executable path for spaces, and warns if the file cannot be found. Existing tag navigation reads previously generated tag files without invoking the executable. Recompile `proj.si` using `build.bat`; the new source has not been compiled under TSE in this workspace.

## Default CTags location

The default `ctags` path is `g:\utils\ctags.exe`, including when the INI is missing or `ctags=` is empty. Change the path in the INI if your executable is elsewhere. Recompile `proj.si` with `build.bat`.

## F12 tag name extraction

Manual **Goto tag** found `draw_menu` in `FOOBAR01.tag`, while **F12** reported `draw menu` even with no marked block. PROJ now reads the identifier directly from the current line and preserves underscores. The cursor may be anywhere within the identifier or immediately after it. Marked character and column selections retain their existing behavior. Rebuild `proj.si` with `build.bat` and test F12 on `draw_menu`; this source change has not been compiled under TSE here.

## Exact F12 tag lookup

passed `draw_menu` correctly but the DLL exact-lookup flag still reported no result. Manual **Goto tag** succeeds using prefix lookup. F12 now uses that lookup path and checks `Tags_GetSymbol()` for an exact match before navigating. Recompile `proj.si` with `build.bat`; test F12 on `draw_menu` in TSE.

## Inspect CTags command

With `ctagsdebug=true`, **CTags â Generate CTags file** copies the actual command line to the Windows clipboard. The generated `proj0200_ctags_run.bat` remains in the installation directory for inspection. For a whole-project build, it also retains the input file list as `proj0200_ctags_files.txt` beside `proj.mac`; if an ignore file is used, it retains `proj0200_ctags_ignore.txt` there. The copied command references these files, so it can be pasted into a command prompt for diagnosis. Set `ctagsdebug=false` after testing to resume temporary input cleanup. This setting also enables the F12 lookup trace described below. Recompile `proj.si` via `build.bat`.

## F12 lookup trace

With `ctagsdebug=true`, F12 writes `proj0200_tag_lookup.txt` beside `proj.mac`. It records the exact tag string and its length, tag file path, first DLL lookup index and symbol, and final matched index. The tag generator diagnostics from  remain available. Recompile `proj.si` with `build.bat`, press F12 on `draw_menu`, and inspect or share the lookup text file.

## F12 lookup fallback

If the tag DLL lookup misses an existing symbol, F12 scans the loaded tag entries for an exact symbol match. The trace records the original DLL lookup result and the final match index. Recompile with `build.bat` and test F12 on `draw_menu`.

## ProjDLL source correction

`SRC/DLL/tags.cpp` now preserves the `lookExact` flag before removing it from the direction bits. It also scans the loaded tag entries if binary search misses. The archive still contains the original compiled `ProjDLL.dll`; the supplied `SRC/DLL/makefile` uses the Microsoft C++ tools (`nmake`, `cl`, `link`) and requires `msbsc60.lib`. The source correction takes effect only after rebuilding the 32-bit DLL and placing it beside `proj.mac`, then restarting TSE. Keep the original DLL as a backup. The SAL fallback from  works with the bundled DLL and can be tested independently. The DLL source change has not been compiled in this environment.

## Tag loading trace

When `ctagsdebug=true`, the F12 trace also records `tag_count`, `current_tagfile`, and the first three loaded symbols. This distinguishes an empty or wrong loaded tag table from a failed search.

## Exuberant Ctags 5.8 header compatibility

The uploaded `FOOBAR01.tag` has six tag entries, including `draw_menu`. Its `!_TAG_FILE_SORTED` header ends in `2=foldcase`, but the bundled original `ProjDLL.dll` requires the older header text exactly. Before loading a tag file, PROJ now changes only that header description to the older form and reloads the DLL tag table. This makes existing and newly generated tag files work without rebuilding the DLL. The DLL source also accepts either sorted-header description when rebuilt. Recompile `proj.si` with `build.bat`, restart TSE, generate tags if needed, then press F12 on `draw_menu`.

## Noninteractive tag header update

The version  header replacement omitted TSE's `n` option, so TSE displayed a Replace (Yes/No/Only/Rest/Quit) prompt. The replacement now runs without confirmation.

## Startup menu and CTags labels

Running `projstart.mac` now opens the Project menu after the optional startup message and first-run setup. Press **Alt+[** to reopen the menu later. User-facing tag menu entries and related settings now say **CTags**. The internal `.tag` format and existing project settings names are retained.

## TSE SAL takes priority

CTags generation loads `proj0200_ctags_languages.conf` from the package directory. It maps `.s` and `.si` to TSE SAL, including when generating tags for a mixed-language project; `.s` assembly files consequently need a different extension or a separate CTags invocation with another mapping. The configuration recognizes SAL `proc`, `menu`, `keydef`, `datadef`, `helpdef`, and `#define` declarations on one line. It is a simple definition index, not a complete SAL parser. Verify on Windows with `build.bat "C:\path\to\sc32.exe"`, then generate CTags and press F12 on a SAL procedure name. This change was not compiled with SAL in this workspace.

## TSE SAL variable navigation

The TSE SAL CTags configuration additionally indexes `integer` and `string` variable declarations, including declarations inside a procedure and at file scope. For a declaration listing several variables on one line, only the first is indexed. The pattern does not match procedure return types (`integer proc` or `string proc`). Generate the CTags file again after changing declarations. F12 uses the nearest same-file variable declaration when several names match, although it does not parse procedure scope. For an unambiguous global, F12 should jump to its declaration. CTags does not show variable values or usages. Verify using your Windows CTags executable; this version was not compiled or run under TSE here.

## Nearest SAL variable declaration

F12 on a name in a `.s` or `.si` file prefers a variable declaration (`integer` or `string`) with the same name **above the cursor** in the current file. If none exists, it tries the nearest declaration below. If there is no indexed same-file variable, the existing matching-tags chooser remains available. This is a line-distance heuristic: it does not parse SAL procedure scope, so a nearby declaration in another procedure may still win. Tag generation uses CTags line-number addresses (`--excmd=n`) so the DLL can compare locations reliably. Regenerate the `.tag` file after upgrading and test on your machine; this workspace has no SAL compiler or Windows CTags executable.

## SAL variable search direction

For a SAL variable, F12 first picks the closest indexed declaration **above or on the cursor line** in the current file. Only when there is no preceding declaration does it use the closest declaration below. With no same-file variable, the matching-tags chooser remains. This follows the usual declaration-before-use pattern but still does not understand procedure scope. Regenerate the CTags file and compile the updated SAL sources on Windows before testing.

## Backward SAL definition search

F12 on an indexed name in a `.s` or `.si` file now applies the same priority to procedures, menus, other named SAL declarations, `#define` names, and variables: the nearest matching tag on or above the cursor line in the current file wins. If there is no preceding same-file match, the nearest later same-file match is used; if there is no same-file match, the usual chooser is shown. Indexing still depends on the simple regex rules in `proj0200_ctags_languages.conf`, and identical names in different scopes cannot be distinguished reliably. Forward declarations may legitimately appear before definitions, so a previous match need not be the full implementation. Regenerate tags after upgrading.

## Rust CTags support

Exuberant CTags 5.8 lacks a built-in Rust parser. The package options file `proj0200_ctags_languages.conf` adds a regex-based `ProjRust` language and maps `.rs` to it. It indexes common `fn` (including basic `pub`, `async`, `const`, and `unsafe` qualifiers), `struct`, `enum`, `trait`, `mod`, `type`, `const`, `static`, and `macro_rules!` declarations. The bundled DLL recognizes the one-letter tag kinds used by these rules. This is deliberately a basic index: it cannot parse Rust scopes, generics, attributes, re-exports, or every form of declaration. The file also keeps the TSE SAL `.s`/`.si` priority rules.

For a **new** project, `rs` is now in **Known file types**, so adding a directory can find `.rs` files. An existing project retains its saved settings: add `rs` to **Project Settings â Known file types** if you use directory scanning, or add a specific `.rs` file by its full path. Generate the CTags file again, then place the cursor on a Rust definition name and press F12. Keep the renamed options file beside `proj.mac` after extracting a fresh ZIP. Verify with your Windows CTags executable; this workspace has not run it.

## Additional CTags languages

The package options file adds basic regex definition indexing for these languages, on top of the configured executable's built-in parsers. Each listed suffix is in the defaults for new projects.

| Language | Package extensions | Indexed examples |
|---|---|---|
| TypeScript | `.ts`, `.tsx` | functions, types, variables |
| Go | `.go` | functions, methods, types, variables |
| Dart | `.dart` | types, basic functions |
| Haskell | `.hs`, `.lhs` | type signatures, types |
| Maple | `.mpl`, `.maple` | procedures, modules |
| R | `.r` (also `.R` in CTags) | function assignments |
| Mathematica | `.wl`, `.wls` | named definitions and usage declarations |
| Swift | `.swift` | functions, types, variables |
| SAS | `.sas` | macros, data sets |
| Kotlin | `.kt`, `.kts` | functions, types, variables |
| Prolog | `.pro`, `.prolog` | basic predicates |
| PowerShell | `.ps1`, `.psm1`, `.psd1` | functions, filters, classes, enums |
| Scala | `.scala`, `.sc` | definitions, types, variables |
| ABAP | `.abap` | classes, methods, forms, functions, variables |

**Extension priority:** `.pl` remains Perl; `.m` remains MATLAB. Prolog and Mathematica therefore use the other extensions shown above. TSE SAL retains priority for `.s`/`.si`. Each added parser uses single-line regexes and indexes common declarations only; it does not understand full language syntax or lexical scopes. A modern CTags with a native parser for these languages may produce better results without this package's override.

For projects created before this version, saved **Known file types** remain unchanged. Add desired extensions there for directory scans, or add specific files by full path; then regenerate the CTags file. Keep `proj0200_ctags_languages.conf` beside `proj.mac`. Compile the five entry macros with `build.bat` for your TSE version. No SAL compiler or Windows CTags executable is available in this workspace, so verify indexing and F12 on your machine.

## Visible subdirectory scan choice

Choose **Alt+[ â Project Settings â Add files or scan directories**. Press **Ins** and enter an exact filename or an existing directory. For a directory, PROJ explicitly asks **âAlso scan subdirectories of this directory?â**; Yes enables recursive scanning, No scans that directory only. In the path list, entries with recursion show **â(includes subdirectories)â**. Select a directory and press **Ctrl+S** to toggle that option later; the full shortcut is displayed in the list footer. **Known file types** filters directory scans; an exact filename includes only that file. Save the path list with **Enter**, then generate the CTags file when needed.

## Windows CTags download

The upstream [Exuberant Ctags 5.8 download page](https://ctags.sourceforge.net/) lists `ctags58.zip` as its Windows source-and-binary package. The direct [SourceForge download for `ctags58.zip`](https://sourceforge.net/projects/ctags/files/ctags/5.8/ctags58.zip/download) contains the executable. Extract it to a directory of your choice, set `ctags=` in `proj0200.ini` to the full path to `ctags.exe`, and check `"C:\path\to\ctags.exe" --version` for `+regex`. The bundled SAL and extra-language rules rely on this feature. The executable is not redistributed in the PROJ ZIP.

## CTags command length and empty index

A user trace for `draw_menu` showed `tag_count=0`, and the attached `FOOBAR01.tag` had only its six CTags header lines. An earlier `.tag` file contained `draw_menu`; the index generation failed before lookup. The project command with the added language-options path can exceed SAL's 255-character string limit (262 characters for a representative command using the user's paths), truncating the output filename. PROJ now builds the complete command incrementally as a line in `proj0200_ctags_run.bat` beside the macros and executes that batch file. It retains the batch file for inspection, copies the full command line to the Windows clipboard when `ctagsdebug=true`, and warns if CTags fails or produces no definitions. The exact project input list remains in `proj0200_ctags_files.txt` when debugging is enabled. After recompiling, regenerate CTags and check the `.tag` file for `draw_menu` before trying F12. If the file remains empty, inspect or run the saved batch file in cmd.exe to see the CTags error.

## CTags project input paths

The CTags batch command was complete in user testing, but its input list contained `ddd.cc:\temp\` instead of `c:\temp\ddd.c`. `InsertFileList(FALSE)` writes PROJ DLL's internal `filename` + separator + `directory` format, which CTags cannot open as a path. Tag generation now converts each project entry with `RealPath(FlatFile_GetFilename(...))` before writing `proj0200_ctags_files.txt`. After recompiling, regenerate tags and inspect that list: for the sample it should contain `c:\temp\ddd.c`, and the generated `.tag` file should contain `draw_menu`. The F12 lookup trace is only written after the tag file loads, so it was absent while the index had zero definitions.

## CTags loader completion

After CTags writes the tag file, PROJ now waits for the DLL to finish loading it before testing the definition count. A new file previously returned the DLL status âload in progress,â which PROJ mistook for an empty index. A nonzero TSE command return alone no longer raises a warning if the tag file loads with definitions. If generation still fails, the warning includes both the command return and the loaded count; run `proj0200_ctags_run.bat` in cmd.exe and inspect the retained input list. Regenerate CTags after recompiling `proj.si`, then place the cursor on `draw_menu` and press F12.

## TSE SAL uppercase declarations

The `.s` test used `PROC FooBar()` and `PROC Main()`. Exuberant CTags 5.8 matched none because the custom SAL regular expressions used lowercase keywords without the case-insensitive flag. All four SAL rules now include `/i`, so uppercase `PROC`, `MENU`, `#DEFINE`, and type keywords are recognized. Re-extract this release and regenerate CTags; `FOOBAR01.tag` should include `FooBar` and `Main` from `ddd.s`. Then press F12 on the `FooBar()` call. Recompilation is optional for this change because only the CTags configuration and documentation changed.

## SAL parser rules

The forced `TSESal` parser listed all four rule kinds, yet the earlier complex optional-group procedure expression produced no tags. A direct simple rule found `FooBar` and `Main` at lines 1 and 4 in the user test. The configuration now starts with the exact case-insensitive procedure expression proven to work in the user test, and also includes anchored expressions for public and typed `PROC` declarations; menu and define rules are retained, and the variable rule is simplified. From a clean extraction, build as usual, generate the project CTags file, and check for `FooBar` and `Main` from `ddd.s` before pressing F12 at the call. This configuration-only revision does not require changed macro binaries.

## Windows `.s` language precedence

The Exuberant CTags 5.8 verbose trace showed `ddd.s` opening as Asm even after mapping `.s` to `TSESal`. Its Assembly parser also owns uppercase `.S`, which this Windows build matches against the lowercase filename. The configuration now maps both `.s` and `.S` (plus `.si`) to `TSESal`, removing the conflicting Assembly entries. The user already confirmed that the forced `TSESal` parser emits `FooBar` and `Main`. In a clean extraction, regenerate the project tag file and verify that it contains those two SAL entries; F12 on the call should then navigate to the declaration.

## CTags C example

`CTAGSEXAMPLES/ddd.c` is a small standalone C program. Add `ddd.c` to a project, generate the CTags file, place the cursor on `draw_menu` in `main`, and press **F12**. The lookup should jump to `static void draw_menu(void)` near the top of the file. You can compile it with a C compiler (for example `gcc ddd.c -o ddd.exe`), but compilation is not required for the CTags test.

## Included language examples

The `CTAGSEXAMPLES` directory contains six `ddd` examples for languages previously tested for CTags navigation. These are optional test files; add only the ones you want to a test project and regenerate its CTags file after adding them. Open a file, put the cursor on the call named below, and press **F12** to jump to its definition. The `.s` example uses TSE SAL and its included custom language configuration.

| File | Language | F12 on call | Expected definition |
|---|---|---|---|
| `CTAGSEXAMPLES/ddd.c` | C | `draw_menu()` | `static void draw_menu(void)` |
| `CTAGSEXAMPLES/ddd.s` | TSE SAL | `FooBar()` | `PROC FooBar()` |
| `CTAGSEXAMPLES/ddd.py` | Python | `greet()` | `def greet():` |
| `CTAGSEXAMPLES/ddd.rs` | Rust | `greet()` | `fn greet()` |
| `CTAGSEXAMPLES/ddd.ts` | TypeScript | `formatName()` | `function formatName(...)` |
| `CTAGSEXAMPLES/ddd.go` | Go | `makeGreeting()` | `func makeGreeting()` |

The examples are newly supplied test sources; they do not require compilation to build a CTags index.

## Full language test set

The `CTAGSEXAMPLES` directory contains all the sample files and a language/file/symbol checklist in `CTAGSEXAMPLES/README.md`. This now covers 59 language entries across 60 files (both `.s` and `.si` for TSE SAL): the 41 built-in languages plus 18 regex languages, with Ada and ActionScript supplied as regex languages. Each file is a small syntax sample intended for CTags indexing; entries marked **Pending TSE test** have not been verified with your executable. Add a chosen example file to a project, regenerate CTags, and test F12 on the symbol. Some languages require a compiler, runtime, or different CTags parser behavior for their examples to be executable or indexed.

## Example layout in 

All `ddd.*` sources are now together under `CTAGSEXAMPLES/`. When updating a test project created from an earlier release, remove its old `ddd.*` entries and add the new full paths, then regenerate the CTags file.

## Known file types in 

The default **Known file types** list is alphabetical and includes the extension of every `CTAGSEXAMPLES/ddd.*` file. It fits SAL's 255-character string limit (251 characters), so some less common prior defaults that are not used by these examples were removed from the default. You can still add any file explicitly by its full filename.

When opening a project whose Known file types list exactly matches the previous package default, PROJ upgrades that list to the new one; customized lists stay as entered. This permits the existing `FOOBAR01` project to recognize the additional extensions after rebuilding and reopening it. Regenerate the CTags file after reopening. A directory scan determines which files enter the project; if a file still has no tag, check the project file list and then CTags parser behavior.

Default: `abap adb as asm asp awk bas bat bet btm c cc cfg cob cpp cs cxx dart e erl f90 go h hpp hs html hxx inc ini java js kt l lisp lua m mak ml mpl pas php pl pro ps1 py r rb rc rc2 rs rx s sas scala scm sh si sl sml sql swift tcl tex ts ui v vhd vr wl xml`

## Parser inventory correction in 

The tested Exuberant CTags 5.8 reports 41 built-in languages, including Vim and YACC, but not Ada or ActionScript. The configuration now supplies basic regex parsers for Ada (`.adb`, `.ads`, `.ada`) and ActionScript (`.as`). `CTAGSEXAMPLES` adds `ddd.vim` and `ddd.y`, bringing the inventory to 59 language entries and 60 sample files (both SAL extensions are tested). These two new parser rules and samples require testing with your Windows CTags.

The alphabetized default list includes `.vim` and `.y` and remains within SAL's 255-character limit. The previous default list is upgraded on project open; customized lists are preserved. To make room, the default no longer includes `cfg` and `rc2`, which may still be added manually. Rebuild the SAL macros, reopen the project, refresh the file list, and regenerate CTags.

## Mapping correction in 

Your CTags `--list-maps` output shows that its **Flex** parser maps Adobe Flex `.as` and `.mxml`, while `.l` maps to Lisp. The previous `ddd.l` example was a lexer sample mismatched to this executable. It is replaced by `ddd.mxml`, an Adobe Flex MXML candidate. The Ant parser recognizes `*.build.xml`, so the old `ddd.xml` is now `ddd.build.xml`. CTags does not have a generic XML parser. `.sl` maps to S-Lang, not Lisp.

The default Known file types list now includes `mxml`; the `.build.xml` file uses the existing `xml` extension. Earlier unmodified defaults upgrade on project open; custom lists are preserved. The MXML and Ant examples still need your CTags test. The BETA, HTML, Make, S-Lang, and TeX examples remain pending because their mapped parsers produced no tag; diagnose those parsers and sample syntax separately.

## TeX sample correction in 

The Exuberant CTags 5.8 Tex parser maps `.tex` but indexes document parts and sections, not `\newcommand`. The revised `CTAGSEXAMPLES/ddd.tex` defines `\section{TexGreeting}` and uses `TexGreeting` in later text. Regenerate the project CTags file and press F12 on the later occurrence; select the `ddd.tex` entry if a chooser appears. A direct `ctags.exe --excmd=n -f C:\TEMP\ddd_tex.tag C:\Users\knud_\Downloads\D\CTAGSEXAMPLES\ddd.tex` should emit a `TexGreeting` section tag. This replacement still requires verification on your Windows CTags build.

## Make sample correction in 

The tested Exuberant CTags 5.8 Make parser indexes macros (`m`), not targets. The previous `greet:` target produced no tag, so the revised `CTAGSEXAMPLES/ddd.mak` defines `GREETING = Hello from Make` and uses `$(GREETING)` in the `all` recipe. Regenerate tags and press F12 on `GREETING` in the recipe. The TeX `TexGreeting` section sample was verified by the user: F12 jumped from its later occurrence to the section at line 3.

If F12 shows a list of other files, it is listing definitions for the symbol under the cursor. A file does not appear there when it contributed no tag for that symbol. The Make correction still needs testing on Windows.

## HTML sample correction in 

The tested Exuberant CTags 5.8 HTML parser lists named anchors and JavaScript functions. The prior sample's heading `id="greet"` produced no tag. The revised `ddd.html` defines `<a name="HtmlGreeting"></a>` and uses that name in a later hyperlink. Regenerate tags and press F12 on `HtmlGreeting` in the hyperlink. Expected destination: the named anchor at line 5. The user has now verified this HTML jump. Make's `GREETING` example is now verified: F12 jumped from its recipe use to line 1.

## startup help

The startup message displays package version **** and explains **F1** help. Dismiss the message to open the Project menu; press **F1** there to open PROJ help. The menu also labels its Help entry with `<F1>`. This F1 binding applies while the Project menu is open. Recompile with `build.bat` before testing.

## optional INI prompt overrides

All three settings are empty by default, preserving interactive prompts:

| Setting | When configured |
|---|---|
| `projectdirectoryorfilename` | Bypasses the new-project filename prompt and the Open Project selection. A bare name such as `FOOBAR01` resolves to `PJ/FOOBAR01.pj`; other relative paths resolve from the package directory. Explicit project filenames supplied internally still take priority. Existing overwrite and close/save confirmations remain. |
| `scanpath` | Bypasses âEnter directory to scan or exact filenameâ when you add a list entry (Insert). An exact filename adds only that file; a directory uses the existing Known file types filter. Relative paths resolve from the package directory. |
| `scansubdirectories` | `yes` scans recursively; `no` scans only the selected directory. Empty keeps the question. Applies only to directories. Other values produce an error message. |

Example for a clean test installation:

```ini
projectdirectoryorfilename=FOOBAR01
scanpath=CTAGSEXAMPLES
scansubdirectories=no
```

Choose **New project** or **Open project** normally; these values do not automatically create a project or start a scan at startup. In **Project settings â Add files or scan directories**, press **Insert** to add the configured scan path, then **Enter** to save the list. Clear `scanpath` to enter other files interactively. Existing list entries are preserved.

HTML navigation has now also been verified by the user: F12 on `HtmlGreeting` in the hyperlink jumps to its named anchor. Recompile this version with `build.bat`; the new INI override code requires testing in TSE.

## startup Project menu selection

Set `startprojectmenu=New Project` (default) or `startprojectmenu=Open Project` in `proj0200.ini`. When the startup Project menu appears, the chosen entry is highlighted and waits for your action; press Enter to execute it. Empty also selects New Project. This setting applies to the startup menu; subsequent Alt+[ openings retain the existing menu behavior. Recompile and test the selection in TSE.

## BETA ordinary patterns

The supplied tag file contained no definition from `ddd.bet`. The BETA parser disables ordinary pattern tags (`p`) by default. The package configuration now adds `--beta-kinds=+p`, enabling them without replacing the built-in parser. `ddd.bet` is now multiline: `greet` is defined on line 4 and used on line 6.

Regenerate project CTags after installing this version. Press F12 on `greet` on line 6; expected destination is line 4. The project tag file should contain a `greet` entry for `ddd.bet` with kind `p`. This change still requires confirmation with your Windows Exuberant CTags 5.8 executable.

To isolate generation from the editor, run:

```bat
g:\utils\ctags.exe --options=proj0200_ctags_languages.conf --excmd=n -f C:\TEMP\ddd_beta.tag CTAGSEXAMPLES\ddd.bet
type C:\TEMP\ddd_beta.tag
```

Run these commands from the extracted package's main directory.

## CTags navigation keys

| Key | Action |
|---|---|
| F12 | Go to the definition of the symbol at the cursor |
| Ctrl+F12 | Enter a symbol name to look up |
| Shift+F12 | Go to the definition in a second window |
| Alt+Shift+F12 | Open the CTags menu |

All package source bindings, labels, example instructions, and README key references now use F12. Prior successful navigation tests were performed with the previous key binding; the replacement keys still need testing in TSE. Compile with `build.bat` and restart TSE to load the rebuilt macros.

This version includes the BETA ordinary-pattern fix from an earlier release. Regenerate CTags, then test **F12** on `greet` at line 6 of `CTAGSEXAMPLES/ddd.bet`; expected destination is line 4.

## resolve duplicate F12 binding

The previous version assigned F12 to both CTags lookup and Open file at cursor, producing warning 1106 and stopping `build.bat`. Open file at cursor now uses **Ctrl+Alt+F12**. CTags keeps **F12**, **Ctrl+F12**, **Shift+F12**, and **Alt+Shift+F12**. Recompile this version; compilation and navigation still require confirmation in TSE.

## Ant target indexing

The supplied project tag file had no entries from `ddd.build.xml`. The configuration now supplements the Ant parser with an explicit target-name regex. This indexes a target whose `name` attribute immediately follows `<target`, as in the packaged sample; it is not a general XML parser. The filename remains `ddd.build.xml` for Ant language detection.

Regenerate CTags and press **F12** on `AntGreeting` in `depends="AntGreeting"` at line 5. Expected destination: the target declaration at line 2. The lookup list shows only generated definitions, so a missing `.build.xml` entry previously meant that no matching Ant definition had been generated. Windows testing of this fix remains pending.

BETA navigation is now confirmed working by the user.

## explicit Ant filename-pattern mapping

The an earlier release trace correctly extracted `AntGreeting` but the generated tag file still contained no Ant entry. This version adds `--langmap=Ant:+(*.build.xml)`: an explicit filename wildcard rather than reliance on the executable's compound extension mapping. The explicit target regex remains. The mapping change needs verification with Windows Exuberant CTags 5.8.

After rebuilding and regenerating, test F12 on `AntGreeting` at line 5 of `ddd.build.xml`; expected destination is line 2. To check generation independently, run these commands from the package directory:

```bat
g:\utils\ctags.exe --options=proj0200_ctags_languages.conf --verbose --excmd=n -f C:\TEMP\ddd_ant.tag CTAGSEXAMPLES\ddd.build.xml
type C:\TEMP\ddd_ant.tag
```

The verbose output should identify the file as Ant and the output should include `AntGreeting`. If it still does not, force the parser to isolate filename detection:

```bat
g:\utils\ctags.exe --options=proj0200_ctags_languages.conf --language-force=Ant --excmd=n -f C:\TEMP\ddd_ant.tag CTAGSEXAMPLES\ddd.build.xml
```

## Ant detection for Windows CTags 5.8

The user's direct tests confirm that forced Ant parsing generates `AntGreeting` at line 2, while automatic detection reports `ddd.build.xml` as an unknown language. The configuration now uses `--langmap=Ant:+.xml` instead of the compound filename pattern. This maps all `.xml` files to Ant; it indexes Ant projects and targets, not arbitrary XML elements. Other language mappings remain unchanged.

Regenerate project CTags, then test F12 on `AntGreeting` at line 5 of `ddd.build.xml`. Expected destination: line 2. Automatic detection with the new simple extension mapping still needs confirmation on Windows.


## SLang example compatible with Exuberant CTags 5.8

The `ddd.sl` function header and body now occupy separate lines. The built-in SLang parser rejects header lines containing a semicolon, so the previous one-line function produced no tag. Regenerate the project CTags file, open `CTAGSEXAMPLES/ddd.sl`, and press F12 on `greet` in the final call (line 6). The expected destination is the definition on line 1. This change still needs testing in TSE on Windows.

## CTags chooser starts at the current file

When F12 finds multiple definitions, the chooser initially highlights the first matching definition from the current file. If none exists, it highlights the first match with the same file extension. Otherwise it retains the first match. All matches remain available, and Enter opens the highlighted definition. The list scrolls to show the selected row. Existing nearest preceding TSE SAL lookup remains in effect.

SLang, Ant, and Java example navigation has now been confirmed by user testing. The new chooser selection still needs compilation and testing in TSE on Windows.

## Remember the project file picklist selection

Reopening the project file picklist highlights the last selected filename and scrolls it into view. The filename field follows that selection. Selection is remembered while the macro remains loaded, for the most recently used project; restarting TSE clears it. If that file is removed or a different project is opened, normal initial selection applies. CTags chooser selection from an earlier release was confirmed by user testing. The new file picklist behavior needs compilation and testing in TSE on Windows.

## Edit history for every Ask prompt

All 11 executable `Ask()` calls now explicitly use `_EDIT_HISTORY_` as their history argument, including project filenames, directory scan prompts, search paths, associated extensions, project display names, CTags lookup/reference prompts, and Windows help prompts. Previously custom CTags and path prompt histories now use the shared edit history too. Configured INI overrides still skip their corresponding prompts. Recompile using build.bat; SAL compilation and runtime verification must be performed on Windows.

## Vera example with a top-level task

The Vera example now declares `task greet()` outside the `program` block and calls it inside that block. Previously the generated tags contained only the program name `ddd`. Regenerate CTags, open `ddd.vr`, and press F12 on `greet` in line 8; the expected destination is line 1. This example still requires testing with Windows Exuberant CTags 5.8.

YACC `.y` navigation was confirmed: test lowercase `greet` in `start: greet;`, rather than uppercase token `GREET`. SQL contains separate tags for table `greeting` and column `greeting.message`; the duplicate SQL file-picklist row remains under investigation and requires the project `.pj` file.

## Exact symbol filtering in the CTags chooser

The chooser now checks each returned symbol explicitly. Looking up `greeting` excludes `greeting.message`, even when the DLL returns that prefix match despite the exact lookup flag. Multiple definitions with the exact requested name remain selectable. A single exact definition opens directly. The SQL file list was confirmed to contain one filename; its two CTags rows represented a table and a column. Vera navigation has now been confirmed by user testing. Recompile and test F12 on `greeting` in line 3 of `ddd.sql`; it should jump directly to line 1.

## Alt+[ replaces Alt+P

The Project menu shortcut is now **Alt+[** (Alt plus the left square bracket). Startup instructions and documentation use the new shortcut. The help viewer print shortcut was changed too, so this package no longer binds Alt+P. Recompile all five macros using build.bat and restart TSE to load the new bindings. an earlier release remains the user-tested stable baseline; the an earlier release key binding needs compilation and testing on Windows.

## project reopen diagnostics and uppercase examples directory

Examples are stored in `CTAGSEXAMPLES/`. Recompile all five macros with `build.bat` using the compiler for the TSE version being tested.

Project reopening now avoids passing zero IDs to the previous-project and temporary-buffer cleanup calls. This is a defensive change for the reported rc24 exit, whose root cause is not yet confirmed. Every Open Project attempt writes `proj0200_project_open_trace.txt` beside the installed macros. The file is replaced at the start of each attempt and saved at each checkpoint, including before project-file loading, list restoration, previous-buffer cleanup, and the empty-ring file prompt. If TSE exits, retain this file before another attempt. Supply the rc24 and 4.50.30 traces separately, together with the corresponding project files. CTags traces describe symbol lookup and do not diagnose project reopening.

In customized TSE menus, use the command that invokes `EditFile()` to reopen the full project picklist; a Buffer List shows only currently loaded files. The user verified SAL definition lookup through the CTags menu in rc24; an existing F12 binding prevented the keyboard shortcut from reaching PROJ.

The SAL changes require compilation and runtime verification on Windows; no TSE compiler is available in the package preparation environment.

## visible loaded-language summary

While a project is open and the editor status line is enabled, its right-hand portion shows `Languages: Python / C / C++`, for example. The summary lists distinct recognized languages of files currently loaded in the normal file ring, updates after commands and on idle, and restores the current buffer and cursor after inspecting the ring. Files included in the project but not loaded are not counted. Unknown file extensions are omitted; `None` means no recognized language is currently loaded. `.s` and `.si` always mean TSE SAL, and `.pl` means Perl. This indicator describes filename mappings; it does not prove that a particular CTags parser indexed a file.

The status summary occupies up to 70 columns, limited to half the screen width, replacing the existing information in that portion of the status line while a project is open. Longer summaries end in `...`. Use **Alt+[ -> Loaded languages...** to view the summary (up to SAL's 255-character limit). The ordering follows the loaded file ring; each language appears once. Recompile all five macros. Compilation and visual behavior still require testing in Windows TSE rc24 and 4.50.30.

## Delete Project

Use **Alt+[ -> Delete project...**, select a saved project, and confirm. Close the selected project first if it is currently open; this prevents later autosaving from recreating its file. Cancellation keeps the saved files. The command validates the PROJ file identifier, deletes the `.pj` file and its adjacent same-name `.tag` file, and removes the project from the Open Project list. It clears a matching last-project profile value. Source files and directories, custom/shared CTags locations, and clipboard/history/key-macro sidecars are retained. Matching AutoLoad associations are removed from the project database. Errors are reported. This release also includes an earlier release's loaded-language indicator. Recompile and test on Windows TSE.

## Delete Project compiler fix

The Delete Project profile cleanup now uses the literal `LastProject` key in the support macro. Its earlier reference to `c_stIniLastProject` failed because that constant is conditionally declared only for the main macro. Recompile all five macros. The user confirmed compilation of the main macro in an earlier release; the corrected support macro still requires Windows compilation and runtime testing.

## language message wording

The Loaded languages message now reads `Current computer language(s) loaded:`, suitable for either one or several languages. Recompile with `build.bat`.

## Escape from the Load prompt

When files are already in the editor ring, Escape cancels the File(s) to edit / Load prompt and returns to the current file without an exit question. The exit confirmation appears only when the ring is empty, where cancelling that prompt can exit TSE. Recompile all five macros and verify the loaded-file and empty-ring cases in your TSE configuration.

## language indicator visibility and position

Corrected the reversed QueryEditState check that suppressed the indicator during ordinary editing. The language summary now begins just right of the screen midpoint and leaves the final 25 columns untouched for date/time information. If fewer than 16 columns remain for it, the status indicator is omitted; the Loaded languages menu entry remains available. Long lists are shortened with `...`. Recompile and check the status line while editing, outside a prompt.

## Emacs Lisp and VimScript

Emacs Lisp (`.el`) is now a separate language label and example; VimScript (`.vim`) was already included under Vim and is now labelled explicitly. There are 60 displayed language entries and 61 example source files, not two newly added parsers: Exuberant CTags 5.8 uses its existing Lisp and Vim parsers. Explicit `.el` and `.vim` mappings are included in the options file. The alphabetized default Known file types list now includes `el`; projects using the prior default are upgraded, while custom lists are kept. If your project has a customized extension list, add `el` manually before scanning a directory.

Recompile the macros, refresh the project file list, add the examples, and regenerate CTags. In `CTAGSEXAMPLES/ddd.el`, press F12 on `emacs-greet` in the call at line 5; expected definition is line 2. The identifier reader now supports hyphens and colons in `.el` symbol names. In `CTAGSEXAMPLES/ddd.vim`, press F12 on `Greet` in the call at line 6; expected definition is line 2. Both labels are included in the loaded-language status indicator. These examples require Windows CTags/TSE testing.

## CTags generation diagnostics

Removed a plain comment from the Exuberant CTags options file for compatibility. Emacs Lisp continues to use the built-in Lisp parser and the `.el` mapping. Generation now saves standard output and errors in `proj0200_ctags_output.txt` beside the macros, including when debugging is disabled. The saved batch command shows the actual output tag filename after `-f`; check that filename when inspecting the generated index. Rebuild with `build.bat`, regenerate CTags, and test F12 on `emacs-greet` in `CTAGSEXAMPLES/ddd.el`. If generation fails, send `proj0200_ctags_output.txt` and `proj0200_ctags_run.bat`. Windows SAL compilation and runtime testing remain to be performed on the user machine.

## Emacs Lisp navigation verified

The user confirmed that F12 navigation works for Emacs Lisp. All listed languages now have F12 verified status in the language table and example inventory. This release updates documentation and version labels; CTags behavior is unchanged from an earlier release.

## Markdown

Markdown is recognized in the loaded-language indicator and by the custom `ProjMarkdown` CTags parser. `CTAGSEXAMPLES/ddd.md` demonstrates heading navigation: regenerate project CTags, put the cursor on `Greet` in `See Greet for the greeting above`, and press F12 to jump to `## Greet`. Markdown indexes headings rather than functions or every word occurrence. The parser covers ATX headings (`#` through `######`), including optional closing hashes; Setext underlined headings and fenced-code awareness are not implemented. For headings containing spaces, use the CTags name prompt and enter the full heading title. The `.markdown` alias is also mapped; add it manually to Known file types when scanning that extension.

The default Known file types list now includes `md`. To stay within SAL's 255-character string limit, the optional `btm` batch alias was removed from that default; custom lists are preserved. Projects with the previous default automatically receive the new default. There are now 62 example source files. Markdown F12 navigation is pending user verification; Windows SAL compilation and CTags runtime testing are required.

## editor-session tools from PROJECTS

Open the project menu with **Alt+[**, then choose **Session tools**. This opens an integrated companion macro, `projsession.mac`, adapted from the attached `projects.s` by **Ian Campbell**, with later revisions credited in its source. The original `projects.s` is part of the TSE **Potpourri** options. Its adapted implementation is `SRC/MAC/projsession.s`; the unused original-source copy is omitted from this package. Rebuild using the usual `build.bat` command; the build now compiles and copies six macros, including `projsession`.

| Menu | Added functionality |
|---|---|
| File / Save session snapshot | Save named editor session and a `!!LAST!!.PRJ` copy; save modified disk files |
| File / Restore session snapshot | Restore saved files and editor context; existing ring files are retained |
| File / Save snapshot & Exit | Save successfully, then use TSE's normal Exit command |
| File / Save & switch session | Choose a snapshot, save the present session, close saved files, and restore the chosen snapshot |
| File / Add another snapshot's files | Add files and saved context from another snapshot to the current editor ring |
| File / List Open | Sortable ring list; name, path, extension and buffer-order sorting; recent-file cycling |
| Search | Audit bookmark navigation; find/repeat/find-word in a file or across open ring files; multi-file replace; toggle previous file |
| Utility | Standard TSE `clipview`, `timelog`, and `cmp2bkup` macros if installed |

Snapshots store normal file names, cursor/view coordinates, ordinary and audit bookmarks, the marked block, main and up to 26 named clipboards, histories, keystroke macros, working directory, editor version, insert/autoindent/wrap/margin state, video mode, and binary/hex state. The imported implementation uses TSE's internal history format; incompatible editor-version histories are skipped by default. SAL macro reloading remains disabled by default. Restoring a snapshot applies its editor settings and clipboards globally. Saving collapses split windows with `OneWindow()`; window layouts are not stored. Unsaved unnamed buffers are not captured as document contents. Source files must still exist on disk for restoration.

The portable snapshot store is **`PRJ/` beside `projsession.mac`**, created on first save. Snapshot sidecars are `.CLP` and `.KBD`. Native PROJ0200 project definitions and CTags remain in `PJ/`; `.PRJ` snapshots do not replace `.PJ` project membership, scan settings, or CTags configuration. Files restored into the ring are not automatically registered in the current `.PJ` project. Add them through the native project menu when needed. Multi-file searches operate on the editor ring, including files outside the active project. From the snapshot selection list, Delete offers confirmation to remove the snapshot and its sidecars; source files are kept.

Global Ctrl-K and right-click assignments and automatic startup takeover from PROJECTS were omitted. List-dialog shortcuts stay local to their dialogs; path sorting uses Alt+[. Existing PROJ0200 Alt+[ and F12 assignments remain in use. Session tools load on demand, retain audit/recent-file hooks after use, and can be reopened from the same project menu. Optional direct calls are `ExecMacro("projsession -save")`, `ExecMacro("projsession -restore")`, and `ExecMacro("projsession -append")`. No separate auto-loading setup is required. Macro-path lookup must find the package, as for the other PROJ0200 macros.

The integration preserves filename case, widens path variables to SAL's 255-character limit, adds `_EDIT_HISTORY_` to imported Ask prompts, avoids recursive control-file restoration, checks snapshot write results, and keeps TSE running when restored files are missing. Canceling the switch selection leaves the ring intact. Markdown navigation is now marked F12 verified following the user's successful test.

**Validation:** archive integrity and integration wiring were checked here. Windows SAL compilation and interactive session save/restore tests are still required. Test a named snapshot using a few saved files, a bookmark, a clipboard and changed cursor positions; restart TSE, open Session tools, restore it, and verify the state. Also test cancellation and mixed `.PJ`/`.PRJ` use before adopting the session tools for everyday work.

## session menu compiler correction

Fixed the Configure entry in the session menu bar: SAL requires a menu there, so it now opens `ConfigMenu()`, whose information item displays the integration message. The reported an earlier release compiler error at line 2113 is corrected. The first five macros compiled successfully in the user test; `projsession.s` still needs recompilation and runtime testing.


## launching Session tools

The Project menu now queues the Session tools request and launches the companion menu bar after closing the Project menu and restoring its menu state. Previously the companion menu bar was invoked inside the still-active Project menu. Missing or incompatible `projsession.mac` now produces an explicit warning. Rebuild, restart TSE, choose Alt+[ then Session tools, and verify that the File/Search/Utility/Configure/Help menu bar appears. This launch correction still requires runtime verification on the user machine.

## advance the file picklist

When reopening the project file picklist, highlight the file immediately below the previously selected file in the same project. For example, selecting and editing `ddd.asp` then returning to the file list highlights `ddd.awk`. The prompt filename also follows that highlighted row. At the final row, keep the final file selected rather than wrap to the first. If the prior file is no longer listed or the project changes, use the usual initial selection. CTags lookup lists retain their existing selection behavior. Rebuild and test this change in TSE.

## context above the next file

Reopening the project picklist still highlights the next file, but now shows up to three preceding filenames above it. Near the beginning of the list it shows as many preceding entries as exist. Small picklist windows reduce that context so the selected row stays visible. CTags result lists are unchanged. Rebuild and verify in TSE.

## keep editor files open during project setup

New Project no longer asks to close all open files and no longer saves or abandons document buffers as part of that question. Open Project also keeps previous document buffers rather than silently abandoning unchanged files absent from the opened project. Existing unsaved edits stay in the ring. Project metadata can still be saved or replaced; ring membership and project membership are separate. Explicit file-close, editor-exit, and session save/switch commands retain their stated actions. Rebuild and verify New/Open Project with both saved and modified files already open.

## Escape cancels without exiting

Escape at the package-managed File/File(s) to edit prompt no longer asks to exit TSE. With files in the ring it cancels the prompt and returns to the editing context from which it was opened. an earlier release replaces the empty-ring fallback described in the original an earlier release implementation: Escape keeps the empty file prompt active without creating a document. Further Escape presses in editing have the editor configuration's normal binding; PROJ0200 does not assign them to Exit. Explicit exit commands remain available. Rebuild, restart, and verify repeated Escape from the file list and project menus, including an initially empty ring.

## Escape never creates an unnamed document

Escape at a package-managed file prompt returns to the existing editing context when files are open. If the file ring is empty, Escape leaves the file prompt active instead of creating an unnamed buffer or requesting editor exit. New/Open Project keep existing document buffers open. Explicit editor exit commands remain available. Rebuild and restart TSE to test this change.

## Escape behavior tested


On 2026-10-01, the user tested the Escape behavior in an earlier release and confirmed that it works correctly: cancelling the file picklist returns to the existing editing context without asking to exit TSE or creating an unnamed buffer. This tested behavior is retained in an earlier release. The empty-file-ring behavior remains to keep the file prompt active; it was not separately confirmed by this test.

## Missing project file diagnostics

Opening a missing project now reports the full project filename and explains that the file or PJ directory may have been deleted. Restore the project metadata or create a new project. A failed project save also reports its filename and asks you to check whether the directory still exists and is writable. These messages do not recreate deleted project membership. The Escape behavior tested in an earlier release is unchanged.

## Opening projects does not save or close documents

Removed the changed-file save questions from Open Project. Switching project membership leaves existing open documents and their unsaved edits in the ring. Existing buffers are also kept when a saved project requests binary mode; they are not discarded to change mode. Project metadata may still be saved by project operations. Explicit document Save, Close and editor Exit commands retain their normal behavior. Session snapshot Save/Switch is a separate explicit operation. Rebuild and restart TSE, then test opening another project with modified documents in the ring.

## Quiet startup by default

The supplied `proj0200.ini` now sets `silent=true`, so opening the Project menu does not repeatedly display the informative startup box. Set `silent=false` to show that information again. Error warnings and setup dialogs remain available. The source fallback when the INI is missing remains `silent=false`.

## Change Projects menu entry

Use **Alt+[ â Change Projectsâ¦** to choose another existing project. This entry uses the same project selector as Open project. Existing open documents and unsaved edits remain in the ring; project membership changes to the selected project. Open project remains available. Rebuild and restart TSE to load the updated menu.

## One-time launcher introduction

`showbeginmessage=true` is the new default in `proj0200.ini`. The first successful run of `projstart.mac` in a TSE session shows the introductory Warn() message once. Subsequent launcher runs and Project menu openings do not repeat it. Restarting TSE resets the one-time state; purging/reloading the launcher does not. Set `showbeginmessage=false` to disable the one-time launcher message. This setting is independent of `silent=true`, which continues to suppress the ordinary repeated introduction. With `silent=false`, ordinary direct runs of proj can still show that introduction. Error warnings are unaffected. Rebuild and restart TSE to test.

## Change Projects menu hotkey

Change Projects now underlines **g** (`Chan&ge Projects...` in SAL). Open the Project menu with **Alt+[**, then press **G** to choose Change Projects. G does not conflict with another active entry in this menu. Rebuild and restart TSE to apply the menu change.

## Project selector highlighting and selection

The project selector clears the copied block before displaying its list, preventing block highlighting from making several project rows look selected. Choosing an existing project explicitly disables the separate filename prompt and uses that selected project path. Only Open other project file requests a filename. This applies to the shared project selector. Rebuild and restart TSE, then test Change Projects with two saved projects.

## Project menu stays available

After a completed Project menu action, the menu is shown again. Press Escape in the Project menu to leave it and return to the editing context. Session tools still opens outside the active Project menu and returns to it afterwards. Ordinary file-picklist and F12 navigation commands are unchanged. Rebuild and restart TSE; verify New Project, Open Project, Change Projects, Close Project and Escape.

## View current active project

Use **Alt+[ â View current active projectâ¦**, or press **A** in the Project menu. It displays the current project name followed by its full saved `.pj` filename. If no project is active, it reports that explicitly; an unsaved project is identified as having no saved filename. This information command does not change projects or documents and keeps the menu available. Rebuild and restart TSE to test.

## Active-project command declaration

Added the forward declaration of PROJ_ShowActiveProject before the Project menu definitions, correcting the undefined-symbol error reported when compiling an earlier release with SAL Compiler V4.50.rc23. The command behavior is unchanged. Rebuild to verify compilation on your machine.

## Project selector navigation

Replaced the project selector's legacy List call with lList, as used by the other project lists. The selected project is read from the selector buffer after acceptance. Explicit CursorUp/CursorDown bindings move one row in the indicated direction and stop at the first/last row. Selector keys are disabled on cleanup. These changes address the reported failure to switch projects and confusing arrow navigation; they need testing with the two saved projects on your TSE installation. Rebuild and restart TSE.

## Preserve project-name case

The project selector now displays project names and directories in their stored case, without title-casing names or lowercasing directory labels. For example, PROJ0200CTAGSEXAMPLES stays uppercase. Case-insensitive path comparisons remain for matching Windows filenames; they do not modify the stored names. Rebuild and restart TSE to apply the display change.

## Native project-list highlighting

Removed the project selector's custom drawing hook, which applied menu-letter colors to the entire project name and made unselected names look highlighted. TSE now draws the project list with its native list colors and selected-row highlighting. Names retain their stored case; stored directory paths may appear directly in the list. Rebuild and restart TSE, then verify one selected row while moving Up/Down.

## Package cleanup

Removed COMDATABASEMYSQL.BAT: it is unrelated to PROJ0200 and is not part of this package. Project selector highlighting in an earlier release was tested by the user and confirmed to work as expected. Program behavior is unchanged in this cleanup release.

## View all projects

Use **Alt+[ â View all projectsâ¦**, or press **V** in the Project menu, to view the saved project names recorded in the project database. Enter or Escape closes the view and returns to the Project menu. Viewing does not open, switch, save or delete a project. Use Change Projects to activate another project. Rebuild and restart TSE to test the new command.

## Export and import project records

The Project menu includes Export Project, Export All Projects, Import Project and Import All Projects. These transfer saved `.pj` records containing filenames, membership and project settings; they never copy source-file contents. Export Project selects a registered project and asks for a destination `.pj` filename. Export All Projects writes the registered saved projects to an existing directory. Import Project copies one `.pj` into the package project directory and registers it; Import All Projects imports every `.pj` in the selected directory, without recursion. Replacing an existing destination requires confirmation. Import does not activate the project or close documents.

Exports use the last saved project record: explicitly Save Project first if you want recent membership changes included. Referenced document paths are preserved, so those documents must remain available at those paths after import. Only `.pj` records are transferred; CTags indexes and session sidecars are excluded. Regenerate CTags when needed. Cancelled or skipped files are not counted in the transfer total. Rebuild and restart TSE; these new commands need Windows SAL compile and runtime testing.

## Import helper declaration

Added the forward declaration for EnsureProjectDirectory before the new import code, correcting the undefined-symbol error reported for an earlier release. Export/import behavior is unchanged. Rebuild with your SAL compiler to verify.

## Validate saved-project entries

Project selection, View all projects and batch transfers validate database entries against an existing `.pj` containing the PROJ project-file identifier. Stray document names and missing/invalid project records are excluded from these views and batch exports. The underlying database is not deleted or rewritten by this filtering. A name containing a period remains valid if it actually has a matching saved project. Rebuild and restart TSE to verify the lists.

## The project file picklist preserves filename and directory capitalization instead of applying title case or lowercase. The forced rebuild introduced in an earlier release has been rolled back in an earlier release because it caused flickering. Case-insensitive filename matching remains available. Recompile with build.bat and restart TSE. These SAL changes require testing in TSE.

## Removed the forced file-list rebuild at File > Open. The earlier refresh behavior is restored, while filenames and directory names retain their original capitalization. Recompile and restart TSE; runtime verification is still required.

## The project menu now has hotkeys X for Export All Projects and M for Import All Projects. The ampersand marks the selected letter in each menu definition. These two letters do not conflict with other current project-menu hotkeys. Recompile with build.bat and restart TSE.

## buffer-based Known file types

Known file types are now held in a temporary buffer, one extension per line, and saved in the project `[KnownFileTypes]` section. There is no 255-character limit on the whole list. New projects use `proj0200_filetypes.txt`; edit the defaults through Settings > Known file types. Old `Extensions=` entries are not read or migrated. Create new projects for this format.

Project settings > Known file types opens the line list. Insert adds a new extension at the top, Delete removes the selected entry, and Escape returns. Each extension is entered without a leading dot. New entries retain all existing entries. Save Project retains the settings.

Directory scanning gathers filenames and then filters them against the buffer directly. If no recognized files exist but unrecognized extensions were found, a list shows the missing extensions and a Yes/No question offers adding them at the top. Accepting filters the existing scan results again; it does not start a second directory scan. Normal File > Open does not force continuous rebuilding. Exact file sources continue to be included directly.

The supplied `proj0200_binarytypes.txt` contains the user's excluded extensions, one per line, without a leading dot. Matching is case-insensitive. These types are excluded from suggestions; an explicitly selected file remains the user's choice. This is an extension exclusion list, not a content-based binary detector.

Recompile with build.bat and restart TSE. The ZIP and buffer/filter invariants were checked locally. SAL compilation and TSE runtime testing remain necessary on Windows.

## load every project file

Open or change to the desired project, then choose Load all files in current project (menu hotkey 2). This opens all files from the project picklist. Already open files are skipped, preserving unsaved edits. Files missing from disk are skipped and counted; no empty replacement document is created. A final message reports loaded, already open, and missing/failed counts. If the directory scan is pending, loading follows its completion. A project switch cancels any queued load. The previously active document is restored after loading.

Recompile and restart TSE. Windows SAL compilation and runtime testing remain required.

## Rename project and explicit menu hotkeys

Open the project to rename, then choose R: Rename project. Enter its new name; capitalization is preserved. The project is saved under the new name in the same directory, its database entry and AutoLoad references are updated, and the old .pj file is removed after a successful save. Existing destination projects are not overwritten. Source files and open documents are kept. Regenerate CTags afterward; old tag/history/keyboard sidecar files may remain under their previous names.

The main project menu uses the explicit &character: Label notation from the supplied example. Hotkeys are N New, Y Copy, O Open, G Change, A Active, V View all, L Load all files, E Export, X Export all, I Import, M Import all, S Save, C Close, D Delete, R Rename, 2 CTags, B Clipboards, 3 Refresh, 4 Settings, 5 Options, 6 Help, 7 Languages, and 8 Session tools. Press F1 for help as before.

Recompile and restart TSE. The ZIP and menu hotkey uniqueness were validated locally; SAL compilation and runtime testing remain required.

## All occurrences of the word projects in the main project-menu labels are lowercase. Hotkey prefixes remain unchanged. Recompile and restart TSE.

### Updated hotkeys in version 

The main project menu uses unique uppercase letters before digits or punctuation. First letters are preferred where available; conflicting labels use another letter. The current keys are N New, Y Copy, O Open, G Change, A Active project, V View all, L Load all files, E Export, X Export all, I Import, M Import all, S Save, C Close, D Delete, R Rename, T CTags, B Clipboards, F Refresh, P Project settings, Q Options, H Help, U Loaded languages, and J Session tools. The label format is &character: Label. F1 still opens help.

## The single-project menu labels now read &I: Import project... and &E: Export project..., with project in lowercase. Existing uppercase hotkeys are retained. Recompile and restart TSE.

## close saved project files in the editor ring

Open or change to the desired project, then choose K: Close saved files in current project. This closes only currently open files present in that project's picklist. It keeps modified buffers, files not yet saved to disk, and buffers outside the project. Project membership, directory sources, and disk files are unchanged. Load all files in current project can reopen them later.

If closing the last editor buffer would exit TSE, that buffer is retained. No unnamed replacement buffer is created. A final message reports closed files, unsaved files retained, and last-buffer protection. If the file scan is pending, closing follows its completion; changing or closing the project cancels a queued operation.

Recompile and restart TSE. ZIP integrity, menu hotkey uniqueness, and the unsaved/last-buffer guards were checked locally. SAL compilation and Windows runtime testing remain pending.

## close saved files across all projects

K: Close saved files in current project closes only members of the active project's picklist. W: Close saved files from all projects closes saved named files across the entire editor ring, including open files not associated with a project. It does not require an active project. Both actions retain modified buffers, unnamed buffers, files not yet saved to disk, and the last buffer needed to keep TSE running. Neither changes project membership, saves source files, or deletes files on disk. A final message reports what was closed and retained.

Recompile and restart TSE. ZIP integrity, unique hotkeys, and source guards were checked locally; SAL compilation and runtime tests remain pending.

## prominent main-menu actions

Moved all three scoped searches and all six disk refresh actions directly onto the main project menu. Unique hotkeys are Z and 1â8. The one-time YesNo warning before overwriting unsaved edits remains in place. Recompile after extracting this release, restart TSE to unload older macros, and run projstart. SAL compilation and Windows testing remain pending.

## Added a main-menu divider between the three Search actions and the six Refresh actions.

## Grouped search and refresh into two prominent main-menu entries with three and six submenu actions respectively. Submenu labels carry ASCII character decimal 16 at the right of their text. The unsaved-edits YesNo warning remains unchanged.

## centered list dialogs

Open/Change project now centers its project selection box horizontally and vertically at startup and during editing. The same positioning is applied to directory/file membership, all saved projects, autoload projects, known/missing file types, clipboard contents, CTags selection lists, and search results. Large lists are clamped to screen bounds. Cascading submenus retain their normal menu behavior. Recompile and restart TSE to test the updated positioning.

The main-menu labels are now Search projects and Refresh projects, each followed by ASCII decimal 16.


## import/export and total known file types

In Project settings > Known file types and Settings > Known file types, right-click for the mouse-aware action menu:

- **I: Import all file types...** (Ctrl+I): choose a plain text file containing one extension per line. New extensions are added at the front in file order; existing entries remain. Case is normalized and an optional leading dot is removed. Duplicates are not added; invalid or binary-excluded extensions are skipped. The result reports how many were added or skipped.
- **E: Export all file types...** (Ctrl+E): choose an output filename. All nonempty extensions are exported, one per line, in displayed order. Replacing an existing output file requires confirmation.
- The footer displays **Total**, counting nonempty entries, and refreshes after adding, removing or importing.

Save Project to retain current-project changes. Use Save in the Settings list to persist the defaults. The existing default extensions are retained for this release; a larger revised default list can be supplied later. The complete list is buffer-based and is not limited to 255 characters.

Rebuild with build.bat and your sc32.exe before testing. SAL compilation and TSE mouse/runtime testing are pending on Windows.


## normal editing and clickable Save

Known file types now has **Enter/Left=Edit** and **Ctrl-S/Left=Save** status labels. Click the labels with the left mouse button. The right-click actions menu also offers **Edit all file types** and **Save file types**. Enter or selecting an extension opens normal TSE text editing of the complete buffer.

In edit mode, use normal TSE cursor movement, text editing, selection and clipboard commands. Keep one extension per line. **Ctrl+S** or clicking **Ctrl-S/Left=Save** saves and returns to the list. **Escape** or clicking **Esc/Left=Return to list** returns with pending edits retained. Returning refreshes the nonempty-entry total.

Save writes the current project through the existing Save Project operation. When editing Settings > Known file types, it writes the defaults file instead. A failed save retains edits and reports the failure. Defaults are now written only by the explicit Save action.

Windows SAL compilation and mouse/runtime verification remain pending; rebuild before testing.


## discover extensions and sort

Right-click in Known file types for four discovery actions and Sort:

| Action | Shortcut | Files examined |
| --- | --- | --- |
| Current file | Ctrl+F | The named file active before opening Known file types |
| Current project | Ctrl+P | Explicit filenames and assigned project directories |
| All projects | Ctrl+A | Current project membership plus registered saved projects |
| TSE ring | Ctrl+R | Named normal documents already open in the editor |
| Sort file types alphabetically | Ctrl+O | Complete displayed list, ascending, ignoring case |

Project directory discovery bypasses Known file types so previously unknown extensions can be found. Assigned subdirectory recursion and excluded paths remain in effect. All-project discovery uses each saved project's assigned paths; cached filenames are a fallback when no paths exist. It adds the combined results to the list being edited, without changing other projects. Files in archives are not unpacked for this operation.

Extensions are normalized to lowercase without the leading dot. New entries are added automatically; existing entries are retained and duplicates are not added. Files without an extension add nothing. Discovery includes binary-file extensions too, because these actions request all filename extensions. It reports filenames processed, extensions added and scan errors. Current-file and ring discovery use filenames in memory and do not require the files to be saved on disk. Unnamed buffers are omitted.

Discovery does not open or edit source files. The result can be edited, sorted or exported before deciding to save it. Ctrl+S or clicking Save persists the current project's list through Save Project, or the default list through Settings. Defaults are no longer automatically saved on exiting Settings. Current-project changes remain in memory and can also be persisted by a later ordinary Save Project; Settings edits are discarded on exit unless explicitly saved.

Rebuild all macros with build.bat. Source and ZIP checks were performed; Windows SAL compilation, PowerShell execution and TSE mouse testing remain pending.


## combined projects and ring extension scan

Known file types > right-click > **B: Scan extensions in all projects + TSE ring** (Ctrl+B) combines the all-project scope with every named normal document in the TSE ring. It includes current in-memory project paths, registered saved project paths and ring filenames in one request. Directory discovery bypasses Known file types while retaining assigned recursion and excluded-path rules. Ring filenames are included even when outside all projects or not yet saved on disk. Duplicate extensions are not added.

The results update the list currently being edited. Use Sort, Edit, Export or Save afterwards as desired. Save remains explicit; this action does not save other projects. Rebuild before testing. Windows SAL/PowerShell/runtime checks remain pending.


## show extension scan errors

A failed or partially failed discovery scan displays the actual helper errors in a horizontally scrollable list before the result summary. Errors are also saved beside the macros in proj0200_filetypes_scan_errors.txt. This provides the reason behind a result such as zero filenames and one scan error. Rebuild before testing; Windows compilation/runtime verification remains pending.


## Settings menu

The main-menu entry previously named Options and its submenu title are now Settings. The existing Q shortcut is retained. Settings > Known file types edits the default extension list. Internal configuration section names are unchanged, preserving saved configuration compatibility.


## wider Known file types window

The Known file types list is widened from 55 to 100 text columns, capped at the available screen width minus four columns. This fits the total and import/export shortcut footer on wider editor screens. Windows runtime verification remains pending.


## visible Save shortcut

The wider Known file types window now explicitly includes Ctrl-S: Save in its footer, in addition to the clickable Ctrl-S/Left=Save status label and right-click Save action.


## Save shortcut at the left

The Known file types footer begins with Total followed immediately by Ctrl-S: Save, keeping Save visible even on narrower screens.


## mouse-aware Return in Known file types

The list and text-edit view now show `Escape/Center: Return`. Press Escape, click the centre mouse button, or left-click the status-line Return label. In text editing these actions return to the list; in the list they return to the previous menu. Save remains a separate action. The footer places Return beside Save so both remain visible. OpenAI Codex (GPT-6). Windows SAL compilation and mouse testing remain pending; run build.bat before testing.


## clickable Save in the list footer

The Known file types list footer now uses native TSE mouse hotspots: {Ctrl S}: Save and {Escape}/Center: Return. The previous plain footer text was not a hotspot; the custom click handler only checked the separate status line. Footer clicks now pass through ProcessHotSpot to the existing Save/Return key actions. Import, Export, Insert and Delete use the same native footer mechanism. OpenAI Codex (GPT-6). Rebuild with build.bat; Windows compilation and mouse verification remain pending.


## whole-label mouse handling

Known file types now explicitly hit-tests the whole Save label, including the word Save, in both the list footer and the status line. Mouse coordinates are converted from popup-relative to screen coordinates, following the existing CTags popup handler. Return, Import and Export footer labels use explicit hit-testing too. OpenAI Codex (GPT-6). Rebuild with build.bat; Windows compilation and mouse testing remain pending.


## automatic refresh before project viewing

View projects now starts a pending current-project file-list rebuild automatically and resumes viewing after Idle_Reload finalizes the list. This handles invalidation after Known file types edits and includes the newly recognized extensions. Current-project and all-project filename lists use the same readiness bridge. Current-file and TSE-ring scopes remain immediate. Cancelling the project rebuild clears the queued action. OpenAI Codex (GPT-6). Rebuild with build.bat; Windows compilation and runtime verification remain pending.


## import all projects first

Import projects now lists A: Import all projects first, followed by I: Import project. Existing hotkeys and import actions are retained. OpenAI Codex (GPT-6). Rebuild with build.bat.

Replaced the default Known file types and the built-in fallback with all 358 unique extensions from dddfileextensionsall(1).txt, in the supplied order. Existing projects retain their saved [KnownFileTypes] lists. OpenAI Codex (GPT-6). Rebuild using build.bat before use.

Compact tokenized fallback for all 358 Known file types fixes the macro-size increase introduced in 291. OpenAI Codex (GPT-6). Windows SAL compilation remains to be verified.

Removed embedded extension fallback data to reduce proj.mac below its prior size. All 358 default extensions remain in proj0200_filetypes.txt. A missing defaults file produces a message asking to restore it. OpenAI Codex (GPT-6). Windows SAL compilation remains unverified.

## script creation and logs

Create script... is directly below Create project... in the main menu.
Choose a new .pjl filename. List() offers every supported command, a custom
line, editing the last line, and Save and return to editor. Selecting a command
opens an editable template; Enter inserts it, Escape cancels that insertion.
The list repeats for the next command. Escape from the list returns to the
normal editor with the script buffer retained; save any further edits.

openallprojects "C:\TEMP\DDDPJ\" imports and registers valid .pj records
from that directory (nonrecursive). It does not restore every project's files
into the editor. Only one project is active at once; the next command can be
openproject PROJ0200HELLOWORLD. Existing destination records use the same
copy behavior as Import all projects. Invalid records are skipped with WARNING;
no valid records or a failed copy stops execution with ERROR.

Script errors create pjlYYYYMMDDHHMMSS.log in the package directory. Each event
uses local Windows time: YYYY-MM-DD HH:MM:SS ERROR/WARNING/INFO message.
ERROR records the script filename, line, and failure. WARNING records skipped
invalid projects. INFO records the completed-command count after a logged run.
Successful runs without warnings do not create a log. Existing same-minute
logs are appended. These .pjl log files are plain text, not executable scripts.
The portable logging helpers use powershell.exe from PATH; script text is
passed through a data file, never evaluated as shell commands.

Rebuild using build.bat. SAL compilation and Windows runtime tests are pending.
Test Create script, openprojects.pjl (adapt the directory), and errorstest.pjl.
OpenAI Codex (GPT-6).

While editing an existing .pjl script, Run scripts > K: Insert PJL keyword
opens the same List(). The selected editable command is inserted at the
current cursor. Commands can also be typed directly in the normal editor.

Main menu shows 4: Create script... directly below Create project...; G: Copy project... now follows Calculate projects. Rebuild with build.bat, then restart TSE to load the newly compiled resident proj.mac. OpenAI Codex (GPT-6). Windows compilation and runtime verification remain pending.

Session Tools About reports the package version and path published by the loaded main proj.mac, separately from the Session Tools version. It shows a mismatch message when versions differ, or Unknown when an older main macro does not publish its package version. Purging the main macro clears its published identity. OpenAI Codex (GPT-6). Rebuild and restart TSE. Windows compilation and runtime verification remain pending.

Help > About credits include previous author Chris Antos - 2002-05-19, alongside Ian Campbell. OpenAI Codex (GPT-6). Rebuild with build.bat and restart TSE.

Help > About credits also include ChatGPT - 2026-08-28. OpenAI Codex (GPT-6). Rebuild with build.bat and restart TSE.

Help > About credits also include Knud van Eeden - 2026-08-28. OpenAI Codex (GPT-6). Rebuild with build.bat and restart TSE.

About now displays a buffer-based list with separate lines, avoiding the 255-character message-string limit. All four author credits are shown, including OpenAI ChatGPT GPT-6.1 Sol Light - 2026-08-28 and Knud van Eeden - 2026-08-28. OpenAI Codex (GPT-6). Rebuild and restart TSE; Windows compilation and runtime verification remain pending.

About credit uses OpenAI ChatGPT GPT-6.1 Sol Light - 2026-08-28. About retains the separate-line list so all author credits remain visible. Rebuild and restart TSE. Windows compilation and runtime verification remain pending.

Create script reopens the initially saved .pjl as a normal named editor file before adding commands. This fixes File has no name when selecting Save and return to editor. OpenAI Codex (GPT-6). Rebuild and restart TSE. Windows compilation and runtime verification remain pending.

Run scripts defaults to the main PROJ0200 directory and *.pjl. Previous script filenames remain available from history without overriding the default directory. The original working directory is restored after cancellation or execution. OpenAI Codex (GPT-6). Rebuild and restart TSE. Windows runtime verification remains pending.

openallprojects removes a trailing filename wildcard added by ExpandPath before constructing the *.pj search. This fixes No valid .pj projects found for directories resolving to path\*.*. OpenAI Codex (GPT-6). Rebuild and restart TSE. Windows runtime verification remains pending.

PJL logging overwrites stale event files and reports event-file or buffer failures. Helper diagnostics go to proj0200_pjl_log_errors.txt; returned log paths are checked for existence. INFO is written only after a successful ERROR event. Test errorstest.pjl to trigger an unknown command and a timestamped log. OpenAI Codex (GPT-6). Windows runtime verification remains pending.

PJL log filenames use pjlYYYYMMDDHHMMSS.log, for example pjl20261013191530.log. Logging includes seconds and retains ERROR, WARNING and INFO timestamps. Stale event files are overwritten and logging failures report diagnostics in proj0200_pjl_log_errors.txt. Test errorstest.pjl. OpenAI Codex (GPT-6). Windows runtime verification remains pending.

Each logged script run reserves a new pjlYYYYMMDDHHMMSS.log using exclusive CreateNew mode. Existing logs are never overwritten or reused for a new run; a timestamp collision waits for the next available second. Later events append to the same run log. OpenAI Codex (GPT-6). Windows runtime verification remains pending.

PJL ERROR log entries and final error messages include a one-based source column. Token columns preserve leading spaces and tabs (each tab counts as one source character). Unknown commands point to the command; invalid parameters point to the parsed token; overlength lines point to column 256. File/read failures use line 0 column 1 when no source location is available. OpenAI Codex (GPT-6). Windows compilation and runtime verification remain pending.

Run scripts lists R: Run Project Language script (.pjl)... first, followed by K: Insert PJL keyword.... Existing actions and hotkeys are retained. OpenAI Codex (GPT-6). Rebuild and restart TSE.

New PJL command viewcurrentactiveproject takes no parameters and invokes the same name, filename and description dialogs as View current active project. No active project or extra parameters produce a logged ERROR. The command is included in the keyword picker and pjl.txt syntax definitions. OpenAI Codex (GPT-6). Rebuild and restart TSE; Windows compilation and runtime verification remain pending.

Run projects now lists R: Run scripts first, above F: Run block or files. Existing hotkeys and actions are retained. OpenAI Codex (GPT-6). Rebuild and restart TSE.

Run a PJL script through the macro parameter:
  projstart.mac newscript.pjl
  projstart.mac "C:\TEMP\my script.pjl"
  proj.mac newscript.pjl
  proj.mac -RunPJL "C:\TEMP\my script.pjl"
Relative script filenames resolve from the main PROJ0200 directory. The filename prompt is skipped. No parameter retains the existing menu behavior. Script errors use the existing timestamped .log mechanism. These are TSE Execute Macro commands; projstart.mac is not a standalone executable. OpenAI Codex (GPT-6). Rebuild and restart TSE; Windows compilation and runtime verification remain pending.

Restored the clean an earlier release implementation. CmdLineParameter source, test macro, build integration and -p parameter capture from an earlier release are absent. In-editor Execute Macro support remains: projstart.mac newscript.pjl. OpenAI Codex (GPT-6). Rebuild and restart TSE.

New PJL command viewallprojects takes no parameters and calls the existing View all projects action. It displays saved project names without switching the active project and does not require an active project. Included in the keyword picker and syntax highlighting. OpenAI Codex (GPT-6). Rebuild and restart TSE; Windows compilation and runtime verification remain pending.

openallprojects can be run repeatedly. Existing valid destination project records are retained and registered, counted as available projects, and do not show replacement prompts. Only missing records are copied. An invalid existing destination reports ERROR without overwriting it. Use the interactive Import action when intentionally replacing an existing record from the source directory. OpenAI Codex (GPT-6). Rebuild and restart TSE; Windows runtime verification remains pending.

PJL pause [text]

pause displays Press a key to continue... and waits for the user to dismiss
the native TSE/selected Windows OK dialog, then continues the script.
pause Some text here displays that text and waits.
pause "Some text here" is also supported; unmatched quotes report ERROR.
Commands are case-insensitive: PAUSE, Pause and pause are equivalent.
Included in the keyword picker and syntax highlighting.
OpenAI Codex (GPT-6). Rebuild and restart TSE; Windows verification pending.

AI selection under Run projects

Run projects > A: Run AI... launches the supplied runprain macro as a
separate companion. It retains the complete AI choice list, web URL
launching, command-line alias execution, and Ctrl-F12 binding from the
submitted source. Escape returns without launching a choice.

The build compiles SRC\MAC\runprain.s and copies runprain.s/runprain.mac
to the package root. Its existing implementation and original credits
are preserved, with a package-version header added.

Command-line choices require the original macro's configured TCC and
alias-file paths (dddpath.ini settings); optional setwiyde.mac is referenced
by its existing diagnostic helpers. These personal dependencies are not
bundled or changed by this integration. Web entries use StartPgm(URL).
No AI service is launched merely by opening the menu.

OpenAI Codex (GPT-6). Rebuild with build.bat and restart TSE.
Windows SAL compilation and launch testing remain pending.

syntax highlight conversion

Change projects > S: Convert syntax highlight .txt to .syn or .syn to .txt
runs the package's syncfg2.mac without parameters, using its existing
interactive/current-buffer interface. Open the syntax highlight file to
convert before selecting the action.

Includes syncfg2.si, common.h and syncfg.inc from syncfg2knud 
in both the package root and SRC\MAC. Component code and its version are
preserved. build.bat compiles syncfg2.si and copies syncfg2.mac and its
sources to the package root. No external converter program is needed.
The converter's explicit file and directory parameter modes remain available.
OpenAI Codex (GPT-6). Rebuild and restart TSE; Windows compilation and
menu/runtime verification remain pending.

Session Tools actions in project menus

Search projects: Replace across open files; Audit bookmarks forward/reverse.
View projects: Toggle to previous file; List open / recent files (sorting
and recent-file keys remain available inside the list).
Save projects is now a submenu: Save current project; Save session snapshot.
Load projects: Restore session snapshot; Add another snapshot's files;
Save and switch session. Snapshots are distinct from .pj project records.
Backup projects: Compare current file to backup (requires the existing TSE
cmp2bkup.mac in the macro search path; it is not included in this package).

Actions reuse Session Tools routines and run after the main menu's buffer,
block and display cleanup. Session Tools load on demand; file/bookmark
tracking starts when those tools load. The original Session Tools menus
remain available. Cross-file replacement operates on the editor ring.
OpenAI Codex (GPT-6). Rebuild and restart TSE; Windows compilation and
runtime verification remain pending.

Removed ten duplicate Session Tools menu entries now available through the main Search/View/Save/Load/Backup menus: open/recent list, previous-file toggle, bookmark forward/reverse, cross-file replace, snapshot save/restore/append/switch, and compare to backup. Shared implementations and action dispatch remain; unique Session Tools entries are retained. OpenAI Codex (GPT-6). Rebuild and restart TSE; Windows compilation and runtime verification remain pending.

built-in SAL backup comparison replacement

Backup projects > Compare current file to backup now runs the supplied
cmp2bkupreplacement.mac, compiled from cmp2bkupreplacement.s by build.bat.
No cmp2bkup.mac, external diff executable, DLL or shell helper is required.
It can also be run directly through TSE Execute Macro.

Open a named text file, select the command, then choose the backup filename.
The default suggests same-basename .bak, then filename.ext.bak when found,
then the most recent comparison path. Other backup filenames can be selected.
For PROJ0200 timestamped backups, browse into the run folder and select the
backed-up file beneath its drive/path subdirectories. Extract ZIP backups
before comparison. No automatic latest-snapshot selection is performed.

Comparison uses the current editor buffer, including unsaved changes, and
reads the backup from disk into a private temporary buffer. It does not
save or modify either input. Differences are compared by line number,
case-sensitively, including whitespace; 255-character chunks allow
comparisons beyond column 255. Each result shows line:column and previews
of both lines (up to 80 characters each). Enter jumps to that position in
the current file; Escape returns. Missing current lines jump to the last
current line. This is a line-by-line comparison, not an aligned diff:
an inserted/deleted line can cause subsequent lines to differ. It compares
editor text, not binary bytes, encoding or line-ending formats.

OpenAI Codex (GPT-6). Rebuild and restart TSE. Windows SAL compilation and
runtime verification remain pending.

cmp2bkupreplacement.s
Backup projects > Compare current file to backup runs the bundled SAL
replacement. build.bat compiles and copies it; no external diff program,
DLL or shell helper is required. Choose a backup file; the default suggests
a nearby .bak or the last comparison filename. For PROJ0200 backups browse
into the timestamped run folder and select its drive/path copy of the file.
Extract ZIP backups first. No automatic latest-snapshot selection is made.
Compares current buffer including unsaved edits against backup text on disk.
Neither input is saved or modified. Results show line:column and 80-character
previews of each line. Enter jumps in the current file; Escape returns.
Comparison is case-sensitive and includes whitespace and columns beyond 255.
This compares matching line numbers, not an aligned diff; insertions/deletions
can cause subsequent lines to differ. Encoding and line-ending differences
are not compared as binary bytes. OpenAI Codex (GPT-6).
Rebuild and restart TSE; Windows compilation/runtime verification pending.

Reduced compiled main-menu help strings to address SAL Macro too long. Menu labels, hotkeys and action calls are retained. Full help descriptions follow below. OpenAI Codex (GPT-6). Rebuild and restart TSE; Windows SAL verification remains pending.

cmp2bkupreplacement now includes its own directory-restoration helper using native ChDir, replacing unavailable CDD calls. OpenAI Codex (GPT-6). Rebuild; Windows compilation and runtime verification remain pending.

Backup menu explicitly labels the comparison action as Compare 2 FILES (current file and backup)... . OpenAI Codex (GPT-6).

Backup projects > B: Backup all files in all projects + all files in the TSE ring. One combined backup, duplicate source paths copied once. Named ring files use the existing backupsnapshotunsaved setting. Unnamed buffers need a filename first.

Search navigation

Search results now accept a left click or Enter to open the match at its line
and column. Ctrl+Alt+Shift+G reopens the latest result list; Esc closes the list.
Applies to current-file, current-project, all-projects and TSE-ring searches.
Search options are shown for project and ring results. The message bar reports
the file currently searched, with a preparation message before archive expansion.
Archive expansion itself still runs synchronously in the existing helper.
Matching extracted members remain in temporary buffers until the next search
replaces the results or projsearchresults.mac is purged. These are temporary
copies: editing them does not update the original archive. Do not save changes
to their extracted paths; use Save As to keep a separate file.
Closed or renamed source buffers can require a new search. Stored line/column
positions reflect the search time and can shift after editing.
Build includes the new independent projsearchresults.s worker. Rebuild the whole
package; existing bundled macros do not contain these source changes.

Manual check: search a project containing a normal file and a nested ZIP match;
click both results, check line and column, then Ctrl+Alt+Shift+G to return.
Repeat with current file and ring (including an unnamed buffer). Esc should
leave the source position unchanged; run a second search to replace old results.

Session Tools menu consolidation

Removed Session Tools from the main project menu. The separate session worker
remains compiled and loads on demand for commands in the ordinary main menus.
Load projects: Open a file.
View projects: Next/previous file, View timelog (optional timelog.mac required).
Save projects: Save current file, Save As, Save session snapshot and exit TSE.
Close projects: Close current file, Save and close current file.
Search projects: Find / replace in current file and Find across open files,
including repeat forward/reverse and find word at cursor in both directions.
Help: About PROJ0200 and integration information.
Clipboards already provides View the current TSE clipboard content; reused it.
Previously migrated session snapshot, audit bookmark and compare-file commands
remain in their respective menus. Legacy worker menus remain only for direct
standalone compatibility; the main project menu no longer exposes them.
Previously abbreviated menu hints were removed to leave main-macro size room.
Full original menu hints remain documented in proj0200_menu_help.txt.

Bundled clipboard tools and timelog

Loaded languages now appears directly above Settings.
Clipboards adds: View the current Microsoft Windows clipboard content (text),
Named TSE clipboards (supplied NAMECLIP by David Marcus), and View named TSE
clipboards (supplied CLIPVIEW by Ian Campbell). The Windows viewer pastes into
a temporary buffer and restores the source/block. Images and rich formatting
are outside this text viewer's scope. NAMECLIP opens its menu directly and
retains its other/settings/global menus; its global F11/keypad bindings were
omitted so existing editor keys continue to work. Legacy WINCLIP macro calls
were replaced with native TSE Windows clipboard functions. CLIPVIEW retains
its supplied A-Z named-clipboard viewer behavior; its naming convention differs
from NAMECLIP's arbitrary named clipboard system.

View projects > View timelog now uses the bundled TIMELOG source by Ian Campbell.
Tracking starts when this menu command first loads the macro, then continues
while the macro is loaded. It follows the active PROJ0200 .pj project and writes
<project-filename-stem>.LOG in the package directory. Viewing flushes the current
interval before displaying the log. Idle project changes flush the old project
and start the new one; editor exit/purge flushes pending times. This measures
editor elapsed time, not active keyboard time. Same-stem projects share a log.
The original accounting uses seconds within a day; long multi-day intervals
retain that limitation. LOADDIR and the old session ProjectName global are no
longer used. Original authors' source headers are retained.

Rebuild the complete package. Manual checks: inspect all three new clipboard
entries, test NAMECLIP copy/paste, confirm F11 retains its usual assignment,
and open a project then View timelog, switch files, wait, view again and check
its package-directory .LOG. Change projects and confirm separate logs.

Clipboard menu uses L: Load, S: Save and V: View labels, with dividers after the TSE clipboard viewer and Windows clipboard viewer.

Moved the clipboard divider above V: View the current TSE clipboard content; retained the divider below W: View the current Microsoft Windows clipboard content.

Named clipboard viewer compatibility

Clipboards > B: View named TSE clipboards now offers N: NAMECLIP named
clipboards and A: Legacy A-Z TSE clipboards. The supplied CLIPVIEW originally
only recognised buffers +++A through +++Z; NAMECLIP stores arbitrary names in
its own registry and temporary buffers. N invokes NAMECLIP's existing viewer
via nameclip.mac -view. A retains the supplied CLIPVIEW browser (starts on the
main clipboard; press A-Z to select an existing legacy named clipboard).
NAMECLIP's viewer retains its supplied Enter-to-edit behavior; Esc returns.
No clipboard data is converted, cleared or copied by selecting a viewer.
Test: mark text, Clipboards > N: Named TSE clipboards > Copy, create a named
clipboard, then Clipboards > B: View named TSE clipboards > N and select it.
Rebuild both nameclip.s and clipview.s using the complete build.bat.


## Syntax highlight conversion choices

Change projects > S: Convert syntax highlight .txt to .syn or .syn to .txt
opens four parameter choices:

- filetexttobinary: choose input .txt and output .syn files.
- filebinarytotext: choose input .syn and output .txt files.
- directorytexttobinary: enter existing input and output directories.
- directorybinarytotext: enter existing input and output directories.

Escape cancels at either input prompt. File output defaults to the source
basename with the target extension; it can be edited. Directory conversion
uses the supplied SYNCFG2 component's existing conversion/report behavior.
The front end runs projsyncfg.mac, which passes the chosen command and both
quoted paths to syncfg2.mac. The bundled component keeps its upstream identity.

## Configure syntax highlight mapping sets

Change projects groups its two syntax highlight actions below a divider:
S: Convert syntax highlight .txt to .syn or .syn to .txt, and
H: Configure syntax highlight mapping sets.
The latter runs the supplied SYNCFG mapping editor with common.h and syncfg.inc.
Build compiles syncfg.si separately and copies syncfg.mac to the package root.
The mapping editor's converter calls use the bundled syncfg2.mac explicitly.
Its directory suggestions use the package directory and its SYNHI subdirectory.
Original SemWare/contributor headers and editor behavior are retained.
Association-management actions retain the supplied dependency on TSE synext;
its sorting action retains the standard TSE sort macro dependency.

## Convert the currently loaded syntax file

The conversion menu's texttobinary and binarytotext options use the current
loaded buffer directly, including unsaved edits. They do not ask for input
filenames or buffer IDs. Choose only the output filename; it defaults to the
current basename with .syn or .txt. The converted result is an editor buffer;
save it explicitly when ready. Input and output must differ. Replacing an
existing open output buffer requires confirmation. Escape cancels the prompt.
The file and directory conversion pairs remain available separately.

## PJL timelog commands

starttimelog starts or resumes elapsed-time tracking for the active project.
showtimelog saves the accumulated interval and displays the log; Escape returns
to the script. stoptimelog saves the interval and stops tracking. Showing a
stopped log does not restart tracking. Running start repeatedly keeps the
existing interval. Stop is harmless when already stopped. Start/show require
an active project; stop can flush the previously tracked project after closure.
All three commands are case insensitive, accept no parameters and are included
in Create script's command templates and the PJL syntax definitions.
Run a script containing starttimelog, then work normally in the editor.
Later run a script containing showtimelog and stoptimelog on separate lines.

## Right-click cancellation in input prompts

Native project text and filename prompts now treat right-click as Escape:
it cancels the input directly. The hint reads Right-click/Esc: Cancel.
Enter still accepts input. This replaces the previous right-click action menu.

## Prompt-time right-click key activation

The right-click cancellation key is enabled by the prompt startup hook, after
the native input prompt is created, and disabled by prompt cleanup. Both text
and filename input wrappers remove their hooks on return. This targets Open
Project, New Project and Create Script prompts where an editor prompt-editing
menu could previously take precedence over the pre-enabled key definition.

## Input prompt mouse priority

Right-click cancellation is reapplied before each key read inside PROJ0200
input prompts, addressing prompt extensions that install their own mouse keys
after startup hooks. The before-key hook is removed during prompt cleanup and
on return from both input wrappers. Other editor prompts remain unchanged.

## Return from Loaded languages and Help

Loaded languages uses a small list dialog with Escape/right-click to return
to the main menu. The Help submenu keeps the parent Project menu open when
cancelled. Its existing help actions remain available.

## Right-click dismissal of OK messages

Native PROJ0200 information/warning boxes with only an OK button now accept
right-click to dismiss. This includes the warning to open a saved project
before Rename project. The temporary mouse binding is removed after dismissal.

## Next and previous open file

View projects > Next file / Previous file cycles through normal TSE ring
buffers, including unnamed documents, skipping system buffers. A successful
switch keeps the Project menu open and updates the active buffer behind it.
With no other open document, an explanatory message is shown and the main
menu remains available. These actions do not open the next project member
from disk; they navigate files already in the editor ring.

## Timelog mouse return

The no-active-project warning uses the shared OK-message right-click handler.
The Time Log list also accepts right-click as Escape to return. Dismissing
the viewer leaves the current tracking state unchanged.

## Consistent right-click dismissal of native messages

Package SAL sources route information/warning and confirmation messages through
the shared dialog helper. Right-click dismisses OK-only messages and sends
Escape for confirmations, without selecting Yes. Temporary keys/hooks are
removed on return. This covers the project manager and supplied syntax,
clipboard, AI and other utility sources. The clipboard viewer's custom Yes/No
menu also recognises right-click as cancellation. Windows OS dialog style
retains standard Windows mouse behavior; this change targets native TSE dialogs.

## Keep the menu open during file navigation

Next file and Previous file leave the main Project menu open after changing
the active buffer. Escape/right-click can then leave the menu normally.

## Search completion instructions

A new search displays its match/file summary and explains that clicking a
found line or pressing Enter opens the file at the row and column, and that
Ctrl+Alt+Shift+G returns to the results. The dialog appears only for newly
completed searches, not each time the results shortcut is used.

## Save the current project from PJL

Use savecurrentproject with no parameters to save the active project record.
The interpreter, command picker and syntax highlighting use this command name.
