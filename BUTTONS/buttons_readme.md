# BUTTONS for TSE Pro

**README version:** 1.0.0.0.0  
**Original macro package:** BUTTONS, dated 28 August 2001  
**Original author:** Dieter Koessl

## Description

BUTTONS is a pair of TSE SAL macros that add mouse-operated controls to the TSE Pro interface:

- **XBTN (`xbtn.s`)** displays an `X` button in the upper-right corner. Clicking it runs the `QUICKXIT` macro to close TSE. If files have unsaved changes, QUICKXIT can ask what to do with them before exiting.
- **SBTN (`sbtn.s`)** displays an `S` button in the lower-right corner. It can resize the TSE window by dragging, and it provides commands to minimize, maximize, and restore the window.

The original documentation states that XBTN supports TSE Pro/32 3.0, with partial support for versions 2.6 and 2.8. SBTN is specifically documented as working only with TSE Pro/32 3.0. Because these macros use old TSE and Windows console behavior, they may need changes for newer TSE releases or modern Windows versions.

## Package contents

| File | Purpose |
|---|---|
| `xbtn.s` | Source for the upper-right exit button |
| `sbtn.s` | Source for the lower-right size button |
| `buttons.doc` | Original plain-text documentation |
| `file_id.diz` | Short archive description |

## Requirements

- TSE Pro/32, with TSE Pro/32 3.0 being the intended version.
- The TSE SAL compiler `SC32`.
- Mouse support enabled in TSE.
- Microsoft Windows; SBTN calls functions in `user32.dll`.
- The `QUICKXIT` macro must be installed and available for XBTN.

## Installation and compilation

1. Extract `buttons.zip`.
2. Copy `xbtn.s` and `sbtn.s` to your TSE macro/source directory, or work from the extracted directory.
3. Open a command prompt in that directory.
4. Compile the desired macros:

   ```text
   sc32 xbtn.s
   sc32 sbtn.s
   ```

5. Start TSE.
6. Open the **Macro** menu and select **Autoload List**.
7. Press **Insert**, enter `XBTN`, and press **Enter**.
8. If you also want the sizing button, repeat the preceding step for `SBTN`.
9. Press **Enter** to save the autoload list.
10. Restart TSE so the macros are loaded automatically.

You may install either macro independently. If XBTN is installed, verify that `QUICKXIT` is also available.

## How to run and use it

There is no separate command to start the buttons after installation. TSE loads the macros from its autoload list when the editor starts.

### XBTN: exit button

1. Look for the yellow `X` on a red background in the upper-right corner of the TSE window.
2. Click the `X` with the left mouse button.
3. XBTN invokes `QUICKXIT`. If files have been modified, follow its prompt to save, abandon, or otherwise handle them.

### SBTN: resize button

1. Look for the yellow `S` on a red background in the lower-right corner.
2. Press and hold the left mouse button on `S`.
3. Drag the mouse. A small status box displays the proposed number of columns and rows.
4. Release the mouse button to resize TSE so its lower-right corner follows the mouse position.
5. To cancel before releasing the mouse button, press **Escape** while continuing to hold the mouse button.

The minimum size used by the macro is 16 columns by 5 rows.

### Minimize, maximize, and restore

- Right-click the `S` button, or press **Alt+-**, to open the size menu.
- Select **Minimize** to reduce TSE to 16 columns by 5 rows.
- Select **Maximize** to expand TSE to the maximum rows and columns available.
- After minimizing or maximizing, right-click `S` or press **Alt+-** again to restore the previous size and position.

## Customization

Edit the constants near the beginning of the source files and recompile the affected macro:

- In `xbtn.s`, change `XNormalColor` and `XClickedColor` to customize the exit button.
- In `sbtn.s`, change `ButtonColor` to customize the size button.
- In `sbtn.s`, change `MENU_KEY` if **Alt+-** conflicts with another key assignment.

After changing a source file, compile it again with `sc32` and restart TSE.

## Uninstallation

1. In TSE, open **Macro > Autoload List**.
2. Select `XBTN` and press **Delete**.
3. Select `SBTN` and press **Delete** if it is installed.
4. Press **Enter** to save the updated list.
5. Restart TSE.
6. Optionally delete the BUTTONS source and compiled macro files from the macro directory.

## Troubleshooting

### The X button appears, but clicking it fails

XBTN executes `QUICKXIT`. Install or compile the QUICKXIT macro and ensure TSE can find it.

### A button does not appear

- Confirm that its macro name is present in TSE's autoload list.
- Confirm that the macro compiled successfully.
- Restart TSE after changing the autoload list.
- Check whether the installed TSE version supports the hooks and commands used by these old macros.

### SBTN does not resize correctly

SBTN was written for TSE Pro/32 3.0 and the Windows console implementation available in 2001. Modern Windows console hosts may calculate character-cell or toolbar sizes differently.

On Windows 9x, the original documentation recommends selecting a fixed console font rather than `AUTO`, because automatic font sizing can change the font while the window is being reduced.

### Alt+- does not open the SBTN menu

Another macro or key assignment may already use that key. Change the `MENU_KEY` constant in `sbtn.s`, then recompile and restart TSE.

## Version history

| README version | Date | Changes |
|---|---|---|
| 1.0.0.0.0 | 2026-08-31 | Initial Markdown description, installation instructions, usage help, customization notes, and troubleshooting guidance for the original BUTTONS package. |

Future README revisions can continue as `1.0.0.0.1`, `1.0.0.0.2`, and so on.

## Original license and disclaimer

The original author donated the programs to the public domain and allowed their use and modification. The original package also states that the programs are used at the user's own risk.
