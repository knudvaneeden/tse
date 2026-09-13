# SPEAK for TSE Pro

**Session:** Create SPEAK MarkDown Readme  
**README version:** 1.0.0.0.0  
**Last updated:** 2026-09-13 15:20:28 UTC  
**Documented package:** `speak.zip`

## Description

SPEAK adds Windows text-to-speech support to The SemWare Editor Professional (TSE Pro). The supplied TSE SAL macro communicates with `speak.dll` to speak entered text, select an installed voice, adjust the volume, and control asynchronous speech.

The package contains:

| File | Purpose |
| --- | --- |
| `speak.s` | TSE SAL source code and key assignments |
| `speak.mac` | Compiled TSE macro, ready to load |
| `speak.dll` | Windows text-to-speech interface used by the macro |

The source history records the original creation on December 15, 2024, asynchronous speech support on December 24, loading additional voices on December 28, and voice-count handling on December 29, 2024.

## Requirements

- TSE Pro for Windows with 32-bit DLL support
- A Windows speech engine with at least one installed voice
- The three package files kept together, especially `speak.mac` and `speak.dll`
- Working sound output and a suitable playback volume in Windows

## Installation

1. Extract `speak.zip` into a folder.
2. Keep `speak.dll`, `speak.mac`, and `speak.s` in the same folder.
3. Start TSE Pro.
4. Load or run `speak.mac` from TSE.
5. When initialization succeeds, SPEAK announces that the DLL has loaded and says to press **Ctrl+F7** for help.

If you prefer to compile the source yourself, run the TSE SAL compiler on `speak.s`:

```text
sc32 speak.s
```

This creates `speak.mac`. Make sure `speak.dll` remains available when the compiled macro is loaded.

## How to run SPEAK

1. Load `speak.mac` in TSE Pro.
2. Press **Ctrl+F8**.
3. Enter the text that you want spoken.
4. Press **Enter** to start speaking the text asynchronously.
5. Use the pause, resume, or stop keys if needed.

## Keyboard commands

| Key | Action |
| --- | --- |
| **Ctrl+F7** | Speak a brief help message |
| **Ctrl+F8** | Ask for text and speak it asynchronously |
| **Ctrl+F9** | Pause asynchronous speech with UID 10 |
| **Ctrl+F10** | Resume asynchronous speech with UID 10 |
| **Ctrl+F11** | Stop asynchronous speech with UID 10 |
| **Alt+F5** | Load additional voices from the configured Windows speech registry path |
| **Alt+F6** | Select and demonstrate the previous voice |
| **Alt+F7** | Select and demonstrate the next voice |
| **Alt+F8** | Choose a volume from 0 through 100 |
| **Alt+F9** | Choose a voice by number |
| **Alt+F10** | Insert the list of available voices into the current editor buffer |
| **Alt+F11** | Insert the SPEAK DLL API list into the current editor buffer |
| **Alt+F12** | Write the DLL API information to `speak_dll_api.txt` |

## Voice selection

Press **Alt+F10** to insert a numbered list of detected voices into the current buffer. You can then press **Alt+F9**, enter one of those voice numbers, and press **Enter**.

The first detected voice is number `0`. **Alt+F6** and **Alt+F7** cycle through the available voices and speak a demonstration using the newly selected voice.

## Volume

Press **Alt+F8**, enter a whole-number volume from `0` through `100`, and press **Enter**. On initialization, the macro selects voice `0` and sets the speech volume to `50`.

## Synchronous and asynchronous functions

The source can also be included or adapted by other TSE SAL macros. It provides procedures for:

- synchronous text speech, which blocks until playback finishes;
- asynchronous text speech, which continues in the background;
- speaking the contents of a file through the DLL interface;
- pausing, resuming, and stopping an asynchronous speech item by UID;
- getting and setting the current voice and volume;
- listing voice and DLL API information;
- loading more voices from a Windows registry path.

The supplied interactive commands use asynchronous UID `10`.

## Troubleshooting

### The speech engine cannot be initialized

- Confirm that `speak.dll` is accessible to the macro.
- Confirm that Windows has at least one installed text-to-speech voice.
- Use the supplied 32-bit DLL with a compatible 32-bit TSE Pro installation.
- Restart TSE after replacing `speak.dll`, because a loaded DLL may remain in memory for the rest of the editor session.

### No sound is heard

- Check the Windows output device and system volume.
- Press **Alt+F8** and set a higher SPEAK volume.
- Try another installed voice with **Alt+F6**, **Alt+F7**, or **Alt+F9**.

### A voice number is rejected

Press **Alt+F10** to obtain the current list. Valid voice numbers start at `0` and end at one less than the detected voice count.

### Extra voices are not listed

Press **Alt+F5** to ask the DLL to load voices registered under:

```text
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\Voices
```

Then press **Alt+F10** again to insert the refreshed list.

### A shortcut conflicts with another macro or Windows

Edit the key assignments at the end of `speak.s`, compile it again with `sc32 speak.s`, restart TSE if necessary, and load the new `speak.mac`.

## Notes

- `speak.s` is both the interface to `speak.dll` and a working demonstration macro.
- The macro limits entered speech text to the TSE SAL string size used by its prompt.
- **Alt+F10** and **Alt+F11** add information at the current location in the active editor buffer.
- **Alt+F12** uses the relative filename `speak_dll_api.txt`; its resulting location therefore depends on the active working directory.

## Version history

### 1.0.0.0.0 — 2026-09-13

- Created `speak_readme.md`.
- Documented the package contents, requirements, installation, compilation, keyboard commands, voices, volume, API features, and troubleshooting.

Future README revisions should continue sequentially as `1.0.0.0.1`, `1.0.0.0.2`, `1.0.0.0.3`, and so on.
