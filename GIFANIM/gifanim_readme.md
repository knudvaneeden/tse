# GIFANIM for TSE SAL

Version **1.0.0.0.14** — 2026-09-28, 01:20 Europe/Amsterdam.

Creates a looping GIF from numbered PNG frames, such as `01.png`, `02.png`, `03.png`. Frames are selected by the `sequence` wildcard and sorted by the number in their filename. One leading underscore is allowed, so `01.png`, `_02.png`, `_03.png` become frames 1, 2, 3. The only encoder is Windows PowerShell and .NET System.Drawing; no FFmpeg or custom DLL is needed.

## Install and run

1. Place `gifanim.s`, `gifanim.ps1`, `gifanim.ini`, `01.png`, and `02.png` together. Compile `gifanim.s` in that directory and keep the resulting `gifanim.mac` there. The macro locates the INI and PowerShell script beside its compiled `.mac` through `CurrMacroFilename()`, even when TSE's working directory is elsewhere.
2. Compile `gifanim.s` with `sc32 gifanim.s`, then execute that `gifanim.mac` in TSE.
3. Review or change the five values shown by `Ask()`: numbered PNG selection, INPUT directory for PNG files, GIF filename, GIF output directory, and delay per frame. Their initial values come from `gifanim.ini`.
4. If no matching numbered PNGs are found, TSE shows a `Warn()` box. The macro checks both whether `Dos()` launched PowerShell and whether `DosIOResult()` reports a zero process exit code; failures produce a warning. Inspect the GIF at the path printed by PowerShell.

The package includes two example frames, `01.png` and `02.png` (both 960 × 516 pixels). Put them beside `gifanim.ps1` to try the default blank `directory=` setting. The uploaded first image was named `01(1).png`; it is named `01.png` inside this package so it matches the numeric filename rule.

## INI parameters

| Parameter | Default | Meaning |
| --- | --- | --- |
| `directory` | blank | Find PNG frames beside the selected `gifanim.ps1`. An explicit path selects a different folder. |
| `sequence` | `*.png` | Select numbered PNG files with or without one leading underscore. Leave `*.png` for mixed names such as `01.png`, `_02.png`; `0*.png` would exclude `_02.png`. |
| `output` | `01.gif` | GIF filename. A relative name is saved beside the selected PNG files. |
| `outputdirectory` | blank | Override the GIF destination directory; a relative path is interpreted from the PNG directory. When specified, it overrides any folder in `output`. The directory must exist. |
| `delay_cs` | `10` | Delay per frame in hundredths of a second, from 1 through 100. |

All PNG frames should have equal dimensions. The GIF color format supports at most 256 colors per frame. The output file is overwritten when it exists. A directory ending in a backslash is made safe for the Windows command line by appending `.` before it is quoted. Paths containing literal double quotes are unsupported.

The macro launches Windows PowerShell with `-NoProfile -ExecutionPolicy Bypass`; this setting applies only to the launched process. The package contains the complete PowerShell encoder script, without any third-party GIF program or DLL.

**Verification:** This environment does not have the Windows TSE SAL compiler or Windows PowerShell, so version `1.0.0.0.14` has not been compiled or run here. The prior PowerShell version was reported working by the user; this revision prompts for the filename selection before the INPUT directory.
