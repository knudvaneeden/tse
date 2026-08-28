# TSE SAL Macro: Archive Integration (`archive7.s`)

## Description
This TSE (The SemWare Editor) SAL macro script, authored by John Barbee, provides seamless integration for archiving and unarchiving files directly within the editor[cite: 1]. It supports three common DOS archive formats: ZIP (`pkzip`/`pkunzip`), LHA (`lha`), and ARJ (`arj`)[cite: 1]. The script allows users to retrieve an archived file for editing, or save an open file directly into a new or existing archive[cite: 1].

## Prerequisites
* The corresponding DOS archiving utilities (`pkzip`, `pkunzip`, `lha`, `arj`) must be accessible in your system's DOS path[cite: 1].
* DOS 6.0 or higher is currently configured for the `deltree` command used in directory cleanup, though legacy support (`del` and `rd`) is commented out in the source code[cite: 1].

## Help & Available Commands
The macro provides the following primary procedures:

* **`mEditfile()`**: Used to retrieve and edit a file that is stored inside an archive[cite: 1]. It creates a temporary `TMP` directory, extracts the chosen archive into it, selects the file for editing, and then safely removes the temporary directory[cite: 1].
* **`mSaveAsZip()`**: Saves the currently active file buffer to disk and archives it[cite: 1]. It will prompt you whether to add the file into an already existing archive or to create a new archive in the current directory[cite: 1]. After archiving, the original unarchived file is deleted[cite: 1].
* **`mDelDir(string path)`**: A helper procedure utilized by `mEditfile()` that safely removes the temporary extraction directory[cite: 1]. It includes a double confirmation prompt ("Are you sure..." and "Really sure?") before executing the DOS `deltree` command to prevent accidental deletions[cite: 1].

## Steps for Usage

### 1. Editing a File from an Archive
1. Execute the `mEditfile()` procedure within TSE[cite: 1].
2. A file picker will appear; select the `.zip`, `.lzh`, or `.arj` file you wish to extract and edit[cite: 1].
3. The macro will automatically extract the contents to a `TMP` directory and open the file[cite: 1].
4. Upon completion, the macro updates the filename path and securely deletes the `TMP` folder[cite: 1].

### 2. Saving a File into an Archive
1. While editing a file you want to archive, execute the `mSaveAsZip()` procedure[cite: 1].
2. The macro will first save your current file normally to ensure all changes are written[cite: 1].
3. You will be prompted with: "Do you want to archive [filename] to another archive file? (Y?N)"[cite: 1].
    * **Choose 'N' (No):** A menu will appear asking you to choose your desired archive format (Zip, ARJ, or LHA)[cite: 1]. The file will be compressed into a new archive in the current directory[cite: 1].
    * **Choose 'Y' (Yes):** A file picker will open allowing you to select an *existing* archive[cite: 1]. The script will automatically detect the archive type by its extension and append your current file to it[cite: 1].
4. The macro will then delete the original unarchived text file from the disk[cite: 1].
