# GIFANIM for TSE SAL

Version **1.0.0.0.23** — 2026-09-28, Europe/Amsterdam.

Creates a looping GIF from numbered PNG frames, such as `01.png`, `02.png`, `03.png`. Frames are selected by the `sequence` wildcard and sorted by the number in their filename. One leading underscore is allowed, so `01.png`, `_02.png`, `_03.png` become frames 1, 2, 3. The only encoder is Windows PowerShell and .NET System.Drawing; no FFmpeg or custom DLL is needed.

## Install and run

1. Place `gifanim.s`, `gifanim.bat`, `gifanim.ps1`, `gifanim.ini`, `01.png`, and `02.png` together. Compile `gifanim.s` in that directory and keep the resulting `gifanim.mac` there. The macro locates its companion files beside its compiled `.mac` through `CurrMacroFilename()`, even when TSE's working directory is elsewhere.
2. Compile `gifanim.s` with `sc32 gifanim.s`, then execute that `gifanim.mac` in TSE.
3. Review or change the six values shown by `Ask()`: numbered PNG selection, INPUT directory for PNG files, GIF filename, GIF output directory, delay per frame in hundredths of a second (`100` means one second), and resize quality. Their initial values come from `gifanim.ini`.
4. TSE evaluates `CurrDir()` at run time and turns relative input and output directories into full paths. The macro writes these resolved paths and the other Ask() values to `gifanim_run.ini` beside the macro, then runs `gifanim.bat`. The current directory is not an INI setting. If PowerShell reports an error, TSE shows the error text in a `Warn()` box.

The package includes two example frames, `01.png` and `02.png` (both 960 × 516 pixels). Put them beside `gifanim.ps1` to try the default blank `directory=` setting. The uploaded first image was named `01(1).png`; it is named `01.png` inside this package so it matches the numeric filename rule.

## INI parameters

| Parameter | Default | Meaning |
| --- | --- | --- |
| `directory` | blank | Find PNG frames beside the selected `gifanim.ps1`. An explicit relative path is resolved from TSE's `CurrDir()`; absolute paths work as written. |
| `sequence` | `*.png` | Select numbered PNG files with or without one leading underscore. Leave `*.png` for mixed names such as `01.png`, `_02.png`; `0*.png` would exclude `_02.png`. |
| `output` | `01.gif` | GIF filename. A relative name is saved beside the selected PNG files. |
| `outputdirectory` | blank | Save beside the PNGs when blank. An explicit relative path is interpreted from TSE's `CurrDir()`; an absolute path works as written. When specified, it overrides any folder in `output`. The directory must exist. |
| `delay_cs` | `10` | Delay per frame in hundredths of a second, from 1 through 65535 (about 10 minutes 55 seconds). For example, `100` is one second and `500` is five seconds. |
| `quality` | `sharp` | Resizing method for frames whose dimensions differ: `sharp` keeps pixel and text edges crisp (nearest neighbor); `smooth` blends during scaling (bicubic); `fast` uses bilinear scaling. No scaling occurs for frames already matching the target size. |

The script makes two passes through the selected PNGs. First it finds the frame with the largest pixel area (width times height) and uses that frame's width and height for the GIF canvas; if frames tie, the first wins. Then it scales each frame, up or down as needed, to fit the canvas, centers it, and uses transparent margins where necessary. Source PNGs are never modified. `quality` changes only resizing; GIF remains limited to 256 colors per frame and the built-in System.Drawing GIF encoder does not expose a JPEG-like quality percentage. Thus it may not remove color speckling in a frame that needed no resizing. The output file is overwritten when it exists. Paths containing literal double quotes are unsupported.

The batch file launches Windows PowerShell with `-NoProfile -ExecutionPolicy Bypass`; this setting applies only to the launched process. The run INI holds the current choices; `gifanim.ini` remains the source of defaults. Do not run two GIFANIM jobs simultaneously from the same macro directory because they share `gifanim_run.ini`. The package contains the complete PowerShell encoder script, without any third-party GIF program or DLL.

**Verification:** This environment does not have the Windows TSE SAL compiler or Windows PowerShell, so version `1.0.0.0.23` has not been compiled or run here. PowerShell writes its error to an INI-formatted status file next to the macro, which SAL reads with `GetProfileStr()`.
