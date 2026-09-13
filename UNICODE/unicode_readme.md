# UNICODE for TSE Pro

**README version:** 1.0.0.0.0  
**Date and time:** 13 September 2026, 20:20 CEST  
**Session:** Create UNICODE MarkDown Readme  
**Documented package:** `Unicode(1).zip`  
**UNICODE source header version:** 2.8.3, dated 13 September 2026  
**Author of UNICODE:** Carlo Hogeveen  
**Website:** [eCarlo.nl/tse](https://ecarlo.nl/tse/)

## Description

UNICODE is a TSE Pro macro extension that lets TSE view and edit files using the major Unicode character encodings:

- UTF-8
- UTF-16 little endian and big endian
- UTF-32 little endian and big endian
- Each supported encoding with or without a byte order mark (BOM)

TSE itself can display ASCII and ANSI characters but cannot directly display every Unicode character. UNICODE therefore converts a Unicode file to an editable ANSI representation when it is loaded and converts it back to its original or selected Unicode encoding when it is saved.

Characters that have an ANSI equivalent appear normally. Other Unicode characters are represented inside TSE by quoted hexadecimal codepoints. When the cursor is on such a representation, the macro can show the character's Unicode description in the status area.

The conversion between the supported encodings is intended to be lossless.

## Package contents

The archive contains:

| File | Purpose |
| --- | --- |
| `Unicode.s` | TSE SAL source code for the UNICODE macro |
| `UnicodeData.txt` | Unicode character names and properties used by the macro |
| `NamesList.txt` | Additional Unicode character names and annotations |

All three files must remain available to the macro.

## Requirements

- TSE Pro 4.4 or newer on Windows, using the GUI executable.
- TSE 4.41.35 or newer on Linux.
- The separate TSE `Status` macro, version 1.2 or newer, must already be installed.
- On Windows, an ANSI-compatible font is required.
- A valid `TMP` or `TEMP` directory must be configured.

### Important font requirement

The macro does **not** support the Windows Console version of TSE (`e32.exe`). Use the Windows GUI version, normally `g32.exe`.

The macro explicitly rejects these Windows fonts because it regards them as incompatible:

- Courier
- Fixedsys
- System
- Terminal

If you normally use the **Terminal** font, change the font before running UNICODE. Suitable examples listed by the source are:

- Consolas
- Courier New
- Lucida Console
- Lucida Sans Typewriter

In Windows, open the TSE window menu by clicking the icon in the upper-left corner or by pressing **Alt+Space**, select an ANSI-compatible font, and then use **Options > Save Current Settings** in TSE to preserve the change.

## Installation

1. Install version 1.2 or newer of the separate `Status` macro.
2. Close or back up important files before testing the macro.
3. Extract `Unicode(1).zip`.
4. Copy these three files to TSE's `mac` directory:
   - `Unicode.s`
   - `UnicodeData.txt`
   - `NamesList.txt`
5. Start the GUI version of TSE with an ANSI-compatible font.
6. Open `Unicode.s` in TSE.
7. Select **Macro > Compile** to compile it as `Unicode.mac`.
8. Select **Macro > Execute**, enter `Unicode`, and run it at least once.
9. The first execution initializes the default configuration and opens the UNICODE menu. Press **Escape** if you want to retain the defaults.
10. Confirm that an encoding status such as `ASCII`, `ANSI`, or a UTF encoding appears in the status area.

UNICODE configures its integration when it is first executed. Its settings are stored in TSE's configuration.

## How to run UNICODE

### Open the main menu

Use **Macro > Execute** and execute:

```text
Unicode
```

On Windows, you can also open the menu by right-clicking the UNICODE status. When the cursor is on that status, **F10** or **Shift+F10** opens the menu and **F1** opens help.

### Open and edit a Unicode file

1. Open the file normally in TSE.
2. Check the character-encoding status displayed by UNICODE.
3. Edit the converted text.
4. Non-ANSI characters appear as quoted hexadecimal Unicode codepoints.
5. Save the file normally. UNICODE converts the editable representation back to the selected Unicode encoding.

For safety, first test the macro with a copy of a file and verify the result in another Unicode-aware editor.

## Main-menu actions

The UNICODE menu provides the following main actions:

- Open the built-in help.
- Insert a Unicode character by searching for part of its codepoint, name, or description.
- Change the current file's character encoding.
- Copy marked text to the Windows clipboard as Unicode text.
- Cut marked text to the Windows clipboard as Unicode text.
- Paste Unicode-compatible text from the Windows clipboard.
- Change the status color.
- Configure conversion, status, preview, warning, and encoding-detection options.

The clipboard actions are available on Windows. Copy and Cut require a marked block.

## Insert a Unicode character

1. Execute `Unicode` and select **Insert a Unicode character**.
2. Type part of the hexadecimal codepoint, Unicode name, or description.
3. The selection list shrinks as you type.
4. Select the intended character and confirm the selection.

Check the complete Unicode name carefully. Some similarly named characters represent different symbols.

## Change the current file's encoding

1. Execute `Unicode`.
2. Select **Change current file's character encoding**.
3. Choose the required ASCII, ANSI, UTF-8, UTF-16, or UTF-32 variant and BOM option.
4. Save the file to write it using the selected encoding.

Always make a backup before changing the encoding of an important file.

## Optional keyboard shortcuts

The source documentation suggests adding commands like these to your TSE user-interface (`.ui`) file:

```text
<CtrlShift I>   ExecMacro('Unicode InsertCharacter')
<CtrlShift C>   ExecMacro('Unicode Copy')
<CtrlShift X>   ExecMacro('Unicode Cut')
<CtrlShift V>   ExecMacro('Unicode Paste')
```

Recompile the `.ui` file and restart TSE after adding the definitions.

If CUAmark already handles these keys, its definitions can conflict with the UNICODE clipboard shortcuts. The UNICODE Copy, Cut, and Paste operations can also be slower for very large blocks.

## Configuration options

Execute `Unicode` to reach options for:

- Enabling or disabling conversion of Unicode files.
- Showing the current file's encoding in the status area.
- Selecting which character descriptions are shown.
- Previewing Unicode characters on Windows; this is disabled by default because the source describes it as imperfect.
- Choosing the default upgrade action when a non-ASCII character is added to an ASCII file.
- Choosing the default upgrade action when a non-ANSI character is added to an ANSI file.
- Checking whether a BOM agrees with the file content.
- Setting how many bytes are examined to detect the encoding.

Checking more bytes may improve encoding detection but can increase loading time.

## EolType compatibility

The `EolType` macro is optional. If it is installed, use `EolType` version 7 or newer. Older releases may not reliably recognize the line-ending type of UTF-16 and UTF-32 files.

## Limitations and warnings

- The Windows Console version of TSE is unsupported.
- The Windows Terminal font is rejected by this macro.
- Unicode conversions, especially UTF-16 and UTF-32 conversions, can take time on large files.
- A Unicode-character preview on Windows is experimental and may display imperfectly.
- An automatic upgrade from ASCII or ANSI can occur up to approximately two seconds after inserting an incompatible character. Avoid saving immediately during that interval.
- Very long input lines may exceed TSE's line-length limit. The macro warns that splitting such lines can corrupt the converted view.
- TSE SAL source files should normally remain ASCII or ANSI. UTF-8 source without a BOM may compile in limited circumstances, but other Unicode encodings and a UTF-8 BOM can prevent compilation.
- The author supplies the macro as-is. Back up important data before use.

## Troubleshooting

### The macro says that the Terminal font is incompatible

Change TSE to Consolas, Courier New, Lucida Console, or Lucida Sans Typewriter, save the current TSE settings, and run the macro again.

### The macro reports that Status is missing

Install the separate `Status` macro version 1.2 or newer, restart TSE if necessary, and execute `Unicode` again.

### UnicodeData.txt or NamesList.txt cannot be found

Make sure both data files are in TSE's `mac` directory beside `Unicode.s`/`Unicode.mac`. Preserve their original filenames.

### No encoding status appears

Execute `Unicode`, enable **Show a file's character encoding**, and confirm that the required `Status` macro is installed and active.

### The file opens slowly

UTF-16 and UTF-32 conversions are slower than UTF-8 conversions. The **Max bytes to check** and **Check BOM correctness** settings also affect load time.

### The macro does not run in e32.exe

This is expected on Windows. Run the GUI version of TSE (`g32.exe`) with an ANSI-compatible font.

## Version history

### 1.0.0.0.0 — 13 September 2026, 20:20 CEST

- Created the initial Markdown description and help document.
- Documented the supplied three-file package.
- Added installation, compilation, first-run, editing, menu, encoding, clipboard, shortcut, and configuration instructions.
- Added Windows GUI and ANSI-font requirements.
- Highlighted the incompatibility with the Terminal font.
- Added troubleshooting, limitations, backup guidance, and EolType compatibility information.

## Source-version note

The comment header in the supplied `Unicode.s` identifies the release as **2.8.3**, dated 13 September 2026. An internal `MY_MACRO_VERSION` constant still contains **2.7**. This README records both facts rather than silently treating them as the same version. The README's own independent version starts at **1.0.0.0.0**.
