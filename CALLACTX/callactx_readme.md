# CallActX

Version: 1.0.0.0.0  
Original author: Christopher Shuffett  
Platform: TSE Pro/32 for Windows

## Description

CallActX is an experimental open-source project that demonstrates how a TSE
SAL macro can call a custom 32-bit Windows DLL written in Microsoft Visual C++
6.0.

The original goal was to let TSE communicate with Microsoft ScriptControl,
VBScript, JScript, and ActiveX objects. Planned examples included:

- converting a Fahrenheit temperature to Celsius with JScript;
- rendering HTML with Microsoft Internet Explorer;
- transforming XML with an XSL stylesheet and displaying the result.

The supplied project is only an early proof of concept. The DLL does not yet
implement the planned ScriptControl interface or those three operations.

## Included files

- `callactx.s` - TSE SAL demonstration macro.
- `callactx.dll` - precompiled 32-bit Windows DLL called by the macro.
- `callactx.cpp` and `callactx.def` - DLL entry point and export definition.
- `ScriptObject.cpp` and `ScriptObject.h` - experimental Microsoft
  ScriptControl wrapper code.
- `SafeArrayHelper.cpp` and `SafeArrayHelper.h` - COM SAFEARRAY helper code.
- `callactx.dsp` and `callactx.dsw` - Microsoft Visual C++ 6.0 project files.
- `IE.vbs` - standalone VBScript example that displays HTML in Internet
  Explorer.
- `XML.vbs` - standalone VBScript example that transforms XML with XSL and
  displays it in Internet Explorer.
- `callactx.txt`, `callactx.doc`, `notes`, and `file_id.diz` - original project
  documentation and notes.

## Requirements

- Microsoft Windows.
- The 32-bit edition of TSE Pro (TSE Pro/32).
- The TSE SAL compiler, normally `sc32.exe`.
- `callactx.dll` in a location where TSE can load it.
- Windows clipboard access.

The optional VBScript examples depend on legacy Internet Explorer and MSXML
components. They might not run on current Windows installations because the
required Internet Explorer automation components may be disabled or absent.

## How to compile and run the TSE macro

1. Extract `callactx.zip` to a working directory.
2. Keep `callactx.s` and `callactx.dll` together initially.
3. Open a command prompt in that directory.
4. Compile the SAL source:

   ```text
   sc32 callactx.s
   ```

5. Start TSE Pro/32 and load the compiled `callactx` macro. Depending on the
   TSE installation and configuration, this can be done from the Macro menu or
   with TSE's normal macro-loading command.
6. Press `F3` to execute `Main()`.

If TSE reports that `CallActX.dll` cannot be found, place the DLL in a directory
searched by Windows/TSE, such as the TSE program directory, or start TSE with
the extracted project directory available in its DLL search path.

## Expected result

When `F3` is pressed, the macro performs these steps:

1. Calls the exported `CallActX()` procedure in `callactx.dll`.
2. The DLL replaces the current clipboard contents with:

   ```text
   Error Msg to TSE
   ```

3. The macro pastes the clipboard text into a temporary TSE buffer.
4. TSE displays the text in a list window titled `[WinClip Viewer]`.
5. Closing the list returns to the editor, and the temporary buffer is removed.

The clipboard text is a fixed diagnostic message. It does not mean that TSE
encountered a new runtime error; it is the demonstration payload hard-coded in
the supplied DLL.

## Running the VBScript examples

The `.vbs` files are independent examples and are not invoked by
`callactx.s`.

On a compatible legacy Windows system, they can be started with Windows Script
Host, for example:

```text
cscript IE.vbs
cscript XML.vbs
```

`IE.vbs` opens Internet Explorer, writes sample HTML, pauses twice, and closes
the browser. `XML.vbs` creates sample XML and XSL documents, transforms the XML
to HTML, displays it, and then closes Internet Explorer.

## Rebuilding the DLL

The included workspace and project files target Microsoft Visual C++ 6.0 and
the Win32 x86 platform. Open `callactx.dsw`, select the Release configuration,
and build the project. The export name in `callactx.def` is `CallActX`.

Modern C++ toolchains may require source and project changes. Any replacement
DLL must remain 32-bit to be loaded by TSE Pro/32 and must export a procedure
compatible with the declaration in `callactx.s`:

```text
proc CallActX(integer hwnd)
```

## Limitations

- The ActiveX/ScriptControl bridge is unfinished.
- The planned temperature, HTML, and XML functions are not exported by the
  supplied DLL.
- Running the macro overwrites the current Windows clipboard contents.
- The DLL and macro are 32-bit components.
- The sample scripts use obsolete Internet Explorer automation.
- The project was created with Microsoft Visual C++ 6.0 and may not build
  unchanged with a modern compiler.

## Troubleshooting

### The DLL cannot be loaded

Confirm that TSE is the 32-bit edition and that `callactx.dll` is in a directory
searched by TSE or Windows. A 64-bit process cannot load this 32-bit DLL.

### Pressing F3 does nothing

Confirm that the compiled macro is loaded and that `F3` has not been reassigned
by another loaded macro or keyboard configuration.

### The list shows `Error Msg to TSE`

This is the correct result for the supplied proof-of-concept DLL.

### The VBScript examples fail

They rely on legacy Internet Explorer and MSXML ActiveX components. Use them
only on a compatible Windows installation; they are not required for the TSE
DLL demonstration.

## Version history

- 1.0.0.0.0 - Initial Markdown README based on the supplied CallActX archive.

Future README revisions can continue as `1.0.0.0.1`, `1.0.0.0.2`, and so on.

## License note

The original documentation describes CallActX as an open-source freeware
project intended to be maintained by the TSE user community. The archive does
not include a separate formal license file. Review the original documentation
and applicable third-party source terms before redistribution.
