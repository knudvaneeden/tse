# ViewFinds Extension for TSE (v1.1.13)

## Overview
**ViewFinds** is a macro extension for The Semware Editor (TSE) that significantly enhances the native "View Finds" window (typically accessed via the `v` search option or the `grep` macro)[cite: 3]. It applies intelligent syntax highlighting and comment coloring to search results, allowing you to easily distinguish between active code and commented-out text at a glance[cite: 3].

## Compatibility
*   **TSE v4.50.26 upwards:** Full syntax highlighting[cite: 3].
*   **TSE v4.50 to v4.50.24 (including rc versions):** Search-term and Regular Expression highlighting fallback using instantaneous lazy evaluation[cite: 3].
*   **OS Support:** Works across all TSE variants, including TSE for Linux[cite: 3].

---

## Installation

You have a few options for installing the macro, ranging from quick testing to permanent integration[cite: 3]:

1.  **Working Directory (Quick Start):** Keep the `.s` file in your TSE working directory[cite: 3].
2.  **Command Line:** Launch TSE with the parameter `-e<filename>` to load it on startup[cite: 3].
3.  **Startup File:** Add the macro to your `tsestart.s` initialization script[cite: 3].
4.  **AutoLoad List (Recommended):**
    *   Place the file in TSE's `mac` folder and compile it using the Macro Compile menu[cite: 3].
    *   Add `ViewFinds` to TSE's Macro AutoLoad List menu and restart the editor[cite: 3].

---

## Configuration

You can customize the visual behavior of the extension by executing `ViewFinds` from the Macro Execute menu[cite: 3]. This opens a configuration menu with two main options:

*   **Current line background color:** This is especially useful for users who configured TSE to have a current line with the same color as other lines[cite: 3]. During editing the cursor still indicates the current line, but in a "View Finds" list there is no cursor to indicate the current line[cite: 3].
*   **Trailing spaces color:** In a "View Finds" list short lines will have trailing spaces[cite: 3]. These trailing spaces can be colored like editor-text or like a menu[cite: 3].

---

## Internal Methods & Procedures

The macro uses advanced memory handling and lazy evaluation to ensure instantaneous loading, even when parsing gigabyte-scale documents. Here is a short description of the core methods driving the extension:

*   **`Main()`**: The primary entry point, which triggers the interactive configuration menu[cite: 3].
*   **`WhenLoaded()` / `WhenPurged()`**: Lifecycle events. `WhenLoaded` initializes variables, creates hidden temp buffers, and hooks into editor events. `WhenPurged` safely destroys memory blocks and buffers to prevent leaks[cite: 3].
*   **`list_startup()` / `list_cleanup()`**: Event hooks that trigger when the View Finds window opens or closes. `list_startup` intercepts the window, securely sanitizes the active search history to explicitly restrict dangerous structural modifier options (like `g` and `v`), and triggers the attribute construction[cite: 3].
*   **`create_attributes_list()`**: The core engine that handles file references. For older TSE versions, this bypasses upfront pre-calculation entirely to enable instant loading. For modern versions, it builds the hidden attribute buffer via rapid memory chunking (O(1) string chunk insertions)[cite: 3].
*   **`temporarily_load_ref_file()`**: Silently loads un-opened files in the background so the macro can accurately retrieve their multi-line delimiter settings. It includes a strict 10 MB size safety cap to prevent the editor from hanging on massive document files[cite: 3].
*   **`get_syn_hi_attrs()`**: A wrapper for TSE's native syntax parser for versions v4.50.25 upwards[cite: 3].
*   **`CurrLine_MLD_Type()`**: A customized replacement for TSE's internal multi-line delimiter function to properly handle files loaded on the fly[cite: 3].
*   **`hd_draw_list_line()`**: Intercepts the screen drawing routine. In older versions, this utilizes **Lazy Evaluation**, dynamically generating string-formatting and stamping search-term highlights onto the string directly as you scroll, completely eliminating buffer-switch bottlenecks. For Regex queries, it securely utilizes the native memory parser `StrFind()` to accurately map variable-length matching patterns directly over the strings without triggering recursive interface errors or touching the active buffers[cite: 3].
*   **`del_line()`**: A custom keyboard handler that overrides the `<Del>` and `<GreyDel>` keys for removing lines or safely unloading referenced files directly from the list[cite: 3].
*   **`do_main_menu()`**: Renders the interactive configuration UI for adjusting background colors and trailing space preferences[cite: 3].
