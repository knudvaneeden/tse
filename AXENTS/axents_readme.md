# AXENTS — accented-vowel dead keys for TSE

`axents.s` is a TSE SAL keyboard macro written by Luigi M. Bianchi. It turns four accent keys into **dead keys**: after pressing an accent key, the macro waits for one more key and either inserts an accented lowercase vowel or inserts the accent followed by the typed character.

## Supported keys

| Press first | Then press | Result |
|---|---|---|
| `` ` `` | `a`, `e`, `i`, `o`, or `u` | `à`, `è`, `ì`, `ò`, or `ù` |
| `'` | `a`, `e`, `i`, `o`, or `u` | `á`, `é`, `í`, `ó`, or `ú` |
| `Shift+'` (`"`) | `a`, `e`, `i`, `o`, or `u` | `ä`, `ë`, `ï`, `ö`, or `ü` |
| `Shift+6` (`^`) | `a`, `e`, `i`, `o`, or `u` | `â`, `ê`, `î`, `ô`, or `û` |

Examples:

- Press `` ` `` and then `a` to insert `à`.
- Press `'` and then `e` to insert `é`.
- Press `Shift+'` and then `u` to insert `ü`.
- Press `Shift+6` and then `o` to insert `ô`.

If the second key is not a supported lowercase vowel, AXENTS inserts the accent and that character unchanged. Pressing Spacebar after an accent inserts only the accent. Pressing Enter inserts the accent and then performs the normal carriage-return action.

## Requirements

- The SemWare Editor (TSE) for DOS or Windows with its SAL compiler.
- The source file `axents.s`.
- An editor/code-page configuration that supports the file's original OEM extended characters. The supplied source is extended-ASCII/OEM encoded, not UTF-8.

## Compile and run

1. Copy `axents.s` to your TSE macro source or working directory.
2. Open a command prompt in that directory.
3. Compile the source with the TSE SAL compiler:

   ```text
   sc32 axents.s
   ```

   If your TSE installation uses a differently named SAL compiler, run that compiler instead. A successful compilation creates the loadable macro file, normally `axents.mac`.

4. Start TSE.
5. Load `axents.mac` using TSE's **Macro → Load** command, or your usual macro-loading command.
6. In an editable file, test the macro—for example, press `'` followed by `e`; TSE should insert `é`.

The four key bindings remain active while the macro is loaded. To restore the keys' normal behavior, unload AXENTS or restart TSE without loading it.

## Optional automatic loading

To make AXENTS available in every TSE session, add `axents.mac` to your normal TSE macro autoload/startup configuration. The exact procedure depends on your TSE version and existing configuration.

## Important notes

- AXENTS handles lowercase `a`, `e`, `i`, `o`, and `u`; uppercase accented vowels are not defined.
- The macro takes over the plain backtick and apostrophe keys plus `Shift+'` and `Shift+6`. This affects normal entry of those punctuation characters while AXENTS is loaded.
- To enter an accent by itself, press the accent key and then Spacebar.
- The supplied source appears to contain a trailing space after the `ë` and `ê` output strings. If you observe an unwanted space after either character, remove the space inside the corresponding `InsertText(...)` string and recompile.
- Avoid converting `axents.s` blindly to UTF-8: older TSE/SAL versions may expect the original OEM character encoding.

## Troubleshooting

### Accented characters appear incorrectly

The source uses OEM extended-ASCII characters. Restore the original file encoding or configure TSE and the SAL compiler for the matching code page. A UTF-8 conversion can change the bytes that TSE inserts.

### The accent key behaves normally

Confirm that `axents.mac` compiled successfully and is currently loaded. Also check whether another loaded macro has replaced the same key binding.

### The SAL compiler is not found

Run it with its complete path, for example:

```text
G:\path\to\TSE\sc32.exe axents.s
```

Alternatively, add the TSE compiler directory to the Windows `PATH`.

### Compilation fails after editing the file

Reopen or save the source using the original OEM-compatible encoding. Also verify that the accent characters and quotation marks inside `InsertText(...)` were not altered by another editor.

## Source information

- Macro name: AXENTS
- Source file: `axents.s`
- Original author: Luigi M. Bianchi
- Date recorded in the source: 04-09-94
