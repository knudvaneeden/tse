# MOVELINE

Version: 1.0.0.0.0  
Updated: 2026-09-22 16:08 UTC  
Updated with: OpenAI Codex

## Description

MOVELINE is a TSE SAL macro for moving the current line or a marked line block up or down. It preserves the original movement commands by Sjoerd W. Rienstra and adds an informative startup message plus an INI option for suppressing that message.

## Files

- `MOVELINE.S` - TSE SAL source code.
- `moveline.ini` - startup-message configuration.
- `moveline_readme.md` - this documentation.

Keep `moveline.ini` in the same directory as `MOVELINE.S` or the compiled `MOVELINE.MAC` file.

## Requirements

- The SemWare Editor (TSE) for Windows.
- The TSE SAL compiler, such as `sc32.exe`.

## Compile

1. Extract `moveline1.0.0.0.0.zip` to a directory.
2. Open a Command Prompt in that directory.
3. Compile the source:

   ```text
   sc32 MOVELINE.S
   ```

4. Confirm that `MOVELINE.MAC` was created without errors.

## Load and run

1. Put `MOVELINE.MAC` and `moveline.ini` in the same directory.
2. In TSE, load or execute the macro with TSE's macro execution command and the name `MOVELINE`.
3. Unless silent mode is enabled, MOVELINE displays a startup message explaining the available keys.
4. Use one of the assigned keys while editing a file.

## Keys

| Key | Action |
| --- | --- |
| `Ctrl+CursorDown` | Move the current line down. |
| `Ctrl+CursorUp` | Move the current line up. |
| `Ctrl+Shift+CursorDown` | Move a marked line block down. |
| `Ctrl+Shift+CursorUp` | Move a marked line block up. |

The block commands operate only when the cursor is inside a marked line block.

## Configuration

The supplied `moveline.ini` contains:

```ini
[moveline]
silent=false
```

- `silent=false` displays the informative `Warn()` box when the macro runs. This is the default.
- `silent=true` suppresses that startup box.

Values other than `true` are treated as `false`. The movement keys remain available in either mode.

## Notes

- Save important work before first testing commands that move text.
- If a key is already assigned by another macro or UI configuration, the most recently loaded assignment may take precedence.
- The current-line commands temporarily mark and move the current line, then restore the previous block state.
- The marked-block commands require a line block; stream and column blocks are not moved.

## Original source information

The original MOVELINE source identifies Sjoerd W. Rienstra as its author and is dated June 13, 1995.
