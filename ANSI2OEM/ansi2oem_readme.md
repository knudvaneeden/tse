# Ansi2oem (v3.0.1) - TSE Macro Documentation

## Description
**Ansi2oem** is an extension created by Carlo Hogeveen for the GUI versions of The SemWare Editor (TSE Pro 4.0 and upwards, specifically `g32.exe`)[cite: 1]. It allows users to customize character rendering by selecting whether TSE should display standard ANSI characters as OEM characters or 3D line drawing characters[cite: 1].

**Critical Note:** This macro **only** modifies the visual display of characters on your screen[cite: 1]. It does **not** alter the actual character codes saved in your text buffer[cite: 1]. Files shared with others will retain their original ASCII/ANSI codes[cite: 1].

## Help & Controls
When running the macro, a configuration interface displays six columns detailing the character's decimal/hex codes, current visual representation, selected display type (`ansi`, `oem`, or `3d`), alternative pictures, and descriptions (for control characters)[cite: 1].

### Key Bindings
*   **Arrow keys, Page Up/Down, Home, End:** Scroll and navigate through the character list[cite: 1].
*   **Spacebar:** Toggle the display setting of the current character (cycles through ANSI, OEM, and 3D)[cite: 1].
*   **Enter:** Insert the currently selected character directly into your text document[cite: 1].
*   **Escape:** Exit the configuration interface[cite: 1].
*   **Digits (0-9):** Jump to a specific decimal ASCII code[cite: 1].
*   **Alt + Keypad Digits (without leading zero):** Jump to a decimal OEM code[cite: 1].
*   **Alt + Keypad Digits (with leading zero):** Jump to a decimal ANSI code[cite: 1]. *(Note: Ensure NumLock is ON).*[cite: 1]
*   **Type a character:** Jump immediately to that character in the menu[cite: 1].
*   **Alt + D:** Delete the saved Ansi2oem settings for the currently active font[cite: 1].
*   **Alt + U:** Uninstall the Ansi2oem macro (removes settings profiles and deletes it from the autoload list)[cite: 1].

## Installation & Configuration Steps
1.  **Copy Source:** Move the `ansi2oem.s` file into your TSE `mac` directory[cite: 1].
2.  **Compile:** Open TSE and compile the macro file[cite: 1].
3.  **Execute:** Run the compiled macro to open the configuration screen[cite: 1].
4.  **Configure:** Use the interface (via `Spacebar` and navigation keys) to modify how specific characters (like control characters or line-drawings) are rendered[cite: 1].
5.  **Save & Autoload:** Upon exiting, the tool will prompt you to save your modified settings[cite: 1]. You can save them as a **default for all fonts** (recommended) or for the current font only[cite: 1]. Saving your settings automatically configures the macro to launch via TSE's Macro AutoloadList[cite: 1].
