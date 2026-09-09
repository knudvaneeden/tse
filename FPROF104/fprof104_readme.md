# FPROF104 — FindProf for TSE

## Document information

- README version: 1.0.0.0.1
- Previous README version: 1.0.0.0.0
- Date: 2026-09-09
- Time: 23:20:47 UTC
- Package documented: FPROF104 / FindProf v1.0.4
- Original package date: 2002-06-19
- Author: Michael Graham

## Description

FPROF104 contains **FindProf**, a small TSE SAL include library that locates the global profile file used by The SemWare Editor (TSE). Depending on the editor version and platform, this profile is normally named `TSE.INI` or `TSEPRO.INI`.

The package is intended for macro authors who use TSE's profile functions and need a reliable profile filename without hard-coding its location. The public function supplied by `FindProf.si` is:

```text
FindProfile()
```

The function returns the path or filename that a calling macro can pass to profile functions such as `GetProfileStr()`.

## Package contents

| File | Purpose |
| --- | --- |
| `FindProf.si` | TSE SAL include file containing `FindProfile()` |
| `FindProf.txt` | Original instructions, description, and license information |
| `FILE_ID.DIZ` | Short package description |

## How FindProf works

When `FindProfile()` is called, it:

1. Checks whether a profile filename has already been cached in the TSE session.
2. Searches the directories in TSE's `TSEPath` for `TSEPRO.INI`.
3. If that file is not found, searches `TSEPath` for `TSE.INI`.
4. If neither file is found, uses a platform-dependent fallback:
   - Win32: `LoadDir() + "tse.ini"`
   - DOS: `LoadDir() + "tsepro.ini"`
5. Saves the result in the session global variable `FindProfile:TSE_Global_Profile` and returns it.

FindProf also observes the `setcache:refresh_serial` session value. When that value changes, the next call searches for the profile again instead of blindly reusing the cached result.

## Requirements

- The SemWare Editor Professional (TSE Pro)
- A TSE SAL macro that needs to use the profile filename
- TSE Pro 2.x, 3.x, or 4.x according to the original package documentation
- `profile.si` when compiling for DOS and using the profile functions shown in the example

`FindProf.si` is an include file and does not contain a `Main()` procedure. It is therefore not intended to be compiled or run by itself.

## Installation

1. Extract `fprof104.zip`.
2. Copy `FindProf.si` to the directory containing your SAL source, or to a directory included in TSE's macro/include search path.
3. Add the appropriate include statements to your macro.
4. Call `FindProfile()` wherever a TSE profile function requires the INI filename.
5. Compile the calling macro with the TSE SAL compiler.

## Example usage

```sal
#ifndef WIN32
#include ["profile.si"]
#endif

#include ["FindProf.si"]

proc Main()
    string setting[255]

    setting = GetProfileStr("My_Settings", "My_Key", "", FindProfile())
    Warn(setting)
end
```

The example reads `My_Key` from the `My_Settings` section of the global TSE profile selected by `FindProfile()`.

## How to compile and run a calling macro

Assume that your calling source is named `myprofile.s` and that `FindProf.si` is available in the same directory or in TSE's include path.

1. Open a command prompt in the directory containing `myprofile.s`.
2. Compile it with the SAL compiler:

   ```text
   sc32 myprofile.s
   ```

3. Confirm that the compiler completes without errors.
4. Start TSE or return to the running editor.
5. Load and execute the compiled `myprofile` macro using your normal TSE macro command or assigned key.

The exact generated macro extension and loading method can depend on the TSE version and local configuration.

## Help and troubleshooting

### The compiler cannot find `FindProf.si`

Place `FindProf.si` in the same directory as the calling `.s` file or in a directory known to TSE's include search path. Keep the include spelling consistent with the actual filename.

### `GetProfileStr()` is undefined in a DOS build

Include `profile.si` before `FindProf.si`, as shown in the example. The conditional `#ifndef WIN32` prevents that compatibility include from being used in the Win32 build.

### The wrong profile file is returned

Check the directories configured in `TSEPath` for old or duplicate copies of `TSEPRO.INI` and `TSE.INI`. The code gives `TSEPRO.INI` priority when both names are found in the search path.

### A moved or newly created INI file is not detected immediately

The result is cached in the TSE session. Restarting the editor clears the session cache. The original documentation also notes that the `SReload` macro from the SetCache package can cause FindProf to search again.

### Portability note

This 2002 source uses `LoadDir()` as its fallback location. That means the fallback depends on the editor's load directory. If strict portability from any working directory is required, review and adapt this behavior before integrating the include into a newer macro package.

### Modern TSE versions

The original author documented support for TSE Pro 2.x through 4.x. Newer editor or compiler versions may still accept the source, but they are not covered by the original compatibility statement and should be tested locally.

## License and disclaimer

The original package states that FindProf is free software distributed under the terms of the Perl Artistic License. Copyright © 2000–2002 Michael Graham.

The software is supplied without warranty and is used at your own risk. Consult `FindProf.txt` in the original archive for the author's complete notice and original project information.

## Version history

### 1.0.0.0.1 — 2026-09-09 23:20:47 UTC

- Expanded the description of the search, fallback, and caching behavior.
- Added installation, compilation, usage, help, troubleshooting, and portability sections.
- Documented the files contained in the FPROF104 archive.
- Added the original FindProf version, date, author, compatibility, and license information.

### 1.0.0.0.0 — 2026-09-09 23:20:47 UTC

- Created the initial Markdown README for FPROF104.

