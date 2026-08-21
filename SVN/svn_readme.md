# SVN Browser Macro for TSE (svn.s)

## Overview
`svn.s` is a high-speed Subversion (SVN) repository browser for The SemWare Editor (TSE). It is specifically designed to handle massive directories where standard GUI tools (like TortoiseSVN) take too long to load.

It allows you to browse the HEAD of a Subversion repository, view file info, inspect properties, view history (logs), and instantly extract or edit historic versions of files directly within TSE. It also includes seamless integration with external diff tools like Beyond Compare.

---

## Configuration & Setup
Before running the macro, ensure the following global variables at the top of the `svn.s` source file reflect your local environment:

*   **`versionControlExecutableGS`**: The absolute path to your `svn.exe` command-line tool (e.g., `"g:\cygwin\bin\svn.exe"`).
*   **`workingDirectoryGS`**: The default SVN working directory to load upon starting the macro.
*   **`compareExecutableGS`**: The absolute path to your external diffing tool (e.g., `"G:\UTILS\COMPARE\BEYONDCOMPARE\Beyond Compare 5\BComp.exe"`).

*Note: SVN command-line tools must be installed and accessible. Security credentials must be handled by SVN/TortoiseSVN natively, as the macro does not prompt for passwords.*

---

## Options and Keybindings

Once the macro is running, the top of the screen displays the currently selected object. A `@` followed by a number indicates a historic revision. The following actions are available via the bottom menu:

*   **`<Enter>` (Read/Edit):** Opens a file for reading first, and editing separately. Note: Editing leaves the browser to give you full TSE functionality, but does not commit directly to SVN.
*   **`<Esc>` (Quit/Back):** Navigates up a directory or closes the browser.
*   **`<F1>` (Help):** Displays the built-in help text.
*   **`<F5>` (Hist):** Opens the SVN log/history for the currently selected file.
*   **`<F8>` (Info):** Displays the Subversion information for the selected file or directory.
*   **`<F9>` (Props):** Displays the Subversion properties of the object.
*   **`<F10>` (Diff):** Marks a file/revision for comparison.

### How to use the Diff Tool (<F10>)
You can compare any two files or revisions using the `<F10>` key:
1. Navigate to a file in the main browser, or press `<F5>` to view its revision history.
2. Select your first file or specific revision and press **`<F10>`**. The macro extracts it to your `%TEMP%` folder silently and marks it.
3. You are seamlessly returned to the list. Navigate to (or stay on) the history list to select the second revision.
4. Press **`<F10>`** again on the second revision.
5. The macro extracts the second file and instantly launches your configured diff tool (e.g., Beyond Compare) to compare the two versions, while leaving TSE ready for your next action.

---

## Version History

*   **1.6** (Current)
    *   Reverted to extracting revisions directly to the `%TEMP%` directory to resolve "File Not Found" errors in Beyond Compare (which cannot natively parse Cygwin SVN URIs).
    *   Updated default Beyond Compare executable path to version 5.
*   **1.5**
    *   Fixed a bug where `<F10>` was ignored in the SVN log view. Enabled `extra_list_keys` to remain active while viewing file history.
*   **1.4**
    *   Streamlined the diff logic to safely return the user to their active list (browse or log) seamlessly in the background after selecting a file.
*   **1.3**
    *   Attempted logic to auto-transition the user to the log view automatically upon marking a file.
*   **1.2**
    *   Suppressed the internal TSE `[Yes] [No] [Cancel]` overwrite prompts when saving temporary diff files.
    *   Changed DOS execution flag to `_DONT_WAIT_` to ensure external GUI windows (like Beyond Compare) appear correctly on screen.
*   **1.1**
    *   Introduced the core `<F10>` Diff functionality. Added state tracking (`firstDiffFileGS`) to hold the first selected file in memory until a second is chosen.
*   **0.9.2** (25 Feb 2013)
    *   Changed the help text and a warning to English. *(Carlo Hogeveen)*
*   **0.9.1** (3 Jun 2012)
    *   If started from the command-line with `-eSvn` and no file was opened for editing, then TSE is closed with the macro. *(Carlo Hogeveen)*
*   **0.9** (25 May 2012)
    *   Initial version. *(Carlo Hogeveen)*
