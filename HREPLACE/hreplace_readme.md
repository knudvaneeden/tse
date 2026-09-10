# HREPLACE

## Description

HREPLACE is a macro for The SemWare Editor Professional (TSE Pro). It works like TSE's standard **Replace** command, but maintains its own histories for:

- Search text
- Replacement text
- Replace options

This prevents the Replace command from sharing and changing the history used by TSE's Find command.

The macro also provides a **Ctrl+A** ASCII chart while the search and replacement prompts are open. Selecting a character from the chart inserts it into the active prompt.

## Compatibility

- TSE Pro 2.5e and later
- Source file: `hReplace.s`
- Original macro version: 1.0.0

## Package contents

| File | Purpose |
| --- | --- |
| `hReplace.s` | TSE SAL source code for the macro |
| `File_id.diz` | Original short package description |

## Installation

Two installation methods are supported.

### Method 1: Replace the standard UI command

1. Copy `hReplace.s` to TSE's `mac` directory.
2. Compile `hReplace.s` with the TSE SAL compiler to create `hReplace.mac`.
3. Open the TSE user-interface source file that you use, typically `win.ui`.
4. Find the standard Replace command entry containing:

   ```text
    Replace()
   ```

5. Replace it with:

   ```text
    ExecMacro('hReplace')
   ```

   Preserve the leading space when modifying the UI source.

6. Recompile the UI file.
7. Restart or reload the relevant TSE configuration if necessary.

This method makes HREPLACE available from TSE's normal Search menu in place of the standard Replace command.

### Method 2: Assign a key and autoload the macro

1. Copy `hReplace.s` to TSE's `mac` directory.
2. Open `hReplace.s` for editing.
3. Delete or comment out this line near the end of `Main()`:

   ```text
   PurgeMacro(macroname)
   ```

4. Add a key assignment after the final `end`. For example:

   ```text
   <Ctrl H> Main()
   ```

5. Change `<Ctrl H>` if you prefer another key combination.
6. Compile `hReplace.s` to create `hReplace.mac`.
7. Add `hReplace` to TSE's **Macro AutoLoad List**.
8. Restart TSE or load the compiled macro.

This method leaves the UI source unchanged, which makes TSE upgrades easier. It does not replace the original Replace entry in TSE's Search menu.

## How to run

Run HREPLACE in the manner configured during installation:

- Select the modified Replace command from the Search menu when using Method 1; or
- Press the assigned key when using Method 2; or
- Execute the compiled macro directly with TSE's macro execution command.

The macro then displays three prompts:

1. **Search for:** Enter the text or regular expression to find.
2. **Replace with:** Enter the replacement text.
3. **Replace options:** Enter any required option letters.

Press **Enter** to accept each prompt. Press **Esc** to cancel. While a text prompt is displayed, press **Ctrl+A** to open the ASCII chart.

## Replace options

The prompt displays the following option letters:

| Option | Meaning |
| --- | --- |
| `A` | Search all files |
| `B` | Search backward |
| `G` | Global operation |
| `L` | Local operation |
| `I` | Ignore letter case |
| `W` | Match whole words |
| `N` | Replace without prompting |
| `X` | Interpret the search text as a regular expression |

Options can be combined. Their exact behavior follows the Replace command in the installed TSE version.

## Example

To replace every occurrence of `oldName` with `newName` in the current scope without being prompted for each replacement:

1. Enter `oldName` at **Search for:**.
2. Enter `newName` at **Replace with:**.
3. Enter the appropriate combination of global and no-prompt options, such as `GN`, at **Replace options:**.

Review the affected scope before using no-prompt replacement, especially when working across multiple files.

## Notes

- HREPLACE uses histories named from the macro filename, keeping them independent from TSE's normal Find history.
- The source purges the macro after each run by default. Remove `PurgeMacro(macroname)` only when installing it as an autoloaded macro with its own key definition.
- A key assignment inside an autoloaded macro can override the same key assignment in a UI file.
- The macro was originally distributed under the name `mReplace`; it was renamed to the more descriptive `hReplace` without other functional changes.

## Troubleshooting

### The macro does not run

- Confirm that `hReplace.s` compiled successfully and that `hReplace.mac` is in a directory searched by TSE.
- Confirm that the UI entry or key definition uses the correct macro name.
- If Method 1 was used, confirm that the modified UI source was recompiled and loaded.
- If Method 2 was used, confirm that `hReplace` is present in the Macro AutoLoad List.

### The assigned key does not work

- Check whether another loaded macro assigns the same key.
- Verify that the key definition was added after the final `end` in `hReplace.s` before compilation.
- Confirm that `PurgeMacro(macroname)` was removed for the autoload method.

### Replace uses an unexpected scope

Check the option letters entered at the third prompt. Options such as All-files, Global, and Local directly affect the replacement scope.

## Version history

### 1.0.0.0.0 — 2026-09-11 00:43 CEST

- Created the Markdown description and help document.
- Documented package contents, compatibility, installation methods, operation, replace options, examples, notes, and troubleshooting.
- Based on the supplied `hreplace.zip` package containing HREPLACE 1.0.0 dated 19 November 2006.

Future document revisions should increment the final component sequentially: `1.0.0.0.1`, `1.0.0.0.2`, and so on.

## Credits

HREPLACE was written by Carlo Hogeveen. The original source lists `Carlo.Hogeveen@xs4all.nl` and `http://www.xs4all.nl/~hyphen/tse`.

---

Document version: **1.0.0.0.0**  
Created: **2026-09-11 00:43 CEST**  
Session: **Create HREPLACE MarkDown Readme**  
Generated with: **OpenAI Codex (GPT-5)**
