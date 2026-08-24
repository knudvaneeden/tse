# TSE SAL Extension: Ampersand as Menu Quick-Key

## Overview
* This documentation details a TSE extension and its companion test macro, both authored by Carlo.Hogeveen@xs4all.nl on December 29, 2019[cite: 1, 2].
* Compatibility for both files strictly requires the GUI version of TSE Pro v4.4 or higher[cite: 1, 2].
* By default, TSE does not possess the native syntax to assign the ampersand ("&") as a functional menu quick-key[cite: 1].
* This toolset circumvents that limitation by rendering ampersands as actionable quick-keys in custom menus[cite: 1, 2].

## Core Extension functionality
* The main extension allows developers to declare a menu quick-key by placing an ampersand immediately before a NULL (" ") character[cite: 1].
* Natively, TSE displays this specific sequence as an invisible, checkable NULL character in menus[cite: 1].
* The macro operates by applying a slight delay to visually overwrite the invisible NULL character with a coloured ampersand[cite: 1].
* When the user is within a recognized non-edit window state (such as a menu), the macro supplements any ampersand keystroke with a "pressed" NULL key[cite: 1].
* This forces TSE to bypass the unrecognized ampersand and execute the hidden NULL quick-key command[cite: 1].

## Demo and Testing Tool
* The secondary file acts as a demonstration tool for the main extension[cite: 2].
* It creates a custom menu that successfully displays a functional, coloured ampersand quick-key right alongside standard ampersand text[cite: 2].
* Users can simply press the ampersand key within this demo menu to trigger the quick-key's assigned operation[cite: 2].

## Installation Steps
1. Copy the main extension file into your TSE "mac" folder and compile it[cite: 1].
2. Add the compiled macro's name to the TSE Macro AutoLoad List, then restart your TSE editor[cite: 1].
3. For verification, place the companion test file into the "mac" folder, compile it, and run it via the Macro Execute menu[cite: 2].
