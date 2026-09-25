# SCROLLWORDCARRIAGERETURN

Version: 1.0.0.0.1  
Date: 2026-09-25, 23:57 Europe/Amsterdam  
Created with: OpenAI Codex (GPT-6)

## Description

SCROLLWORDCARRIAGERETURN lets you keep typing on a long single line. After a typed character moves the cursor to the configured right position (`targetend=75` by default), the editing window scrolls horizontally so the cursor appears at the configured left position (`targetbegin=25` by default). The text, logical cursor column, and line remain unchanged. Continue typing normally from that point.

The percentages refer to the width of the current editing window, including a split window. The macro hooks TSE's `_ON_SELFINSERT_` event and acts only after a character is inserted. Moving the cursor by itself does not trigger an automatic return.

## Files

- `scrollwordcarriagereturn.s` — TSE SAL source.
- `scrollwordcarriagereturn.ini` — left and right positions and message setting.
- `scrollwordcarriagereturn_readme.md` — these instructions.

## Compile and run

1. Keep the `.s` and `.ini` files together in the same directory. Compile with `sc32 scrollwordcarriagereturn.s` to produce `scrollwordcarriagereturn.mac`.
2. Run `scrollwordcarriagereturn.mac` once in TSE to enable the automatic action. With the default `silent=false`, a status message is shown.
3. Type along a long line. Each time the cursor reaches the right position, the view returns it to the left position without changing the text.
4. Run the macro again to disable the automatic action. Running it again enables it and rereads the INI values.

The **Ctrl+Alt+Shift+C** key shifts the current horizontal view immediately to place the cursor at `targetbegin`, regardless of whether the automatic action is enabled. It does not toggle the automatic action. As with the original SCROLLWORD package, this key assignment may conflict with another assignment in your TSE setup.

The automatic hook lasts while this macro is loaded in the editor session. After restarting TSE, run the macro once to enable it again; alternatively add it to your editor startup configuration.

## Settings

```ini
[scrollwordcarriagereturn]
targetbegin=25
targetend=75
silent=false
```

Set `targetbegin` and `targetend` to integer percentages. The values are read when you run the macro, not after each typed character. `targetbegin` is clamped to 1–99 and `targetend` to 2–100. If the resulting beginning is at or beyond the ending, the macro uses 25 and 75. Very narrow windows may place both percentages in the same screen column; the automatic trigger still returns the view as far as possible. Near the start of a line, the view offset cannot be negative.

`silent=true` suppresses the enable/disable `Warn()` box; `silent=false` shows that status message after running the macro. The default is `false`, including when the setting is absent. The keyboard shortcut does not display a message.

The INI is found beside the compiled macro using `CurrMacroFilename()`; no editor installation directory is required.

## Version history

### 1.0.0.0.1 — 2026-09-25

- Set the initial `silent` value and missing-setting fallback to `false`.

### 1.0.0.0.0 — 2026-09-25

- Based on SCROLLWORD 1.0.0.0.2.
- Added automatic horizontal return after typed characters at `targetend`.
- Added configurable `targetbegin` and `targetend`, with defaults 25 and 75.
- Added an enable/disable toggle when the macro is run.
