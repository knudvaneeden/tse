# GENERATE

**Session title:** Create GENERATE MarkDown Readme  
**README version:** 1.0.0.0.3  
**Date:** 2026-09-10  
**Time:** 12:21:47 CEST  
**Original author:** Hans de Wit, The Netherlands

## Description

GENERATE is a TSE (The SemWare Editor) SAL macro that repeats a marked block or the current line and automatically increments one or more numbers in the generated text.

Numbers to increment are written as `#` followed by their starting value. Each generated copy adds the step value to every marked number. Leading zeroes are retained where possible, making the macro useful for generating numbered variable names, repetitive commands, test data, and similar text.

The archive contains:

- `GENERATE.S` - the SAL source code.
- `GENERATE.MAC` - the compiled TSE macro supplied with the original package.

## Requirements

- The SemWare Editor (TSE) for DOS or a compatible TSE environment.
- The supplied `GENERATE.MAC`, or a compatible SAL compiler if you want to compile `GENERATE.S` yourself.
- Text containing at least one counter in the form `#number`, such as `#1` or `#001`.

The supplied files date from 1993. Compatibility with a recent TSE version may require recompiling or adapting the source.

## How GENERATE works

For example, begin with:

```text
bla var#1 bla
```

With a repeat count of `5` and a step of `1`, GENERATE produces:

```text
bla var1 bla
bla var2 bla
bla var3 bla
bla var4 bla
bla var5 bla
```

More than one counter can occur in the same block. For example:

```text
recode (#1=#2)
```

With a repeat count of `5` and a step of `1`, this becomes:

```text
recode (1=2)(2=3)(3=4)(4=5)(5=6)
```

Leading zeroes are supported:

```text
var#001
```

This generates values such as `var001`, `var002`, and eventually `var010`.

## Installation

### Using the supplied compiled macro

1. Extract `generate.zip`.
2. Copy `GENERATE.MAC` to a directory from which TSE can load macros.
3. Start TSE.

### Compiling the source

1. Extract `generate.zip`.
2. Open a command prompt in the extracted directory.
3. Compile the source with the SAL compiler appropriate for your TSE version, for example:

```bat
sc32 GENERATE.S
```

4. Confirm that the compiler creates `GENERATE.MAC` without errors.
5. Place the compiled macro where TSE can load it.

## Steps to run GENERATE

1. Open the file that contains the text to generate.
2. Add `#` immediately before each starting number that must be incremented.
3. Mark the required text as a character or line block. If no block is marked and TSE's `UseCurrLineIfNoBlock` setting is enabled, GENERATE uses the current line.
4. Execute the `GENERATE` macro from TSE.
5. At the `Repeat #:` prompt, enter the total number of copies to create.
6. At the `Step:` prompt, enter the amount to add for each successive copy.
7. Press **Enter** to generate the text. Cancel either prompt to stop the operation.

## Block selection notes

- A line block produces repeated lines.
- A character block can produce consecutive text on the same line.
- Do not extend a character block beyond the end of the line unless you want each generated copy placed on a separate line.
- If no block is active and `UseCurrLineIfNoBlock` is disabled, the macro displays `No block is active` and stops.

## Examples

### Step greater than one

Input:

```text
item#10
```

Repeat count: `4`  
Step: `5`

Result:

```text
item10
item15
item20
item25
```

### Two counters

Input:

```text
range #10 through #20
```

Repeat count: `3`  
Step: `10`

Result:

```text
range 10 through 20
range 20 through 30
range 30 through 40
```

## Help and troubleshooting

### The message `No block is active` appears

Mark a block before running the macro, or enable TSE's `UseCurrLineIfNoBlock` setting so the current line can be used automatically.

### A number is not incremented

Verify that the starting value is written immediately after `#`, for example `#1`. The marker must be inside the selected block.

### Generated copies appear on separate lines

Check the end of a character-block selection. A selection that continues beyond the end of the source line causes the generated text to be laid out differently.

### Leading zeroes disappear

GENERATE preserves the available zero prefix until the increasing number needs more digits. For example, `#009` becomes `009`, `010`, and so on.

### The supplied macro does not run

`GENERATE.MAC` is an older compiled macro. Compile `GENERATE.S` with the SAL compiler belonging to your installed TSE version. Source changes may be necessary if that compiler no longer supports an older command or configuration variable.

## Safety notes

- Save the current file before running GENERATE on important text.
- Test the macro on a small block first when using a large repeat count.
- Check the selected block carefully because GENERATE replaces the original selection with the generated result.
- The TSE 4.50-compatible source uses the active TSE clipboard, so copy important clipboard contents elsewhere before running the macro.

## Version history

### 1.0.0.0.3 - 2026-09-10 12:31:35 CEST

- Removed the obsolete `GetClipboardId()` and `SetClipboardId()` calls, which are unavailable in TSE SAL Compiler V4.50.rc23.
- Updated the macro to use the active TSE clipboard.
- Documented that running GENERATE replaces the current clipboard contents.

### 1.0.0.0.2 - 2026-09-10 12:27:40 CEST

- Updated `GENERATE.S` for TSE SAL Compiler V4.50.rc23.
- Replaced the obsolete `GetFreeHistory()` calls, which caused errors 2204 and 2302, with `_EDIT_HISTORY_`.
- Added global strings that retain the last repeat and step values while the macro remains loaded.

### 1.0.0.0.1 - 2026-09-10 12:21:47 CEST

- Expanded the documentation with detailed installation, usage, examples, block-selection guidance, troubleshooting, and safety notes.
- Documented the contents of the supplied archive and the age-related compatibility consideration.

### 1.0.0.0.0 - 2026-09-10 12:21:47 CEST

- Created the initial Markdown description and basic instructions for GENERATE.
