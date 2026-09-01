# CAPSNUMS DLL

Version: **1.0.0.0.3**

## Description

CAPSNUMS DLL is a modern 32-bit Windows replacement for the original 1994 `CAPSNUMS.BIN` package by Peter Granaldi. It lets a TSE Pro/32 SAL macro explicitly switch Caps Lock and Num Lock on or off.

The DLL provides four exported procedures:

- `CapsOff()` - switches Caps Lock off.
- `CapsOn()` - switches Caps Lock on.
- `NumsOff()` - switches Num Lock off.
- `NumsOn()` - switches Num Lock on.

Unlike the original 16-bit binary, this DLL does not access the DOS BIOS keyboard-status byte. It uses the Windows keyboard API and is intended for 32-bit Windows TSE.

## Package contents

| File | Purpose |
| --- | --- |
| `capsnums.c` | Borland C++ 5.5-compatible DLL source code. |
| `capsnums.def` | Module-definition file listing the four exports. |
| `build.bat` | Command-line build script. |
| `capsnums.s` | TSE Pro/32 SAL demonstration macro. |
| `capsnums_readme.md` | Description, build instructions, and usage help. |

The generated `capsnums.dll`, object file, and import library are not included until `build.bat` is run.

## Requirements

- Microsoft Windows.
- A 32-bit Windows edition of TSE Pro.
- Borland C++ command-line compiler version 5.5.
- The Borland compiler's `Bin` directory in `PATH`, or a command prompt configured to call `bcc32.exe` by its full path.
- The TSE SAL compiler, such as `sc32.exe`.

## Build the DLL

1. Extract the package into a writable directory.
2. Open a Windows command prompt in that directory.
3. Confirm that Borland C++ 5.5 is available:

   ```bat
   bcc32
   ```

4. Run:

   ```bat
   build.bat
   ```

The batch file executes:

```bat
bcc32 -c -O2 -w- capsnums.c
ilink32 -Tpd c0d32.obj capsnums.obj, capsnums.dll,, import32.lib cw32.lib, capsnums.def
```

The first command compiles `capsnums.c` into `capsnums.obj`. The second command links the object into a Windows DLL and passes `capsnums.def` in ILINK32's module-definition-file field.

Do not append `capsnums.def` directly to a `bcc32` source-file command. Borland then treats the `.def` file as C/C++ source and reports declaration errors.

The important options are:

- `-c` - compile without linking.
- `-O2` - enable code optimization.
- `-w-` - suppress compiler warnings.
- `-Tpd` - tell ILINK32 to create a Windows DLL.

Borland prefixes the internal C symbols with underscores. `capsnums.def` maps those internal names to the exact public names required by TSE, for example `CapsOff=_CapsOff`.

After a successful build, `capsnums.dll` is created in the same directory.

## Compile the TSE SAL macro

Keep `capsnums.dll` in the same directory as `capsnums.s` while testing. From a command prompt configured for the TSE compiler, run:

```bat
sc32 capsnums.s
```

If your TSE compiler uses a different executable name or directory, substitute the correct command.

## Run the macro

1. Make sure TSE can locate `capsnums.dll`. For initial testing, place the DLL in TSE's program directory or another directory that Windows searches for DLLs.
2. Load or execute the compiled `capsnums` macro in TSE.
3. Select one of the four menu commands:
   - `CAPS OFF`
   - `CAPS ON`
   - `NUMS OFF`
   - `NUMS ON`
4. Verify the keyboard state and indicator light.

The DLL first checks the current state. It generates a key event only when the requested state differs, so `CapsOn()` cannot accidentally switch Caps Lock off and `NumsOff()` cannot accidentally switch Num Lock on.

## SAL DLL declarations

The procedures are declared as follows:

```sal
dll "capsnums.dll"
   proc CapsOff()
   proc CapsOn()
   proc NumsOff()
   proc NumsOn()
end
```

These declarations can be copied into another compatible SAL macro. Call the procedure needed by that macro, for example:

```sal
CapsOn()
NumsOff()
```

## Troubleshooting

### `bcc32` is not recognized

Add the Borland C++ 5.5 `Bin` directory to `PATH`, or edit `build.bat` so it calls `bcc32.exe` using its full path.

### Borland reports missing headers or libraries

Check the Borland `bcc32.cfg` and `ilink32.cfg` configuration files. Their include and library paths must point to the actual `Include` and `Lib` directories of the Borland C++ 5.5 installation.

### TSE cannot load `capsnums.dll`

Confirm that the DLL was built as 32-bit and that Windows can find it. A 32-bit DLL cannot be loaded by a 64-bit process, and a 64-bit DLL cannot be loaded by 32-bit TSE. Borland C++ 5.5 creates a 32-bit DLL.

If TSE has already loaded an earlier copy, exit and restart TSE before testing a rebuilt DLL. Windows can keep a loaded DLL in memory until the host program closes.

### An imported procedure cannot be found

Run Borland's `tdump` utility to inspect the export table:

```bat
tdump -ee capsnums.dll
```

The export names must appear exactly as `CapsOff`, `CapsOn`, `NumsOff`, and `NumsOn`.

### The state changes but the keyboard LED does not

Some USB keyboards, remote sessions, virtual machines, and keyboard utilities synchronize their LEDs separately. Check whether Windows and typed characters reflect the requested lock state.

## Compatibility

This version targets TSE Pro/32 on Windows. It does not target DOS TSE, Linux TSE, or a hypothetical 64-bit TSE process.

The source uses the legacy Windows `keybd_event()` API because it is available in the Windows headers shipped with Borland C++ 5.5.

## Version history

- **1.0.0.0.0** - Initial README for the original DOS `CAPSNUMS.BIN` package.
- **1.0.0.0.1** - Replaced the DOS binary design with Borland C++ 5.5-compatible source for a 32-bit Windows DLL; added the module-definition file, build script, and updated TSE Pro/32 SAL macro.
- **1.0.0.0.2** - Corrected `build.bat` so Borland does not compile `capsnums.def` as source; exports now come from `__declspec(dllexport)`. Removed `exit /b` for compatibility with the user's command shell.
- **1.0.0.0.3** - Corrected the Borland export warnings by compiling and linking separately. The `.def` file now maps the four public TSE names to Borland's underscore-prefixed C symbols.

Future revisions should increment the final component sequentially: `1.0.0.0.4`, `1.0.0.0.5`, and so on.

## Credits

The procedure names and original idea come from the 1994 CAPSNUMS package by Peter Granaldi. The DLL implementation is a new Windows-compatible replacement and does not reuse the original machine code.
