# CMTSE - TSE Pro/32 Web Page Badges

## Document information

- **README file:** `cmtse_readme.md`
- **README version:** 1.0.0.0.0
- **Date:** 2026-09-02
- **Time:** 23:55 CEST (UTC+02:00)
- **Original package:** `cmtse.zip`
- **Original package date:** 2003-01-31

## Description

CMTSE is a small graphics package containing two GIF badges for use on a web page that was created or is maintained with **The SemWare Editor Professional (TSE Pro/32)**.

The badges were created by David Queenan. According to the included `file_id.diz`, permission was granted to anyone who wants to use them to advertise that a web page uses TSE. The package was uploaded by Dave Boyd.

This archive does not contain a TSE SAL macro or executable program. Nothing needs to be compiled or run inside TSE.

## Package contents

| File | Size | Dimensions | Purpose |
|---|---:|---:|---|
| `created_with_tse.gif` | 1,800 bytes | 88 x 31 pixels | Badge for a web page created with TSE |
| `maintained_with_tse.gif` | 1,878 bytes | 88 x 31 pixels | Badge for a web page maintained with TSE |
| `file_id.diz` | 319 bytes | Not applicable | Original package description and credits |

## Requirements

- A program that can extract ZIP archives.
- A website or local HTML page on which the badge will be displayed.
- A text or HTML editor, such as TSE Pro/32, for editing the page.

## Installation

1. Extract `cmtse.zip` to a temporary directory.
2. Choose the appropriate badge:
   - Use `created_with_tse.gif` when the web page was created with TSE.
   - Use `maintained_with_tse.gif` when the web page is maintained with TSE.
3. Copy the selected GIF file to the image directory of your website, for example `images`.
4. Upload the GIF together with the other website files when publishing the page.

## How to use it

Add an HTML image element at the location where the badge should appear.

For the **created with TSE** badge:

```html
<img src="images/created_with_tse.gif"
     width="88"
     height="31"
     alt="Created with TSE Pro/32">
```

For the **maintained with TSE** badge:

```html
<img src="images/maintained_with_tse.gif"
     width="88"
     height="31"
     alt="Maintained with TSE Pro/32">
```

Adjust the path in `src` if the GIF is stored in another directory. For example, use `created_with_tse.gif` when the image and HTML file are in the same directory.

## Steps to display a badge locally

1. Place an HTML file and the selected GIF in the same directory.
2. Add the corresponding `<img>` element to the HTML file.
3. If both files are in the same directory, remove `images/` from the image path.
4. Save the HTML file.
5. Open the HTML file in a web browser.
6. Confirm that the badge appears and is displayed at 88 x 31 pixels.

## Troubleshooting

### The badge does not appear

- Check that the filename in `src` exactly matches the GIF filename.
- Check that the directory path is correct relative to the HTML file.
- Make sure that the GIF was uploaded to the web server.
- Remember that some web servers treat uppercase and lowercase letters as different characters.

### A broken-image symbol appears

The browser cannot find or read the referenced file. Open the image URL directly in the browser and correct the path or filename as necessary.

### The image is distorted

Keep the original dimensions of 88 pixels wide by 31 pixels high, or omit the `width` and `height` attributes so the browser uses the GIF's natural dimensions.

## Credits and permission

- **Graphics created by:** David Queenan
- **Original uploader:** Dave Boyd (`dave@tsc-corp.com`)
- **Permission:** The included `file_id.diz` states that permission is granted to anyone who wants to use the graphics to advertise that a web page uses TSE.

## Version history

| Version | Date | Time | Changes |
|---|---|---|---|
| 1.0.0.0.0 | 2026-09-02 | 23:55 CEST | Initial Markdown README based on the contents of `cmtse.zip`. |

Future revisions should increment the final version component sequentially, for example:

- 1.0.0.0.1
- 1.0.0.0.2
- 1.0.0.0.3

