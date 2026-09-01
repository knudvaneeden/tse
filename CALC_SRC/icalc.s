/*
   RPN integer calculator begun: Wednesday, 17 March 1993
           Last Revised: Thursday, 10 June 1993 (prettied up)

Functions to Implement:

[x] Enter
[x] LastX
[X] UpdateRegs - update display to current values
[x] Alternate Base math
[X] Add
[X] Sub
[X] Mul
[X] Div
[x] Mod
[x] And
[x] Or
[x] Xor
[x] Not
[x] Shr
[x] Shl
[X] RollUp
[X] RollDn
[X] x<>y
[x] Trap overflows of MaxInt [x] add, [x] sub, [x] Mul
[x] Set a word size for [x] NOT, [x] AND, [x] OR, [x] XOR.
[x] Move calculator box via ctrl direction keys...

*/
/******************* Global Constants and Variables ***********************/

   Constant
      MaxField = 17,          // max size of input field
      XX = 6,                 // horiz location of start of field
      Xy = 8,                 // verticle location of x register
      Yy = 6,                 // verticle location of y register
      Zy = 4,                 // verticle location of z register
      Ty = 2                  // verticle location of t register

   String
      Input[MaxField] = '', // keyboard input accumulator
      cursorNumberS[MaxField] = '',// Word under cursor
      BaseLtr[1] = 'd'

   Integer
      UpLtCol =  10,          // location for calc window
      UpLtRow =  10,          // location for calc window
      BotRtCol = 34,          // location for calc window - UpLtCol+24
      BotRtRow = 21,          // location for calc window - UpLtRow+11
      X,                // <--+
      Y,                //    |
      Z,                //    |
      T,                //    |- Stack registers
      LastX,            //    |
      Temp,             //    |
      Xa,               // <--+
      Base,             // number base
      WordSize=16,      // width of word to flip, affects Not, And, Or, Xor
      New   = True,     // Flags NEW input
      InitFlag = False, // flag to initiate vars on firs load only
      EnterFlag = false,// allows operations with 'X' not <Enter>ed
      OpFlag = false,   // indicates last operation was a math op
      HelpFlag = False  // remember to trap keypress when back from help

/************************************************************************/
/*                   Calculator helper functions                        */
/************************************************************************/
Proc InitRegs()   // initiate variable initial values

   x = 0        //<-----+
   y = 0        //      |
   z = 0        //      |
   t = 0        //      |-- Init vars
   Xa = 0       //      |
   LastX = 0    //      |
   Temp = 0     //<-----+
   Base = 10    // default to decimal (set via global var???)
   InitFlag = true      // we're loaded...
End InitRegs
//-------------------------------------------------------------------------
Proc ClrXYZT(Integer y) // Used to clear info from register fields
   Vgotoxy(XX,y)              // on screen when being updated with new
   PutLine(' ',MaxField-1)    // data.
End ClrXYZT
//-------------------------------------------------------------------------
Proc UpDateRegs() // update display to new values of registers

   String Filler[1]=Iif(Base == 2, '0', ' ') // fill field with 0s for binary

   ClrXYZT(Xy)                // update x
   Vgotoxy(XX,xy)
   PutLine(Format(X:MaxField-1:Filler:Base,BaseLtr:1),MaxField)
   ClrXYZT(Yy)                // update y
   Vgotoxy(XX,Yy)
   PutLine(Format(Y:MaxField-1:Filler:Base,BaseLtr:1),MaxField)
   ClrXYZT(Zy)                // update z
   Vgotoxy(XX,Zy)
   PutLine(Format(Z:MaxField-1:Filler:Base,BaseLtr:1),MaxField)
   ClrXYZT(Ty)                // update t
   Vgotoxy(XX,Ty)
   PutLine(Format(T:MaxField-1:Filler:Base,BaseLtr:1),MaxField)
End UpDateRegs
//-------------------------------------------------------------------------
#INCLUDE 'icalc.hlp'           /***** contains help display *****/
//-------------------------------------------------------------------------
Proc SetWordSize()// set number of bits to toggle with AND/OR/XOR/NOT
   Integer  key,
            OldAttr

   If Not EnterFlag X = Xa EndIf             // number not <Enter>ed
   OpFlag = True
   New = True
   Vgotoxy(XX,xy)                            // locate
   PutLine('WordSize?',MaxField)             // and place prompt
   OldAttr = Set(Attr,Query(MenuTextAttr))   // set color to match menus
   VgotoXy(XX,Xy+1)                          // locate
   PutLine('0FEDCBA987654321',MaxField-1)    // and add wordsize indicators
   VgotoXY(XX+(MaxField-(1+WordSize)),Xy+1)  // locate on current size
   PutAttr(Query(MenuTextLtrAttr),1)         // highlight it
   Set(Attr,OldAttr)                         // reset color
   key = GetKey() & 0FFh                     // get keys char value
   Case key
      When 30h..39h,41h..46h,61h..66h        // number 0..16
         Vgotoxy(XX+Maxfield-3,xy)           // locate to show choice
         If Val(Chr(Key),16)                 // if not 0
            WordSize = Val(Chr(Key),16)
         Else                                // if 0 force to 10h
            WordSize = 16
         EndIf
         PutLine(Format(WordSize:2:'0':16,'h'),3)  // display value for
         Delay(4)                                  // only short time
         UpdateRegs()                              // redisplay registers
      When 01Bh         // When Esc do nothing
         UpdateRegs()   // redisplay registers
      Otherwise
         SetWordSize()  // recurse until 0..F or Esc
   EndCase
   Set(Attr,Query(MenuTextAttr))                   // set color to match menus
   VgotoXY(XX,Xy+1)                 // locate and replace tic marks
   PutLine('    '+chr(249)+'   '+chr(249)+'   '+Chr(249),MaxField)
   VgotoXY(XX+(MaxField-(1+WordSize)),Xy+1)        // locate wordsize point
   PutLine(Chr(24),1)                              // place arrow indicator
   VgotoXY(XX+(MaxField-(1+WordSize)),Xy+1)        // back to arrow location
   PutAttr(Query(MenuTextLtrAttr),1)               // highlight it
   Set(Attr,OldAttr)                               // reset color
End SetWordSize
//-------------------------------------------------------------------------
Proc Math(Integer Op)

 Integer i = 1

   String XStr[MaxField-1] = '',   // holds binary string representaion of X
          YStr[MaxField-1] = '',   // holds binary string representaion of Y
          NewStr[MaxField-1] = '', // holds binary string representaion
          AddZeros[MaxField-1] = ''    // accumulates 0's for SHL

   If Not EnterFlag X = Xa EndIf // number not <Enter>ed
   LastX = X   // always update Last X
   Case Op
      When 1 X = y + x  // Add function
      When 2 X = y - x  // Subtract function
      When 3 X = y * x  // Multiply function
      When 4 X = y / x  // Divide function
      When 5 X = y MOD x// Modulus function
      When 6            // AND
         XStr = Format(X:MaxField-1:'0':2)
         YStr = Format(Y:MaxField-1:'0':2)
         NewStr = SubStr(YStr,1,(MaxField-WordSize)-1)
         i = MaxField - WordSize
         Repeat
            NewStr = NewStr + Str(Val(Ystr[i]) & Val(XStr[i]))
            i = i + 1
         Until i > Length(YStr)
         X = Val(NewStr,2)
      When 7            // OR
         XStr = Format(X:MaxField-1:'0':2)
         YStr = Format(Y:MaxField-1:'0':2)
         NewStr = SubStr(YStr,1,(MaxField-WordSize)-1)
         i = MaxField - WordSize
         Repeat
            NewStr = NewStr + Str(Val(Ystr[i]) | Val(XStr[i]))
            i = i + 1
         Until i > Length(YStr)
         X = Val(NewStr,2)
      When 8            // XOR
         XStr = Format(X:MaxField-1:'0':2)
         YStr = Format(Y:MaxField-1:'0':2)
         NewStr = SubStr(YStr,1,(MaxField-WordSize)-1)
         i = MaxField - WordSize
         Repeat
            NewStr = NewStr + Str(Val(Ystr[i]) ^ Val(XStr[i]))
            i = i + 1
         Until i > Length(YStr)
         X = Val(NewStr,2)
      // Special ops
      When 9 //X = ~x     // NOT X <--+ operate only on X no stack shift
         XStr = Format(X:MaxField-1:'0':2)
         i = MaxField - WordSize
         Repeat
            if XStr[i] == '0'   // if 0 toggle to 1
               XStr = (SubStr(XStr,1,i-1)+'1'+SubStr(XStr,i+1,Length(XStr)))
            Else                    // if 1 toggle to 0
               XStr = (SubStr(XStr,1,i-1)+'0'+SubStr(XStr,i+1,Length(XStr)))
            EndIf
            i = i + 1
         Until i > Length(XStr) // done
         X = Val(XStr,2)        // get bitwise NOT value in X
      When 10           // Shr
         XStr = Format(Y:MaxField-1:'0':2)
         X = Val(SubStr(XStr,1,Length(XStr)-x),2)   //clip off X digits
      When 11           // Shl
         XStr = Format(Y:MaxField-1:'0':2)
         Repeat
            AddZeros = AddZeros + '0'  // add X trailing 0s to Y
            i = i + 1
         Until i > x
         X = Val(SubStr(XStr,1+x,Length(XStr))+AddZeros,2) //place Val in X
   EndCase
   Xa = X                     // force accumulator and X to match
   If Op <> 9                 // adjust stack EXCEPT for NOT operation
      Y = Z
      Z = T
   EndIf
   EnterFlag = True           // Enter/Op
   New = True                 // any further entry is new
   OpFlag = True              // operation completed
   UpdateRegs()               // redisplay registers
End Math
//-------------------------------------------------------------------------
Proc ShiftStat()  // common operations to all register manipulations
   Xa = X         // force accumulator to match X
   New = True     // ready for new input
   OpFlag = True  // last function was an operation
End ShiftStat
//-------------------------------------------------------------------------
Proc ShiftUp()    // swap regs up
   Temp  =  T
   T     =  Z
   Z     =  Y
   Y     =  X
   X     =  Temp
   UpdateRegs()
   ShiftStat()
End ShiftUp
//-------------------------------------------------------------------------
Proc ShiftDn()    // swap regs down
   Temp  =  X
   X     =  Y
   Y     =  Z
   Z     =  T
   T     =  Temp
   UpdateRegs()
   ShiftStat()
End ShiftDn
//-------------------------------------------------------------------------
Proc SwapXY()     // swap x and y registers
   Temp  =  X
   X     =  Y
   Y     =  Temp
   UpdateRegs()
   ShiftStat()
End SwapXY
//-------------------------------------------------------------------------
Proc LstX()       // recall last X entry
   New = True
   ShiftUp()
   X  =  LastX
   UpdateRegs()
   ShiftStat()
End LstX
//-------------------------------------------------------------------------
Proc Clx()        // clear X value, ready for new entry
   X = 0
   UpdateRegs()
   Input = ''
   Xa = X
   New = True
   OpFlag = False
End Clx
//-------------------------------------------------------------------------
Proc OpTest()     // test for last action = operation, handle accordingly

   If OpFlag
      ShiftUp()
      OpFlag = False
   EndIf
End OpTest
//-------------------------------------------------------------------------
Proc Overflow()   // display warning of pending overflow condition
      Vgotoxy(XX,xy)                // locate for output
      PutLine('OVERFLOW',MaxField)  // Error Msg
      Delay(9)                      // pause for a bit
End Overflow
//-------------------------------------------------------------------------
Proc BinHexDecOct(Integer MyBase)// Dec Hex or Binary Oct mode toggles

   OpFlag = True
   New = true
   If MyBase == 16
      BaseLtr = 'h'
      Base = 16
   EndIf
   If MyBase == 10
      BaseLtr = 'd'
      Base = 10
   EndIf
   If MyBase == 8
      BaseLtr = 'o'
      Base = 8
   EndIf
   If MyBase == 2
      BaseLtr = 'b'
      Base = 2
   EndIf
   UpdateRegs()                  // update regs - completes partial ops
End BinHexDecOct

/**************************************************************************/

Proc ShadowBox(Integer OnOff) // turn shadow under calc on or off
   If OnOff
      PopWinOpen(UpLtCol+1,UpLtRow+1,BotRtCol+1,BotRtRow+1,1,'',Color(Black on Black))
   Else
      PopWinClose()           // turn shadow off
   EndIf
End ShadowBox

/**************************************************************************/

Proc CalcBox(Integer OnOff)   // place the calculator display on the screen
                              // or turn it off
   Integer
      OldAttr
   String
      Tic[13] = '    '+chr(249)+'   '+chr(249)+'   '+Chr(249)

   If OnOff
      PopWinOpen(UpLtCol,UpLtRow,BotRtCol,BotRtRow,1,'Integer Calculator',Query(MenuBorderAttr))
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
      VgotoXY(XX,Xy+1)
      PutLine(Tic,MaxField)                     // nibble tic marks
      VgotoXY(XX+(MaxField-(1+WordSize)),Xy+1)
      PutLine(Chr(24),1)                        // wordsize indicator
      VgotoXY(XX+(MaxField-(1+WordSize)),Xy+1)
      PutAttr(Query(MenuTextLtrAttr),1)
      VgotoXY(1,Xy+2)
      PutLine('Esc to Exit, H for help',23)     // short help
      Set(Attr,Query(TextAttr))  // set the attribute to reg edit screen
      ClrXYZT(Ty) // <-----+
      ClrXYZT(Zy) //       |- display blank fields
      ClrXYZT(Yy) //       |
      ClrXYZT(Xy) // <-----+
   Else
      PopWinClose()  // all done, turn shadow off
   EndIf
End CalcBox
/************************* Move box Location ****************************/
Proc MoveBox(integer LtRt, integer UpDn)

   If (UpLtCol + LtRt > 0) AND (UpLtCol + LtRt + 24 < Query(ScreenCols))
      UpLtCol = UpLtCol + LtRt
      BotRtCol = UpLtCol+24
   Else
      Return()
   EndIf
   If (UpLtRow + UpDn > 0) AND (UpLtRow + UpDn + 11 < Query(ScreenRows))
      UpLtRow = UpLtRow + UpDn
      BotRtRow = UpLtRow+11
   Else
      Return()
   EndIf
   CalcBox(Off)            // close the calc window
   ShadowBox(Off)          // erase the shadow
   ShadowBox(On)           // redraw the shadow
   CalcBox(On)             // redraw the window
   UpDateRegs()            // refill the fields
End MoveBox
/*********************** Get and display input ****************************/

Proc ShowInput(String tmp) // ShowInput only used by GetInput()

   String   InputTest[MaxField]  = '', // copy of input string
            s[1] = Upper(tmp)   // force a..f upper case for overflow compare

   If New
      ClrXYZT(Xy)          // if NEW entry clear field
      InPut = s            // set Input to first char
      New = False          // after first key no longer 'New'
   // check for string length and overflow
   Elseif Length(Input) <= Length(Str(MaxInt,Base)) and Length(Input) < MaxField-1
      InputTest = Input + s// string for compare
      While InputTest[1] == '0' and Length(InputTest) > 1  // no leading zeros
         InputTest = SubStr(InputTest,2,Length(InputTest)) // strip leading 0s
      EndWhile
      If InputTest <> Str(Val(Input+s,base),base)  // if overflow strings won't match
         Overflow()        // show error message
      Else
         Input = Input+s   // all is well add new digit on tail
      EndIf
   EndIf
   Xa = Val(Input,Base)    // accumulate Real Input
   Vgotoxy(XX,xy)          // goto 'X' field
   PutLine(Format(Input:MaxField-1),MaxField-1)  // write the entered data
End ShowInput

//---------------------------

Proc GetInput()   // get keyboard input and display it

   Integer
      Key,                    // key character value
      NumKey,                 // number value of key
      i                       // scratch counter

Loop              // you're in the loop now, only one way out...
   Repeat until Keypressed()  // keep cycling while waiting for keys
   Key = GetKey()             // get value
   NumKey = Key & 0FFh  // character value of key (or 0 for numpad or 224 for greykeys)
   If HelpFlag                // trap key used to exit help
      Key = 255               // set key to unused value
      NumKey = 0              // set key to unused value
      HelpFlag = False        // ready to accept values or commands
   EndIf
   If EnterFlag               // if last function was <Enter> or an operation
      Case Key & 0FFh         // choose based on ascii value
         When 030h..039h,041h..046h,061h..066h, 02Eh, 08h // nums, decimal, backspace
            EnterFlag = False // indicator of last operation
         Otherwise            // don't loose entries not terminated with <Enter>
            EnterFlag = True  // otherwise last function was an operation
      EndCase
   EndIf
   case NumKey                /***** MAIN INPUT *****/
      /***** NUMBER INPUT '0'..'9',A..F,a..f *****/
      When 030h..039h,041h..046h,061h..066h  // test if in 'all numbers set'
         If Base == 16                       // HEX accepts [0..9,a..f,A..F]
            OpTest()                         // action based on last operation
            ShowInput(Chr(NumKey))           // display keyed number
         ElseIf Base == 10                   // DEC accepts [0..9]
            Case NumKey
               When 030h..039h
                  OpTest()                   // action based on last operation
                  ShowInput(Chr(NumKey))     // display keyed number
            EndCase                          // fall through if not 0..9
         ElseIf Base == 8                    // OCT accepts [0..7]
            Case NumKey
               When 030h..037h
                  OpTest()                   // action based on last operation
                  ShowInput(Chr(NumKey))     // display keyed number
            EndCase                          // fall through if not 0..7
         ElseIf Base == 2                    // BIN accepts [0,1]
            Case NumKey
               When 030h..031h
                  OpTest()                   // action based on last operation
                  ShowInput(Chr(NumKey))     // display keyed number
            EndCase                          // fall through if not 0..7
         EndIf
      When 08h                /***** BACKSPACE *****/
         If EnterFlag InPut = '' EndIf
         Input = SubStr(Input,1,Length(Input)-1)   // remove last char.
         If Length(Input) > 0    // as long as it has a length, 'Input'
            Xa = Val(Input,Base) //  still has a value, update accumulator.
         Else
            Xa = 0               // otherwise zero the accumulator
         EndIf
         ClrXYZT(Xy)             // clear the 'X' register
         Vgotoxy(XX,xy)
         PutLine(Format(Xa:MaxField-1:' ':Base,BaseLtr:1),MaxField)  // display
      When 0Dh                /***** ENTER *****/
         X = Xa         // stuff the accumulator into the Real 'X' register
         T = Z          // enter
         Z = Y          //    only
         Y = X          //       stack handling
         UpDateRegs()   // update the register display
         Xa = X         // force match of X and input accumulator
         New = True     // assure that next entry is NEW
         EnterFlag = True  // value was entered - no special handling
      When 02Bh               /****** ADD *****/
         /*check for overflow*/
         If MaxInt - Iif(Y<0,-y,y) >= Iif((Xa<0 and Y<0),-Xa,Xa)
            Math(1)     // 1=Add, 2=Subtract, 3=Multiply, 4=Divide...
         Else
            OverFlow()
            X = Xa
            UpDateRegs()
         EndIf
      When 02Dh               /****** SUBTRACT *****/
         /*check for overflow*/
         If X > 0 and Y > 0   // if both positive ok to subtract
            Math(2)     // 1=Add, 2=Subtract, 3=Multiply, 4=Divide...
         // test for underflow (over -MaxInt)
         ElseIf MaxInt - Iif(Y<0,-y,y) >= Iif((Xa<0 and Y<0),-Xa,Xa)
            Math(2)     // 1=Add, 2=Subtract, 3=Multiply, 4=Divide...
         Else
            OverFlow()
            X = Xa
            UpDateRegs()
         EndIf
      When 02Ah               /***** MULTIPLY *****/
         /*check for overflow*/
         If MaxInt/Iif(Xa<0 ,-Xa,Xa) > Iif(Y<0,-Y,Y) or Xa == 0
            Math(3)     // 1=Add, 2=Subtract, 3=Multiply, 4=Divide...
         Else
            OverFlow()
            X = Xa
            UpDateRegs()
         EndIf
      When 02Fh           /****** DIVIDE *****/
         Math(4)  // 1=Add, 2=Subtract, 3=Multiply, 4=Divide...
      When 05Ch         /****** MODULO *****/
         Math(5)  // 5=Modulo, 6=And, 7=Or, 8=Xor, 9=Not, 10=Shr, 11=Shl
      When 026h         /****** Bitwise AND *****/
         Math(6)  // 5=Modulo, 6=And, 7=Or, 8=Xor, 9=Not, 10=Shr, 11=Shl
      When 07Ch         /****** Bitwise OR *****/
         Math(7)  // 5=Modulo, 6=And, 7=Or, 8=Xor, 9=Not, 10=Shr, 11=Shl
      When 05Eh         /****** Bitwise XOR *****/
         Math(8)  // 5=Modulo, 6=And, 7=Or, 8=Xor, 9=Not, 10=Shr, 11=Shl
      When 06Eh, 04Eh   /****** Bitwise NOT *****/
         Math(9)  // 5=Modulo, 6=And, 7=Or, 8=Xor, 9=Not, 10=Shr, 11=Shl
      When 03Eh, 02Eh   /****** SHR *****/
         Math(10) // 5=Modulo, 6=And, 7=Or, 8=Xor, 9=Not, 10=Shr, 11=Shl
      When 03Ch, 02Ch   /****** SHL *****/
         Math(11) // 5=Modulo, 6=And, 7=Or, 8=Xor, 9=Not, 10=Shr, 11=Shl
                       /****** CURSOR KEYS *****/
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
               If Not EnterFlag X = Xa EndIf // number not <Enter>ed force value into X
               SwapXY()       // swap x and y values
            When 83           // del
               Clx()
            When 115
               MoveBox(-1,0)
            When 116
               MoveBox(1,0)
            When 141
               MoveBox(0,-1)
            When 145
               MoveBox(0,1)
         EndCase
                       /****** LETTER KEYS *****/
      When 057h, 077h         // 'W','w' = binary
         If Not EnterFlag X = Xa EndIf // number not <Enter>ed
         BinHexDecOct(2)
      When 04Fh, 06Fh         // 'O','o' = Octal
         If Not EnterFlag X = Xa EndIf // number not <Enter>ed
         BinHexDecOct(8)
      When 054h, 074h         // 'T','t' = Decimal
         If Not EnterFlag X = Xa EndIf // number not <Enter>ed
         BinHexDecOct(10)
      When 058h, 078h         // 'x','X' = HexiDecimal
         If Not EnterFlag X = Xa EndIf // number not <Enter>ed
         BinHexDecOct(16)
      When 06Ch, 4Ch          // 'l' or 'L' gets Last X
         If Not EnterFlag X = Xa EndIf // number not <Enter>ed
         LstX()
      When 048h, 068h         // 'H' or 'h' calls help
         CalcHelp()
      When 047h, 067h         // 'G' or 'g' get number
         If cursorNumberS == ''
            // do nothing
         Else
               ShiftUp()            // adjust the stack
               X = Val(cursorNumberS,base) // save the value
               Xa = X               // update the accumulator
               UpDateRegs()         // update the display
               EnterFlag = False    // reset the flag
         EndIf
      When 050h, 070h         // 'P' or 'p' Paste X into buffer
         i = 1
         cursorNumberS = Format(x:MaxField-1:' ':Base)
         While cursorNumberS[i] == chr(32) and i < MaxField
            i = i + 1
         EndWhile
         cursorNumberS = SubStr(cursorNumberS,i,Length(cursorNumberS)) // trim leading spaces
         InsertText(cursorNumberS)   // paste into text
         New = True           // assure that next entry is NEW
         EnterFlag = True     // forced entry
         Break                // exit loop and drop back to edit session
      When 72h,52h            // set wordsize
         SetWordSize()
      When 053h, 073h         // 'S' or 's' Clears the stack
         i = base             // save current base
         key = LastX          // use Key var to save LastX
         InitRegs()           // reset all variables
         LastX = Key          // restore LastX
         Key = 255            // set key to unused value
         BinHexDecOct(i)      // restore base
                       /****** ESCAPE KEY *****/
      When 01Bh               // Esc pressed, time to quit
         If Not EnterFlag X = Xa EndIf // save current x
         New = True           // assure that next entry is NEW
         EnterFlag = True     // forced entry
         Break                // exit loop return to edit
   EndCase
EndLoop           // end key entry loop
End GetInput

/******************************** MAIN ************************************/

Proc Main()       // Setup
   If Not InitFlag         // if first use,
      InitRegs()           // inititilize vars, otherwise retain previous values
   EndIf
   // Mark current word for import
   If IsBlockMarked() PushBlock() EndIf   // save existing block marks
   If MarkWord()                          // a word was markable
      cursorNumberS = GetMarkedText()            // grab it
      UnMarkBlock()                       // unmark word
   Else
      cursorNumberS = ''                         // set string to nil on failure
   EndIf
   PopBlock()                             // restore previous marking
   // end get import string
   UpDateDisplay()         // clean up any editor messages left onscreen
   Set(Cursor,Off)         // turn off cursor since it intrudes if under box
   ShadowBox(On)           // draw the shadow
   CalcBox(On)             // draw the window
   UpDateRegs()            // fill the fields
   GetInput()              // enter Input loop
   CalcBox(Off)            // close the calc window
   ShadowBox(Off)          // erase the shadow
   Set(Cursor,On)          // done - turn cursor back on
End Main

/**************************** EOF 'calc.s'*********************************/

// <Ctrl centercursor>     ExecMacro('icalc')   // my calc button