# NEWCOLOR

Version: **1.0.0.0.0**  
Prepared: **2026-09-24 22:42 UTC**  
Documentation and companion macro: **GPT-6**

## Description

NEWCOLOR is Tom Bowden's public-domain collection of syntax-color template files for Ian Campbell's **Colors** macro, originally supplied with The SemWare Editor 2.00. The `.TSE` files define highlighting rules; they are not SAL source files and cannot be compiled with `sc32`. The original `NEWCOLOR.TXT` remains in this package with the author's detailed per-template color descriptions.

Templates: CIM (CompuServe Information Manager), EZT (CA-EASYTRIEVE), INI, MAK (Borland makefiles), MDF (Automenu), NAV (NavCIS), PPS (PCBoard PPL), PRO (Prolog), QM (Qmodem), REX (REXX), SCR (OzCIS), TAP (TapCIS), and WBT (WinBatch).

## Install and run

1. Extract the archive and read `NEWCOLOR.TXT`. Back up any existing color template before replacing it.
2. Install and configure the compatible TSE **Colors** macro separately; it is **not included** here. Place the selected `.TSE` template where that macro expects its templates, following its own instructions.
3. For CIM, NAV, QM, or TAP scripts, copy the chosen template under the name `SCRCOLOR.TSE`. The archive already contains an OzCIS `SCRCOLOR.TSE`, so keep the original or give each alternative a separate folder. Only one can occupy that filename in one folder.
4. Open a supported file in TSE and invoke the **Colors** macro according to its own instructions. If the extension is not recognized, configure that macro's group-to-extension mapping. The original notes give an example for REXX (`.rex`, `.r`, `.cmd`, `.exc`) in `colors.s`.

These templates were written for TSE 2.00. Compatibility with current TSE 4.50 and newer versions of the Colors macro has not been verified.

## Optional informational companion

`newcolor.s` is a newly added SAL macro that explains the package when run. It does not install templates or start Colors. Compile it using `sc32 newcolor.s`, then run `newcolor.mac` from TSE. Put `newcolor.ini` in TSE's current working directory when running the companion. Its `[newcolor]` `silent=false` setting displays the informational `Warn()` box; `silent=true` suppresses it. If the INI is absent, the macro defaults to displaying the box. The INI controls only the companion macro.

## Original material

The 14 original `.TSE` files, `NEWCOLOR.TXT`, and `FILE_ID.DIZ` are preserved from the supplied archive. Their public-domain statement appears in `NEWCOLOR.TXT`.
