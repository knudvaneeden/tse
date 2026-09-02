# CMPFILE2

**README version:** 1.0.0.0.0  
**CMPFILE2 source version:** 1.04  
**Created:** 2026-09-02 22:21:30 CEST (+0200)  
**Source file:** `CMPFILE2.S`

## Description

CMPFILE2 is a TSE SAL macro that compares the file currently open in The SemWare Editor (TSE) with another file or with a matching file stored in a backup archive.

The two files are displayed in vertically or horizontally split windows. Navigation can be synchronized, differences can be located and highlighted, and a marked difference block can be replaced with the corresponding block from the other window.

CMPFILE2 is an enhanced version of the `CmpFiles` macro supplied with TSE Pro 2.5e. Its additions include:

- comparison of up to 250 characters on the two current lines;
- comparison from column 1 or from the first visible column in each window;
- independent left/right scrolling of the current window;
- an optional ignore-case filter;
- an updated help screen;
- code intended to work with TSE Pro 2.5e and the TSE Pro 4 Test Drive.

The original archive states that the macro was tested only with TSE Pro 2.5e and the TSE Pro 4 Test Drive. Compatibility with newer TSE releases is not guaranteed.

## Archive contents

- `CmpFiles2/CMPFILE2.S` — TSE SAL source code.
- `CmpFiles2/file_id.diz` — short package description.

## Requirements

- The SemWare Editor (TSE) with a compatible SAL compiler.
- A normal file loaded as the current TSE file before the macro is started.
- For comparisons against an archive, a suitable command-line decompressor available through the system `PATH`.
- Supported archive extensions in the source are `.ARC`, `.ARJ`, `.LZH`, and `.ZIP`.

When an archive is selected, the file inside it must have the same filename as the current file. The archive may contain additional files; CMPFILE2 extracts the matching one.

## Installation and compilation

1. Extract `cmpfile2.zip`.
2. Locate `CmpFiles2/CMPFILE2.S`.
3. Copy `CMPFILE2.S` to your preferred TSE macro source directory, if desired.
4. Open a command prompt in that directory.
5. Compile the macro with the SAL compiler appropriate for your TSE installation. For a 32-bit TSE installation, a typical command is:

   ```text
   sc32 CMPFILE2.S
   ```

6. Confirm that compilation completes successfully and produces the compiled macro file expected by your TSE version.
7. Place the compiled macro where TSE can find external macros, or run it by specifying its full path.

Because this is older SAL source, a modern SAL compiler may report compatibility errors or warnings that require source changes.

## How to run

1. Start TSE.
2. Open the original file that you want to compare.
3. Run the compiled `CMPFILE2` macro from Potpourri, Projects, or TSE's macro execution command.
4. At the `Compare ... to:` prompt, select or enter:
   - a second ordinary file;
   - a wildcard, which CMPFILE2 resolves through a file-selection list;
   - a directory, in which case CMPFILE2 tries the current file's name in that directory; or
   - an `.ARC`, `.ARJ`, `.LZH`, or `.ZIP` backup archive containing a file with the same name as the current file.
5. Use the split windows to inspect the two files.
6. Press `Enter` to begin or continue searching for differences.
7. Press `F1` for the built-in help screen or `F10` for the menu system.
8. Press `Esc` to leave the comparison. CMPFILE2 may ask whether the comparison copy should be unloaded.

The macro purges itself from memory when it finishes.

## Main keys

| Key | Action |
|---|---|
| `Enter` | Begin or continue comparison |
| `Ctrl+Enter` | Compare the current lines starting at column 1 |
| `Ctrl+Shift+Enter` | Compare the current lines starting at the current visible columns |
| `F1` | Open the help screen |
| `F10` | Open the menu system |
| `Esc` | Exit the macro |
| `Spacebar` | Toggle vertical/horizontal split windows |
| `Tab` | Switch between the two windows |
| `W` | Toggle whitespace filtering |
| `I` | Toggle ignore-case filtering |
| `R` | Replace the marked block with the block from the other window |
| `J` or `Ctrl+J` | Go to a line |
| `Ctrl+F` | Find in both files |
| `Ctrl+L` | Repeat the find operation |
| `F11` or numeric keypad `-` | Go to the beginning of marked difference text |
| `F12` or numeric keypad `+` | Go to the end of marked difference text |
| `Ctrl+Home` | Go to the beginning of both files |
| `Ctrl+End` | Go to the end of both files |
| `Ctrl+Up` / `Ctrl+Down` | Roll the current window up/down |
| `Ctrl+Left` / `Ctrl+Right` | Roll the current window left/right |
| `Ctrl+PgUp` / `Ctrl+PgDn` | Page the current window up/down |
| `V` | Cycle/change the video mode |

The menus also expose editing, viewing, searching, and help commands. Some mouse actions are supported by the original macro.

## Comparison behavior

Whitespace filtering is enabled by default. Runs of spaces and tabs are treated as a single space to reduce unhelpful mismatches. Press `W` to toggle this behavior.

Ignore-case filtering is also initialized as enabled in this version. Press `I` to toggle it.

After CMPFILE2 re-synchronizes the files, difference text is marked in both windows. Use `F11` and `F12` to move between the beginning and end of the currently marked difference, then press `Enter` to search for the next difference.

## Archive handling

For an archived comparison, CMPFILE2 uses the directory named by the Windows `TEMP` environment variable. If that is unavailable or unsuitable, the macro may create a `TSETEMP` directory near the original file. It extracts the matching backup file, loads it with a `.CBK` extension for comparison, and removes temporary disk files afterward.

The required decompressor must be accessible through `PATH`; otherwise the archive comparison can fail with a file-not-found error.

## Limitations and cautions

- The source documentation states that line length must be under 250 characters.
- The current-line comparison examines at most 250 characters at a time.
- Whitespace filtering helps while files are already synchronized, but the macro's re-synchronization search cannot filter whitespace. Extensively converting tabs to spaces, or spaces to tabs, may prevent successful re-synchronization.
- Archive extraction depends on external decompression programs and their command-line behavior.
- The macro can replace text in one compared file with text from the other. Save or back up important files before using replacement commands.
- The source predates modern TSE releases and may need maintenance before it will compile or run correctly on them.

## Troubleshooting

### The macro cannot find an archived file

Check that the archive exists, its extension is supported, the required decompressor is installed, and the decompressor's directory is included in `PATH`.

### No matching file is extracted from an archive

Confirm that the archive contains a file whose filename matches the current TSE file.

### The comparison will not re-synchronize

Try toggling whitespace filtering with `W` and ignore-case filtering with `I`. Major tab/space transformations or large structural changes can still prevent re-synchronization.

### The source does not compile

CMPFILE2 was written for older TSE versions. Review compiler messages for obsolete syntax, APIs, screen-handling code, or platform conditionals. Make changes on a copy of the source and increment the README or package version when recording a revised release.

## Version history

| README version | Date and time | Changes |
|---|---|---|
| 1.0.0.0.0 | 2026-09-02 22:21:30 CEST (+0200) | Initial Markdown documentation based on `CMPFILE2.S` version 1.04 and `file_id.diz`. |

For later README revisions, increment the final component sequentially:

```text
1.0.0.0.0
1.0.0.0.1
1.0.0.0.2
1.0.0.0.3
...
```

## Credits

- Original CMPFILES author: Ian Campbell.
- Later Win32 revisions: Chris Antos.
- CMPFILE2 enhancements and English documentation: Flavio Suarez.

## Disclaimer

This is legacy third-party macro source. Test it with copies of files first. The original source is supplied with an at-your-own-risk disclaimer.
