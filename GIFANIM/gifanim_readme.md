# GIFANIM for TSE SAL

Version **1.0.0.0.9** — 2026-09-27, 21:05 Europe/Amsterdam.

Creates a looping GIF from numbered PNG frames, such as `01.png`, `02.png`, `03.png`. Frames are selected by the `sequence` wildcard and sorted by the numeric filename. The only encoder is Windows PowerShell and .NET System.Drawing; no FFmpeg or custom DLL is needed.

## Install and run

1. Place `gifanim.s`, `gifanim.ps1`, and `gifanim.ini` together in a `GIFANIM` subdirectory of TSE's working directory, or beside the compiled `gifanim.mac`. TSE checks `GIFANIM` first, then beside the running macro using `CurrMacroFilename()`.
2. Compile `gifanim.s` with `sc32 gifanim.s`, then execute `gifanim.mac` in TSE.
3. Review or change the five values shown by `Ask()`: PNG directory, PNG filename selection, GIF filename, GIF output directory, and delay per frame. Their initial values come from `gifanim.ini`.
4. If no matching numbered PNGs are found, TSE shows a `Warn()` box. Other encoding failures also produce a warning. Inspect the GIF at the path printed by PowerShell.

The package includes two example frames, `01.png` and `02.png` (both 960 × 516 pixels). Put them beside `gifanim.ps1` to try the default blank `directory=` setting. The uploaded first image was named `01(1).png`; it is named `01.png` inside this package so it matches the numeric filename rule.

## INI parameters

| Parameter | Default | Meaning |
| --- | --- | --- |
| `directory` | blank | Find PNG frames beside the selected `gifanim.ps1`. An explicit path selects a different folder. |
| `sequence` | `*.png` | Select numerically named PNG files. For example, `0*.png` selects `01.png`, `02.png`, etc. |
| `output` | `01.gif` | GIF filename. A relative name is saved beside the selected PNG files. |
| `outputdirectory` | blank | Override the GIF destination directory; a relative path is interpreted from the PNG directory. When specified, it overrides any folder in `output`. The directory must exist. |
| `delay_cs` | `10` | Delay per frame in hundredths of a second, from 1 through 100. |

All PNG frames should have equal dimensions. The GIF color format supports at most 256 colors per frame. The output file is overwritten when it exists. Paths containing literal double quotes are unsupported.

The macro launches Windows PowerShell with `-NoProfile -ExecutionPolicy Bypass`; this setting applies only to the launched process. The package contains the complete PowerShell encoder script, without any third-party GIF program or DLL.

**Verification:** This environment does not have the Windows TSE SAL compiler or Windows PowerShell, so version `1.0.0.0.9` has not been compiled or run here. The prior PowerShell version was reported working by the user; this revision adds a TSE warning for an empty matching PNG sequence.
