# INVERSEMATRIXCIRCLE 1.0.0.0.2

Interactive visual proof that applying the inverse matrix to a transformed vector gives the original vector back.

## Contents

- `inversematrixcircle.s` — TSE SAL launcher; all prompts use `Ask()` with independent persistent TSE history IDs (71–76).
- `inversematrixcircle.ps1` — Windows PowerShell / Windows Forms 2D XY graph and interactive keyboard controls.
- `inversematrixcircle.ini` — default and last-entered parameters.
- `inversematrixcircle_readme.md` — instructions.

## Requirements

- TSE Pro 4.50.33 or compatible TSE SAL, `sc32.exe` compiler.
- Microsoft Windows and Windows PowerShell 5.1 with WinForms and System.Drawing.
- No third-party PowerShell modules.

## Installation and running

1. Extract all four files **together in the same directory**, preferably a normal TSE macro directory.
2. Compile `inversematrixcircle.s` with `sc32 inversematrixcircle.s`.
3. From the TSE editor run macro `inversematrixcircle` (or its compiled `.mac`).
4. Answer the six TSE `Ask()` prompts: length R, `a11`, `a12`, `a21`, `a22`, and angular step in degrees.
5. PowerShell opens a separate keyboard-controlled plot window. The SAL launcher does not change the editor's current directory.

The `Ask()` fields are prefilled from the INI and use the standard native TSE persistent Ask history, with a separate history ID for each parameter. On acceptance the values are written to the INI. All values are checked for valid finite numbers by PowerShell. `R > 0`, `0 < step <= 360`.

## Default INI

```ini
[InverseMatrixCircle]
R=1
a11=3
a12=1
a21=1
a22=1
step=5
```

The defaults define `A = [[3,1],[1,1]]`, with determinant `3*1 - 1*1 = 2`. Inverse `A^-1 = (1/2) * [[1,-1],[-1,3]]`.

## Keyboard navigation

- **LEFT**, **SPACE**, **ENTER**: advance from stage 1 to 2 to 3, then advance the angle by `step` degrees and return to stage 1.
- **RIGHT**, **BACKSPACE**: go to the previous stage; from stage 1, move back an angular step to stage 3.
- **HOME**: restart at angle 0 degrees, stage 1.
- **ESC**: close the graph.

Angles run from 0 to 360 degrees. If 360 is not an exact multiple of `step`, the last angle is capped at 360. The next forward step wraps to 0. The axis scale remains fixed as the vectors rotate.

## Three stages at each angle

1. **Blue**: original vector `v=(R*cos(theta),R*sin(theta))`.
2. **Red**: transformed vector `Av=(a11*x0+a12*y0,a21*x0+a22*y0)`; the blue arrow stays visible.
3. **Green dashed**: inverse-transformed vector `A^-1(Av)`, alongside both previous arrows. Because it coincides with the original blue arrow, the green arrow is drawn wider and behind the blue arrow, providing an overlapping green dashed outline. All three coordinate pairs and the numerical recovery error are shown.

For a matrix `A=[[a11,a12],[a21,a22]]` with `d=a11*a22-a12*a21`,

```
x2 = ( a22*x1 - a12*y1 ) / d
 y2 = (-a21*x1 + a11*y1 ) / d
```

The graph displays `A^-1`, `det(A)` and the numerical recovery error `sqrt((x2-x0)^2+(y2-y0)^2)`.

## Special cases and limits

A determinant of zero means there is no inverse: the PowerShell program shows an error dialog rather than a misleading recovered vector. Very nearly singular matrices are also rejected using a relative tolerance because floating-point inversion may be unreliable. Extreme values unable to fit in the graph are rejected. Dot and comma decimal formats are accepted; negative matrix entries are permitted.

The graphics are implemented using Windows Forms, not external plotting libraries. Run from a Windows TSE installation. All file names are lowercase.

## Version history

- **1.0.0.0.1 — 2026-11-17**: first release, derived from EIGENVECTORCIRCLE 1.0.0.0.2; three-stage graph and inverse recovery, singular-matrix check, SAL history, persistent INI.
