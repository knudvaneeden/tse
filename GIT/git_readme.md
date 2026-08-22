# Git Browser for The Semware Editor (TSE)

**Macro:** `Git.s`
**Author:** Knud van Eeden (adapted from `svn.s` by Carlo Hogeveen)
**Version:** 1.1.0.7 (22 August 2026)

## Purpose
This macro provides a fast Git browser for The Semware Editor (TSE), intended for browsing large working-tree directories where GUI tools can feel slow. It allows you to browse your Git repository, perform automated and manual DIFFs, and revert to older working versions.

## Features
* Browse the HEAD of a Git repository's directories and files.
* View file information, properties, and commit history.
* Read or edit historic versions of a file (without saving directly to the repository).
* **NEW:** Built-in DIFF functionality integrating with external tools like Beyond Compare.

## Installation
1. **Prerequisites:** You must install Cygwin `git.exe`.
2. **Configuration:** Change the working directory variable to match your environment. Open `git.s` and modify:
   ```sal
   STRING workingDirectoryGS[ MAXSTRINGLEN ] = 'G:\VERSIONCONTROL\GIT\DDD01\'
   ```
   *Optional:* Update the path to your preferred Diff executable (defaults to Beyond Compare):
   ```sal
   STRING compareExecutableGS[ MAXSTRINGLEN ] = "G:\UTILS\COMPARE\BEYONDCOMPARE\Beyond Compare 5\BComp.exe"
   ```
3. **Compile:** Recompile the macro once in TSE.

## Usage
Run the `git.s` macro to display a list of TSE programs under git control. It automatically searches for the current filename.
The top of the screen shows the currently selected object. An `@` followed by a commit hash indicates you are viewing a historic version of the file; no `@` means you are looking at the current working-tree version.

### Navigation & Hotkeys
**Browsing:** Use `Up`, `Down`, `PageUp`, `PageDown`, `Home`, and `End`.
* **<F1>** - Help
* **<F5>** - History / Log: See the file content of a specific revision.
* **<F8>** - Info: View information about the file revision.
* **<F9>** - Props: View Git-related properties (status, last commit, etc.).
* **<F10>** - Diff: Select a file or revision, then select another to automatically trigger a comparison.
* **<Enter>** - Read / Edit (Editing leaves the browser and provides all editing options of TSE)
* **<Esc>** - Quit / Back

### Creating a DIFF between 2 versions
* **Automated (New):** In the file list or log view, press `<F10>` on the first revision you want to compare. This marks it as the first diff file. Navigate to the second revision (or the current working-tree version) and press `<F10>` again. Your configured diff program will automatically launch to show the differences.
* **Manual:** Open two different revisions of the file by pressing `<F5>` on each. Use a difference program (e.g., Larry Hayes difference program) within TSE to view the DIFFs.
* **External:** Alternatively, save these two files manually and run an external diff tool from the DOS command line.

## Links
* [Download from SourceForge](https://sourceforge.net/p/the-semware-editor-tse/code/HEAD/tree/TRUNK/git.s?format=raw)
* [View on GitHub](https://github.com/knudvaneeden/tse/blob/TRUNK/git.s)
