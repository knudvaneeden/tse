// Monday, 9 August 1993
/************************************************************************/
/*                   Calculator helper functions                        */
/************************************************************************/
Proc InitRegs()

   x = ZeroExtended        //<-----+
   y = ZeroExtended        //      |
   z = ZeroExtended        //      |
   t = ZeroExtended        //      |-- Init vars
   Xa = ZeroExtended       //      |
   LastX = ZeroExtended    //      |
   Temp = ZeroExtended     //<-----+
   If NOT InitFlag   // when called to clear stack, don't change 'fixed' value.
      If GetGlobalInt('hpcalc') Fixed = GetGlobalInt('hpcalc') EndIf
   EndIf
   InitFlag = true      // we're loaded...
End InitRegs
//-------------------------------------------------------------------------
Proc ClrXYZT(Integer y)       // Used to clear info from register fields
   Vgotoxy(XX-MaxField,y)     // on screen when being updated with new
   PutLine('',MaxField)       // data.
End ClrXYZT
//-------------------------------------------------------------------------
String Proc FixIt(Integer switch)   // get pretty format for output
   String tmp[MaxField+3]

   Case Switch
      When 1 tmp = FStr(X,MaxField,Fixed)
      When 2 tmp = FStr(Y,MaxField,Fixed)
      When 3 tmp = FStr(Z,MaxField,Fixed)
      When 4 tmp = FStr(T,MaxField,Fixed)
   EndCase
   Return(tmp)
End FixIt
//-------------------------------------------------------------------------
Proc UpDateRegs()    // update display to new values of registers

   String Field[MaxField+3]

   ClrXYZT(Xy)                // update x
   Field = FixIt(1)
   Vgotoxy(XX-Length(Field),xy)
   PutLine(Field,Length(Field))
   ClrXYZT(Yy)                // update y
   Field = FixIt(2)
   Vgotoxy(XX-Length(Field),Yy)
   PutLine(Field,Length(Field))
   ClrXYZT(Zy)                // update z
   Field = FixIt(3)
   Vgotoxy(XX-Length(Field),Zy)
   PutLine(Field,Length(Field))
   ClrXYZT(Ty)                // update t
   Field = FixIt(4)
   Vgotoxy(XX-Length(Field),Ty)
   PutLine(Field,Length(Field))
End UpdateRegs
//-------------------------------------------------------------------------
Proc Fix()     // fix number of _DISPLAYED_ decimal places
   Integer key

   If Not EnterFlag X = Xa EndIf // number not <Enter>ed
   OpFlag = True
   New = True
   Vgotoxy(XX-MaxField,xy)
   PutLine('Fix [0..9]',MaxField)
   key = GetKey() & 0FFh
   Case key
      When 30h..39h     // number 0..9
         Vgotoxy(XX-1,xy)
         Fixed = Val(Chr(Key))
         PutLine(Format(Fixed,1),1)
         Delay(4)
         UpdateRegs()
      When 01Bh         // When Esc do nothing
         UpdateRegs()
      Otherwise
         Fix()          // recurse until 0..9 or Esc
   EndCase
End Fix
//-------------------------------------------------------------------------
Proc Math(Integer Op)

   If Not EnterFlag X = Xa EndIf // number not <Enter>ed
   LastX = X   // always update Last X

   Case Op
      When 1
         If FSub(ZeroExtended,x) == Y
            X = ZeroExtended
         Else
            X = FAdd(y,x) // call the add function
         EndIf
      When 2
         If Y == X
            X = ZeroExtended
         Else
            X = FSub(y,x) // call the Subtract function
         EndIf
      When 3
         If Y == ZeroExtended or X == ZeroExtended
            X = ZeroExtended
         Else
            X = FMul(y,x) // call the Multiply function
         EndIf
      When 4
         If Y == ZeroExtended
            X = ZeroExtended
         Else
            X = FDiv(y,x) // call the Divide function
         EndIf
   EndCase
   If Not FMathError             // no errors
      Xa = X                     // force accumulator and X to match
      Y = Z                      // swap
      Z = T                      //   the
      UpdateRegs()               // redisplay registers
      EnterFlag = True           // Enter/Op
      New = True                 // any further entry is new
      OpFlag = True
   Else                          // announce error
      Vgotoxy(XX-MaxField,xy)    // locate for output
      PutLine('ERROR',MaxField)  // Error Trap
      Delay(18)                  // pause for a bit
      X = LastX                  // assume 'X' destroyed
      UpdateRegs()               // recover from LastX reg
      EnterFlag = True           // recover to a stable status
      New = True                 // ready for new input
   EndIf
End Math
//-------------------------------------------------------------------------
Proc ShiftStat()
   Xa = X            // force accumulator to match X
   New = True        // ready for new input
   OpFlag = True     // last function was an operation
End ShiftStat
//-------------------------------------------------------------------------
Proc  ShiftUp()      // swap regs up
   Temp  =  T
   T     =  Z
   Z     =  Y
   Y     =  X
   X     =  Temp
   UpdateRegs()
   ShiftStat()
End ShiftUp
//-------------------------------------------------------------------------
Proc  ShiftDn()      // swap regs down
   Temp  =  X
   X     =  Y
   Y     =  Z
   Z     =  T
   T     =  Temp
   UpdateRegs()
   ShiftStat()
End ShiftDn
//-------------------------------------------------------------------------
Proc  SwapXY()       // swap x and y registers
   Temp  =  X
   X     =  Y
   Y     =  Temp
   UpdateRegs()
   ShiftStat()
End SwapXY
//-------------------------------------------------------------------------
Proc LstX()          // recall last X entry
   EnterFlag = True
   New = True
   ShiftUp()
   X  =  LastX
   UpdateRegs()
End LstX
//-------------------------------------------------------------------------
Proc Clx()           // clear X value, ready for new entry
   X = ZeroExtended
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
Proc BinHex(Integer MyBase)   // display X value as Hex or Binary

   String
      Tmp[MaxField+3] = FStr(X,MaxField,0),
      Base[1]
   Integer
      Convert = Val(SubStr(Tmp,1,Pos('.',Tmp)))

   HelpFlag = True
   OpFlag = True
   New = true
   If MyBase == 16 Base = 'h' EndIf
   If MyBase == 2  Base = 'b' EndIf
   VGotoXY(XX-MaxField,Xy)
   PutLine(format(Convert:MaxField-1:'0':MyBase,Base:1),MaxField)
   Repeat until keypressed()           // keep waiting for a keypress
   UpdateRegs()                  // update regs - completes partial ops
End BinHex

/**************************** Help Screen *******************************/

Proc CalcHelp()      // minimum help.

   Integer
      OldAttr = Set(Attr,Query(MenuTextAttr))

   HelpFlag = True   // let GetInput know to trap keys entered here.
   PopWinOpen(1,1,42,20,1,'Calculator Help',Query(MenuBorderAttr))
   VgotoXY(1,1)
   ClrScr()
   /* Put help text in help box */
   VgotoXY(1,2)                              // get video cursor in box
   PutLine('    Active functions are highlighted    ',40)
   VgotoXY(1,4)
   PutLine('Last X  XY   RollUp   RollDn  Fix',40)
   VgotoXY(1,6)
   PutLine('Hex or Binary display of X Register',40)
   VgotoXY(1,8)
   PutLine('Backspace: Clear X register, Rt to Lt.',40)
   VgotoXY(1,10)
   PutLine('Delete: Clear X, Clear Stack, % Percent',40)
   VgotoXY(1,12)
   PutLine('+ Add  - Subtract  * Multiply  / Divide',40)
   VgotoXY(1,14)
   PutLine('Enter: Adjust stack and place X in Y',40)
   VgotoXY(1,16)
   PutLine('Paste X into Current edit buffer',40)
   VgotoXY(1,18)
   PutLine('Get number under cursor into X register',40)
   /* Highlight the hotkeys */
   VGotoXY(1,4)
   PutAttr(Query(MenuTextLtrAttr),1)   //LastX
   VGotoXY(10,4)
   PutAttr(Query(MenuTextLtrAttr),2)   // x<>y
   VGotoXY(15,4)
   PutAttr(Query(MenuTextLtrAttr),1)   // rollup
   VGotoXY(25,4)
   PutAttr(Query(MenuTextLtrAttr),1)   // rolldn
   VGotoXY(35,4)
   PutAttr(Query(MenuTextLtrAttr),1)   // fix decimals
   VGotoXY(3,6)
   PutAttr(Query(MenuTextLtrAttr),1)   // hex
   VGotoXY(8,6)
   PutAttr(Query(MenuTextLtrAttr),1)   // binary
   VGotoXY(1,8)
   PutAttr(Query(MenuTextLtrAttr),9)   // backspace
   VGotoXY(1,10)
   PutAttr(Query(MenuTextLtrAttr),6)   // delete
   VGotoXY(24,10)
   PutAttr(Query(MenuTextLtrAttr),1)   // Clear stack
   VGotoXY(31,10)
   PutAttr(Query(MenuTextLtrAttr),1)   // %
   VGotoXY(1,12)
   PutAttr(Query(MenuTextLtrAttr),1)   // +
   VGotoXY(8,12)
   PutAttr(Query(MenuTextLtrAttr),1)   // -
   VGotoXY(20,12)
   PutAttr(Query(MenuTextLtrAttr),1)   // *
   VGotoXY(32,12)
   PutAttr(Query(MenuTextLtrAttr),1)   // '/'
   VGotoXY(1,14)
   PutAttr(Query(MenuTextLtrAttr),5)   // Enter
   VGotoXY(1,16)
   PutAttr(Query(MenuTextLtrAttr),1)   // Enter
   VGotoXY(1,18)
   PutAttr(Query(MenuTextLtrAttr),1)   // Enter
   Repeat until keypressed()           // keep waiting for a keypress
   Set(Attr,OldAttr)                   // restore previous attr
   PopWinClose()                 // close up the box
   UpdateRegs()                  // update regs - completes partial ops
End CalcHelp

/*************************** EOF 'calc.inc' *****************************/