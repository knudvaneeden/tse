# HLP2TXT

**Session:** Create HLP2TXT MarkDown Readme  
**README version:** 1.0.0.0.0  
**Date and time:** Thursday, 10 September 2026, 22:28:47 UTC  
**Macro version:** 2.4.4  
**Original author:** Carlo Hogeveen  
**Supported editor:** The SemWare Editor Professional (TSE) 2.6 and later, Win32

## Description

HLP2TXT is a TSE SAL macro that converts TSE's internal interactive Help system into a standalone manual. It reads the internal Help index, retrieves the associated topics and subtopics, and creates the selected output file in TSE's `Help` directory.

The macro can generate four formats:

| Choice | Output file | Purpose |
| --- | --- | --- |
| ASCII | `TseHelp.txt` | Plain, unformatted text suitable for viewing in TSE or another text editor |
| HTML | `TseHelp.html` | A browser-readable manual with extensive hyperlinks between topics |
| Word | `TseHelp.doc` | HTML-based content without hyperlinks, with additions intended for formatting and printing in Microsoft Word |
| Generic | `TseHelp.htm` | HTML without hyperlinks or Word-specific additions, suitable for another HTML-aware application |

HLP2TXT 2.4.4 can obtain the detailed TSE version automatically in TSE 4.4 and later by using `VersionStr()`. Older supported TSE versions may ask you to confirm or refine the detected version description.

## Files in the package

- `Hlp2txt.s` — TSE SAL source code.
- `File_Id.diz` — short package description and release information.

The compiled `Hlp2txt.mac` file is not included and must be created with the TSE SAL compiler.

## Requirements

- A Win32 version of TSE Professional 2.6 or later.
- The TSE SAL compiler appropriate for your TSE installation, such as `sc32.exe`.
- Write permission in TSE's `Help` directory.
- Sufficient free memory and disk space for the generated manual.

The macro does not work with TSE 2.5 or earlier because those versions ignore the required `PushKey()` operations while the Help system is active.

## Installation

1. Extract `hlp2txt.zip` into a temporary directory.
2. Copy `Hlp2txt.s` to TSE's `MAC` directory, or to another directory from which you compile and load TSE macros.
3. Compile the source with the 32-bit SAL compiler:

   ```text
   sc32 Hlp2txt.s
   ```

4. Confirm that compilation creates `Hlp2txt.mac` without errors.
5. Place `Hlp2txt.mac` in TSE's `MAC` directory or in a directory included in `TSEPath`.

## How to run HLP2TXT

1. Start TSE Professional.
2. Run the compiled macro by selecting **Macro > Execute** and entering `Hlp2txt`, or execute it using your usual TSE macro command.
3. Read the introductory information screen and press **Enter** to continue. Press **Escape** if you want to cancel.
4. On TSE versions earlier than 4.4, examine the displayed TSE version and confirm or refine the proposed version description when prompted.
5. Choose one of the output formats: **ASCII**, **HTML**, **Word**, or **Generic**.
6. Wait while the macro reads the Help index and generates the manual. Progress messages appear while it is working.
7. You can press **Escape** during processing to abort.
8. When HTML or Word output is selected, answer the final prompt if you want to open the result in the default browser or word processor.

The generated file remains open in TSE and is stored in TSE's `Help` directory under the filename listed in the format table above.

## Help and usage notes

### Existing output files

HLP2TXT recreates the selected output file. Save or rename an older generated manual first if you want to retain it.

### GetHelp and HelpHelp compatibility

HLP2TXT does not include extra Help topics supplied by Chris Antos' GetHelp extension. To prevent incompatibility, the macro temporarily renames `HelpHelp.mac` to `HelpHelp.nomac` and restores it when processing finishes or is aborted normally.

If TSE or Windows crashes during the short period in which `HelpHelp.mac` is disabled, run HLP2TXT again and allow it to finish; the macro will restore the original filename. You can also manually rename `HelpHelp.nomac` back to `HelpHelp.mac` after closing TSE.

### Word output

The `.doc` output is HTML-formatted content intended for opening and improving in Word. Because Word may still recognize the original HTML format, use **Save As** rather than an ordinary **Save** when converting it into a native Word document.

### Cancelling

Press **Escape** to request cancellation. A normal cancellation restores `HelpHelp.mac` if it was temporarily disabled and displays `Hlp2txt was aborted.`

## Troubleshooting

### The macro does not compile

- Verify that you are compiling with the Win32 SAL compiler.
- Confirm that the complete, unchanged `Hlp2txt.s` source was extracted.
- Use a TSE release supported by the source.

### The output file cannot be created

- Confirm that TSE's `Help` directory exists.
- Check that your Windows account can write to that directory.
- Close another application if it has locked the existing output file.

### Additional GetHelp topics are missing

This is expected. HLP2TXT converts TSE's internal Help and intentionally does not add the extra topics supplied by GetHelp.

### `HelpHelp.mac` appears to be missing

Look for `HelpHelp.nomac`. If a previous run was interrupted by a crash, either run HLP2TXT through completion or, with TSE closed, rename it to `HelpHelp.mac` manually.

## Version history

| README version | Date and time | Changes |
| --- | --- | --- |
| 1.0.0.0.0 | 2026-09-10 22:28:47 UTC | Initial Markdown description, installation instructions, run procedure, format reference, compatibility notes, and troubleshooting help. |

Future README revisions should increment the final component sequentially: `1.0.0.0.1`, `1.0.0.0.2`, `1.0.0.0.3`, and so on.

## Original macro release

HLP2TXT version 2.4.4 was released on 31 July 2005. It replaced version 2.4.2 and added compatibility improvements for an installed `HelpHelp.mac` plus optimized TSE 4.4 version detection.
