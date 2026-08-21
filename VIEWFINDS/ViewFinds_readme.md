# ViewFinds Extension for TSE (v1.1.18)

## Overview
**ViewFinds** is a macro extension for The Semware Editor (TSE) that significantly enhances the native "View Finds" window (typically accessed via the `v` search option or the `grep` macro). It applies intelligent syntax highlighting and comment coloring to search results, allowing you to easily distinguish between active code and commented-out text at a glance. 

## Compatibility
*   **TSE v4.50.26 upwards:** Full syntax highlighting combined with instantaneous lazy-evaluated Regex and search-term overlays. Includes Dynamic Engine Switching to prevent lockups on massive logs or documents.
*   **TSE v4.50 to v4.50.24 (including rc versions):** Search-term and Regular Expression highlighting fallback using instantaneous lazy evaluation.
*   **OS Support:** Works across all TSE variants, including TSE for Linux.

---

## Installation

You have a few options for installing the macro, ranging from quick testing to permanent integration:

1.  **Working Directory (Quick Start):** Keep the `.s` file in your TSE working directory.
2.  **Command Line:** Launch TSE with the parameter `-e<filename>` to load it on startup.
3.  **Startup File:** Add the macro to your `tsestart.s` initialization script.
4.  **AutoLoad List (Recommended):**
    *   Place the file in TSE's `mac` folder and compile it using the Macro Compile menu.
    *   Add `ViewFinds` to TSE's Macro AutoLoad List menu and restart the editor.

---

## Configuration

You can customize the visual behavior of the extension by executing `ViewFinds` from the Macro Execute menu. This opens a configuration menu with two main options:

*   **Current line background color:** This is especially useful for users who configured TSE to have a current line with the same color as other lines. During editing the cursor still indicates the current line, but in a "View Finds" list there is no cursor to indicate the current line.
*   **Trailing spaces color:** In a "View Finds" list short lines will have trailing spaces. These trailing spaces can be colored like editor-text or like a menu.

---

## Internal Methods & Procedures

The macro uses advanced memory handling and lazy evaluation to ensure instantaneous loading, even when parsing gigabyte-scale documents. Here is a short description of the core methods driving the extension:

*   **`Main()`**: The primary entry point, which triggers the interactive configuration menu.
*   **`WhenLoaded()` / `WhenPurged()`**: Lifecycle events. `WhenLoaded` initializes variables, creates hidden temp buffers, and hooks into editor events. `WhenPurged` safely destroys memory blocks and buffers to prevent leaks.
*   **`list_startup()` / `list_cleanup()`**: Event hooks that trigger when the View Finds window opens or closes. `list_startup` intercepts the window, securely sanitizes the active search history to explicitly restrict dangerous structural modifier options (like `g` and `v`), and triggers the attribute construction.
*   **`create_attributes_list()`**: The core engine that handles file references. By default, it builds the hidden attribute buffer via rapid memory chunking (O(1) string chunk insertions). However, if the grep list exceeds 2,000 lines (e.g. searching 1.5GB .dok files), it automatically triggers the **Dynamic Engine Switch**, entirely bypassing this upfront loop to ensure the editor loads instantly.
*   **`temporarily_load_ref_file()`**: Silently loads un-opened files in the background so the macro can accurately retrieve their multi-line delimiter settings. It includes a strict 10 MB size safety cap to prevent the editor from hanging on massive document files.
*   **`get_syn_hi_attrs()`**: A wrapper for TSE's native syntax parser for versions v4.50.25 upwards.
*   **`CurrLine_MLD_Type()`**: A customized replacement for TSE's internal multi-line delimiter function to properly handle files loaded on the fly, with strict distance limits to prevent hanging.
*   **`hd_draw_list_line()`**: Intercepts the screen drawing routine. This logic dynamically generates string formatting and stamps search-term highlights onto the string directly as you scroll, completely eliminating buffer-switch bottlenecks. For Regex queries across all versions, it securely utilizes the native memory parser `StrFind()` to accurately map variable-length matching patterns directly over the strings without triggering recursive interface errors or relying on static buffer cursors.
*   **`del_line()`**: A custom keyboard handler that overrides the `<Del>` and `<GreyDel>` keys for removing lines or safely unloading referenced files directly from the list.
*   **`do_main_menu()`**: Renders the interactive configuration UI for adjusting background colors and trailing space preferences.
