# COPYBLOCKTOVM

Version: **1.0.0.0.1**  
Date and time: **2026-10-28 22:08:15**

## Description

COPYBLOCKTOVM is a TSE SAL macro for Windows. It copies the marked block from the current TSE file to the Windows clipboard, then runs PowerShell and VirtualBox `VBoxManage.exe` to type that text into a running Linux virtual machine.

The destination is the VM's currently focused input. Prepare that input before running the macro. The Windows clipboard is replaced with the marked text.

## Package contents

- `copyblocktovm.s`: SAL source, including settings and the startup information message.
- `copyblocktovm.ini`: editable settings.
- `copyblocktovm_readme.md`: description, help and instructions.

The ZIP is named `copyblocktovm1.0.0.0.1.zip`. A compiled `.mac` file is not included.

## Requirements

- Windows and TSE Pro with a compatible SAL compiler (`sc32.exe` or `sc32b.exe`).
- Windows PowerShell available as `powershell`.
- VirtualBox with `VBoxManage.exe` installed at `C:\Program Files\Oracle\VirtualBox\VBoxManage.exe`.
- A running VM with one of these exact names:

| INI value | VirtualBox VM name |
| --- | --- |
| `Ubuntu` | `Linux Ubuntu` |
| `Debian` | `Linux Debian` |
| `CentOS` | `Linux CentOS` |

These are VirtualBox VM names, not WSL distribution names. If your executable path or VM naming scheme differs, edit the `commandText = Format(...)` statement in the source and recompile.

## Install and compile

1. Extract all three files to a macro folder.
2. Open a command prompt in that folder. Ensure the SAL compiler is available on PATH, or invoke it using its full path.
3. Compile using either installed compiler:

   ```bat
   sc32 copyblocktovm.s
   ```

   Or:

   ```bat
   sc32b copyblocktovm.s
   ```

4. Confirm that compilation succeeds and produces `copyblocktovm.mac`.
5. Keep `copyblocktovm.ini` beside that `.mac` file. Place the macro in a folder on TSE's macro search path, or use its full path when executing it.

## Settings

Default `copyblocktovm.ini`:

```ini
[copyblocktovm]
silent=false
linuxdistribution=Ubuntu
```

| Setting | Default | Effect |
| --- | --- | --- |
| `silent` | `false` | `false` shows the informative `Warn()` box in `Main()`. `true` hides that startup box. |
| `linuxdistribution` | `Ubuntu` | Prefills the distribution prompt. Supported values: `Ubuntu`, `Debian`, `CentOS`. |

For example:

```ini
[copyblocktovm]
silent=true
linuxdistribution=Debian
```

Settings are read on each run from the macro's own folder. No working-directory change is needed. Missing settings or a missing INI use the defaults. Key names and supported values are handled without case sensitivity; surrounding spaces are removed. Put comments on separate lines beginning with `;` or `#`. If a key occurs more than once, the last value wins. The section heading is for readability; the reader scans key/value lines throughout the file.

`silent=true` suppresses only the startup information box. The distribution prompt, error boxes and final status message remain active. Distribution choices made in the prompt are not written back to the INI; edit the INI to change the default.

## Run step by step

1. Start the destination VirtualBox VM.
2. Inside that VM, focus the application and input where you want the text typed. Review the selected text first: line breaks sent to a terminal can execute commands.
3. Return to TSE and mark the desired block in the current file.
4. Open TSE's **Execute Macro** command (normally **F9**), enter `copyblocktovm`, and confirm. Use the full `.mac` path if it is outside the macro search path.
5. When `silent=false`, read and dismiss the startup information box.
6. Accept the prefilled distribution or enter `Ubuntu`, `Debian` or `CentOS`. Cancel exits without sending the block.
7. The macro copies the block to the Windows clipboard and launches PowerShell to send it to the corresponding VM.
8. Check the destination VM to confirm the text arrived correctly.

The source also defines **Ctrl+F12** to call `Main()` while the macro remains loaded. Executing the macro by name is the primary way to run it; if that shortcut conflicts with another macro or editor binding, change the binding and recompile.

## Help and troubleshooting

- **Please mark a block:** mark a block in the current TSE file and run again.
- **Clipboard error:** the copy failed; no VirtualBox command is launched.
- **Invalid distribution:** use one of the three supported names. An empty value is rejected. No command is sent.
- **VM not found or not running:** check the exact VM name and running state in VirtualBox.
- **Executable not found:** adjust the VirtualBox path in the SAL source and recompile.
- **Text arrives in the wrong place:** focus the intended input inside the VM before running the macro.
- **Startup box remains visible:** put `silent=true` in the INI beside the actual compiled macro being executed, then run again.
- **Special characters or line breaks differ:** test a short sample first. VirtualBox keyboard injection, the guest keyboard layout and the receiving application can affect the result.

The final message confirms that the macro launched the command. It does not verify the PowerShell/VirtualBox exit status or successful delivery inside the guest. Inspect any PowerShell error output and the destination VM.

## Changes in package 1.0.0.0.1

- Added this README with installation, configuration, usage and troubleshooting.
- Added `copyblocktovm.ini` with `silent=false` and `linuxdistribution=Ubuntu`.
- Added an informative startup `Warn()` in `Main()`, controlled by `silent`.
- Added distribution validation and reliable cancellation of the prompt.
- Stop after a clipboard-copy failure.
- Preserve the original VirtualBox keyboard-injection approach.

The supplied source contained an embedded library-routine version `1.0.0.0.7`. This deliverable uses the requested package version **1.0.0.0.1** consistently.

## Marked-block correction

The block checks use the explicit SAL form `IF ( NOT ( IsBlockInCurrFile() ) )`. The copy routine returns `FALSE` if no block is marked. INI loading now saves the existing block with `PushBlock()` and restores it with `PopBlock()` after returning to the original buffer. This protects the selection while reading settings in a temporary buffer.

Recompile the updated source and execute the newly compiled macro. Verify with a marked block and an unmarked buffer, using both `silent=false` and `silent=true`.

## Validation

The package contents and configuration were inspected and the ZIP integrity checked. TSE/SAL, Windows PowerShell and VirtualBox are unavailable in the build environment, so compilation and an end-to-end VM transfer must be checked on your Windows installation.
