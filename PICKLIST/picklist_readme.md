# PICKLISTer — generic picklist helper for TSE

**Package version:** 1.0.0.0.0  
**Date and time:** 2026-09-26 18:24:55 CEST (Europe/Amsterdam)  
**Original author:** David Marcus (1993)  
**Package adaptation:** OpenAI Codex (2026)

## Description

`PICKLIST.S` displays the lines of a text file as a TSE picklist for another SAL macro. The calling macro supplies the filename, list title and maximum returned text width through TSE globals. After the selection, it reads the chosen text and a success flag from globals. You can edit the list file without recompiling PICKLIST.

The original macro is version 1. This package adds an introductory `Warn()` message when PICKLIST is executed without a filename, controlled by `picklist.ini`; the caller interface remains the same.

## Files

| File | Purpose |
| --- | --- |
| `PICKLIST.S` | TSE SAL source, with the introductory message and INI setting |
| `picklist.ini` | Default `silent=false` setting |
| `picklist_readme.md` | Description, help and usage instructions |

## Install and compile

1. Extract `picklist1.0.0.0.0.zip` into a working directory.
2. Open a command prompt in that directory and compile with the SAL compiler appropriate to your TSE installation. For TSE Pro/32:

   ```bat
   sc32 PICKLIST.S
   ```

3. Make the resulting `PICKLIST.MAC` available in TSE's macro search path. Keep `picklist.ini` in TSE's **current working directory** if you want to change its default setting.
4. Put the text file containing the choices where the caller can find it. Each line becomes a selectable item.

The source is from 1993. Compilation with a recent TSE Pro/32 compiler has not been verified here; if it reports errors, consult the compiler output for compatibility changes before using it.

## How to run it from another SAL macro

Set these globals, call PICKLIST, and read the returned globals:

```sal
proc SamplePicklistUse()
    STRING tagS[45] = ''

    SetGlobalStr('picklist_fn', 'tags.txt')
    SetGlobalStr('picklist_title', 'Select Item [Esc=Abort]')
    SetGlobalInt('picklist_maxwidth', Length(tagS))
    ExecMacro('picklist')

    if GetGlobalInt('picklist_return')
        tagS = GetGlobalStr('picklist_result')
        Warn('Selected: ', tagS)
    else
        Warn('No entry selected!')
    endif
end
```

Compile your caller, open `tags.txt` in the working directory, and execute the caller in TSE. Select a line to return its text, or press `Esc` to cancel. The helper also stores the last selected line in `picklist_line` so the next call can reopen near that position. The selected text is limited by `picklist_maxwidth` and the capacity of the caller's string.

If the named file is missing, PICKLIST displays an error box. The `silent` setting applies only to the introductory message; it does not hide missing-file errors or messages from the calling macro.

## Run PICKLIST directly

In TSE, execute the compiled `picklist` macro from **Macro → Execute**. Without `picklist_fn` set by another macro, it displays an explanation and exits without opening a list. If `silent=true`, it exits without this explanation. To display a list, use a calling macro as shown above.

## Configuration

```ini
[picklist]
silent=false
```

`false` shows the introductory `Warn()` box; `true` suppresses it. If `picklist.ini` is absent, the source defaults to `false`. The setting is read from the current working directory. Change the value, then execute the macro again.

## Attribution and license

David Marcus granted noncommercial redistribution with credit to the author and attribution for changes. The original source header contains the complete terms. This package retains that header and labels the 2026 adaptation.
