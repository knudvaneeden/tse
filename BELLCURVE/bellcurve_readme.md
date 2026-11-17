# BELLCURVE 1.0.0.0.2

A standalone TSE SAL / Windows PowerShell normal-distribution (bell-curve) visualizer.

## Files

- `bellcurve.s` — TSE SAL macro; provides all user input through `Ask()`.
- `bellcurve.ps1` — performs floating-point calculations and opens the 2D graph.
- `bellcurve.ini` — default input parameters.
- `bellcurve_readme.md` — these instructions.

## Requirements

- TSE Pro 4.50 (target 4.50.33) and its `sc32` compiler.
- Windows 10/11 with Windows PowerShell 5.1 and .NET Windows Forms / System.Drawing.
- No Python, plotting modules, or third-party libraries required.

## Installation and use

1. Extract the ZIP into one directory and keep the `.s`, `.ini`, and `.ps1` files together.
2. You can start TSE from any working directory. The macro uses `CurrMacroFilename()` and `SplitPath()` to find the `.ini` and `.ps1` files beside the executing compiled `.mac` file. **Keep `bellcurve.mac` beside `bellcurve.ini` and `bellcurve.ps1`.**
3. Compile using `sc32 bellcurve.s` in the package directory, then run the `bellcurve` macro in TSE. If you copy the compiled `.mac` to another directory, copy its `.ps1` and `.ini` companions too.
4. Answer the two `Ask()` prompts: `N` and comma-separated floating-point data values.
5. The macro launches Windows PowerShell; the graph window remains open until closed. The macro returns to TSE after closure.

The `Ask()` prompts use separate named TSE histories via `GetFreeHistory()`, letting you recall previous values with the editor's normal history keys. Their persistence across editor sessions follows your TSE `PersistentHistory` configuration. The INI provides editable initial values (the history remains available).

## Default INI

```ini
[Parameters]
N=8
; Comma-separated floating-point values.
datapoints=2, 4, 4, 4, 5, 5, 7, 9
```

The number of values must match N exactly. Decimal points are supported (`2.5`), and a comma separates values. The implementation checks N and each numerical value before drawing.

## Mathematical definition

For observations x1 ... xN:

- Mean: `mu = sum(xi) / N`
- Sum of squared deviations: `SSD = sum((xi - mu)^2)`
- **Population variance:** `sigma^2 = SSD / N`
- **Population standard deviation:** `sigma = sqrt(sigma^2)`
- Normal probability density: `f(x) = exp(-(x-mu)^2 / (2*sigma^2)) / (sigma * sqrt(2*pi))`

For the default data: `mu = 5`, `SSD = 32`, `variance = 4`, `sigma = 2`.

## What the graph shows

- X: observed data values.
- Y: **probability density**, rather than raw frequency.
- Blue line: normal density curve using the dataset's population mean and standard deviation.
- Orange circles: individual observations placed at their X positions along the bottom, stacking vertically if values repeat. Their Y heights are only for separating markers and do not represent density.
- Dashed red line: mean.
- The graph resizes with the window.

The curve is a normal model fitted by its mean and population standard deviation; arbitrary datasets need not themselves follow a normal distribution. If all values are identical, sigma=0 and a finite normal-density curve is undefined; the program reports this rather than dividing by zero.

## Running PowerShell directly (optional)

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File .\bellcurve.ps1 -N 8 -Data "2, 4, 4, 4, 5, 5, 7, 9"
```

For normal use, enter all values from TSE `Ask()` instead.

## Version history

- **1.0.0.0.2 — 2026-11-18:** Fixed companion file resolution using `CurrMacroFilename()` instead of `CurrDir()`; works when the TSE working directory differs from the macro directory.
- **1.0.0.0.1 — 2026-11-18:** Initial TSE SAL launcher, persistent Ask history, INI parameters, PowerShell floating-point calculations, resizable 2D Windows Forms graph, and duplicate data point markers.
