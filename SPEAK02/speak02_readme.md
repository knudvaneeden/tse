# SPEAK02 for The SemWare Editor

**README version:** 1.0.0.0.0  
**Created:** 2026-09-13 16:11:52 UTC  
**Session:** Create SPEAK02 MarkDown Readme

## Description

SPEAK02 adds text-to-speech support to the 32-bit Windows edition of The SemWare Editor (TSE). The supplied TSE SAL macro calls `speak.dll`, which uses the Microsoft Speech API (SAPI) and the speech voices installed in Windows.

The package supports synchronous and asynchronous speech. The demonstration included in `speak.s` starts speech in the background, allowing it to be paused, resumed, or stopped with keyboard shortcuts.

When the macro loads successfully, it says:

> Welcome. You've got SPEAK DLL.

The macro initially selects voice number `0` and sets the speech volume to `35`.

## Package contents

| File or directory | Purpose |
| --- | --- |
| `speak.s` | TSE SAL source code and demonstration key assignments |
| `speak.mac` | Precompiled TSE macro, ready to load |
| `speak.dll` | 32-bit Windows speech DLL used by the macro |
| `speak_readme.txt` | Original notes supplied by the author |
| `dll/` | Microsoft Visual C++ source and project files for building the DLL |

The supplied DLL is a 32-bit Intel 80386 Windows DLL. It is intended for a compatible 32-bit Windows version of TSE.

## Requirements

- Microsoft Windows with at least one SAPI speech voice installed.
- The 32-bit Windows edition of The SemWare Editor.
- `speak.mac` and `speak.dll` from this package.
- The TSE SAL compiler only if you want to rebuild `speak.mac` from `speak.s`.

## Installation

1. Extract `speak02.zip` to a directory of your choice.
2. Keep `speak.mac`, `speak.s`, and `speak.dll` together.
3. Make sure TSE can locate `speak.dll` when it loads `speak.mac`.
4. If TSE reports that the DLL cannot be found, copy `speak.dll` to the directory from which TSE loads its DLLs, commonly the TSE program directory, and restart TSE.

TSE can keep a DLL loaded in memory. If you replace `speak.dll`, close and restart TSE before testing the replacement.

## How to run SPEAK02

### Run the supplied compiled macro

1. Start the 32-bit Windows edition of TSE.
2. Use TSE's macro-loading command to load `speak.mac`.
3. Select `speak.mac` when TSE asks for the macro filename.
4. Listen for the welcome message. Hearing it confirms that the DLL initialized and found at least one Windows speech voice.
5. Press `Ctrl+F8` to play the demonstration speech.

### Compile the SAL source first

If you prefer to rebuild the macro, open a Windows command prompt in the directory containing `speak.s` and run:

```bat
sc32 speak.s
```

After a successful compilation, load the resulting `speak.mac` in TSE. Keep `speak.dll` available in a location where TSE can find it.

## Demonstration keys

| Key | Action |
| --- | --- |
| `Ctrl+F8` | Start the demonstration speech asynchronously |
| `Ctrl+F9` | Pause demonstration speech ID `10` |
| `Ctrl+F10` | Resume demonstration speech ID `10` |
| `Ctrl+F11` | Stop demonstration speech ID `10` |

The pause, resume, and stop commands apply to the unique speech identifier passed to `SpeakAsync()`. The supplied demonstration uses identifier `10`.

## SAL interface

### Main procedures

| Procedure | Description |
| --- | --- |
| `Speak(text)` | Speaks text synchronously and waits until speech finishes |
| `SpeakAsync(text, uid)` | Starts non-blocking speech with a user-supplied identifier |
| `SpeakAsyncPause(uid)` | Pauses the matching asynchronous speech operation |
| `SpeakAsyncResume(uid)` | Resumes the matching asynchronous speech operation |
| `SpeakAsyncStop(uid)` | Stops the matching asynchronous speech operation |
| `SetVolume(volume)` | Sets the volume; the intended range is `0` through `100` |
| `SetVoice(voice)` | Selects a voice by its zero-based number |
| `GetVoice(voice)` | Returns information about a voice by its zero-based number |
| `Initialize()` | Initializes the DLL, selects voice `0`, and sets volume to `35` |

### Global values

| Value | Meaning |
| --- | --- |
| `speak_voice_count` | Number of speech voices reported by the DLL |
| `is_speak_initialized` | `TRUE` after successful initialization |
| `speak_show_no_msgboxes` | When `FALSE`, initialization errors are displayed in a message box |

Valid voice numbers range from `0` through `speak_voice_count - 1`.

## Example use in another SAL macro

The procedures in `speak.s` can be reused or adapted in another TSE SAL macro. For example:

```sal
SetVolume(50)
Speak("This text is spoken in the foreground.")

SpeakAsync("This text is spoken in the background.", 20)
```

Use a distinct `uid` when more than one asynchronous speech operation must be controlled independently.

## Troubleshooting

### No welcome message is heard

- Confirm that Windows audio is not muted and that the correct output device is selected.
- Confirm that at least one Windows SAPI voice is installed.
- Confirm that the 32-bit `speak.dll` is available to the 32-bit TSE process.
- Restart TSE after copying or replacing the DLL.

### “The speak.dll engine could not be initialized” appears

The DLL was loaded, but its speech engine did not report an available voice. Check the installed Windows speech voices and then restart TSE.

### A DLL loading error appears

Keep the matching `speak.dll` with the macro or place it in TSE's DLL search location. Do not substitute a 64-bit DLL: a 32-bit TSE process requires a 32-bit DLL.

### Pause, resume, or stop has no effect

First start the demonstration with `Ctrl+F8`. The speech may already have finished before the control key is pressed. In custom code, the `uid` passed to pause, resume, or stop must equal the identifier used to start that speech operation.

### A voice number does not work

Voice numbers are zero-based. Use only values from `0` through `speak_voice_count - 1`.

## Notes

- The DLL exposes functions for speaking text strings and text files, both synchronously and asynchronously.
- The supplied SAL demonstration directly wraps text-string speech and the asynchronous controls.
- Synchronous speech blocks the calling macro until the speech finishes.
- Asynchronous speech runs in the background so editing can continue.
- The source uses Windows SAPI; available voices and their pronunciation depend on the Windows installation.

## Credits

The original `speak.dll` plugin was written by Rick C. Hodgin (`rick.c.hodgin@gmail.com`) and dated December 15, 2024. The original package asks that inquiries reference `speak.dll` for The SemWare Editor.

## Version history

### 1.0.0.0.0 — 2026-09-13 16:11:52 UTC

- Created `speak02_readme.md` in Markdown format.
- Added a package description, requirements, installation instructions, operating steps, shortcut reference, API help, troubleshooting information, and credits.
- Documented the version-number sequence. Future revisions should use `1.0.0.0.1`, `1.0.0.0.2`, and so on.

