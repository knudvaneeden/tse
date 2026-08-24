## Anagram Finder Overview
This TSE SAL program is designed to find all valid anagrams from a user-supplied string of letters[cite: 1]. Originally authored by Peter Birch and later revised by Warren Porter for TSE32 v 2.8, the script systematically generates permutations and validates them against a dictionary[cite: 1]. The primary goal is to provide a complete list of real words that can be uniquely formed from the initial input[cite: 1].

## Core Functionality
The macro relies on complex recursive algorithms and external dictionary validation to efficiently produce its results[cite: 1].
* **Permutation Generation:** The program uses a recursive procedure, `visit()`, to create unique letter arrangements by swapping character positions[cite: 1].
* **Duplicate Elimination:** It implements Pascal-language "sets" to avoid processing identical duplicate characters[cite: 1].
* **Mathematical Optimization:** By dividing total permutations by the factorial of duplicate letters, it reduces execution time significantly[cite: 1].
* **Dictionary Validation:** The macro interfaces with SemWare's `spell.dll` to check if a generated permutation is a legitimate English word[cite: 1].
* **Buffer Operations:** Valid anagrams are written line-by-line into a newly created temporary work buffer[cite: 1].

## User Experience and Interface
The script includes practical features to keep the user informed and in control during potentially lengthy operations[cite: 1].
* **Progress Tracking:** A pop-up window displays the search completion percentage based on factorial calculations[cite: 1].
* **Interruptibility:** Users can press any key to safely abort a long-running search and view the anagrams found up to that point[cite: 1].
* **Input Sorting:** The user's input string is alphabetized before processing to ensure the final anagram list is orderly[cite: 1].

## Technical Requirements
To execute properly, this macro requires a specific environmental setup within the TSE editor[cite: 1].
* **Dictionary File:** It strictly depends on the SemWare dictionary file, typically named `semware.lex`, being accessible[cite: 1].
* **Search Path:** The `WhenLoaded` procedure intelligently attempts to locate this dictionary file in the editor's `SPELL\` directory[cite: 1].
* **Dynamic Link Library:** The `spell.dll` file must be accessible for functions like `_OpenSpell` and `_SpellCheckWord` to operate correctly[cite: 1].
