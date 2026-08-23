# Summary: viewmenuampersand.s[cite: 2]

## Overview & History
* **Author:** Steve Kraus[cite: 2]
* **Version:** 1.0.0.0.0[cite: 2]

`viewmenuampersand.s` is a utility macro designed for The SemWare Editor (TSE) SAL macro developers[cite: 2]. Its primary purpose is to assist in menu development by extracting, sorting, and displaying all the mnemonic "quick-keys" (ampersand hotkeys) defined within a specific SAL menu block[cite: 2]. This allows macro writers to easily spot conflicts, view existing shortcuts, and thoughtfully choose new mnemonic keys without having to manually scan the code[cite: 2].

## How to Use
1. Open a TSE SAL source code file in the editor[cite: 2].
2. Position your cursor anywhere inside a menu definition block (specifically between the `menu` and `end` statements)[cite: 2].
3. Press the default macro hotkey: `<CtrlAltShift Q>`[cite: 2].
4. A pop-up list will appear near the right margin of the screen, displaying all the quick-keys found in that menu, sorted in alphabetical order[cite: 2].
5. Select a menu item from the list[cite: 2]. The pop-up will close, and your cursor will automatically jump directly to the corresponding quick-key ampersand in the source code[cite: 2].

## Technical Details & Implementation
* **Boundary Detection:** When triggered, the script (`ShowQuickKey()`) saves the current cursor position, searches backwards to identify the `menu` line's indentation level, and then searches forwards to find the matching `end` statement to establish the boundaries[cite: 2].
* **String Parsing:** It scans the isolated menu block for ampersands (`&`) enclosed in double quotes (`"`), specifically checking for and ignoring escaped ampersands (`&&`) so only true hotkeys are captured[cite: 2].
* **Buffer Management:** The extracted hotkeys and their corresponding menu strings are written to a hidden, reusable temporary buffer named `<QuickKey>`[cite: 2].
* **Data Tracking:** To facilitate the jump-back navigation, the macro cleverly appends the original source code line number far out of view at column 240 of the temporary list buffer[cite: 2].
* **Interface:** The buffer is sorted (ignoring case) and presented to the user using the `lList` command[cite: 2]. Once an option is selected, it parses the hidden line number from column 240 and uses `GotoLine` to navigate the user[cite: 2].
