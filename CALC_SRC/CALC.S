/*
   RPN calculator begun: Saturday, 6 March 1993
           Last Revised: Monday, 9 August 1993

Functions to Implement:

[x] Enter
[X] UpdateRegs - update display to current values
[X] Fix   - number of trailing decimals
[X] Add
[X] Sub
[X] Mul
[X] Div
[X] RollUp     // up arrow
[X] RollDn     // dn arrow
[X] x<>y       // lt/rt arrows
[X] Binary  - View Int value 'X' only
[X] Hex     - View Int value 'X' only
[x] move calculator via ctrl direction keys
[ ] Binary math - (integer)
[ ] Octal math - (integer)
[ ] Hex math - (integer)
*/
/**************************************************************************/
#INCLUDE 'fp_min.s'  // include minimum floating point lib
                     // (reduces mac size 350 bytes)
/******************* Global Constants and Variables ***********************/

   Constant
      MaxField = 17,          // max size of input field
      XX = 23,                // horiz location of right end of field
      Xy = 8,                 // verticle location of x register
      Yy = 6,                 // verticle location of y register
      Zy = 4,                 // verticle location of z register
      Ty = 2                  // verticle location of t register

   String
      x[IEEE],                //<---+
      y[IEEE],                //    |
      z[IEEE],                //    |-- Stack registers
      t[IEEE],                //    |
      LastX[IEEE],            //<---+
      Temp[IEEE],             // temp storage used for reg manipulation
      Xa[IEEE],               // X Real input accumulator
      Input[MaxField+3]  = '',// keyboard input accumulator
      GetStr[MaxField+3] = '' // Word under cursor

   Integer
      UpLtCol   = 10,     // location for calc window
      UpLtRow   = 10,     // location for calc window
      BotRtCol  = 34,     // location for calc window - UpLtCol+24
      BotRtRow  = 21,     // location for calc window - UpLtRow+11
      Fixed     = 4,      // defaut number of displayed decimals
      New       = True,   // Flags NEW input
      InitFlag  = False,  // flag to initiate vars on firs load only
      EnterFlag = false,  // allows operations with 'X' not <Enter>ed
      OpFlag    = false,  // indicates last operation was a math op
      HelpFlag  = False   // remember to trap keypress when back from help

/**************************************************************************/
#INCLUDE 'calc.inc'           /***** contains needed helper functions *****/
/**************************************************************************/

Proc CalcBox()          // place the calculator display on the screen

   Integer
      OldAttr

   PopWinOpen(UpLtCol,UpLtRow,BotRtCol,BotRtRow,1,'Calculator',Query(MenuBorderAttr))
   VgotoXY(1,1)                              // get video cursor in box
   OldAttr = Set(Attr,Query(MenuTextAttr))   // set color to match menus
   clrscr()                                  // clear box
   Vgotoxy(4,2)                              // <-----+
   PutLine('T',1)                            //       |
   Vgotoxy(4,4)                              //       |
   PutLine('Z',1)                            //       |- add labels
   Vgotoxy(4,6)                              //       |
   PutLine('Y',1)                            //       |
   Vgotoxy(4,8)                              //       |
   PutLine('X',1)                            // <-----+
   VgotoXY(1,10)
   PutLine('Esc to Exit, H for help',23)
   Set(Attr,Query(TextAttr))  // set the attribute to reg edit screen
   ClrXYZT(Ty) // <-----+
   ClrXYZT(Zy) //       |- display blank fields
   ClrXYZT(Yy) //       |
   ClrXYZT(Xy) // <-----+
End CalcBox
/************************* Move box Location ******************************/
Proc MoveBox(integer LtRt, integer UpDn)

   If (UpLtCol + LtRt > 0) AND (UpLtCol + LtRt + 24 < Query(ScreenCols))
      UpLtCol = UpLtCol + LtRt
      BotRtCol = UpLtCol+24
   Else
      Return()             // illegal move - do nothing
   EndIf
   If (UpLtRow + UpDn > 0) AND (UpLtRow + UpDn + 11 < Query(ScreenRows))
      UpLtRow = UpLtRow + UpDn
      BotRtRow = UpLtRow+11
   Else
      Return()             // illegal move - do nothing
   EndIf
   PopWinClose()           // close the calc window
   CalcBox()               // redraw the window
   UpDateRegs()            // refill the fields
End MoveBox
/*********************** Get and display input ****************************/

Proc ShowInput(String s)// ShowInput only used by GetInput()

   If New
      ClrXYZT(Xy)          // if NEW entry clear field
      InPut = s            // set Input to first char
      New = False          // after first key no longer 'New'
   Else
      if Length(Input) < MaxField   // as long as field length not exceeded
         Input = Input + s          // accumulate Ascii Input
      EndIf
   EndIf
   If Input[1] == '.' Input = '0'+Input EndIf   // tack on leading '0'
   Xa = FVal(Input)              // accumulate Real Input
   If FMathError
      FmathError = False
   EndIf
   // The following line corrects an error in the FP package that causes
   // a value of 0 to be returned by FVal('0.25') or FVal('0.250')
   If InPut == '0.25' or InPut == '0.250' Xa = FVal('0.2500') EndIf
   Vgotoxy(XX-MaxField,xy)                   // goto 'X' field
   PutLine(Format(Input:MaxField),MaxField)  // write the entered data
End ShowInput

//---------------------------

Proc GetInput()         // get keyboard input and display it

   Integer
      Key,                       // key character value
      i                          // scratch counter
   String
      PasteStr[MaxField+3]

Loop                          // you're in the loop now, only one way out...
   Repeat until Keypressed()  // keep cycling while waiting for keys
   Key = GetKey()             // get value
   If HelpFlag                // trap key used to exit help
      Key = 0                 // set key to unused value
      HelpFlag = False        // be sure to turn the flag off
   EndIf
   If EnterFlag               // if last function was <Enter> or an operation
      Case Key & 0FFh         // choose based on ascii value
         When 030h..039h, 02Eh, 08h // nums, decimal, backspace
            EnterFlag = False // indicator of last operation
         Otherwise            // don't loose entries not terminated with <Enter>
            EnterFlag = True  // otherwise last function was an operation
      EndCase
   EndIf
   case Key & 0FFh            /***** MAIN INPUT *****/
      When 030h..039h         /***** NUMBER INPUT '0'..'9' *****/
         OpTest()
         ShowInput(Chr(Key & 0FFh))
      When 2Eh                /***** DECIMAL POINT *****/
         If Not Pos('.', Input) or New // if x doesn't have a decimal yet
            OpTest()          // special work if last action was an operation
            ShowInput('.')    //  accept it...
         endif                //   otherwise ignore it.
      When 08h                /***** BACKSPACE *****/
         Input = SubStr(Input,1,Length(Input)-1)   // remove last char.
         If Length(Input) > 0 // as long as it has a length, 'Input'
            Xa = FVal(Input)  //  still has a value, update accumulator.
         Else
            Xa = ZeroExtended // otherwise zero the accumulator
         EndIf
         ClrXYZT(Xy)                   // clear the 'X' register
         Vgotoxy(XX-Length(Input),xy)
         PutLine(Input,Length(Input))  // show the value
      When 0Dh                /***** ENTER *****/
         X = Xa   // stuff the accumulator into the Real 'X' register
         T = Z    // enter
         Z = Y    //    only
         Y = X    //       stack handling
         UpDateRegs()   // update the register display
         Xa = X         // force match of X and input accumulator
         New = True     // assure that next entry is NEW
         EnterFlag = True  // value was entered - no special handling
      When 02Bh               /****** ADD *****/
         Math(1)  // 1=Add, 1=Subtract, 3=Multiply, 4=Divide
      When 02Dh               /****** SUBTRACT *****/
         Math(2)  // 1=Add, 1=Subtract, 3=Multiply, 4=Divide
      When 02Ah               /***** MULTIPLY *****/
         Math(3)  // 1=Add, 1=Subtract, 3=Multiply, 4=Divide
      When 02Fh           /****** DIVIDE *****/
         Math(4)  // 1=Add, 1=Subtract, 3=Multiply, 4=Divide
      When 0, 224       // when number pad arrows or grey arrows
         Case Key Shr 8 // get key value
            When 72, 75, 77, 80, 115, 116, 141, 145  // if any key matches
               If Not EnterFlag  // number not <Enter>ed but need to
                  X = Xa         // update x with accumulator
                  EnterFlag = True  // toggle flag
                  New = True        // flags
                  OpFlag = True     // on
               EndIf
         EndCase
         Case Key shr 8       // test key again for extended values
            When 72           // cursor up
               ShiftUp()      // shift registers up
            When 80           // cursor dn
               ShiftDn()      // shift registers down
            When 75, 77       // Lt/Rt Cursor
               If Not EnterFlag X = Xa EndIf // number not <Enter>ed
               SwapXY()       // swap x and y values
            When 83           // del
               Clx()
                    /***** MOVE BOX COMMANDS *****/
            When 115          // Lt cursor
               MoveBox(-1,0)
            When 116          // Rt cursor
               MoveBox(1,0)
            When 141          // Up cursor
               MoveBox(0,-1)
            When 145          // Dn cursor
               MoveBox(0,1)
         EndCase
                       /****** LETTER KEYS *****/
      When 062h, 042h         // 'B','b' = binary
         If Not EnterFlag X = Xa EndIf // number not <Enter>ed
         BinHex(2)
      When 058h, 078h         // 'x','X' = Hex
         If Not EnterFlag X = Xa EndIf // number not <Enter>ed
         BinHex(16)
      When 46h,66h            // 'F' or 'f' call fix()
         Fix()
      When 06Ch, 4Ch          // 'l' or 'L' gets Last X
         LstX()
      When 048h, 068h         // 'H' or 'h' calls help
         If Not EnterFlag X = Xa EndIf // update x with accumulator
         CalcHelp()
      When 047h, 067h         // 'G' or 'g' get number
         If GetStr == ''
            // do nothing
         Else
            // First work around 'fp' bug...
            If GetStr == '0.25' or GetStr == '0.250' GetStr = '0.2500' EndIf
            FVal(GetStr)      // see if it's a number
            If FMathError     //  it's not
               FMathError = False   // clear the error
               // do nothing
            Else
               ShiftUp()            // adjust stack
               X = FVal(GetStr)     // save the value
               Xa = X               // update the accumulator
               UpDateRegs()         // update the display
               OpFlag = True        // flag a successful operation
            EndIf
         EndIf
      When 050h, 070h         // 'P' or 'p' Paste X into buffer
         i = 1
         PasteStr = Fixit(1)  // pretty up the string
         While PasteStr[i] == chr(32) and i < MaxField// find first non space
            i = i + 1
         EndWhile
         PasteStr = SubStr(PasteStr,i,Length(PasteStr))  // trim leading spaces
         InsertText(' '+PasteStr+' ')  // bracket with spaces
         New = True           // assure that next entry is NEW
         EnterFlag = True
         Break
      When 053h, 073h         // 'S' or 's' Clears the stack
         InitRegs()           // zero all values
         UpdateRegs()         // redisplay
      When 01Bh               // Esc pressed, time to quit
         If Not EnterFlag X = Xa EndIf // save current x
         New = True           // assure that next entry is NEW
         EnterFlag = True
         Break          // exit loop. (only way out)
   EndCase
EndLoop                 // end keyboard input
   PopWinClose()        // close the calc window
End

/******************************** MAIN ************************************/

Proc Main()             // to start will not return any values

String OldWordSet[32]

   If Not InitFlag      // if vars not previously initiated
      InitRegs()        // init first time in only, regs can retain data
   EndIf
   // Mark current word for import
   If IsBlockMarked() PushBlock() EndIf
   OldWordSet = Set(Wordset,ChrSet("0-9"+Chr(046)))
   If MarkWord()
      GetStr = GetMarkedText()
      UnMarkBlock()
   Else
      GetStr = ''          // if no 'word' marked make string a nul
   EndIf
   PopBlock()              // restore prev marked block
   Set(Wordset,OldWordSet)
   // end get import string
   UpDateDisplay()         // clean up any editor messages left onscreen
   Set(Cursor,Off)         // turn off cursor since it intrudes if under box
   CalcBox()               // draw the window
   UpDateRegs()            // fill the fields
   GetInput()              // enter Input loop
   Set(Cursor,On)          // done - turn cursor back on
End Main

/**************************** EOF 'calc.s'*********************************/

// <Ctrl centercursor>     ExecMacro('calc')   // my calc button