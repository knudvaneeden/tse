/*
                          Thursday, 8 July 1993
*/
/**************************************************************************/
#INCLUDE 'fp_min.s'  // include minimum floating point lib (reduces mac size 350 bytes)
/******************* Global Constants and Variables ***********************/
   Constant
      MaxField = 17,       // max size of input field
      FieldX   = 6,        // horiz location of start of field
      FieldY   = 2         // verticle location of field

   String
      x[IEEE],                // entry = accumulator
      y[IEEE],                // prev entry
      Input[MaxField+3] = '', // keyboard input accumulator
      GetStr[MaxField+3] = '' // Word under cursor

   Integer
      UpLtCol  = 10,    // initial location for calc window
      UpLtRow  = 10,    // initial location for calc window
      BotRtCol = 34,    // initial location for calc window - UpLtCol+24
      BotRtRow = 15,    // initial location for calc window - UpLtRow+5
      Fixed    =  4,
// Booleans
      New      = True,  // Flags NEW input
      InitFlag = False, // flag to initiate vars on firs load only
      HelpFlag = False, // remember to trap keypress when back from help
// Math flags
      Add      = False,    // <----+
      Subtract = False,    //      | flags to control DoMath()
      Multiply = False,    //      | when "=" key is pressed
      Divide   = False,    //      |
      Percent  = False     // <----+


/************************************************************************/
/*                   Calculator helper functions                        */
/************************************************************************/
Proc InitRegs()      // initiate variable initial values
   x = ZeroExtended  // type defined in fp.s (or fp_min.s)
   y = ZeroExtended  // type defined in fp.s (or fp_min.s)
   If GetGlobalInt('fpcalc')
      Fixed = GetGlobalInt('fpcalc')   // changes default number of decimals
   EndIf
   InitFlag = true   // we're loaded...
End InitRegs
//-------------------------------------------------------------------------
Proc ClrField()      // Used to clear numbers from field
   Vgotoxy(FieldX,FieldY)  // on screen when being updated with new
   PutLine(' ',MaxField-1) // data.
End ClrField
//-------------------------------------------------------------------------
Proc UpdateField()   // update display
   String Field[MaxField+3] = FStr(X,MaxField,Fixed) // convert to string

   ClrField()                       // clear the display
   Vgotoxy(FieldX,FieldY)           // set up for output
   PutLine(Field,Length(Field))     // display the number
End UpdateField
//-------------------------------------------------------------------------
Proc Fix()     // fix number of _DISPLAYED_ decimal places
   Integer key

   Vgotoxy(FieldX,FieldY)
   PutLine('Fix [0..9]',MaxField)   // prompt for places
   key = GetKey() & 0FFh            // get the key value
   Case key
      When 30h..39h                 // number 0..9
         Vgotoxy(FieldX+MaxField-1,FieldY)
         Fixed = Val(Chr(Key))      // set the new value
         PutLine(Format(Fixed,1),1) // display it
         Delay(4)                   // delay a bit
         UpdateField()              // refresh the display field
      When 01Bh         // When Esc
         UpdateField()  //  update display and do nothing
      Otherwise
         Fix()          // recurse until 0..9 or Esc
   EndCase
End Fix
//-------------------------------------------------------------------------
Proc DoMath(Integer Chain)  // Do the math - chain indicates cumlative math

   String LastX[IEEE] = X

   If Add
      If FSub(ZeroExtended,x) == Y  // if = 0 (-1 + 1) else FAdd returns error
         X = ZeroExtended           //  just zero it out
      Else
         X = FAdd(y,x)  // call the add function
      EndIf
      Add = False       // done
   ElseIf Subtract
      If Y == X                     // if = 0 (1 - 1) else FSub returns error
         X = ZeroExtended           //  just zero it out
      Else
         X = FSub(y,x)  // call the Subtract function
      EndIf
      Subtract = False  // done
   ElseIf Multiply
      If Y == ZeroExtended or X == ZeroExtended // if=0 (1*0,0*1) FMul returns
         X = ZeroExtended                       //  an error so zero it out
      Else
         X = FMul(y,x)  // call the Multiply function
      EndIf
      Multiply = False  // done
   ElseIf Divide
      If Y == ZeroExtended // if legal 0/1 FDiv returns error (1/0 is error)
         X = ZeroExtended  //  so avoid error
      Else
         X = FDiv(y,x)  // call the Divide function
      EndIf
      Divide = False    // done
   ElseIf Percent
      If Y == ZeroExtended // if legal 0/1 FDiv returns error (1/0 is error)
         X = ZeroExtended  //  so avoid error
      Else
         X = FMul(y,FDiv(x,FVal('100')))  // do X percentage of Y
      EndIf
      Divide = False    // done
   EndIf
   If Not FMathError             // no errors
      Y = X                      // update the accumulator
      If NOT Chain               // if "=" pressed
        UpdateField()              // refresh the display field
      EndIf                      // if chaining don't update display!
      New = True                 // any further entry is new
   Else                          // announce error
      Vgotoxy(FieldX,FieldY)     // locate for output
      PutLine('ERROR',MaxField)  // Error Trap
      Delay(18)                  // pause for a bit
      X = LastX                  // assume 'X' destroyed recover value
      UpdateField()              // restore display
      New = True                 // ready for new input
   EndIf
End DoMath
//-------------------------------------------------------------------------
Proc BinHex(Integer MyBase)   // display X value as Hex or Binary

   String
      Tmp[MaxField+3] = FStr(X,MaxField,0),  // fp.bin needs [+3] for results
      Base[1]
   Integer
      Convert = Val(SubStr(Tmp,1,Pos('.',Tmp))) // integer portion only!

   HelpFlag = True   // make use of this flag to throw away next key
   New = true
   If MyBase == 16 Base = 'h' EndIf // set hex base indicator
   If MyBase == 2  Base = 'b' EndIf // set binary base indicator
   VGotoXY(FieldX,FieldY)
   PutLine(format(Convert:MaxField-1:'0':MyBase,Base:1),MaxField) // display
   Repeat until keypressed()           // keep waiting for a keypress
   UpdateField()                       // update regs - completes partial ops
End BinHex
//-------------------------------------------------------------------------
Proc ShadowBox(Integer SwitchOn)    // turn shadow under calc on or off
   If SwitchOn
      PopWinOpen(UpLtCol+1,UpLtRow+1,BotRtCol+1,BotRtRow+1,1,'',Color(Black on Black))
   Else
      PopWinClose()           // turn shadow off
   EndIf
End ShadowBox
//-------------------------------------------------------------------------
Proc CalcBox(Integer Open) // place the calculator display on the screen
                           // or turn it off
   Integer
      OldAttr

   If Open
      PopWinOpen(UpLtCol,UpLtRow,BotRtCol,BotRtRow,1,'Decimal Calculator',Query(MenuBorderAttr))
      VgotoXY(1,1)                              // get video cursor in box
      OldAttr = Set(Attr,Query(MenuTextAttr))   // set color to match menus
      clrscr()                                  // clear box
      VgotoXY(1,FieldY+2)                       // locate for help line
      PutLine('Esc to Exit, H for help',23)     // short help
      Set(Attr,Query(TextAttr))  // set the attribute to reg edit screen
      ClrField()
   Else
      PopWinClose()  // all done, close window
   EndIf
End CalcBox
//-------------------------------------------------------------------------
Proc MoveBox(integer LtRt, integer UpDn)  // move the box around the screen

   /* if movement is legal (on screen) */
   If (UpLtCol + LtRt > 0) AND (UpLtCol + LtRt + 24 < Query(ScreenCols))
      UpLtCol = UpLtCol + LtRt
      BotRtCol = UpLtCol+24
   Else
      Return()    // not a legal move so quit
   EndIf
   /* if movement is legal (on screen) */
   If (UpLtRow + UpDn > 0) AND (UpLtRow + UpDn + 5 < Query(ScreenRows))
      UpLtRow = UpLtRow + UpDn
      BotRtRow = UpLtRow+5
   Else
      Return()    // not a legal move so quit
   EndIf
   CalcBox(Off)            // close the calc window
   ShadowBox(Off)          // erase the shadow
   ShadowBox(On)           // redraw the shadow in new position
   CalcBox(On)             // redraw the window in new position
   UpdateField()           // refill the fields
End MoveBox
/*********************** Temporary help display ***************************/
Proc CalcHelp()      // minimum help.

   Integer
      OldAttr = Set(Attr,Query(MenuTextAttr))

   HelpFlag = True   // let GetInput know to trap keys entered here.
   PopWinOpen(1,1,42,21,1,'Help',Query(MenuBorderAttr))
   VgotoXY(1,1)
   ClrScr()
/* Put help text in help box */
   VgotoXY(1,2)
   PutLine('Active function keys are hi-lighted.',40)
   VgotoXY(1,5)
   PutLine('Editing:',40)
   VgotoXY(1,6)
   PutLine('Backspace: Delete entry Rt to Lt.',40)
   VgotoXY(1,7)
   PutLine('Delete: Clear entry',40)
   VgotoXY(1,10)
   PutLine('Math:',40)
   VgotoXY(1,11)
   PutLine('+ Add  - Subtract  * Multiply  / Divide',40)
   VgotoXY(1,12)
   PutLine('% Percent  = or GreyEnter: Show result',40)
   VgotoXY(1,15)
   PutLine('Other:',40)
   VgotoXY(1,16)
   PutLine('Get number under cursor into Field',40)
   VgotoXY(1,17)
   PutLine('Paste Field into Current edit buffer',40)
   VgotoXY(1,18)
   PutLine('Fix number of displayed decimals',40)
/* Highlight the hotkeys */
   VGotoXY(1,6)
   PutAttr(Query(MenuTextLtrAttr),9)   // backspace
   VGotoXY(1,7)
   PutAttr(Query(MenuTextLtrAttr),6)   // delete
   VGotoXY(1,11)
   PutAttr(Query(MenuTextLtrAttr),1)   // +
   VGotoXY(8,11)
   PutAttr(Query(MenuTextLtrAttr),1)   // -
   VGotoXY(20,11)
   PutAttr(Query(MenuTextLtrAttr),1)   // *
   VGotoXY(1,12)
   PutAttr(Query(MenuTextLtrAttr),1)   // '%'
   VGotoXY(17,12)
   PutAttr(Query(MenuTextLtrAttr),9)   // 'GreyEnter'
   VGotoXY(12,12)
   PutAttr(Query(MenuTextLtrAttr),1)   // '='
   VGotoXY(32,11)
   PutAttr(Query(MenuTextLtrAttr),1)   // '/'
   VGotoXY(1,16)
   PutAttr(Query(MenuTextLtrAttr),1)   // Get
   VGotoXY(1,17)
   PutAttr(Query(MenuTextLtrAttr),1)   // Paste
   VGotoXY(1,18)
   PutAttr(Query(MenuTextLtrAttr),1)   // Fix
/* wait for key before exiting */
   Repeat until keypressed()           // keep waiting for a keypress
   Set(Attr,OldAttr)                   // restore previous attr
   PopWinClose()                 // close up the box
End CalcHelp
/*********************** Get and display input ****************************/
Proc ShowInput(String s) // ShowInput only used by GetInput()

   If New
      ClrField()          // if NEW entry clear field
      InPut = s            // set Input to first char
      New = False          // after first key no longer 'New'
   // check for string length and overflow
   Else
      if Length(Input) < MaxField   // as long as number isn't to long
         Input = Input + s          // tack on next digit
      EndIf                         //  otherwise key is ignored
   EndIf
   If Input[1] == '.' Input = '0'+Input EndIf   // tack on leading '0'
   X = FVal(Input)   // accumulate Real Input
   If FMathError     // traps error condition (see below)
      FmathError = False   // reset error flag
   EndIf
   // The following line traps an error in the FP package that causes
   // a value of 0 to be returned by FVal('0.25') or FVal('0.250')
   If InPut == '0.25' or InPut == '0.250' X = FVal('0.2500') EndIf
   Vgotoxy(FieldX,FieldY)
   PutLine(Format(Input:MaxField),MaxField)  // write the entered data
End ShowInput
//---------------------------
Proc SetOpFlags()
  If (Add|Subtract|Multiply|Divide|Percent)  // if any math pending
    DoMath(TRUE)                             // do the math (chain=true)
  Else                                       // no pending operation
    Y = X
    New = True        // ready for next entry
  EndIf
End SetOpFlags
//---------------------------
Proc GetInput()      // get keyboard input and display it

   Integer
      Key,                       // key character value
      NumKey,                    // number value of key
      i                          // scratch counter

Loop                 // you're in the loop now, only one way out...
   Repeat until Keypressed()  // keep cycling while waiting for keys
   Key = GetKey()             // get value
   NumKey = Key & 0FFh  // character value of key (or 0 for numpad or 224 for greykeys)
   If HelpFlag                // trap key used to exit help
      Key = 255               // set key to unused value
      NumKey = 0              // set key to unused value
      HelpFlag = False        // ready to accept values or commands
   EndIf

   case NumKey                /***** MAIN INPUT *****/
      /***** NUMBER INPUT '0'..'9',A..F,a..f *****/
      When 030h..039h                        // test if [0..9]
         ShowInput(Chr(NumKey))     // display keyed number
      When 2Eh                /***** DECIMAL POINT *****/
         If Not Pos('.', Input) or New // if x doesn't have a decimal yet
            ShowInput('.') // accept it...
         endif             //  otherwise ignore it.
      When 08h                /***** BACKSPACE *****/
         If New InPut = '' EndIf
         If Length(Input)        // as long as it has a length
            Input = SubStr(Input,1,Length(Input)-1)   // remove last char.
            X = FVal(Input)      //  still has a value, update accumulator.
         Else
            X = ZeroExtended     // otherwise zero the accumulator
         EndIf
         ClrField()              // clear the display
         Vgotoxy(FieldX,FieldY)
         PutLine(Format(Input:MaxField),MaxField)
      When 02Bh               /****** ADD(+) *****/
        SetOpFlags()
        Add = True        // ready for '=' key
      When 02Dh               /****** SUBTRACT(-) *****/
        SetOpFlags()
        Subtract = True   // ready for '=' key
      When 02Ah               /***** MULTIPLY(*) *****/
        SetOpFlags()
        Multiply = True   // ready for '=' key
      When 02Fh               /****** DIVIDE(/) *****/
        SetOpFlags()
        Divide = True     // ready for '=' key
      When 025h               /****** Percentage(%) *****/
        SetOpFlags()
        Percent = True     // ready for '=' key
      When 03Dh,0Dh  // '='or 'greyenter' key pressed
         DoMath(FALSE)    //  go do the math - NOT chain calculation
                       /****** SPECIAL KEYS *****/
      When 0, 224             // when number pad arrows or grey arrows
         Case Key shr 8       // test key for extended values
            When 83           // del
               X = ZeroExtended  // zero accumulator
               New = True        // set for new input
               UpdateField()  // clear current entry
            When 115          // ctrl left
               MoveBox(-1,0)  //    move box left
            When 116          // ctrl right
               MoveBox(1,0)   //    move box right
            When 141          // ctrl up
               MoveBox(0,-1)  //    move box up
            When 145          // ctrl dn
               MoveBox(0,1)   //    move box dn
         EndCase
                       /****** LETTER KEYS *****/
      When 042h,062h          // B or b : display binary value
         BinHex(2)
      When 058h,078h          // X or x : display hex value
         BinHex(16)
      When 046h,066h          // F or f : set number displayed decimals
         Fix()
      When 048h, 068h         // 'H' or 'h' calls help
         CalcHelp()
      When 047h, 067h         // 'G' or 'g' get number
         If GetStr == ''
            // do nothing
         Else
         // First work around 'fp' bug...
         If GetStr == '0.25' or GetStr == '0.250' GetStr = '0.2500' EndIf
         FVal(GetStr)
            If FMathError           // string is not a number
               FMathError = False   // reset flag
               // do nothing
            Else
               X = FVal(GetStr)     // it's a number, save it
               UpDateField()        // and display it
            EndIf
         EndIf
      When 050h, 070h         // 'P' or 'p' Paste X into buffer
         i = 1
         GetStr = FStr(X,MaxField,Fixed)
         While GetStr[i] == chr(32) and i < MaxField // find first nonblank pos
            i = i + 1
         EndWhile
         GetStr = SubStr(GetStr,i,Length(GetStr)) // trim leading spaces
         InsertText(' '+GetStr+' ') // paste into text bracketed with spaces
         New = True           // assure that next entry is NEW
         Break
                       /****** ESCAPE KEY *****/
      When 01Bh               // Esc pressed, time to quit
         Y = X                // update
         New = True           // assure that next entry is NEW
         Break                // exit loop return to edit
   EndCase
EndLoop              // End entry loop - back to start
End GetInput
/******************************** MAIN ************************************/

Proc Main()          // Startup code FPCalc.s

  String OldWordSet[32]

   If Not InitFlag         // if first use,
      InitRegs()           // inititilize vars, otherwise retain previous values
   EndIf
   // Mark current word for import
   If IsBlockMarked() PushBlock() EndIf   // save existing block marks
   OldWordSet = Set(Wordset,ChrSet("0-9"+Chr(046))) // just '0..9' and '.'
   If MarkWord()                          // a fp number was markable
      GetStr = GetMarkedText()            // grab it
      UnMarkBlock()                       // unmark word
   Else
      GetStr = ''                         // set string to nil on failure
   EndIf
   If GetStr <> '' PopBlock() EndIf       // restore previous marking
   Set(Wordset,OldWordSet)                // restore wordset
   // end get import string
   UpDateDisplay()         // clean up any editor messages left onscreen
   Set(Cursor,Off)         // turn off cursor since it intrudes if under box
   ShadowBox(On)           // draw the shadow
   CalcBox(On)             // draw the window
   UpdateField()               // fill the fields
   GetInput()              // enter Input loop
   CalcBox(Off)            // close the calc window
   ShadowBox(Off)          // erase the shadow
   Set(Cursor,On)          // done - turn cursor back on
End Main             // Acalc.s

/**************************** EOF 'FPcalc.s' *********************************/

// <Ctrl centercursor>     ExecMacro('fpcalc')   // my calc button
