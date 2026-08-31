# BrowsMod for The SemWare Editor (TSE)

**README version:** 1.0.0.0.0  
**Macro:** `BROWSMOD.S`  
**Original author:** Carlo Hogeveen  
**Supported editor:** The SemWare Editor (TSE) 3.0 and later

## Description

BrowsMod is a TSE SAL macro that automatically switches the current file's **Browse Mode** on or off.

Browse Mode lets you view and navigate through a file while preventing accidental changes inside the editor. This is especially useful when a file cannot or should not be modified.

BrowsMod can enable Browse Mode when:

- The file has the read-only disk attribute.
- Any part of its full drive, path, filename, or extension contains one of the configured strings.

If neither condition applies, the macro automatically turns Browse Mode off. You can still manually override the selected mode for the current file by using TSE's Browse Mode toggle.

## Files in the archive

- `BROWSMOD.S` — TSE SAL source code.
- `FILE_ID.DIZ` — brief description of the original macro.

After configuration, the macro also creates:

- `BrowsMod.cfg` — configuration file stored in TSE's `mac` directory.

## Installation

1. Extract `BROWSMOD.S` from the ZIP archive.
2. Copy `BROWSMOD.S` into TSE's `mac` directory.
3. Compile the macro with the TSE SAL compiler.

For example, open a command prompt in the `mac` directory and run:

```text
sc32 BROWSMOD.S
```

The exact compiler command can differ with the installed TSE version. You can also compile the source using your usual TSE SAL compilation command or macro.

## First-time configuration

1. Start TSE.
2. Run the compiled macro by entering:

```text
BrowsMod
```

3. At the first prompt, choose whether Browse Mode should be enabled for write-protected disk files:

```text
Set BrowseMode ON for write-protected disk-files (y/n)?
```

4. At the second prompt, enter the filename or path strings that should activate Browse Mode. Separate multiple strings with spaces.

The proposed default strings are:

```text
* readonly read_only read\only read/only
```

5. Confirm the configuration. BrowsMod writes the settings to `BrowsMod.cfg` and adds itself to TSE's Macro AutoLoad List when at least one automatic rule is enabled.

## How it works

While TSE is idle, BrowsMod detects when you switch to a different normal file buffer or when the current filename changes. It then checks:

1. Whether checking the read-only disk attribute is enabled and the current disk file is read-only.
2. Whether the lowercase full filename contains any configured lowercase string.

When either test matches, Browse Mode is turned on. Otherwise, Browse Mode is turned off. A short pop-up reports `ON` or `OFF` whenever BrowsMod changes the mode.

String matching is case-insensitive and applies to the complete filename, including its drive and directory path. For example, configuring `readonly` also matches a file located in a directory such as:

```text
C:\Projects\readonly\notes.txt
```

## Reconfiguring BrowsMod

Run the macro again at any time:

```text
BrowsMod
```

Enter the new choices when prompted. The configuration file and AutoLoad setting are updated automatically.

## Disabling automatic Browse Mode

Run `BrowsMod`, answer `n` to the read-only-file question, and leave the configurable strings field empty.

BrowsMod will then:

- Delete `BrowsMod.cfg`.
- Remove itself from TSE's Macro AutoLoad List.
- Purge the loaded macro.

## Manual override

You can use TSE's normal Browse Mode menu command to override BrowsMod for the current file. BrowsMod normally evaluates a buffer when it is first encountered or when its filename changes, so the manual setting can remain in effect while you continue working in that buffer.

## Troubleshooting

### The macro does not run automatically

Run `BrowsMod` once and enable at least one rule. The macro adds itself to the Macro AutoLoad List only when read-only checking is enabled or at least one match string is configured.

### The macro cannot create its configuration file

Verify that TSE's `mac` directory exists and that you have permission to write to it. BrowsMod expects to save `BrowsMod.cfg` in:

```text
<TSE load directory>\mac\BrowsMod.cfg
```

### Browse Mode activates unexpectedly

Run `BrowsMod` and review the configured strings. Each string is matched anywhere in the complete path and filename, not only in the base filename. Remove any rule that is too broad.

### A read-only file is not detected

Run `BrowsMod` and answer `y` when asked whether Browse Mode should be enabled for write-protected disk files. The check applies to an existing disk file with the read-only attribute.

## Version history

### 1.0.0.0.0

- Initial Markdown documentation for the supplied BrowsMod archive.
- Documented installation, compilation, configuration, operation, disabling, manual override, and troubleshooting.

Future README revisions can continue as `1.0.0.0.1`, `1.0.0.0.2`, and so on.

## Credits

BrowsMod was written by Carlo Hogeveen. The supplied source identifies the original date as January 6, 2002, and the rewrite date as September 4, 2003.
