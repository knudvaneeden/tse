# PROF135

**Package version:** 1.0.0.0.9  
**Original Profile library version:** 1.3.5 (12 December 2001)  
**Updated:** 29 September 2026, 15:04 CEST (Europe/Amsterdam)

## Description

Profile is a compatibility macro for **TSE 2.5 DOS** that reads and writes INI files through an interface modeled on the profile functions built into TSE/32. `profile.si` supplies functions for other macros; `Profile.s` implements the underlying operations. It is primarily a library; the added direct-run interface lets you browse an existing INI file. The original authors are Chris Antos and Michael Graham. Their original documentation is included as `Profile.txt`.

The package adds a section and key picker to `Profile.s` and a `prof135.ini` setting that controls its result `Warn()` boxes. Internal command dispatch used by `profile.si` remains available.

## Files

- `Profile.s` — source for the DOS helper macro; compile this into `Profile.mac`.
- `profile.si` — include file for macros using the helper.
- `Profile.txt` — original detailed API documentation.
- `prof135.ini` — direct-run result message setting.
- `FILE_ID.DIZ` — original package description.

## Install and run

1. Extract all files. For TSE 2.5 DOS, compile `Profile.s` with that version's SAL compiler to create `Profile.mac`. Keep the compiled macro where TSE can find it.
2. Put `profile.si` where your consuming macro can include it. In that macro use:

   ```sal
   #ifndef WIN32
   #include ["profile.si"]
   #endif
   ```

3. Compile and run the consuming macro. For example, with a full INI path:

   ```sal
   string name[80]
   name = GetProfileStr("User", "Name", "Unknown", "C:\\settings\\example.ini")
   ```

4. Run `Profile.s` directly in TSE (or compile and run `Profile.mac`). Select an **existing INI file** with F10 or enter its path. If the file does not exist, the filename prompt repeats until you choose an existing file or press Esc. A filename without a path refers to TSE's current directory. The macro reads the file and presents a list of its `[sections]`.
5. Use Up/Down and Enter to select a section. A second list shows its `key=value` lines; select a key with Enter. Choose `V` to view the complete value, `E` to edit it, or `R` to remove the key (with confirmation). The key list also offers `+ Add a new key` and `- Delete this section` (with confirmation). The section list offers `+ Create a new section`, followed by prompts for its first key and value. Changes are saved immediately. After viewing, updating, adding, or deleting a key, the refreshed key list stays open. In the key list, put the cursor on an existing `key=value` line and press Enter to open its action prompt: `V` or `G` views the value, `E` updates it, and `R` deletes it. Esc from keys returns to sections; Esc from sections returns to the filename prompt; Esc at the filename prompt exits.
6. Keep `prof135.ini` beside the running `Profile.mac` (or beside `Profile.s` when TSE compiles it there). The macro first looks beside its compiled macro file, then in TSE's current directory. `inifilename=` (empty by default) supplies an editable suggestion in the filename prompt. Press Enter to accept it or type another path to override it. `silent=false` (default) displays result and missing-file `Warn()` boxes; `silent=true` suppresses them. The lists and prompts remain visible. The option does not suppress library error messages.

The include file calls `Profile.mac` internally. Do not purge it between dependent operations. On TSE/32, the `#ifndef WIN32` include above uses the editor's built-in profile functions instead; the DOS macro is not required there. Compile the source with the appropriate TSE version; a `.mac` made for another version may be incompatible.

## INI behavior

The target INI file is chosen in the interface or by the consuming macro's profile function call; `prof135.ini` configures only the direct-run result message. The original library resolves a target filename without a directory against the Windows directory and an empty target filename against `tse.ini` in the editor load directory. Pass a full filename to control the location. See `Profile.txt` for the complete API, section/key enumeration, saving, and removal operations.

## Verification

The package contents and separate interactive and internal command branches were inspected. Version 1.0.0.0.9 resolves `prof135.ini` beside the running macro first, then in TSE's current directory; it keeps the key list open after each action and makes the selected-key action prompt explicit. It also recognizes short keys such as `a=`. The internal library call path retains its linefeed-delimited argument handling. A TSE 2.5 DOS SAL compiler is unavailable in this environment, so compilation and runtime behavior require verification in TSE.
