# TSE SAL Macro: File Replace / Load from Disk (Refresh All)

## Description
The `PROCFileReplaceLoadFromDiskRefreshRingAllDefault` macro automates the process of refreshing all currently loaded files in the TSE (The SemWare Editor) file ring[cite: 1]. Instead of manually refreshing a single file via the TSE menu (`Util` > `Potpourri` > `ReplaceF`), this script systematically iterates through every open file and replaces the in-memory buffer with the latest version from the disk[cite: 1].

## Help & Use Cases
This macro is particularly helpful in the following scenarios:
* **External AI Generation:** When using AI to generate code into a fixed download directory (e.g., `c:\downloads\foobar.s`), you can keep the file open in TSE and simply run this macro to immediately load the latest AI-generated updates[cite: 1].
* **Cross-Platform Editing:** If you have files loaded in TSE for Linux but are editing them concurrently in TSE for Windows, running this macro syncs the TSE ring with the updated files saved by the other operating system[cite: 1].
* **Batch File Updates:** If you have extracted a `.zip` archive (e.g., `FppPack_1_04_portable.zip`) and loaded its contents into TSE, editing or overwriting those files outside of the editor requires a refresh[cite: 1]. This macro instantly refreshes all of those files to their newest disk versions[cite: 1].

## Steps to Execute
1. Ensure that the files you want to monitor or edit are currently loaded in the TSE file ring.
2. Load and compile this SAL script in TSE.
3. Press `<Ctrl F12>` to execute the `Main()` procedure[cite: 1].
4. The macro will silently perform the following actions:
   * Count the total number of files in the ring using `NumFiles()`[cite: 1].
   * Loop through each file sequentially[cite: 1].
   * Refresh the display (`UpDateDisplay()`) and execute the native `replacef` macro for the active file[cite: 1].
   * Move to the next file in the ring using `NextFile()` until all files are refreshed[cite: 1].
