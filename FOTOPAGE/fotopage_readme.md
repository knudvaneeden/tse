# FOTOPAGE

## Description

FOTOPAGE is a TSE Pro/32 SAL macro that generates a single-page HTML photo album from a directory of full-size JPEG images and a subdirectory containing matching thumbnails.

For every image found, the generated page displays a thumbnail, the filename, and the approximate file size in kilobytes. Selecting a thumbnail opens the corresponding full-size image in a browser window named `ImageWindow`.

The generated file is named `index.html` and is saved in the directory containing the full-size images.

## Package contents

- `fotopage.s` - TSE SAL source code for the macro.
- `file_id.diz` - Original short package description.

## Requirements

- The SemWare Editor Professional (TSE Pro/32) for Windows.
- The TSE SAL compiler if `fotopage.s` has not yet been compiled.
- A directory containing full-size `.jpg` images.
- A thumbnail subdirectory containing smaller images with exactly the same filenames as the corresponding full-size images.
- A web browser for viewing the generated album.

## Required directory structure

The files should be arranged as follows:

```text
Photos\
|-- image1.jpg
|-- image2.jpg
|-- image3.jpg
`-- Thumbnails\
    |-- image1.jpg
    |-- image2.jpg
    `-- image3.jpg
```

The thumbnail directory may have another name, but each thumbnail filename must match its full-size image filename.

## Installation

1. Extract `fotopage.zip` to a working directory.
2. Open a command prompt in that directory.
3. Compile the SAL source with the TSE SAL compiler:

   ```bat
   sc32 fotopage.s
   ```

4. Confirm that the compiler creates the executable TSE macro, normally `fotopage.mac`.
5. Place the compiled macro where TSE can find it, or supply its complete path when running it.

## How to run FOTOPAGE

1. Create the full-size image directory and its thumbnail subdirectory as described above.
2. Start TSE Pro/32.
3. Execute the `fotopage` macro from TSE.
4. At **Enter directory path to build for**, enter the image search path. The original default is `*.jpg`. To process another directory, include its path and wildcard, for example:

   ```text
   C:\Photos\*.jpg
   ```

5. At **Name of thumbnail directory**, enter the relative thumbnail directory name, including its trailing slash. The default is:

   ```text
   Thumbnails/
   ```

6. At **Enter Window/Bookmark Title**, enter the title to use for the browser window and page heading.
7. At **Additional URL**, enter the web address for the optional link displayed at the bottom of the page.
8. At **Additional URL Description**, enter the visible text for that link.
9. At **Number of Columns for page**, enter the number of photographs to display in each row. The default is `3`.
10. When generation finishes, open `index.html` from the full-size image directory in a web browser.

## Prompt reference

| Prompt | Purpose | Original default |
| --- | --- | --- |
| Enter directory path to build for | Selects the full-size JPEG files | `*.jpg` |
| Name of thumbnail directory | Supplies the relative path used by thumbnail image links | `Thumbnails/` |
| Enter Window/Bookmark Title | Sets the HTML title and page heading | `Featured Photos` |
| Additional URL | Sets the link at the bottom of the page | Original sample voting URL |
| Additional URL Description | Sets the visible text for the additional link | `Cast your Vote` |
| Number of Columns for page | Controls how many thumbnails appear in each row | `3` |

## Help and troubleshooting

### No photographs appear

- Confirm that the image path ends with a suitable wildcard such as `*.jpg`.
- Confirm that the path exists and contains JPEG files.
- The original macro searches only for filenames matching the supplied pattern.

### Thumbnails are missing in the browser

- Check that the thumbnail directory name entered in the prompt matches the actual directory.
- Include the trailing `/` in the thumbnail directory value.
- Confirm that every thumbnail has exactly the same filename as its full-size image.
- Check filename capitalization when the album is uploaded to a case-sensitive web server.

### The full-size image does not open

Confirm that `index.html` remains in the same directory as the full-size images. The generated links use the image filenames rather than absolute paths.

### The layout is too wide

Run the macro again and choose fewer columns. The original source recommends three columns for 240-by-180-pixel thumbnails on an 800-by-600 display.

### Existing output file

The macro always writes the result as `index.html`. Back up an existing file of that name before running FOTOPAGE if it must be retained.

## Notes and limitations

- FOTOPAGE is legacy software originally dated December 4, 2000, and was written for TSE Pro/32 v2.x.
- The original source is designed for JPEG files, although another pattern may be entered if the browser can display the selected image format.
- Images are processed in the order returned by TSE's file-search functions.
- The macro does not create thumbnails; they must be prepared separately.
- The generated HTML uses legacy elements and attributes and may require manual cleanup for modern HTML validation.
- The original generated metadata line contains `<<meta` instead of `<meta`. If strict HTML is required, correct this in the generated file or source.
- The macro does not escape special HTML characters occurring in filenames, titles, link descriptions, or URLs.
- Enter a positive, nonzero column count to avoid invalid arithmetic during page generation.

## Original author

Mike Chambers (Contributing User)

## Document version history

| Version | Date and time | Changes |
| --- | --- | --- |
| 1.0.0.0.0 | 2026-09-09 23:04:47 UTC | Created the initial FOTOPAGE Markdown description and run instructions. |
| 1.0.0.0.1 | 2026-09-09 23:04:47 UTC | Added detailed prompt help, directory example, troubleshooting, and legacy limitations. |

## README information

- README filename: `fotopage_readme.md`
- Current README version: `1.0.0.0.1`
- Date: `2026-09-09`
- Time: `23:04:47 UTC`
- Created with: OpenAI Codex (GPT-5)
