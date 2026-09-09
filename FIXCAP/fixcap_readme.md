# FIXCAP for TSE Pro/32

## Description

FIXCAP is a TSE Pro/32 SAL macro that corrects reversed uppercase and lowercase keyboard input caused by a historical Windows console-input problem.

The problem can occur under Windows 95 OSR2 or the original release of Windows 98 when Caps Lock is enabled before TSE Pro/32 is started. In that situation, an uppercase letter may be received as lowercase and a lowercase letter may be received as uppercase, contrary to the Caps Lock indicator.

FIXCAP monitors keys after they are read by TSE. It compares each alphabetic key with the reported Caps Lock and Shift states and changes the character's case when the received character does not match the expected state. It also adjusts affected Alt+letter and Alt+Shift+letter key codes.

The macro may remain loaded even when the problem is not present. Characters whose case already agrees with the keyboard state are left unchanged.

## Package contents

| File | Purpose |
| --- | --- |
| `fixcap.s` | TSE SAL source code for the macro. |
| `fixcap.mac` | Supplied compiled macro, originally intended for TSE Pro/32 v2.x. |
| `read.me` | Original installation notes. |
| `file_id.diz` | Original short package description. |

## Requirements

- The SemWare Editor Professional (TSE Pro/32).
- Windows 95 OSR2 or the original release of Windows 98 if the historical Caps Lock reversal is being experienced.
- The TSE SAL compiler only when recompiling `fixcap.s`.

This macro was created for an old Windows console issue and is normally unnecessary on modern Windows versions.

## How FIXCAP works

When loaded, FIXCAP hooks TSE's `_AFTER_GETKEY_` event. For each keyboard event, it reads:

- the character received by TSE;
- the Caps Lock state;
- the left or right Shift-key state.

For letters `A` through `Z` and `a` through `z`, the macro checks whether the received case is consistent with Caps Lock and Shift. If it is inconsistent, FIXCAP changes the key code to the expected uppercase or lowercase value before TSE processes the key normally.

When the macro is purged, its keyboard hook is removed automatically.

## Installation using the supplied compiled macro

1. Close TSE Pro/32 if it is running.
2. Extract `fixcap.zip`.
3. Copy `fixcap.mac` to the TSE Pro/32 macro directory.
4. Start TSE Pro/32.
5. Add `FIXCAP` to TSE's autoload macro list so that it is loaded automatically at startup.
6. Restart TSE and test alphabetic input with Caps Lock both enabled and disabled, with and without Shift.

## Compiling from the SAL source

1. Copy `fixcap.s` to a working directory or to the TSE macro directory.
2. Open a command prompt in that directory.
3. Compile the source with the TSE SAL compiler:

   ```text
   sc32 fixcap.s
   ```

4. Confirm that compilation creates `fixcap.mac` without errors.
5. Copy the newly compiled `fixcap.mac` to the TSE macro directory if it was compiled elsewhere.
6. Add `FIXCAP` to the TSE autoload macro list.
7. Restart TSE Pro/32.

## How to run it

FIXCAP is intended to run as an autoloaded background macro. It does not open a dialog and does not require a command for each correction.

After it is loaded, type letters in these four conditions to verify the result:

| Caps Lock | Shift | Expected letters |
| --- | --- | --- |
| Off | Not pressed | Lowercase |
| Off | Pressed | Uppercase |
| On | Not pressed | Uppercase |
| On | Pressed | Lowercase |

## Removing or disabling FIXCAP

1. Remove `FIXCAP` from the TSE autoload macro list.
2. Purge the macro or restart TSE Pro/32.
3. Delete `fixcap.mac` from the macro directory only if it is no longer required.

Purging the macro invokes its cleanup procedure and removes the `_AFTER_GETKEY_` hook.

## Troubleshooting

### The macro appears to do nothing

This is expected if keyboard input already agrees with the Caps Lock and Shift states. FIXCAP changes only inconsistent alphabetic key codes.

### Letter case is still reversed

- Confirm that `fixcap.mac` is in the correct TSE macro directory.
- Confirm that `FIXCAP` is present in the autoload macro list.
- Restart TSE after changing the autoload configuration.
- Recompile `fixcap.s` with the SAL compiler belonging to the installed TSE version if the supplied historical `fixcap.mac` is incompatible.

### A warning says that the macro code needs to be adjusted

The source assumes that TSE's `_RIGHT_SHIFT_KEY_` and `_LEFT_SHIFT_KEY_` constants have the same value. If they differ in the installed TSE version, FIXCAP displays a warning and purges itself. The Shift-key detection logic in `fixcap.s` must then be updated before use.

### A simple workaround is preferred

On the affected Windows versions, turn Caps Lock off before opening the command prompt or shortcut used to start TSE Pro/32. The original package notes state that input should then behave normally without FIXCAP.

## Version history

### 1.0.0.0.1 - 2026-09-09 18:41:04 CEST

- Expanded the documentation with package contents, requirements, operating details, installation, compilation, testing, removal, and troubleshooting instructions.
- Clarified the historical Windows and TSE Pro/32 scope.

### 1.0.0.0.0 - 2026-09-09 18:41:04 CEST

- Created the initial Markdown description and help documentation from the supplied FIXCAP package.

## Credits

FIXCAP was uploaded by SemWare. The original source is dated 1999-07-07 and identifies the program as a helper macro for TSE Pro/32 v2.x.

---

README version: **1.0.0.0.1**  
Generated: **2026-09-09 18:41:04 CEST**  
Generated by: **OpenAI Codex (GPT-5)**
