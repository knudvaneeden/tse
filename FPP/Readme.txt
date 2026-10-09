****************************************************************************
This software is provided "as is" without express or implied warranty.
****************************************************************************

FppPack_1_04 portable custom release

Portable custom revision: Aug 2026
- Support-file lookup is based on CurrMacroFilename(), not LoadDir().
- GetFileVersion.mac is executed by its full macro-relative pathname.
- BO_Helper.dll and the Microsoft-built FppCon executables are included in
  the mac directory so that directory can be copied and used as one unit.

This update contains all previously released macro updates plus some unpublished
updates of the macros and exe files.

--------------------------------------------------------------------------------
Included in FppPack_1_03 are the following version of the files:

File:              Version:
FppCon_x64.exe     2.4.3.26
FppCon_x86.exe     2.4.3.26
BO_Helper.dll      1.9.1.29

BO_Helper.inc      1.0.0.8
FPPError.h         1.0.0.1
FppHelp.txt        20260423
FppShell.s         1.1.32.99
FppSum.s           1.0.0.84
FppSumLine.s       1.0.0.82
GetFileVersion.s   1.0.0.1

--------------------------------------------------------------------------------
Changes since FppPack_1_02_2, files not listed remained unchanged:

FppCon_x64.exe
FppCon_x86.exe
==============
- Added evc command.
  evc is identical to ev, except that it uses coloring to display the result.
**Coloring may not work with every command-line tool and every Windows version**
  To change the default colors see FppHelp.txt, section 'Using FppCon.ini' for
  details.

BO_Helper.dll
=============
- Added GetOsVersionString()

FppHelp.txt
===========
 -Updated to cover the latest enhancements.

FppShell.s
==========
- Improved handling of very very rare cases
- Minor fixes and improvements

FppSum.s
========
- Improved handling of very very rare cases
- Minor fixes and improvements

FppSumLine.s
============
- Improved handling of very very rare cases
- Minor fixes and improvements

BO_Helper.inc
=============
- Added call GetOsVersionString()

--------------------------------------------------------------------------------
Info:
All the macros and dll/exe files were tested with TSE V4.50.22 gui and console
version running on Windows 11 PRO. They all should work with older Windows
versions but not before Windows 7. They also work with older TSE versions.
Sorry, but I'm unable to test it with other Windows versions than 11, because I
don't have any of them any more.

--------------------------------------------------------------------------------
Structure include in the zip:

TSEPro
 |
 +- I_MS           -> Contains the necessary exe-files compiled using
 |   |                Visual Studio 2022 and Microsoft compiler.
 |   |                These should work on allmost any machine but are the slowest.
 |   |
 |   +- FppCon_x64.exe -> Is used on 64-bit systems
 |   +- FppCon_x86.exe -> Is used on 32-bit systems
 |
 +- II_INTEL       -> Contains the necessary exe-files compiled using
 |   |                Visual Studio 2022 and Intel compiler.
 |   |                These may not work on every machine but run much faster.
 |   |
 |   +- FppCon_x64.exe -> Is used on 64-bit systems
 |   +- FppCon_x86.exe -> Is used on 32-bit systems
 |
 +- mac            -> contains all the necessary TSE-macros and include files
 |   |
 |   +- BO_Helper.inc    -> Include (Header DLL-Calls to BO_Helper.dll)
 |   +- FPPError.h       -> Include (Error-codes)
 |   +- FppHelp.txt      -> The help for using FppXXX-macros
 |   +- FppShell.s       -> The source of the shell macro
 |   +- FppSum.s         -> The source of the sum macro
 |   +- FppSumLine.s     -> The source of the linesum macro
 |   +- GetFileVersion.s -> The source of the helper-function macro
 |
 +- BO_Helper.dll -> Provides supporting routines for Fpp*.mac
 +- Readme.txt    -> This file

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!                                                                            !!
!! PORTABLE CUSTOM VERSION:                                                   !!
!!                                                                            !!
!! The macros find the exe and dll files in the same directory as the macro  !!
!! source/compiled macro, independently of the g32.exe/e32.exe directory and !!
!! independently of the current working directory.                           !!
!!                                                                            !!
!! If you don't want it this way please change the macros to your liking and  !!
!! create a custom version that suits your personal environment.              !!
!!                                                                            !!
!! If none of the above is an option, don't use any of it. Sorry, I apologize !!
!! for not meeting your expectations and wasting your time.                   !!
!!                                                                            !!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--------------------------------------------------------------------------------
Steps to install:
- For updaters, please make a backup of the current exe and macro files, just in
  case...

- Unzip the FppPack_1_03.zip to a temporary directory

- Keep the following 3 files in the same directory as the macro files.
  Choose which exe-files you want to use from the above directory-tree. You
  should probably start with the files in the I_MS directory. They can
  be changed later if everything is working by simply replacing them with the
  ones from II_INTEL directory.

  -BO_Helper.dll

  -FppCon_x64.exe
  -FppCon_x86.exe

- Copy the complete mac directory to any desired TSE SAL working directory
  and compile the following macros there:

  -GetFileVersion.s (compile this one first)
  -FppShell.s
  -FppSum.s
  -FppSumLine.s

  Keep the resulting GetFileVersion.mac in this same directory. The three
  Fpp macros execute it by its full pathname, so the directory does not need
  to be present in TSE's configured macro search path.

When everything is in place and compiled you should try to run the
FppShell-macro first. Because if this works the other macros will also work.
Start the FppShell using Menue->Macro->Execute and type FppShell press enter.
You should see a display similiar to this:

+--------------------------------- FppShell --------------------------------+
| -+  2:                                                                    |
| -+  8:                                                                    |
| -+ 16:                                                                    |
|---------------------------------------------------------------------------|
|   Values: 64-Bitxxxxxxxx                 32-Bitxxxx      16-Bitxx  8-Bitx |
| Unsigned:                                                                 |
|   Signed:                                                                 |
|      Hex:                                                                 |
|---------------------------------------------------------------------------|
| IEEE    Hex                              Decimal                          |
| Single:                                                                   |
|    Bin:                                                                   |
| Double:                                                                   |
|    Bin:                                                                   |
|---------------------------------------------------------------------------|
| Result-G:                                                                 |
|----------                                                                 |
| Enter Expression:                                                         |
|                                                                           |
|                                                                           |
|                                                                           |
+-CR-Parse @F-Func @V-Var @T-Con @L-Lst @P-Paste @S-Sf @I-Ig @O-Opt F1-Help-+


To test if everything works: Type 1 <Enter>

Your display should look similiar to this:

+--------------------------------- FppShell --------------------------------+
| -+  2: 0000000000000000000000000000000000000000000000000000000000000001   |
| -+  8: 0000000000000000000001                                             |
| -+ 16: 0000000000000001                                                   |
|---------------------------------------------------------------------------|
|   Values: 64-Bitxxxxxxxx                 32-Bitxxxx      16-Bitxx  8-Bitx |
| Unsigned: 1                              1               1         1      |
|   Signed: 1                              1               1         1      |
|      Hex: 0000000000000001               00000001        0001      01     |
|---------------------------------------------------------------------------|
| IEEE    Hex                              Decimal                          |
| Single: 3F800000                         1                                |
|    Bin: 00111111100000000000000000000000                                  |
| Double: 3FF0000000000000                 1                                |
|    Bin: 0011111111110000000000000000000000000000000000000000000000000000  |
|---------------------------------------------------------------------------|
| Result-G: 1                                                               |
|----------                                                                 |
| Enter Expression:                                                         |
|1                                                                          |
|                                                                           |
|                                                                           |
+-CR-Parse @F-Func @V-Var @T-Con @L-Lst @P-Paste @S-Sf @I-Ig @O-Opt F1-Help-+


--------------------------------------------------------------------------------
Info:
Non of the macros has a fixed key-assignment. So you always have to start them
using Menue->Macro->Execute and type FppShell or FppSum or FppSumLine and press
<enter>. If you plan to use them frequently you may add them to your ui-file for
example by adding the following lines.

<CtrlAlt I>  ExecMacro("FppShell")
<CtrlAlt S>  ExecMacro("FppSum")
<CtrlAlt L>  ExecMacro("FppSumLine")

