===

1. -To install

     1. -Take the file hidden_knud.zip

     2. -And unzip it in any arbitrary directory

     3. -Then run the file zipinstallhidden.bat

     4. -That will create a new file hidden_knud.zip
         in that directory

     5. -Unzip that latest file in a new arbitrary directory

     6. -Then run the file

          hidden.mac

2. -The .ini file is the local file 'hidden.ini'
    (thus not using tse.ini)

===

/*
  Macro          Hidden
  Author         Carlo Hogeveen
  Website        eCarlo.nl/tse
  Version        1.3.1   4 Mar 2022
  Compatibility  Windows TSE Pro v4.0 upwards,
                 Linux TSE (Tested with Linux TSE 4.42)


  When executed this tool shows a list of all buffers in memory
  those of files as well as hidden and system buffers.

  From the list you can select a buffer:
  - A normal buffer is just switched to.
  - A hidden or system buffer is made a copy of to a normal buffer,
    and then the copy is switched to.

  The advantage of this tool over TSE's own "buffers" macro is,
  that for system and hidden buffers the "buffers" macro switches you to the
  real buffer and makes it editable, which usually is a risk instead of a
  benefit, while the Hidden tool lets you safely view a copy of those buffers.


  INSTALLATION

  Copy this file to TSE's "mac" folder, open it there with TSE,
  and apply the Macro -> Compile menu.


  USAGE

  Just execute "Hidden" as a macro, either from the Macro -> Compile menu,
  or by adding it to the PotPourri menu and executing it from there.


  HISTORY

  v1.0 ~ 13 May 2011
    Initial version

  v1.1 ~ 26 Jun 2011
    Cosmetic improvements.

  v1.2 -  9 Aug 2020
    Translated its text parts to English, and first-time published it.

  v1.3 - 29 Aug 2020
    Added some missing buffer descriptions learned from Semware's "buffers"
    macro.
    Modernized and optimized the code.

  v1.3.1 - 4 Mar 2022
    Bug fixed: Now if you select a system or hidden buffer more than once,
    its copy-buffer is refreshed.

*/
