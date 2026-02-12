===

1. -To install

     1. -Take the file blockhilite_knud.zip

     2. -And unzip it in any arbitrary directory

     3. -Then run the file zipinstallblockhilite.bat

     4. -That will create a new file blockhilite_knud.zip
         in that directory

     5. -Unzip that latest file in a new arbitrary directory

     6. -Then run the file

          blockhilite.mac

2. -The .ini file is the local file 'blockhilite.ini'
    (thus not using tse.ini)

===

/*
  Macro           BlockHilite
  Author          Carlo Hogeveen
  Website         eCarlo.nl/tse
  Compatibility   TSE 4.0 upwards
  Version         v1   20 Jul 2022

  This TSE extension syntax-hilites characters in a marked block with the same
  syntax-hilited foreground colors they would get without a marked block.

  Obviously this will not work for all normal, syntax hilited and blocked color
  combinations.

  My tip is to make your normal text and blocked text background colors both
  light or both dark, and similarly make your normal text and blocked text
  foreground colors are of contrasting colors of both of the background colors.
  And to make your syntax hiliting colors match the normal text's background
  colors.



  INSTALLATION

  Copy this file to TSE's "mac" folder and compile it there, for example by
  opening it there in TSE and applying the Macro -> Compile menu.

  Add the macro's name "BlockHilite" to TSE's Macro -> AutoLoad List menu,
  and restart TSE.
*/
