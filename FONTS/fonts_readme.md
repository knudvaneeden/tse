# FONTS for TSE Pro

**Session title:** Create FONTS MarkDown Readme  
**README version:** 1.0.0.0.0  
**Date and time:** 2026-09-09 22:46:26 UTC  
**Original archive:** `fonts.zip`

## Description

`fonts.zip` is a collection of eight legacy Windows bitmap font files for use with TSE Pro v4.0 for Windows. The fonts provide compact fixed-width choices that can improve character alignment and make source code and text easier to distinguish.

The information supplied with the original archive says the fonts were intended for TSE Pro v4.0 on Windows 9x through Windows XP. They may also work with later TSE releases and Windows versions, but compatibility with current systems such as Windows 11 is not guaranteed.

## Included files

| File | Description |
| --- | --- |
| `fixedsysoem14.fon` | FixedSys OEM 14 bitmap font, contributed by Chris Antos. |
| `sprog5x8.fon` | SPROG bitmap font in a compact 5-by-8 size. |
| `sprog5x9.fon` | SPROG bitmap font in a compact 5-by-9 size. |
| `sprog6x8.fon` | SPROG bitmap font in a 6-by-8 size. |
| `sprog6x9.fon` | SPROG bitmap font in a 6-by-9 size. |
| `sprog8x8.fon` | SPROG bitmap font in an 8-by-8 size. |
| `kourier.fon` | Monospaced Courier-style font with larger punctuation and clearer differences between `l` and `1`, and between `o` and `0`. |
| `ksans.fon` | Sans-serif version of Kourier with a cleaner appearance. |
| `file_id.diz` | Original package description and contributor information. |

The SPROG fonts were contributed by Michael Durland. Kourier and Ksans were contributed by Karl Bochert.

## Installation

1. Extract `fonts.zip` to a temporary directory.
2. Close TSE before installing or changing fonts.
3. In Windows File Explorer, select one or more `.fon` files.
4. Right-click the selected file or files and choose **Install**. If that option is unavailable, open the Windows Fonts control panel and add the fonts there.
5. Start TSE Pro for Windows.
6. Open TSE's font-selection or configuration dialog and select the installed font.
7. Test several font sizes and choose the one that gives the preferred number of rows and columns while remaining readable.

Administrative permission may be required to install fonts for all users. On a current 64-bit Windows release, legacy `.FON` installation or display can vary by system configuration.

## How to run and use

These files are fonts, not TSE SAL macros or executable programs. There is therefore no `.s` file to compile and no macro command to run.

After installing a font:

1. Start the Windows version of TSE.
2. Open the editor's font settings.
3. Select one of the installed FONTS package fonts.
4. Confirm the change and return to the editor.
5. Check source code, punctuation, line drawing, and visually similar characters such as `l`, `1`, `o`, and `0`.
6. If the result is unsuitable, return to the font settings and select another font or size.

## Help and troubleshooting

### The font does not appear in TSE

- Restart TSE after installing the font.
- If necessary, sign out of Windows or restart Windows so the font list is refreshed.
- Confirm that the font appears in the Windows Fonts settings.
- Try installing the font with administrative permission.
- Remember that some current applications do not list legacy bitmap fonts.

### The characters are too small or too large

Try another SPROG variant. The numbers in names such as `sprog5x8.fon` and `sprog6x9.fon` identify different bitmap dimensions. A smaller font normally displays more text on screen, while a larger font is usually easier to read.

### Similar characters are difficult to distinguish

Try Kourier. It was specifically designed with larger punctuation and clearer differences between lowercase `l` and digit `1`, and lowercase `o` and digit `0`.

### The font looks distorted

Bitmap fonts are designed for particular pixel sizes. Avoid unsupported scaling and test the font at its native sizes. Display scaling and high-DPI settings on modern Windows systems can affect its appearance.

### Restoring the previous font

Open TSE's font settings and select the font that was used previously. Uninstalling the package fonts is not necessary merely to stop using them.

## Uninstallation

1. Close TSE.
2. Open **Settings > Personalization > Fonts** or the Windows Fonts control panel.
3. Locate the installed font.
4. Select **Uninstall**.
5. Restart TSE if it was open during the change.

Do not remove a font if another program still depends on it.

## Notes

- The archive contains no TSE SAL source code.
- Keep the original ZIP file as a backup before installing or removing fonts.
- The external download links recorded in `file_id.diz` date from 2003 and may no longer be available; they are not required to use the eight included fonts.
- The package description attributes the included fonts to their individual contributors; retain `file_id.diz` when redistributing the archive.

## Version history

| Version | Date and time (UTC) | Changes |
| --- | --- | --- |
| 1.0.0.0.0 | 2026-09-09 22:46:26 | Initial Markdown documentation with description, file list, installation steps, usage help, troubleshooting, and removal instructions. |

Future revisions should increment the final component sequentially: `1.0.0.0.1`, `1.0.0.0.2`, and so on.
