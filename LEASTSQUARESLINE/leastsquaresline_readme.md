# Least Squares Line

**Version:** 1.0.0.0.5  
**Date:** 2026-11-17  
**Environment:** TSE Pro 4.50.33 (Windows), Windows PowerShell 5.1, Windows Forms

## Purpose

Plot N user-supplied `(x,y)` observations and their ordinary least-squares straight line, `y = A*x + B`. The input points are shown in red, the fitted line in blue, and a predicted point for a user-supplied X value is shown in green.

All interactive input is done with TSE SAL `Ask()`. PowerShell performs the floating-point calculations and draws the graph.

## Package files

- `leastsquaresline.s` — TSE SAL front end with persistent `Ask()` history, INI persistence, and detached PowerShell launch.
- `leastsquaresline.ps1` — least-squares calculations, prediction calculation, and resizable XY graph.
- `leastsquaresline.ini` — default and last accepted values.
- `leastsquaresline_readme.md` — this documentation.

## Installation

Keep all files together. Compile:

```text
sc32 leastsquaresline.s
```

Then execute `leastsquaresline.mac` from TSE.

## Input

The SAL macro asks for:

1. `N`, the number of XY points.
2. The `(x,y)` point list.
3. The X value for which a Y value on the fitted least-squares line should be calculated.

The three prompts use separate persistent history lists: 231, 232, and 233.

The parser accepts point lists with spaces, commas, or no separator between successive pairs, for example:

```text
(1,2) (2,3) (3,5) (4,6)
(1,2),(2,3),(3,5),(4,6)
(1,2)(2,3)(3,5)(4,6)
```

The comma inside each `(x,y)` pair remains required.

## INI defaults

```ini
[parameters]
N=4
xypoints=(1,2) (2,3) (3,5) (4,6)
xpredictionvalue=8
```

After an accepted run, the macro writes the accepted values back to the INI file.

## Mathematics

For N points `(x_i,y_i)`:

```text
sumxsquared = sum(x_i^2)
sumx        = sum(x_i)
sumy        = sum(y_i)
sumxy       = sum(x_i*y_i)

D = N*sumxsquared - sumx^2
A = (N*sumxy - sumx*sumy) / D
B = (sumxsquared*sumy - sumx*sumxy) / D
```

The fitted line is:

```text
y = A*x + B
```

For the prediction input `xpredictionvalue`, PowerShell calculates:

```text
yPrediction = A*xpredictionvalue + B
```

For the default points `(1,2) (2,3) (3,5) (4,6)`, the fitted line is:

```text
y = 1.4*x + 0.5
```

Therefore, with `xpredictionvalue=8`:

```text
yPrediction = 11.7
```

## Graph

- Red circles: supplied XY points.
- Blue line: fitted least-squares line.
- Green circle: predicted point `(xpredictionvalue,yPrediction)`.
- The heading shows N, slope A, intercept B, sum of squared residuals, and the prediction.
- The graph automatically expands its X/Y ranges so the predicted point remains visible, even when it is an extrapolation beyond the supplied data.

## Launch behavior

The SAL macro uses Windows `cmd.exe /D /C start` to launch PowerShell independently. The TCC/console window can return immediately while the Windows Forms graph remains open. PowerShell itself is launched with `-WindowStyle Hidden`.

## Validation and limits

- `N` must be at least 2 and must equal the number of parsed XY pairs.
- Numbers use `.` as the decimal separator and may use scientific notation.
- The prediction X value must be numeric and finite.
- If all X coordinates are identical, a unique slope cannot be calculated.
- TSE SAL strings are limited to 255 characters, so the complete XY list and command line must fit within that limit.
- The graph requires Windows Forms and therefore Windows.

## Version history

### 1.0.0.0.5 — 2026-11-17

- Added `xpredictionvalue=8` to the INI defaults.
- Added a third TSE `Ask()` prompt with persistent history list 233.
- Calculates `yPrediction = A*xpredictionvalue + B`.
- Displays the prediction in the graph heading.
- Draws the predicted point in green and labels it.
- Automatically expands the graph range to include the prediction point.
- Preserves the detached PowerShell launch and flexible XY-pair separators from version 1.0.0.0.4.

### 1.0.0.0.4 — 2026-11-17

- Default data set changed to `N=4`, `xypoints=(1,2) (2,3) (3,5) (4,6)`.
- Successive XY pairs may be separated by spaces, commas, or nothing.
- Removed the PowerShell `Add-Type` warning.
- Detached PowerShell from the TCC console so the graph can remain open independently.
