# DelSpace 6 for TSE Pro/32

**README version:** 1.0.0.0.0  
**Created:** 2026-09-04 21:42:51 UTC  
**Original macro:** DelSpace version 6 (2001-11-11)  
**Original author:** Carlo Hogeveen  

## Description

DelSpace is a SAL macro for The SemWare Editor Professional (TSE Pro/32). It scans the current text file for words that may have been split by one or more spaces and proposes repairs such as changing `opera te` to `operate`.

The macro uses TSE's spelling dictionary to decide whether a joined word is valid. It does not immediately alter the document. Instead, it creates a report containing all proposed changes so that you can review and remove unwanted changes before applying the remaining ones.

The supplied archive contains:

- `DELSPACE.S` - SAL source code for DelSpace version 6.
- `FILE_ID.DIZ` - Short original package description.

## Requirements

- The SemWare Editor Professional for Windows (TSE Pro/32).
- The TSE SAL compiler (`sc32.exe`).
- TSE's spelling components:
  - `spell.dll`
  - `semware.lex`
- A file open in TSE that you want to inspect and correct.

The source was originally distributed for TSE Pro/32 version 3.0. Compatibility with substantially newer TSE releases may depend on continued support for the older SAL statements and spelling-library interface used by the macro.

## Installation and compilation

1. Extract `delspac6.zip` to a working directory.
2. Copy `DELSPACE.S` to an appropriate TSE macro source directory, if desired.
3. Open a command prompt in the directory containing `DELSPACE.S`.
4. Compile the source with the TSE SAL compiler:

   ```bat
   sc32 DELSPACE.S
   ```

5. Confirm that the compiler creates the compiled DelSpace macro file.
6. Make sure TSE can find the compiled macro through its normal macro directory or macro search path.

The source expects the spelling dictionary at the following location relative to TSE's load directory:

```text
spell\semware.lex
```

It also uses `spell.dll`, which must be available to TSE when the macro runs.

## How to run DelSpace

1. Make a backup of the document you intend to process.
2. Open that document in TSE.
3. Run the compiled `DelSpace` macro using TSE's macro execution command.
4. Wait while DelSpace scans the file. Progress is displayed as a percentage.
5. Review the generated report of proposed changes.
6. Use the report controls described below to approve, reject, or cancel the changes.

## Report controls

| Key | Action |
| --- | --- |
| Up/Down Arrow | Move through the proposed changes. |
| Page Up/Page Down | Move through the report one page at a time. |
| Home | Go to the beginning of the report. |
| End | Go to the end of the report. |
| Spacebar | Delete the selected report line so that change will not be applied. |
| Enter | Apply every change still present in the report. |
| Escape | Cancel the operation and return to the original document without applying changes. |

## Example

If the document contains:

```text
Please opera te the machine carefully.
```

and `operate` is recognized by the TSE spelling dictionary, DelSpace may propose:

```text
At line 1 column 8 change opera te to operate
```

Leave that report line in place and press **Enter** to apply it. Press **Spacebar** on the line first if you do not want that particular replacement.

## Important notes

- DelSpace relies on dictionary validation. A proposed joined word should still be checked in its sentence context.
- Pressing **Enter** applies all proposal lines remaining in the report.
- Pressing **Escape** cancels the operation without applying any proposals.
- The document is changed in memory; save it through TSE after reviewing the result.
- The Windows code path uses `spell.dll`. The source also contains a historical non-Windows path that refers to `spellbin.bin`.
- If DelSpace reports `Can't open semware.lex`, verify that the dictionary exists in TSE's `spell` directory and that TSE's load directory is configured correctly.

## Troubleshooting

### The macro does not compile

- Confirm that `sc32.exe` is installed and accessible from the command prompt.
- Run the compiler from the directory containing `DELSPACE.S`, or provide the complete path to the source file.
- Check whether your TSE version still supports the SAL syntax and DLL declarations used by this 2001 source.

### The macro cannot open `semware.lex`

- Check for `semware.lex` under TSE's `spell` directory.
- Confirm that TSE's load directory points to the correct TSE installation.
- Make sure the spelling files belong to the same TSE installation being used to run the macro.

### No changes are proposed

- The split text may not form a word recognized by `semware.lex`.
- The text may already be valid according to the dictionary.
- Review punctuation and spelling around the suspected fragment.

### A proposed change is unwanted

Select its line in the report and press **Spacebar**. The deleted proposal will not be applied when you press **Enter**.

## Version history

### README 1.0.0.0.0 - 2026-09-04 21:42:51 UTC

- Created the Markdown documentation.
- Added a description of the macro and its review-before-change workflow.
- Added requirements, compilation steps, run instructions, controls, an example, and troubleshooting help.
- Documented the original archive contents and the spelling-library dependency.

## README version numbering

Future documentation revisions should increment the final component:

```text
1.0.0.0.0
1.0.0.0.1
1.0.0.0.2
1.0.0.0.3
```

Major documentation changes may increment an earlier component when appropriate.

## Original program history

- Version 2 (1999-07-31): Renamed to Fragment and added music.
- Version 3 (2001-11-07): Renamed to DelSpace, removed music, and optimized spell checking by directly using the spelling binary or DLL.
- Version 4 (2001-11-08): Added immediate and more frequent progress percentages and removed an incorrect keypress message.
- Version 5 (2001-11-09): Added support for joining a valid word followed by one or more invalid fragments, such as `opera te` to `operate`.
- Version 6 (2001-11-11): Corrected punctuation handling and report-line deletion behavior, with an apparent performance improvement.

## Disclaimer

Use this macro on copies or backed-up files until you are satisfied with its behavior. The README documents the supplied historical source but does not modify the original program.
