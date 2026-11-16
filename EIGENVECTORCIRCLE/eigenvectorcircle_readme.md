# EIGENVECTORCIRCLE

**Version:** 1.0.0.0.2 (2026-11-16)  
**Platform:** TSE Pro 4.50.x for Microsoft Windows, plus Windows PowerShell 5.1 and .NET Windows Forms.

## Purpose

Visualize what a real 2-by-2 matrix does to each direction of a vector as that input vector rotates through a complete circle. At each angle, the display contains exactly **two vector arrows** sharing the origin:

- **Blue:** original vector `v = (R cos(theta), R sin(theta))`.
- **Red:** matrix-transformed vector `Av`.

The Cartesian axes and a light grid are shown for orientation. The arrows are replaced at every keypress rather than leaving a trail.

The coordinates are:

```text
x0 = R * cos(theta)
y0 = R * sin(theta)

|x1|   |a11 a12| |x0|
|y1| = |a21 a22| |y0|

x1 = a11*x0 + a12*y0
y1 = a21*x0 + a22*y0

theta = angle_degrees * PI / 180
```

An **eigenvector direction** occurs when `Av` is parallel or antiparallel to `v`, or `Av=0`. The eigenvalue is the scale factor along that direction (negative means the arrow reverses). The plot also reports the real eigenvalues algebraically when they exist. Some real matrices have complex eigenvalues, and thus no real eigenvector directions.

## Package contents

```text
eigenvectorcircle.s          TSE SAL launcher; all interactive input via Ask()
eigenvectorcircle.ps1        Windows PowerShell WinForms visualization
eigenvectorcircle.ini        Configuration and initial values
eigenvectorcircle_readme.md This document
```

## Installation

1. Extract all four files **into the same folder**. Keep the files beside the compiled macro `eigenvectorcircle.mac`, too.
2. In TSE for Windows, compile `eigenvectorcircle.s` with `sc32 eigenvectorcircle.s`, or compile inside TSE.
3. Run the compiled macro, for example via TSE's *Execute Macro* command.
4. Answer the six TSE `Ask()` prompts (R, four matrix entries, and angular step). Press **Escape** on any prompt to cancel before launching PowerShell.
5. A separate Windows Forms graph opens. Press **Left Arrow**, **Space**, or **Enter** to increase the angle; press **Right Arrow** to decrease it.

No interactive prompts are presented by PowerShell itself; numeric errors are shown only in an error message box. The SAL macro starts `powershell.exe` without changing TSE's working directory.

## Configuration

The initial INI file is:

```ini
[EigenvectorCircle]
R=1
a11=2
a12=1
a21=1
a22=2
StepDegrees=5
```

`StepDegrees` determines the angular increment. The initial default is `5`, visiting 0, 5, 10, ..., 360 degrees. A non-divisor such as `7` ends on 360 degrees, not 364 degrees. Values must be greater than 0 and at most 360. The step is requested in its own TSE `Ask()` dialog (history 76); its default is loaded from the INI and the answer is saved back to the INI.

The six numerical entries initialize the six TSE Ask prompts. Accepted values include negatives and decimals (e.g. `-0.5`, `2.5`). Both comma and dot decimal separators are accepted by PowerShell. TSE saves the six newly supplied inputs back to the INI after all prompts complete. In addition, each Ask prompt uses its own **dedicated TSE history list** (numbers 71 through 76), compatible with TSE's `PersistentHistory` facility when enabled in editor settings.

**Important:** INI values are read with TSE `GetProfileStr` from a file in the *compiled macro directory*, not the current edited file's directory. `eigenvectorcircle.ps1` must be in that same directory. The program does not require a fixed installation drive.

## Controls

| Key | Effect |
|---|---|
| Left Arrow, Space, Enter | Increase angle by one step |
| Right Arrow, Backspace | Decrease angle by one step |
| Home | Go to 0 degrees |
| Escape | Close graph |

The display wraps from 360 degrees back to 0 degrees. The input radius and graph scale stay constant throughout the animation so geometric changes are visually comparable between steps. The scale is chosen to fit the input circle and the matrix image, using a conservative bound.

## Default eigenvalue example

For the supplied default matrix:

```text
A = [2 1]
    [1 2]
```

Eigenvector directions and factors are:

- Along `(1, 1)` (45 degrees): eigenvalue **3**. The red arrow has triple the blue arrow's length, in the same direction.
- Along `(1, -1)` (315 degrees): eigenvalue **1**. The red and blue arrows coincide.

**Note:** The default `StepDegrees=5` visits the 45-degree and 315-degree eigenvector directions exactly.

## Running PowerShell directly (diagnostics only)

Normal operation is through TSE. For direct diagnosis from Windows PowerShell or `cmd.exe`:

```powershell
powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -File ".\eigenvectorcircle.ps1" -Radius 1 -A11 2 -A12 1 -A21 1 -A22 2 -StepDegrees 5
```

The program is designed for **Windows** PowerShell with Windows Forms; PowerShell 7/Linux without Windows Forms is not supported.

## Version history

- **1.0.0.0.2, 2026-11-16:** Left Arrow increases the angle, Right Arrow decreases it; new TSE Ask() for step size with persistent history and INI default of 5 degrees.
- **1.0.0.0.1, 2026-11-16:** Initial stepwise circular-vector/matrix visualization, TSE SAL Ask() front-end, INI persistence, eigenvalue commentary, and Windows Forms graph.

## Testing status

The source files have been packaged and reviewed. The actual graphical execution and TSE 4.50.33 SAL compilation have **not** been run in the authoring environment and should be verified on the target Windows/TSE machine.
