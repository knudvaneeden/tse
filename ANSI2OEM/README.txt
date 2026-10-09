===

1. -To install

     1. -Take the file ansi2oem_knud.zip

     2. -And unzip it in any arbitrary directory

     3. -Then run the file zipinstallansi2oem.bat

     4. -That will create a new file ansi2oem_knud.zip
         in that directory

     5. -Unzip that latest file in a new arbitrary directory

     6. -Then run the file

          ansi2oem.mac

2. -The .ini file is the local file 'ansi2oem.ini'
    (thus not using tse.ini)

===

 /*
   Macro          Ansi2oem
   Author         Carlo.Hogeveen@xs4all.nl
   Date           10 Februari 2004
   Version 2      9 March 2004
   Version 3      21 JUne 2004
   Compatibility  GUI versions of TSE Pro 4.0 upwards.

   Documentation:
      See the help in the source below, or press F1 after executing the macro.

   Installation:
      This macro only works for the GUI versions of TSE (g32.exe).
      Copy the source file to TSE's "mac" directory, compile it,
      and run it to configure it.

      (Configuring it automatically adds it to or removes it from
       the Macro AutoloadList.)

   History
      Version 1, 10 Februari 2004.
         Initial version.
      Version 2, 9 March 2004.
         Remember and return to last character.
      Version 3, 21 June 2004.
         Minute improvements in the help text.
*/

/*

(06-21-2004) Ansi2oem for GUI versions of TSE Pro. In editing text it
can show ANSI characters as OEM, and line drawing characters in 3D. It
can do this  very configurably. With ANSI fonts get rid of those
control characters all looking like squares, and get line drawing(s)
back! At the same time it serves as an ascii chart which correctly
shows each character's look. Version 3 remembers the last character and
has minute improvements to the help text. Author:
Carlo.Hogeveen@xs4all.nl.

*/
