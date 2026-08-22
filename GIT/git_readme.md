# Git Browser for The Semware Editor (TSE)

**Macro:** `Git.s`
**Author:** Knud van Eeden (adapted from `svn.s` by Carlo Hogeveen)
**Version:** 1.0.0.0 (12 February 2026)

## Purpose
This macro provides a fast Git browser for The Semware Editor (TSE), intended for browsing large working-tree directories where GUI tools can feel slow. It allows you to browse your Git repository, perform manual DIFFs, and revert to older working versions.

## Features
* Browse the HEAD of a Git repository's directories and files.
* View file information, properties, and commit history.
* Read or edit historic versions of a file (without saving directly to the repository).

## Installation
1. **Prerequisites:** You must install Cygwin `git.exe`.
2. **Configuration:** Change the working directory variable to match your environment. Open `git.s` and modify:
   ```sal
   STRING workingDirectoryGS[ MAXSTRINGLEN ] = 'G:\VERSIONCONTROL\GIT\DDD01\'
   ```
3. **Compile:** Recompile the macro once in TSE.

## Usage
Run the `git.s` macro to display a list of TSE programs under git control. It automatically searches for the current filename.

The top of the screen shows the currently selected object. An `@` followed by a commit hash indicates you are viewing a historic version of the file; no `@` means you are looking at the current working-tree version.

### Navigation & Hotkeys
* **Browsing:** Use `Up`, `Down`, `PageUp`, `PageDown`, `Home`, and `End`.
* **<F1>** - Help
* **<F5>** - History / Log: See the file content of a specific revision.
* **<F8>** - Info: View information about the file revision.
* **<F9>** - Props: View Git-related properties (status, last commit, etc.).
* **<F10>** - Diff
* **<Enter>** - Read / Edit (Editing leaves the browser and provides all editing options of TSE)
* **<Esc>** - Quit / Back

### Creating a DIFF between 2 versions
1. Open two different revisions of the file by pressing `<F5>` on each.
2. Use a difference program (e.g., Larry Hayes difference program) to view the DIFFs.
3. Alternatively, save these two files and run an external diff tool (e.g., BeyondCompare) from the DOS command line.

## Links
* [Download from SourceForge](https://sourceforge.net/p/the-semware-editor-tse/code/HEAD/tree/TRUNK/git.s?format=raw)
* [View on GitHub](https://github.com/knudvaneeden/tse/blob/TRUNK/git.s)# Git Browser for The Semware Editor (TSE)

**Macro:** `Git.s`
**Author:** Knud van Eeden (adapted from `svn.s` by Carlo Hogeveen)
**Version:** 1.0.0.0 (12 February 2026)

## Purpose
This macro provides a fast Git browser for The Semware Editor (TSE), intended for browsing large working-tree directories where GUI tools can feel slow. It allows you to browse your Git repository, perform manual DIFFs, and revert to older working versions.

## Features
* Browse the HEAD of a Git repository's directories and files.
* View file information, properties, and commit history.
* Read or edit historic versions of a file (without saving directly to the repository).

## Installation
1. **Prerequisites:** You must install Cygwin `git.exe`.
2. **Configuration:** Change the working directory variable to match your environment. Open `git.s` and modify:
   ```sal
   STRING workingDirectoryGS[ MAXSTRINGLEN ] = 'G:\VERSIONCONTROL\GIT\DDD01\'
   ```
3. **Compile:** Recompile the macro once in TSE.

## Usage
Run the `git.s` macro to display a list of TSE programs under git control. It automatically searches for the current filename.

The top of the screen shows the currently selected object. An `@` followed by a commit hash indicates you are viewing a historic version of the file; no `@` means you are looking at the current working-tree version.

### Navigation & Hotkeys
* **Browsing:** Use `Up`, `Down`, `PageUp`, `PageDown`, `Home`, and `End`.
* **<F1>** - Help
* **<F5>** - History / Log: See the file content of a specific revision.
* **<F8>** - Info: View information about the file revision.
* **<F9>** - Props: View Git-related properties (status, last commit, etc.).
* **<F10>** - Diff
* **<Enter>** - Read / Edit (Editing leaves the browser and provides all editing options of TSE)
* **<Esc>** - Quit / Back

### Creating a DIFF between 2 versions
1. Open two different revisions of the file by pressing `<F5>` on each.
2. Use a difference program (e.g., Larry Hayes difference program) to view the DIFFs.
3. Alternatively, save these two files and run an external diff tool (e.g., BeyondCompare) from the DOS command line.

## Links
* [Download from SourceForge](https://sourceforge.net/p/the-semware-editor-tse/code/HEAD/tree/TRUNK/git.s?format=raw)
* [View on GitHub](https://github.com/knudvaneeden/tse/blob/TRUNK/git.s)
