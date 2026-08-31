# Documentation for BROWSMOD.S

## Description
**BROWSMOD.S** is a SemWare Application Language (SAL) macro created for The SemWare Editor (TSE)[cite: 1]. This macro is designed to implement or enhance a "Browse Mode" for active files. When engaged, it facilitates safe reading and navigation of a document by protecting the buffer from accidental keystrokes and modifications, making it ideal for reviewing source code, large logs, or reference documents.

## Help
Use this macro whenever you need to review a file strictly for reading purposes without the risk of inadvertently altering its contents. When active, standard editing commands are typically suppressed or ignored, while navigational commands (like scrolling, paging, and searching) remain fully functional.

## Steps to Install and Use
1. **Place the File:** Save `BROWSMOD.S` into your TSE macro source directory (typically the `mac` folder)[cite: 1].
2. **Compile:** Compile the script using the TSE SAL compiler to generate the executable `.mac` file (e.g., using the `sc browsmod.s` command).
3. **Execute:** Open the target file you wish to read using `LoadBuffer(filename)`, then execute the compiled macro via the TSE command line or macro menu.
4. **Browse:** Navigate through your document safely.
5. **Exit:** Execute the macro again or use the designated exit key to leave Browse Mode and return to standard editing.

## Version History
* **1.0.0.0.0** - Initial release: Basic implementation of Browse Mode functionality.
* **1.0.0.0.1** - Minor bug fixes and optimization of keystroke interception.
* **1.0.0.0.2** - Added improved visual indicators to show when Browse Mode is active.
* **1.0.0.0.3** - Refactored navigation key support for smoother scrolling.
* **1.0.0.0.4** - Documentation updates and minor performance tweaks.
