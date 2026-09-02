# Standalone TSE SAL Clipboard Stack

**Version:** 1.0.0.0.7  
**Date:** 2026-09-02  
**Time:** 17:50 CEST (UTC+02:00)  
**Created by:** OpenAI Codex

## Description

`clipstack.inc` is a small standalone include library for The SemWare Editor (TSE). It saves the current internal TSE clipboard on a last-in, first-out stack and restores it later.

It also provides a separate stack for textual contents of the Microsoft Windows clipboard.

The native `.inc` extension is used because this file is intended for inclusion in another SAL source file. The `.si` extension is not used here because it denotes a SemWare in-house file rather than a general user include file.

Unlike the original ClipBord version 2 macro, this version requires no `global.si`, `initpar.si`, `poppar.si`, `procpar.si`, or `pushpar.si` files. It uses only built-in TSE SAL commands and hidden system buffers.

## Files

- `clipstack.inc` - reusable standalone clipboard-stack include library.
- `clipstack_demo.s` - minimal example and test macro.
- `clipstack_readme.md` - this documentation.

## Public library actions

```sal
PROCPushClipboard()
PROCPopClipboard()
PROCPushClipboardWin()
PROCPopClipboardWin()
```

All four actions return `TRUE` on success and `FALSE` on failure.

## Use it in another SAL program

1. Put `clipstack.inc` in the same directory as your SAL source, or in the SAL compiler's include path.
2. Add this line near the top of your source:

   ```sal
   #include ["clipstack.inc"]
   ```

3. Push the clipboard before code that might change it:

   ```sal
   PROCPushClipboard()
   ```

4. Restore it afterward:

   ```sal
   PROCPopClipboard()
   ```

Typical use:

```sal
#include ["clipstack.inc"]

proc MyAction()
   if PROCPushClipboard()
      // Code that temporarily changes the clipboard.
      PROCPopClipboard()
   endif
end
```

Always balance every successful push with one pop.

## Microsoft Windows clipboard actions

Save the current textual Windows clipboard contents:

```sal
PROCPushClipboardWin()
```

Restore the most recently saved textual Windows clipboard contents:

```sal
PROCPopClipboardWin()
```

Typical use:

```sal
if PROCPushClipboardWin()
   // Code that temporarily changes the Windows clipboard.
   PROCPopClipboardWin()
endif
```

The Windows clipboard stack is separate from the internal TSE clipboard stack. Calls can therefore be nested independently, provided every successful push is eventually matched by the corresponding kind of pop.

## Compile the demonstration

Keep `clipstack_demo.s` and `clipstack.inc` together, then run:

```cmd
sc32 clipstack_demo.s
```

Load or run `clipstack_demo.mac` in TSE.

- The first run pushes the current clipboard.
- Change the clipboard as desired.
- Run the macro again to pop and restore the saved clipboard.
- If the stack already contains more than one entry, each rerun pops one entry.

The demo also provides explicit keyboard actions:

| Key | Action |
| --- | --- |
| `Ctrl+Alt+O` | Calls `PROCPushClipboard()` and pushes the current clipboard. |
| `Ctrl+Alt+P` | Calls `PROCPopClipboard()` and restores the most recently pushed clipboard. |
| `Ctrl+Alt+Q` | Calls `PROCPushClipboardWin()` and pushes the textual Windows clipboard. |
| `Ctrl+Alt+R` | Calls `PROCPopClipboardWin()` and restores the most recently pushed textual Windows clipboard. |

The rerun behavior checks `clipStackTopI`, the library's actual stack depth. Therefore, clipboard entries pushed with `Ctrl+Alt+O` are also detected and can be popped by rerunning the macro.

## How it works

Each pushed clipboard is pasted into a uniquely numbered hidden `_SYSTEM_` buffer. A second hidden buffer records the block type and column width. `PROCPopClipboard()` locates the most recent pair of buffers, copies their data back to TSE's clipboard, empties them for reuse, and decreases the stack depth.

The library preserves the caller's current buffer and marked block while it works. It supports empty, line, column, inclusive character, and non-inclusive character clipboards.

`PROCPushClipboardWin()` uses TSE's native `PasteFromWinClip()` command to store Windows clipboard text in a separate hidden buffer. `PROCPopClipboardWin()` marks that saved text and uses TSE's native `CopyToWinClip()` command to restore it.

## Important naming note

The hidden buffers use this prefix:

```sal
string clipStackPrefixS[40] = "_codex_clipstack_"
```

If two separately compiled resident macros both include this library and might use their stacks at the same time, give each compiled macro a different prefix. This prevents one macro from reusing the other macro's hidden stack buffers.

For example:

```sal
string clipStackPrefixS[40] = "_my_macro_clipstack_"
```

Change the initializer in that macro's private copy of `clipstack.inc` before compiling it.

## Limitations

- `PROCPushClipboard()` and `PROCPopClipboard()` operate on TSE's internal clipboard. `PROCPushClipboardWin()` and `PROCPopClipboardWin()` operate on the Microsoft Windows clipboard.
- The Windows actions preserve text only. Images, HTML, RTF, and other Windows clipboard formats cannot be retained faithfully in TSE text buffers.
- The Windows actions require a Windows version of TSE that supplies `PasteFromWinClip()` and `CopyToWinClip()`.
- The stack exists only while the compiled macro that includes the library remains loaded.
- Hidden buffers consume memory until that macro is unloaded.
- A failed pop leaves the stack level in place so it can be retried.
- The code was constructed from the supplied historical source but cannot be compiled in this environment because the TSE `sc32` compiler is not installed here.

## Version history

| Version | Date | Changes |
| --- | --- | --- |
| 1.0.0.0.7 | 2026-09-02 | Renamed all four public procedures with a `PROC` prefix to avoid possible clashes with present or future native TSE keywords. |
| 1.0.0.0.6 | 2026-09-02 | Added `Ctrl+Alt+Q` for `PushClipboardWin()` and `Ctrl+Alt+R` for `PopClipboardWin()` to the demo. |
| 1.0.0.0.5 | 2026-09-02 | Added the separate `PushClipboardWin()` and `PopClipboardWin()` stack using TSE's native Windows clipboard commands. |
| 1.0.0.0.4 | 2026-09-02 | Updated the demo so rerunning it pushes when the stack is empty and pops when the stack contains an entry. Added `Ctrl+Alt+O` for push and retained `Ctrl+Alt+P` for pop. |
| 1.0.0.0.3 | 2026-09-02 | Renamed the reusable library to `clipstack.inc`, the native extension for a general TSE SAL include file. Clarified that `.si` denotes a SemWare in-house file. |
| 1.0.0.0.2 | 2026-09-02 | Restored the customary `.si` extension because the library is intended to be included in other SAL `.s` programs. Updated all source and documentation references. |
| 1.0.0.0.1 | 2026-09-02 | Renamed the reusable library from `clipstack.si` to the customary `clipstack.s` extension and updated the demo and documentation. |
| 1.0.0.0.0 | 2026-09-02 | Initial standalone version with `PushClipboard()` and `PopClipboard()`; no external `.si` dependencies. |

Future revisions should increment the last component: `1.0.0.0.8`, `1.0.0.0.9`, and so on.
