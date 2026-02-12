===

1. -To install

     1. -Take the file prettse_knud.zip

     2. -And unzip it in any arbitrary directory

     3. -Then run the file zipinstallprettse.bat

     4. -That will create a new file prettse_knud.zip
         in that directory

     5. -Unzip that latest file in a new arbitrary directory

     6. -Then run the file

          prettse.mac

2. -The .ini file is the local file 'prettse.ini'
    (thus not using tse.ini)

===

 //
 // Use case = Pretty print for TSE SAL. It is a special case of refactoring, because you change the source code, but not the functionality of that source code.
 //
 // ===
 //
 // ===
 //
 // Method =
 //
 // Idea
 //
 // The basic idea for pretty print would be that:
 //  1. If you find a begin word you move it to the left
 //  2. If you find a corresponding end word you move it to the right
 //  3. else you do nothing
 //
 // In practice you have a space counting variable that you
 // systematically decrease or increase depending on the words found
 //
 //  ---
 //
 //  How to use?
 //
 //  Steps:
 //
 //  1. Load this file in your TSE editor
 //  2. Compile this file (e.g. via <CTRL><F9>)
 //  3. Goto the other file you want to pretty print
 //  4. In this other file highlight a block of TSE code you want to pretty print
 //
 // ===
 //
 // Example:
 //
 // Input:
 //
 /*
--- cut here: begin --------------------------------------------------
FOR T = 1 TO 4
WHILE
This is a test
ENDWHILE
ENDFOR
--- cut here: end ----------------------------------------------------
 */
 //
 // Output:
 //
 /*
--- cut here: begin --------------------------------------------------
FOR T = 1 TO 4
 WHILE
  This is a test
 ENDWHILE
ENDFOR
--- cut here: end ----------------------------------------------------
 */
 //
 // Todo:
 //
 //  [kn, ri, sa, 20-08-2022 11:59:57]
 //  -Add a boolean yes/no to add 'PROC' or 'FN' in front of function or procedure name definitions. [kn, ri, fr, 19-08-2022 16:15:43]
 //  -Thus check if this can be isolated in the source code. [kn, ri, fr, 19-08-2022 16:15:45]
