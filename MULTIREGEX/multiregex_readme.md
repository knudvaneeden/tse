# MULTIREGEX — version 1.0.0.0.22

Pure TSE SAL macro for TSE 4.50.33. **Session-lifecycle correction** based on version 1.0.0.0.21. Keep the verified version 21 as a backup until this release has been tested.

## Critical correction

The previous non-view search left a nested `Process()` editor level open while waiting for `<Ctrl L>` or `<Escape>`. This could prevent normal custom key bindings (such as `<Shift Tab>`) from behaving as expected, and could make purging the macro unreliable.

**Version 22 retains `<Ctrl L>` repeat forward without starting `Process()` for normal non-`v` searches.** It enables a temporary `KEYDEF` and returns immediately to TSE's existing editor process. `<Escape>` or `<CtrlAltShift X>` disables this key definition and restores the original bindings. Other normal editor shortcuts should remain available. Starting a fresh MULTIREGEX search first disables any earlier repeat key definition.

The `v` results viewer still uses a nested `Process()` for mouse-driven navigation. In the results list **and while visiting a match in the source file**, `<Escape>` or `<CtrlAltShift X>` invokes `EndProcess()`, after which both results-view key definitions are disabled and the nested viewer session is closed. `<CtrlAltShift G>` continues to return to the same result. Mouse click continues to jump to the source.

`PurgeMacro()` deliberately is **not** invoked by MULTIREGEX itself. Purging an executing macro is not a safe substitute for leaving its nested editor process. After the session exits and bindings are disabled, normal manual purging can be used if desired.

## Controls

- Normal search (`ix`, `gix`, `gilx`, etc.): after finding first match, `<Ctrl L>` repeats forward; `<Escape>` or `<CtrlAltShift X>` ends repeat mode.
- Results view (`ivx`, `givx`, `gilvx`): click a result to visit; `<CtrlAltShift G>` returns; `<Escape>` or `<CtrlAltShift X>` closes the viewer from **either** results or source.
- Only two input prompts: expression and alphabetical options.
- The INI provides maximum and adaptive window sizes without further prompts.

## Test plan

1. **Important:** Restart TSE once before testing if a previous v21 `Process()` session may still be active. The new macro cannot reliably unwind an older already-running nested process.
2. Compile `multiregex.s` with `sc32 multiregex.s` in TSE 4.50.33.
3. Search `BEGIN TRANSACTION.*COMMIT TRANSACTION` with `gix`. Verify first match, press `<Ctrl L>` for second, use `<Shift Tab>` to check your custom main menu, then `<Escape>` or `<CtrlAltShift X>` to end repeat mode. Confirm original `<Ctrl L>` behavior returns.
4. Search with `givx`. Left-click the second result; use `<CtrlAltShift G>` to return. Left-click again and use `<CtrlAltShift X>` directly from the source to close the viewer. Verify ordinary `<Shift Tab>` works afterward.
5. Verify clipboard and source remain unchanged, and search counts match version 21 on small test data before running large files.

## Unchanged correctness limits

Search logic, `FastPlan=0` default, adaptive window, timing, matching and source coordinates are unchanged from v21. The scan still may miss matches longer than the configured search context and skips source lines longer than `AdaptiveWindow=30000`. Prior benchmarks recorded 4 skipped lines in a 10,046,760-line file and 50 in a 16,364,141-line file.

This release has **not** been compiled or executed in TSE locally. It requires your compiler/runtime check.
