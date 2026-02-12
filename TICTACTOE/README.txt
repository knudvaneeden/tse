===

1. -To install

     1. -Take the file tictactoe_knud.zip

     2. -And unzip it in any arbitrary directory

     3. -Then run the file zipinstalltictactoe.bat

     4. -That will create a new file tictactoe_knud.zip
         in that directory

     5. -Unzip that latest file in a new arbitrary directory

     6. -Then run the file

          tictactoe.mac

2. -The .ini file is the local file 'tictactoe.ini'
    (thus not using tse.ini)

===

/*

Author: Ross Boyd

===

A Tic Tac Toe game for TSE (just for fun)

Uses a recursive alphabeta minimax search algorithm.
The board is represented by 18 bits (stored in one 32bit integer).

The lower 0-8 bits are the X bits,
The upper 9-17 bits are the O bits

Win/loss/draw detection is accelerated by use of an encoded 62 byte bitmap
to quickly detect wins (and thus avoid iterating rows,cols and diagonals).
To see how this works look at IsWin() and Init()

*/
