# AbanName Macro - README

## Metadata
* **Macro:** AbanName
* **Author:** Carlo.Hogeveen@xs4all.nl
* **Date:** 3 August 2007
* **Version:** 3.0.2
* **Compatibility:** TSE Pro 2.5e upwards

## Overview
From the files already opened in TSE, you can select files based on (part of) their `drive:\path\filenames`, and either **Abandon** or **Keep** the selected files. Keeping the selected files means abandoning all others.

This macro utilizes TSE's ability to open files without loading them, which avoids memory issues when dealing with large directories.

## Matching Methods
When selecting files to abandon or keep, you can choose to match a part of the filename ("contain") or the whole filename ("fully match"). The string you supply can use one of three formats:
1. **Literal text:** All characters are interpreted exactly as themselves.
2. **MsDos expression:** May contain the MsDos wildcards `*` and `?`.
3. **Regular expression:** All TSE regular expression characters except `^` and `$` are allowed.

## WARNING - File Limits
Because this macro encourages opening enormous amounts of files, you must be aware of TSE version limitations:
* **TSE Pro 2.5 through 2.8:** Can only load up to **65,536** files safely.
* **TSE Pro 3.0 through 4.4:** Can only load up to **32,767** files safely.

Exceeding these limits can cause TSE to become unstable without a warning. The macro attempts to detect if too many files are loaded and will issue a warning if possible.

## Installation
1. Copy the `abanname.s` file to TSE's `mac` directory and compile it.
2. You can execute it via:
   * Menu: Macro Execute "AbanName"
   * Key assignment: `ExecMacro("AbanName")`
   * Potpourri menu addition

## Version History
* **v1 (16 December 2003):** Initial version.
* **v2 (16 June 2004):** Fixed infinite loop error. Added whole filename matching, MsDos expressions, regular expressions, and run-time Help.
* **v3 (13 August 2005):** Fixed counting error. Merged the v2 interface with an improved search algorithm.
* **v3.0.1 (1 July 2007):** Solved bug and improved open file limit detection.
* **v3.0.2 (3 August 2007):** Fixed a bug where the current file was loaded as an empty file if it hadn't been loaded yet.
