# AutoBookMark for TSE

## Description

AutoBookMark is a TSE SAL macro that automatically places bookmarks at useful locations whenever you change to another supported file.

The archive contains:

- `AUTOBM.S` — the TSE SAL source code.
- `FILE_ID.BM` — the original short program description.

The supplied source is **AutoBookMark Version 2**, dated **24 February 1994**. Version 2 avoids rebuilding bookmarks when TSE returns to the same file, which improves performance when other macros temporarily use work buffers or lists.

## Default behavior

AutoBookMark examines the extension of the file being entered and applies these rules:

| File extensions | Bookmark targets |
| --- | --- |
| `.s`, `.inc` | Lines containing `proc` or `menu`, excluding lines containing `forward` |
| `.asc`, `.txt`, `.mvp` | Lines beginning with the configured Visual Page major-heading tag; if none are found, lines beginning with the medium-heading tag |

Bookmarks begin with the seventh letter, `g`, so bookmarks `a` through `f` remain available for manual use. The macro can therefore create up to 20 automatic bookmarks, `g` through `z`, in each supported file.

System buffers are ignored. The macro also stops processing after TSE begins exiting.

## Requirements

- The SemWare Editor (TSE) with a SAL compiler compatible with this source.
- For 32-bit TSE installations, the compiler is normally `SC32.EXE`.
- The Visual Page rules require the global strings `vp_major_heading_tag` and `vp_medium_heading_tag` to be defined by the relevant macro or configuration. The `.s` and `.inc` rules do not require them.

## Installation and compilation

1. Extract `autobm.zip` into a working directory.
2. Open a Command Prompt in that directory.
3. Compile the source with the SAL compiler used by your TSE installation:

   ```bat
   sc32 AUTOBM.S
   ```

   If `SC32.EXE` is not in `PATH`, supply its full path. For example:

   ```bat
   G:\path\to\TSE\SC32.EXE AUTOBM.S
   ```

4. Confirm that compilation creates the compiled macro, normally `AUTOBM.MAC`.
5. Load `AUTOBM.MAC` in TSE using TSE's **Load Macro** command or macro manager.
6. Add the macro to your normal TSE startup or autoload configuration if you want it loaded automatically in future sessions.

## How to use it

1. Load the compiled AutoBookMark macro.
2. Open or switch to a supported file, such as a `.s` file.
3. AutoBookMark scans the file automatically when TSE changes to it.
4. Use TSE's normal bookmark commands to jump to bookmarks `g` through `z`.

There is no separate command that must be run for every file. The macro installs an `_ON_CHANGING_FILES_` hook when it is loaded.

## Customizing the bookmark rules

Edit the `case` statement inside `proc automarks()` in `AUTOBM.S`. Each `when` branch selects file extensions and defines:

- `str1` — the primary search expression.
- `opt1` — search options for the primary expression.
- `str2` — an optional fallback expression.
- `opt2` — search options for the fallback expression.
- `excl` — text that prevents a bookmark on a matching line.
- `eopt` — search options for the exclusion text.

For example, the supplied SAL rule is:

```sal
when '.s', '.inc'
    str1 = '{proc }|{menu }'
    opt1 = 'ix+'
    excl = 'forward'
    eopt = 'i'
```

After changing the rules, compile `AUTOBM.S` again and reload the resulting macro.

### Changing the first automatic bookmark

The following declaration controls the first bookmark letter:

```sal
start_count = 7
```

With the supplied value of `7`, automatic bookmarks start at `g`. Lowering the value allows more automatic bookmarks but uses letters that may otherwise be reserved for manual bookmarks.

## Notes and limitations

- Only extensions explicitly listed in `proc automarks()` are processed.
- At most 20 automatic bookmarks are created with the default `start_count` value.
- Existing automatic bookmark letters that are no longer required are cleared.
- The macro compares the full current filename with the last processed filename and skips an unnecessary rescan when both are the same.
- Search expressions use TSE's search syntax and options, not PCRE or another external regular-expression engine.
- This is legacy source code. If a modern SAL compiler reports incompatibilities, adapt the source to that compiler version before loading it.

## Troubleshooting

### No bookmarks appear

- Confirm that `AUTOBM.MAC` was compiled successfully and loaded.
- Confirm that the current file has one of the configured extensions.
- Check that the file contains text matching the configured search expression.
- For `.asc`, `.txt`, or `.mvp` files, confirm that the required Visual Page global heading strings exist.

### Compilation command is not found

Run `SC32.EXE` with its full path, or add the TSE compiler directory to `PATH`.

### Bookmarks appear on unwanted lines

Adjust `str1`, `str2`, or `excl` and their corresponding search options in `proc automarks()`, then recompile and reload the macro.

### Changes do not take effect

Unload the old compiled macro if necessary, recompile `AUTOBM.S`, and load the newly created `AUTOBM.MAC`.

