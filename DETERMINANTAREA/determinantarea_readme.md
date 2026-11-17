# DETERMINANTAREA

Version **1.0.0.0.1** — 2026-11-17

A TSE SAL + Windows PowerShell visual demonstration that the absolute determinant of a 2x2 matrix is the area of the parallelogram obtained by transforming the unit square. The **sign** of the determinant tells whether orientation is preserved or reversed.

## Contents

- `determinantarea.s` — TSE SAL launcher; all user input uses four `Ask()` dialogs.
- `determinantarea.ps1` — Windows Forms XY plot and step-by-step visualization.
- `determinantarea.ini` — default matrix, last selections and display settings.
- `determinantarea_readme.md` — instructions.

## Setup and run

1. Unzip all four files into the same directory, preferably your TSE macro directory. Do not separate the PowerShell and INI files from the compiled macro.
2. Compile `determinantarea.s` with your TSE `sc32` compiler, e.g. `sc32 determinantarea.s`.
3. Run the macro from TSE: `determinantarea` (or `ExecMacro("determinantarea")`).
4. Supply `a11`, `a12`, `a21`, `a22` in four TSE `Ask()` dialogs. `Esc` cancels. Use decimal **points** (e.g. `-1.5`).
5. The macro writes your selections to `[LastUsed]` in `determinantarea.ini` and launches `powershell.exe` to render the XY diagram.

The `.ini` file is located **beside the compiled `.mac` file** by using `CurrMacroFilename()`; it need not be in TSE's current working directory. Windows PowerShell 5.1+ with Windows Forms is required. The command invokes PowerShell with `-ExecutionPolicy Bypass` for that process only, without changing the system policy.

## Default matrix

```text
A = [ 3  1 ]
    [ 1  2 ]

u = A(1,0) = (3,1)
v = A(0,1) = (1,2)
u+v = (4,3)
det(A) = 3*2 - 1*1 = 5
area = |det(A)| = 5 square units
```

## The four edges (shown sequentially in different colors)

1. Blue: `(0,0)` to `(a11,a21)` — transformed horizontal unit vector.
2. Orange: `(0,0)` to `(a12,a22)` — transformed vertical unit vector.
3. Purple: `(a11,a21)` to `(a11+a12,a21+a22)` — translated vertical edge.
4. Green: `(a12,a22)` to `(a11+a12,a21+a22)` — translated horizontal edge.

The original unit square is shown as a gray dashed outline for comparison. The completed parallelogram is shaded. The XY axes retain equal scales, so the apparent area matches the mathematical area. Negative determinant indicates reversed orientation; zero determinant collapses the parallelogram to a line or point.

## Controls in PowerShell graph

- `Right` or `Space`: advance one edge.
- `Left`: go back one edge.
- `Home`: show no transformed edges.
- `End`: show all four edges and shade area.
- `O`: toggle original unit square.
- `L`: toggle labels.
- `Escape`: close the graph.
- Resize the graph window to zoom to the available viewport automatically.

The graph initially opens with all four edges visible; press `Home` to step through the transformation from the start.

## Persistent TSE Ask() history

Every entry (`a11`, `a12`, `a21`, `a22`) uses a **separate named** TSE history (`GetFreeHistory`). The most recently accepted value is displayed as the next prompt's initial value; older values are available using the normal TSE Ask history keys (Up/Down). Accepted entries are promoted to the newest position, removing duplicates in that list. The `[Matrix]` INI defaults seed prompts only when their own TSE history is empty; they never change automatically. `PersistentHistory = On` must be enabled in TSE configuration for histories to survive editor restarts.

## INI

- `[Matrix]`: default `a11=3`, `a12=1`, `a21=1`, `a22=2`.
- `[LastUsed]`: four selected matrix values, written by TSE after prompts finish and read by PowerShell.
- `[Display]`: `Title`, `Width`, `Height` for initial chart window.

## Notes

- This is a visualization tool, not a general purpose numerical solver.
- The graph uses Windows Forms and `System.Drawing`; no Python or plotting-library installation is needed.
- Very large or invalid numeric values cause a visible error.
- The source code has been prepared for TSE SAL 4.50.x; verify with your local `sc32` before use.
